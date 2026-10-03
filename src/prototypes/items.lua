local item_weight = 1 * (kg or 1000) -- 1 kg per bottle, exactly 1000 fit per rocket load

-- Detect Factorio version dynamically from loaded mods (mods["base"] is e.g. "2.0.77" or "2.1.20")
local is_factorio_2_1 = false
if mods and mods["base"] then
  local major, minor = mods["base"]:match("^(%d+)%.(%d+)")
  if (tonumber(major) or 0) > 2 or ((tonumber(major) or 0) == 2 and (tonumber(minor) or 0) >= 1) then
    is_factorio_2_1 = true
  end
end

-- Factorio 2.1+ requires array fuel_categories; Factorio 2.0 requires string fuel_category
local nutrient_fuel_categories = is_factorio_2_1 and {"nutrients"} or nil
local nutrient_fuel_category = (not is_factorio_2_1) and "nutrients" or nil

data:extend({
  {
    type = "item",
    name = "clean-bottle",
    icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/clean-bottle.png",
    icon_size = 64,
    subgroup = "agriculture-products",
    order = "a[nutrients]-a[clean-bottle]",
    stack_size = 50,
    weight = item_weight
  },
  {
    type = "item",
    name = "dirty-bottle",
    icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/dirty-bottle.png",
    icon_size = 64,
    subgroup = "agriculture-products",
    order = "a[nutrients]-b[dirty-bottle]",
    stack_size = 50,
    weight = item_weight
  },
  {
    type = "item",
    name = "spoiled-nutrient-bottle",
    icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/spoiled-nutrient-bottle.png",
    icon_size = 64,
    subgroup = "agriculture-products",
    order = "a[nutrients]-c[spoiled-bottle]",
    stack_size = 50,
    weight = item_weight
  },
  {
    type = "item",
    name = "bottled-nutrients",
    icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/bottled-nutrients.png",
    icon_size = 64,
    subgroup = "agriculture-products",
    order = "a[nutrients]-d[bottled-nutrients]",
    stack_size = 50,
    weight = item_weight,
    fuel_value = "20MJ", -- 10 nutrients equivalent (50% compaction loss)
    fuel_categories = nutrient_fuel_categories,
    fuel_category = nutrient_fuel_category,
    burnt_result = "dirty-bottle",
    spoil_ticks = 30 * 60 * 60, -- 30 minutes
    spoil_result = "spoiled-nutrient-bottle"
  },
  {
    type = "item",
    name = "hermetic-bottled-nutrients",
    icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/hermetic-bottled-nutrients.png",
    icon_size = 64,
    subgroup = "agriculture-products",
    order = "a[nutrients]-e[hermetic-bottled-nutrients]",
    stack_size = 50,
    weight = item_weight,
    fuel_value = "20MJ", -- 10 nutrients equivalent (50% compaction loss)
    fuel_categories = nutrient_fuel_categories,
    fuel_category = nutrient_fuel_category,
    burnt_result = "dirty-bottle",
    spoil_ticks = 60 * 60 * 60, -- 1 hour
    spoil_result = "spoiled-nutrient-bottle"
  },
  {
    type = "item",
    name = "cryo-bottled-nutrients",
    icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/cryo-bottled-nutrients.png",
    icon_size = 64,
    subgroup = "agriculture-products",
    order = "a[nutrients]-f[cryo-bottled-nutrients]",
    stack_size = 50,
    weight = item_weight,
    fuel_value = "30MJ", -- 15 nutrients equivalent (75% retention upgrade)
    fuel_categories = nutrient_fuel_categories,
    fuel_category = nutrient_fuel_category,
    burnt_result = "dirty-bottle",
    spoil_ticks = 120 * 60 * 60, -- 2 hours
    spoil_result = "spoiled-nutrient-bottle"
  }
})
