---
name: factorio-mod-builder
description: >-
  Builds, packages, versions, and deploys Factorio mods from the src/ directory
  into target/ and the local Factorio mods directory (%APPDATA%/Factorio/mods).
  Use this skill when releasing a new mod version, packaging the mod for testing,
  or updating mod metadata and dependencies.
---

# Factorio Mod Builder & Deployment Guide

This skill governs the packaging, versioning, and local deployment pipeline for the **Nutrients Storage** Factorio 2.0 / Space Age mod.

## Project Structure Overview

The source code and prototype assets are maintained under `src/`:

```text
nutrients-storage/
├── src/                                # Active mod source root
│   ├── info.json                       # Mod manifest & dependencies
│   ├── thumbnail.png                   # 144x144 mod browser thumbnail
│   ├── data.lua                        # Prototype entry point
│   ├── prototypes/                     # Items, recipes, technologies
│   ├── graphics/icons/                 # 64x64 item & 256x256 tech icons
│   └── locale/en/en.cfg                # English localization
├── scripts/
│   └── build.py                        # Automated packaging & deployment tool
└── target/                             # Output directory for packaged .zip files
```

---

## Mod Packaging Workflow

### 1. Build and Auto-Deploy to Factorio

To build the mod and immediately install it to the local Factorio mods folder (`%APPDATA%/Factorio/mods/`), run:

```powershell
python scripts/build.py -y
```

This performs the following actions:
1. Validates `src/info.json` for proper JSON format and mandatory `"name"` and `"version"` fields.
2. Creates `./target/` if it does not exist.
3. Compresses all files in `src/` into `./target/{name}_{version}.zip`.
4. Enforces Factorio's mandatory archive layout: all files inside the zip are placed under a root directory matching the archive name (e.g., `tugboatcapitans-nutrients-storage_0.1.0/`).
5. Overwrites any existing version and removes older version `.zip` files from `%APPDATA%/Factorio/mods/` to avoid Factorio loading conflicts.

### 2. Build Only (No Deployment)

When generating a release zip for distribution or testing without updating the local Factorio installation:

```powershell
python scripts/build.py -n
```

### 3. Multi-Version Packaging (Factorio 2.0 & 2.1)

Build specifically for Factorio 2.0, Factorio 2.1, or produce releases for both simultaneously:

```powershell
# Build for Factorio 2.0 (v0.1.0)
python scripts/build.py -t 2.0 -n

# Build for Factorio 2.1 (v0.1.1)
python scripts/build.py -t 2.1 -n

# Build BOTH releases for Mod Portal upload
python scripts/build.py -t all -n
```

### 4. Interactive Mode

Running without flags will auto-detect the local Factorio version, build into `./target/`, and prompt whether to deploy:

```powershell
python scripts/build.py
```

---

## Mod Versioning & Manifest Management

When releasing updates or modifying dependencies, update `src/info.json`:

1. **Version Bumping (`version`)**: Follow semantic versioning (`MAJOR.MINOR.PATCH`).
   - `0.1.0` $\rightarrow$ Initial functional release.
   - `0.1.1` $\rightarrow$ Bug fixes, balance adjustments, or icon tweaks.
   - `0.2.0` $\rightarrow$ New features (new tech tiers, new bottle types, custom entities).
   - `1.0.0` $\rightarrow$ Full public release.
2. **Dependencies (`dependencies`) & `factorio_version`**:
   - For Factorio 2.1 builds, set `"factorio_version": "2.1"` and ensure `"base >= 2.1"` and `"space-age >= 2.1"` are present.
   - For Factorio 2.0 builds, set `"factorio_version": "2.0"` and `"base >= 2.0"`.
   - Prefix optional dependencies with `?` (e.g. `"? quality >= 2.1"`).

---

## Validation Checklist Before Building

Before creating a new zip release, verify:
- [ ] `src/info.json` has the intended version number and valid JSON syntax.
- [ ] `src/thumbnail.png` exists, is 144x144 pixels, and is under 500 KB.
- [ ] All Lua prototype files in `src/prototypes/` have balanced brackets and valid syntax.
- [ ] Every item, recipe, and technology prototype added or edited has corresponding entries in `src/locale/en/en.cfg`.
- [ ] `target/` is listed in `.gitignore` so build artifacts are not checked into Git.

