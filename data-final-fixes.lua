local pumpjack = data.raw["mining-drill"]["pumpjack"]

local resource_categories = {}

for i, resource_category in ipairs(pumpjack.resource_categories) do
  resource_categories[resource_category] = true
end

local resource_entities = Oil_Patches_Organizer.resource_entities

for resource_name, resource in pairs(data.raw["resource"]) do
  if resource_categories[resource.category] then
    resource_entities[#resource_entities + 1] = resource_name
  end
end
