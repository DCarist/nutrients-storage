# Factorio 2.0 / Space Age Prototype & Engine Mechanics

This document provides technical reference for the prototype fields and engine behaviors in Factorio 2.0 (Space Age).

---

## 1. Spoilage & Freshness Mechanics

### ItemPrototype Spoilage Fields
- **`spoil_ticks`** (`uint`): The lifespan of the item in ticks ($60\text{ ticks} = 1\text{ second}$).
  - Raw Nutrients: 18,000 ticks (5 minutes / 300s).
  - Tier 1 Bottled Nutrients: 108,000 ticks (30 minutes / 1,800s).
  - Tier 2 Hermetic Bottled Nutrients: 216,000 ticks (1 hour / 3,600s).
  - Tier 3 Cryogenic Bottled Nutrients: 432,000 ticks (2 hours / 7,200s).
  - If omitted or `nil`, the item never spoils.
- **`spoil_result`** (`ItemID`): The single item that appears when the item spoils.
  > [!IMPORTANT]
  > Factorio engine only supports a **single item ID** for `spoil_result`. To return multiple items (e.g. 1 Dirty Bottle + 10 Spoilage), the item must spoil into an intermediate item (such as `spoiled-nutrient-bottle`), which the player dumps/empties via a recipe.

### Recipe Freshness Reset
- In Factorio 2.0, if a recipe consumes spoilable ingredients (like nutrients), the output product **inherits the average freshness** of the ingredients by default. Setting `percent_spoiled = 0` on the product is overridden by ingredient inheritance!
- To guarantee an output item is **100% fresh** regardless of ingredient age, you must set:
  ```lua
  reset_freshness_on_craft = true,
  ```
  directly on the `RecipePrototype`.

---

## 2. Burner Fuel Slots & Burnt Results

### Fuel Properties on ItemPrototype
- **`fuel_value`** (`string`): Energy provided when burned (e.g. `"20MJ"`, `"30MJ"`, `"40MJ"`).
- **`fuel_category`** and **`fuel_categories`**:
  ```lua
  fuel_category = "nutrients",
  fuel_categories = {"nutrients"},
  ```
  Biochambers consume fuel in the `"nutrients"` category at a rate of 500 kW (0.5 MW).
  - 20 MJ powers a Biochamber for: $\frac{20\,\text{MJ}}{0.5\,\text{MW}} = 40\,\text{seconds}$.
  - 30 MJ powers a Biochamber for: $\frac{30\,\text{MJ}}{0.5\,\text{MW}} = 60\,\text{seconds}$.
- **`burnt_result`** (`ItemID`): Produced in the burner entity's spent fuel inventory when the fuel item finishes burning.
  ```lua
  burnt_result = "dirty-bottle",
  ```
  This creates a completely automatic closed recycling loop without requiring runtime scripts.

---

## 3. Catalyst Protection & Productivity Defense

Production machines like the **Electromagnetic Plant** (`electromagnetic-plant`) possess built-in base productivity (+50% bonus).

When a recipe consumes a fluid or item as a catalyst (e.g., 5 `electrolyte` in, 5 `electrolyte` out), built-in machine productivity could duplicate the catalyst into free resources unless properly configured.

### Defense Strategy
1. On the recipe, disable productivity modules:
   ```lua
   allow_productivity = false,
   ```
2. On both input and output, specify `catalyst_amount`:
   ```lua
   ingredients = {
     {type = "fluid", name = "electrolyte", amount = 5, catalyst_amount = 5}
   },
   results = {
     {type = "item", name = "hermetic-bottled-nutrients", amount = 1, percent_spoiled = 0},
     {type = "fluid", name = "electrolyte", amount = 5, catalyst_amount = 5, ignored_by_productivity = 5}
   }
   ```
   `ignored_by_productivity = 5` guarantees that machine base productivity will never produce bonus electrolyte.

---

## 4. Machine Fluid Box Limitations

When designing recipes with multiple fluid inputs, check the machine's fluid boxes:

| Machine Entity | Fluid Inputs | Fluid Outputs | Crafting Categories |
| :--- | :---: | :---: | :--- |
| **Assembling Machine 2 / 3** | 1 | 0 | `crafting`, `advanced-crafting` |
| **Chemical Plant** | 2 | 2 | `chemistry` |
| **Cryogenic Plant** | **3** | **3** | `cryogenics`, `chemistry-or-cryogenics`, `cryogenics-or-assembling` |
| **Electromagnetic Plant** | 1 | 1 | `electromagnetics` |
| **Biochamber** | 2 | 2 | `organic` |

### Key Takeaway:
- Any recipe requiring **3 fluid inputs** (such as Water + Lubricant + Cold Fluoroketone) **cannot run in a Chemical Plant**. It natively requires a **Cryogenic Plant** (which has 3 inputs at `{-2, 2}`, `{0, 2}`, `{2, 2}`).

---

## 5. Rocket Payload & Logistics Balancing

In Factorio Space Age:
- Rocket Silo payload limit: **1,000 kg** (1 ton) per launch.
- Rocket Cargo Pod inventory slots: **20 slots**.
- To ensure exactly **1,000 items fit in one rocket**:
  ```lua
  stack_size = 50,
  weight = 1 * (kg or 1000), -- 1 kg per item
  ```
  - Slot limit: $20\text{ stacks} \times 50 = 1,000\text{ items}$.
  - Weight limit: $1,000\text{ items} \times 1\text{ kg} = 1,000\text{ kg}$.
  Both limits synchronize perfectly.

