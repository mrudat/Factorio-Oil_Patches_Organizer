Oil_Patches_Organizer = {
  resource_entities = {}
}

local resource_entities = Oil_Patches_Organizer.resource_entities

data:extend({
  {
    type = "selection-tool",
    name = "oil-patches-organizer",
    icon = "__Oil_Patches_Organizer-0_18__/organizer.png",
    icon_size = 64, icon_mipmaps = 6,
    flags = {
      "only-in-cursor"
    },
    subgroup = "tool",
    order = "c[automated-construction]-a[oilorganizer]",
    stack_size = 1,
    stackable = false,
    selection_color = { r = 0, g = 1, b = 0 },
    alt_selection_color = { r = 0, g = 1, b = 0 },
    selection_mode = {"any-entity"},
    alt_selection_mode = {"any-entity"},
    selection_cursor_box_type = "copy",
    alt_selection_cursor_box_type = "copy",
    entity_filter_mode = "whitelist",
    alt_entity_filter_mode = "whitelist",
    entity_filters = resource_entities,
    alt_entity_filters = resource_entities,
  },
  {
    type = "shortcut",
    name = "oil-patches-organizer",
    icon = {
      filename = "__Oil_Patches_Organizer-0_18__/organizer.png",
      size = 64,
      flags = {
        "mipmap"
      },
      mipmaps = 4,
    },
    order = "o[oil-organizer]",
    action = "create-blueprint-item",
    localised_name = {"item-name.oil-patches-organizer"},
    technology_to_unlock = "oil-processing",
    item_to_create = "oil-patches-organizer",
    style = "blue",
  }
})
