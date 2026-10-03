---
name: factorio-asset-pipeline
description: >-
  Manages the creation, formatting, resizing, and localization of Factorio mod
  assets including 64x64 item sprites, 256x256 technology icons, and 144x144 mod
  thumbnails. Use this skill when generating new graphics, editing icons, or
  ensuring visual legibility at low resolutions.
---

# Factorio Asset & Graphics Pipeline

This skill defines the technical standards, resolution constraints, and generation workflows for icons and visual assets in the **Nutrients Storage** mod.

---

## Asset Standard Specifications

| Asset Type | Target Resolution | Destination Path | Notes |
| :--- | :---: | :--- | :--- |
| **Item Icon** | **64×64** PNG | `src/graphics/icons/<item-name>.png` | Standard Factorio inventory & belt sprite |
| **Tech Card Icon** | **256×256** PNG | `src/graphics/icons/<tech-name>.png` | In-game technology tree research node |
| **Mod Thumbnail** | **144×144** PNG | `src/thumbnail.png` & `./thumbnail.png` | Official Factorio mod manager & portal size |
| **High-Res Source** | Native (e.g. 1024×1024) | `icons - original/<name>.png` | Preserved master copy for future edits |

---

## Design Principles for Factorio Icons

1. **Aesthetic Consistency**:
   - Factorio uses a gritty, industrial dieselpunk/space-age art style with heavy metallic plating, visible rivets, conduits, weathered rust, and dark vignette borders.
   - Gleba assets feature organic green bio-sludge and tendrils.
   - Fulgora assets feature energized purple arcs and electromagnetic coils.
   - Aquilo assets feature heavy cyan ice frost, condensation plumes, and cold steel.
2. **Low-Resolution Legibility (Crucial for 144×144 & 64×64)**:
   - **Never place tiny text inside small items**: It will turn into blurry noise when downscaled.
   - If text is required (such as on mod thumbnails), use **large, bold, high-contrast lettering** placed prominently across the top and bottom borders.
   - Use strong silhouette contrast between the foreground item (e.g. glowing green canister) and the background machinery.

---

## Resizing & Processing Workflow

When new or edited images are generated, use the following PowerShell script to resize them with bicubic interpolation and save to the correct locations:

```powershell
Add-Type -AssemblyName System.Drawing

function Resize-FactorioIcon {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [int]$Width,
        [int]$Height
    )
    $orig = [System.Drawing.Image]::FromFile($SourcePath)
    $bmp = New-Object System.Drawing.Bitmap($Width, $Height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($orig, 0, 0, $Width, $Height)
    $bmp.Save($DestPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    $orig.Dispose()
}

# Example: Process a 64x64 item icon
Resize-FactorioIcon -SourcePath "C:/path/to/raw.png" -DestPath "src/graphics/icons/new-item.png" -Width 64 -Height 64

# Example: Process a 256x256 tech icon
Resize-FactorioIcon -SourcePath "C:/path/to/raw.png" -DestPath "src/graphics/icons/new-tech.png" -Width 256 -Height 256

# Example: Process a 144x144 thumbnail
Resize-FactorioIcon -SourcePath "C:/path/to/raw.png" -DestPath "src/thumbnail.png" -Width 144 -Height 144
```

---

## Localization Synchronization

Whenever a new item, recipe, or technology icon is added:
1. Update `src/locale/en/en.cfg`.
2. Ensure all four sections are populated:
   - `[item-name]` and `[item-description]`
   - `[recipe-name]` and `[recipe-description]`
   - `[technology-name]` and `[technology-description]`
3. Keep descriptions clear and descriptive, explaining game mechanics (e.g., fuel MJ, biochamber burn time, shelf life, recovery percentage).

