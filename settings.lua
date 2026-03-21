data:extend({
  {
    type = "bool-setting",
    name = "wdm-expansion-event-enable",
    setting_type = "runtime-global",
    default_value = true,
    order = "a"
  },
  {
    type = "bool-setting",
    name = "wdm-expansion-debug",
    setting_type = "runtime-global",
    default_value = false,
    order = "b"
  },
  {
    type = "bool-setting",
    name = "wdm-expansion-disable-friendly-fire",
    setting_type = "runtime-global",
    default_value = false,
    order = "c"
  },
  {
    type = "bool-setting",
    name = "wdm-expansion-show-turret-buff-text",
    setting_type = "runtime-global",
    default_value = true,
    order = "d"
  }
})

if mods["ZombieHordeFaction"] then
  data:extend({
    {
      type = "bool-setting",
      name = "wdm-expansion-zombie",
      setting_type = "startup",
      default_value = true,
      order = "e"
    }
  })
end
