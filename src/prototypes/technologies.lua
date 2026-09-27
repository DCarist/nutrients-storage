data:extend({
  -- 1. Tier 1: Nutrient Bottling (Gleba)
  {
    type = "technology",
    name = "nutrient-bottling",
    icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/tech-nutrient-bottling.png",
    icon_size = 256,
    prerequisites = {"carbon-fiber", "agriculture"},
    effects = {
      {type = "unlock-recipe", recipe = "clean-bottle"},
      {type = "unlock-recipe", recipe = "bottled-nutrients"},
      {type = "unlock-recipe", recipe = "bottle-washing"},
      {type = "unlock-recipe", recipe = "enzymatic-bottle-washing"},
      {type = "unlock-recipe", recipe = "empty-spoiled-nutrient-bottle"}
    },
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
        {"agricultural-science-pack", 1}
      },
      time = 30
    }
  },

  -- 2. Tier 2: Hermetic Nutrient Bottling (Fulgora)
  {
    type = "technology",
    name = "hermetic-nutrient-bottling",
    icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/tech-hermetic-bottling.png",
    icon_size = 256,
    prerequisites = {"nutrient-bottling", "electromagnetic-science-pack"},
    effects = {
      {type = "unlock-recipe", recipe = "hermetic-bottled-nutrients"}
    },
    unit = {
      count = 1000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"electromagnetic-science-pack", 1}
      },
      time = 30
    }
  },

  -- 3. Tier 3: Cryogenic Nutrient Bottling (Aquilo)
  {
    type = "technology",
    name = "cryogenic-nutrient-bottling",
    icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/tech-cryogenic-bottling.png",
    icon_size = 256,
    prerequisites = {"hermetic-nutrient-bottling", "cryogenic-science-pack"},
    effects = {
      {type = "unlock-recipe", recipe = "cryo-bottled-nutrients"}
    },
    unit = {
      count = 1500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"cryogenic-science-pack", 1}
      },
      time = 45
    }
  },

  -- 4. Tier 4: Cryogenic Bottle Washing (Endgame - Promethium)
  {
    type = "technology",
    name = "cryogenic-bottle-washing",
    icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/tech-cryogenic-washing.png",
    icon_size = 256,
    prerequisites = {"cryogenic-nutrient-bottling", "promethium-science-pack"},
    effects = {
      {type = "unlock-recipe", recipe = "cryogenic-bottle-sterilization"}
    },
    unit = {
      count = 2000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"cryogenic-science-pack", 1},
        {"promethium-science-pack", 1}
      },
      time = 60
    }
  }
})
