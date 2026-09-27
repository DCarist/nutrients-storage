data:extend({
  -- 1. Clean Bottle Crafting
  {
    type = "recipe",
    name = "clean-bottle",
    category = "crafting",
    energy_required = 3.0,
    enabled = false,
    allow_productivity = false,
    ingredients = {
      {type = "item", name = "steel-plate", amount = 4},
      {type = "item", name = "plastic-bar", amount = 4},
      {type = "item", name = "carbon-fiber", amount = 1}
    },
    results = {
      {type = "item", name = "clean-bottle", amount = 4}
    }
  },

  -- 2. Tier 1: Bottled Nutrients (30m Spoilage)
  {
    type = "recipe",
    name = "bottled-nutrients",
    category = "crafting",
    energy_required = 2.0,
    enabled = false,
    allow_productivity = false,
    reset_freshness_on_craft = true,
    ingredients = {
      {type = "item", name = "clean-bottle", amount = 1},
      {type = "item", name = "nutrients", amount = 20}
    },
    results = {
      {type = "item", name = "bottled-nutrients", amount = 1, percent_spoiled = 0}
    }
  },

  -- 3. Tier 2: Hermetic Bottled Nutrients (1h Spoilage - Fulgora)
  {
    type = "recipe",
    name = "hermetic-bottled-nutrients",
    category = "electromagnetics",
    energy_required = 2.0,
    enabled = false,
    allow_productivity = false,
    reset_freshness_on_craft = true,
    ingredients = {
      {type = "item", name = "clean-bottle", amount = 1},
      {type = "item", name = "nutrients", amount = 20},
      {type = "fluid", name = "electrolyte", amount = 5, catalyst_amount = 5}
    },
    results = {
      {type = "item", name = "hermetic-bottled-nutrients", amount = 1, percent_spoiled = 0},
      {type = "fluid", name = "electrolyte", amount = 5, catalyst_amount = 5, ignored_by_productivity = 5}
    },
    main_product = "hermetic-bottled-nutrients"
  },

  -- 4. Tier 3: Cryo Bottled Nutrients (2h Spoilage - Aquilo)
  {
    type = "recipe",
    name = "cryo-bottled-nutrients",
    category = "cryogenics",
    energy_required = 2.0,
    enabled = false,
    allow_productivity = false,
    reset_freshness_on_craft = true,
    ingredients = {
      {type = "item", name = "clean-bottle", amount = 1},
      {type = "item", name = "nutrients", amount = 20},
      {type = "fluid", name = "fluoroketone-cold", amount = 5, catalyst_amount = 5}
    },
    results = {
      {type = "item", name = "cryo-bottled-nutrients", amount = 1, percent_spoiled = 0},
      {type = "fluid", name = "fluoroketone-hot", amount = 5, catalyst_amount = 5, ignored_by_productivity = 5}
    },
    main_product = "cryo-bottled-nutrients"
  },

  -- 5. Basic Bottle Washing (50% recovery)
  {
    type = "recipe",
    name = "bottle-washing",
    category = "chemistry",
    energy_required = 3.0,
    enabled = false,
    allow_productivity = false,
    ingredients = {
      {type = "item", name = "dirty-bottle", amount = 1},
      {type = "fluid", name = "water", amount = 10},
      {type = "fluid", name = "lubricant", amount = 5}
    },
    results = {
      {type = "item", name = "clean-bottle", amount = 1, probability = 0.50}
    },
    main_product = "clean-bottle"
  },

  -- 6. Enzymatic Bottle Washing (75% recovery with Jelly)
  {
    type = "recipe",
    name = "enzymatic-bottle-washing",
    category = "chemistry",
    energy_required = 4.0,
    enabled = false,
    allow_productivity = false,
    ingredients = {
      {type = "item", name = "dirty-bottle", amount = 1},
      {type = "item", name = "jelly", amount = 1},
      {type = "fluid", name = "water", amount = 10},
      {type = "fluid", name = "lubricant", amount = 5}
    },
    results = {
      {type = "item", name = "clean-bottle", amount = 1, probability = 0.75}
    },
    main_product = "clean-bottle"
  },

  -- 7. Cryogenic Bottle Sterilization (100% recovery with cold fluoroketone)
  {
    type = "recipe",
    name = "cryogenic-bottle-sterilization",
    category = "cryogenics",
    energy_required = 4.0,
    enabled = false,
    allow_productivity = false,
    ingredients = {
      {type = "item", name = "dirty-bottle", amount = 1},
      {type = "fluid", name = "water", amount = 10},
      {type = "fluid", name = "lubricant", amount = 5},
      {type = "fluid", name = "fluoroketone-cold", amount = 10, catalyst_amount = 10}
    },
    results = {
      {type = "item", name = "clean-bottle", amount = 1, probability = 1.0},
      {type = "fluid", name = "fluoroketone-hot", amount = 10, catalyst_amount = 10, ignored_by_productivity = 10}
    },
    main_product = "clean-bottle"
  },

  -- 8. Empty Spoiled Nutrient Bottle
  {
    type = "recipe",
    name = "empty-spoiled-nutrient-bottle",
    category = "crafting",
    energy_required = 1.0,
    enabled = false,
    allow_productivity = false,
    icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/spoiled-nutrient-bottle.png",
    icon_size = 64,
    ingredients = {
      {type = "item", name = "spoiled-nutrient-bottle", amount = 1}
    },
    results = {
      {type = "item", name = "dirty-bottle", amount = 1},
      {type = "item", name = "spoilage", amount = 10}
    },
    main_product = "dirty-bottle"
  }
})
