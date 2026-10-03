---
name: factorio-spoilage-prototypes
description: >-
  Guides the design, implementation, and balancing of Factorio 2.0 / Space Age
  prototypes involving spoilable items, freshness mechanics, fuel consumption,
  fluid recipes, and catalyst loops. Use this skill when adding or tuning items,
  recipes, technologies, spoilage timers, or rocket cargo balance.
---

# Factorio Spoilage & Prototype Design Guide

This skill provides step-by-step procedures and rules for implementing and tuning prototypes in the **Nutrients Storage** mod.

For deep engine specifications, read [Engine Mechanics Reference](./references/engine_mechanics.md).

---

## 1. Adding a New Bottled Nutrient Tier

To introduce a new preservation tier (e.g., Vulcanus Lava-Insulated Canister or Platform Tier):

### Step 1: Define the Item Prototype in `src/prototypes/items.lua`
```lua
{
  type = "item",
  name = "custom-bottled-nutrients",
  icon = "__tugboatcapitans-nutrients-storage__/graphics/icons/custom-bottled-nutrients.png",
  icon_size = 64,
  subgroup = "agriculture-products",
  order = "a[nutrients]-g[custom-bottled-nutrients]",
  stack_size = 50,
  weight = 1 * (kg or 1000), -- Exactly 1,000 per rocket
  fuel_value = "30MJ",        -- Calculate based on compaction energy
  fuel_category = "nutrients",
  fuel_categories = {"nutrients"},
  burnt_result = "dirty-bottle",
  spoil_ticks = 180 * 60 * 60, -- Set spoil time (e.g., 3 hours)
  spoil_result = "spoiled-nutrient-bottle"
}
```

### Step 2: Define the Recipe in `src/prototypes/recipes.lua`
> [!IMPORTANT]
> Always include `reset_freshness_on_craft = true` so the output canister starts at 100% freshness regardless of input nutrient age.

```lua
{
  type = "recipe",
  name = "custom-bottled-nutrients",
  category = "crafting", -- or electromagnetics, cryogenics, metallurgy
  energy_required = 2.0,
  enabled = false,
  allow_productivity = false,
  reset_freshness_on_craft = true,
  ingredients = {
    {type = "item", name = "clean-bottle", amount = 1},
    {type = "item", name = "nutrients", amount = 20},
    -- add planet-specific catalyst or fluid if appropriate
  },
  results = {
    {type = "item", name = "custom-bottled-nutrients", amount = 1, percent_spoiled = 0}
  }
}
```

### Step 3: Unlock via Technology in `src/prototypes/technologies.lua`
Add an unlock effect to an existing technology or create a new technology prototype:
```lua
effects = {
  {type = "unlock-recipe", recipe = "custom-bottled-nutrients"}
}
```

### Step 4: Add English Localization in `src/locale/en/en.cfg`
Add matching entries in `[item-name]`, `[item-description]`, `[recipe-name]`, and `[recipe-description]`.

---

## 2. Tuning Compaction & Energy Balance

When balancing nutrient compaction recipes:

1. **Input Baseline**: 20 raw nutrients = $20 \times 2.0\,\text{MJ} = 40\,\text{MJ}$ theoretical maximum.
2. **Standard Compaction (Tier 1 & Tier 2)**:
   - 50% energy retention: `fuel_value = "20MJ"` (10 nutrients equivalent).
   - Biochamber burn time (500 kW): **40 seconds**.
3. **Advanced Compaction (Tier 3 Cryogenic)**:
   - 75% energy retention: `fuel_value = "30MJ"` (15 nutrients equivalent).
   - Biochamber burn time (500 kW): **60 seconds**.
4. **Throughput Calculation**:
   - At 20 nutrients per 2.0s crafting time, throughput is **10 nutrients/second** per machine (at 1.0 crafting speed).

---

## 3. Designing Bottle Washing Recipes

When adding or adjusting bottle washing recipes:

1. **Check Fluid Input Capacity**:
   - 1 or 2 fluid inputs (e.g. Water + Lubricant) $\rightarrow$ Can run in Chemical Plants (`category = "chemistry"`).
   - 3 fluid inputs (e.g. Water + Lubricant + Cold Fluoroketone) $\rightarrow$ **Must run in Cryogenic Plants** (`category = "cryogenics"`). Chemical Plants only have 2 input fluid boxes.
2. **Configure Catalysts**:
   - If a fluid passes through (such as cold fluoroketone heated to hot fluoroketone), set `catalyst_amount` on both input and output, and set `ignored_by_productivity` on the output to prevent machine productivity duplication.
3. **Recovery Rates**:
   - Basic (no bio-enzymes): 50% (`probability = 0.50`).
   - Enzymatic (with Jelly): 75% (`probability = 0.75`).
   - Cryogenic Sterilization: 100% (`probability = 1.0`).

