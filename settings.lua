data:extend({
  {
    type = "bool-setting",
    name = "oil-patches-organizer-autoorganize",
    setting_type = "runtime-global",
    default_value = false,
  },
  {
    type = "int-setting",
    name = "oil-patches-organizer-grid-cell-size",
    setting_type = "runtime-global",
    -- 6 by default: 3 for the patch (size of oil pump) and 3 for the gap between patches
    default_value = 6,
    minimum_value = 4,
    maximum_value = 20,
  }
})
