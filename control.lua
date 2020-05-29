-- "Globals"

local GridCellSize = settings.global["oil-patches-organizer-grid-cell-size"].value

-- Functions

function FindResourceEntities()
  global.resource_entities = {}
  local resource_entities = global.resource_entities
  local organizer = game.item_prototypes["oil-patches-organizer"]
  local entity_filters = organizer.entity_filters
  for entity_name, entity_prototype in pairs(entity_filters) do
    resource_entities[#resource_entities + 1] = entity_name
    if entity_prototype.type ~= "resource" then
      error(string.format('Unable to continue, filter includes "%s", which is not a resource.', entity_name))
    end
  end
  if #resource_entities == 0 then
    error('Unable to continue, could not find any resources to arrange.')
  end
end

function on_init()
  global.OilCenters = {}

  FindResourceEntities()
end

function on_configuration_changed(event)
  FindResourceEntities()
end

function on_runtime_mod_setting_changed(event)
  if event.setting_type ~= "runtime-global" then return end
  local setting = event.setting
  if setting == "oil-patches-organizer-autoorganize" then
    if settings.global["oil-patches-organizer-autoorganize"].value then
      script.on_event(defines.events.on_chunk_generated, on_chunk_generated)
    else
      script.on_event(defines.events.on_chunk_generated, nil)
    end
  elseif setting == "oil-patches-organizer-grid-cell-size" then
    GridCellSize = settings.global["oil-patches-organizer-grid-cell-size"].value
  end
end

function IsZeroSize(area)
  local left_top = area.left_top
  local right_bottom = area.right_bottom
  return (left_top.x == right_bottom.x and left_top.y == right_bottom.y)
end

function GetCenter(resource_deposits)
  local first_pos = resource_deposits[1].position
  local min_x = first_pos.x
  local min_y = first_pos.y
  local max_x = min_x
  local max_y = min_y

  for i, resource_deposit in pairs(resource_deposits) do
    local pos = resource_deposit.position
    local pos_x = pos.x
    local pos_y = pos.y

    if pos_x > max_x then
      max_x = pos_x
    elseif pos_x < min_x then
      min_x = pos_x
    end

    if pos_y > max_y then
      max_y = pos_y
    elseif pos_y < min_y then
      min_y = pos_y
    end
  end
  return {
    x = math.floor((max_x + min_x) / 2),
    y = math.floor((max_y + min_y) / 2)
  }
end

function GridDeposits(resource_deposits, surface, center)
  if not center then
    center = GetCenter(resource_deposits)
  end

  -- destroy the old resource_deposits, but save their type and amount for later in the original array.
  for i, resource_deposit in ipairs(resource_deposits) do
    resource_deposits[i] = {
      name = resource_deposit.name,
      amount = resource_deposit.amount,
    }
    resource_deposit.destroy()
  end

  local distance = GridCellSize
  local direction_x = distance
  local direction_y = 0
  local half_arc_counter = 1
  local side_of_half_arc = 1
  local steps_to_turn = 1
  local current_position_x = center.x - center.x % distance
  local current_position_y = center.y - center.y % distance
  local i = 1 -- patches counter

  repeat
    local resource_deposit = resource_deposits[i]
    resource_deposit.position = {
      x = current_position_x,
      y = current_position_y,
    }
    if surface.create_entity(resource_deposit) then
      i = i + 1
    end

    current_position_x = current_position_x + direction_x
    current_position_y = current_position_y + direction_y

    steps_to_turn = steps_to_turn - 1
    if steps_to_turn == 0 then
      -- turn right
      local temp = direction_y
      direction_y = direction_x
      direction_x = -temp
      side_of_half_arc = side_of_half_arc + 1
      -- lengthen arc side
      if side_of_half_arc > 2 then
        side_of_half_arc = 1
        half_arc_counter = half_arc_counter + 1
      end
      steps_to_turn = half_arc_counter
    end
  until i > #resource_deposits
end

function on_chunk_generated(event)
  local surface = event.surface
  if not surface.name == "nauvis" then return end
  local resource_deposits = surface.find_entities_filtered({
    area = event.area,
    name = global.resource_entities
  })
  if not next(resource_deposits) then return end
  GridDeposits(resource_deposits, surface)
end


function on_player_selected_area(event)
  if event.item ~= "oil-patches-organizer" then return end
  local area = event.area
  if IsZeroSize(area) then return end
  local resource_deposits = event.entities
  if not next(resource_deposits) then return end
  GridDeposits(resource_deposits, event.surface)
end

function on_player_alt_selected_area(event)
  if event.item ~= "oil-patches-organizer" then return end

  local area = event.area
  local player_index = event.player_index
  local surface = event.surface

  local OilCenters = global.OilCenters

  if IsZeroSize(area) then
    OilCenters[player_index] = {
      surface = surface,
      position = {
        x = area.left_top.x,
        y = area.left_top.y
      }
    }
    game.players[player_index].print({"oil-patches-organizer-message.center-is-set"})
    return
  end

  local resource_deposits = event.entities
  if not next(resource_deposits) then return end

  local oil_center = OilCenters[player_index]
  if oil_center then
    local oil_center_surface = oil_center.surface
    if oil_center_surface.valid then
      GridDeposits(resource_deposits, oil_center_surface, oil_center.position)
      return
    else
      -- someone deleted our target surface, forget it
      OilCenters[player_index] = nil
    end
  end

  GridDeposits(resource_deposits, surface)
end

-- register for events.

script.on_init(on_init)

script.on_load(on_load)

script.on_configuration_changed(on_configuration_changed)

script.on_event({defines.events.on_runtime_mod_setting_changed}, on_runtime_mod_setting_changed)

if settings.global["oil-patches-organizer-autoorganize"].value then
  script.on_event(defines.events.on_chunk_generated, on_chunk_generated)
end

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)

script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)
