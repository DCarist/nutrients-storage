import argparse
import json
import os
import shutil
import sys
import zipfile
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Build and package Factorio mod from src/ directory."
    )
    parser.add_argument(
        "-y",
        "--yes",
        action="store_true",
        help="Automatically copy to local Factorio mods folder without prompting",
    )
    parser.add_argument(
        "-n",
        "--no-copy",
        action="store_true",
        help="Skip copying to local Factorio mods folder",
    )
    args = parser.parse_args()

    # Determine paths
    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent
    src_dir = project_root / "src"
    target_dir = project_root / "target"
    info_json_path = src_dir / "info.json"

    # Validate src and info.json
    if not src_dir.is_dir():
        print(f"Error: Source directory '{src_dir}' not found.", file=sys.stderr)
        sys.exit(1)

    if not info_json_path.is_file():
        print(f"Error: 'info.json' not found in '{src_dir}'.", file=sys.stderr)
        sys.exit(1)

    try:
        with open(info_json_path, "r", encoding="utf-8") as f:
            info_data = json.load(f)
    except Exception as e:
        print(f"Error reading info.json: {e}", file=sys.stderr)
        sys.exit(1)

    mod_name = info_data.get("name")
    mod_version = info_data.get("version")

    if not mod_name or not mod_version:
        print(
            "Error: 'info.json' must contain both 'name' and 'version'.",
            file=sys.stderr,
        )
        sys.exit(1)

    # Output filename and internal directory structure
    archive_folder_name = f"{mod_name}_{mod_version}"
    zip_filename = f"{archive_folder_name}.zip"
    target_dir.mkdir(parents=True, exist_ok=True)
    target_zip_path = target_dir / zip_filename

    print(f"Packaging mod: {mod_name} v{mod_version}")
    print(f"Source: {src_dir}")
    print(f"Target: {target_zip_path}")

    # Build ZIP archive
    file_count = 0
    total_uncompressed_bytes = 0

    with zipfile.ZipFile(target_zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, _, files in os.walk(src_dir):
            for file in files:
                full_path = Path(root) / file
                rel_path = full_path.relative_to(src_dir)
                archive_internal_path = Path(archive_folder_name) / rel_path

                # Zip paths always use forward slashes
                arcname = str(archive_internal_path).replace("\\", "/")
                zipf.write(full_path, arcname=arcname)

                file_count += 1
                total_uncompressed_bytes += full_path.stat().st_size

    compressed_bytes = target_zip_path.stat().st_size
    print(f"\nSuccessfully built {zip_filename}:")
    print(f"  Files packaged: {file_count}")
    print(f"  Uncompressed:   {total_uncompressed_bytes / 1024:.1f} KB")
    print(f"  Archive size:   {compressed_bytes / 1024:.1f} KB")

    if args.no_copy:
        print("\nSkipping copy to Factorio mods folder (--no-copy specified).")
        return

    # Check for local Factorio mods directory
    appdata = os.environ.get("APPDATA")
    if not appdata:
        print(
            "\nNotice: %APPDATA% environment variable not found. Skipping local copy."
        )
        return

    factorio_mods_dir = Path(appdata) / "Factorio" / "mods"
    if not factorio_mods_dir.is_dir():
        print(f"\nNotice: Factorio mods folder not found at '{factorio_mods_dir}'.")
        return

    # Prompt user or use -y
    copy_confirmed = False
    if args.yes:
        copy_confirmed = True
    else:
        try:
            choice = (
                input(
                    f"\nCopy {zip_filename} to local Factorio mods folder ({factorio_mods_dir})? [y/N]: "
                )
                .strip()
                .lower()
            )
            copy_confirmed = choice in ("y", "yes")
        except (KeyboardInterrupt, EOFError):
            print("\nOperation cancelled.")
            return

    if copy_confirmed:
        dest_zip = factorio_mods_dir / zip_filename

        # Remove older version zips of this mod to avoid duplicates in Factorio
        for old_zip in factorio_mods_dir.glob(f"{mod_name}_*.zip"):
            if old_zip != dest_zip:
                try:
                    old_zip.unlink()
                    print(f"  Removed older version: {old_zip.name}")
                except Exception as e:
                    print(f"  Warning: could not remove {old_zip.name}: {e}")

        # Overwrite current zip
        shutil.copy2(target_zip_path, dest_zip)
        print(f"\nSuccessfully deployed to: {dest_zip}")
    else:
        print("\nSkipped copy to local Factorio mods folder.")


if __name__ == "__main__":
    main()
