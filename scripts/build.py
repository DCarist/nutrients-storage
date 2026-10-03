import argparse
import json
import os
import re
import shutil
import sys
import zipfile
from pathlib import Path


def detect_local_factorio_version():
    """Detects the major.minor version of the local Factorio installation from factorio-current.log."""
    appdata = os.environ.get("APPDATA")
    if not appdata:
        return None
    log_path = Path(appdata) / "Factorio" / "factorio-current.log"
    if not log_path.is_file():
        return None
    try:
        with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
            for _ in range(20):
                line = f.readline()
                if not line:
                    break
                match = re.search(r"Factorio\s+(\d+\.\d+)", line)
                if match:
                    return match.group(1)
    except Exception:
        pass
    return None


def package_mod_for_version(src_dir, target_dir, target_factorio_version=None):
    """Packages the mod into target_dir with info.json configured for the given Factorio version."""
    info_json_path = src_dir / "info.json"
    with open(info_json_path, "r", encoding="utf-8") as f:
        info_data = json.load(f)

    mod_name = info_data.get("name")
    if not mod_name:
        print("Error: 'info.json' must contain 'name'.", file=sys.stderr)
        sys.exit(1)

    if target_factorio_version == "2.0":
        info_data["factorio_version"] = "2.0"
        info_data["dependencies"] = ["base >= 2.0", "space-age >= 2.0"]
        info_data["version"] = "0.1.0"
    elif target_factorio_version == "2.1":
        info_data["factorio_version"] = "2.1"
        info_data["dependencies"] = ["base >= 2.1", "space-age >= 2.1"]
        info_data["version"] = "0.1.1"

    mod_version = info_data["version"]
    factorio_version = info_data["factorio_version"]

    archive_folder_name = f"{mod_name}_{mod_version}"
    zip_filename = f"{archive_folder_name}.zip"
    target_dir.mkdir(parents=True, exist_ok=True)
    target_zip_path = target_dir / zip_filename

    print(
        f"\n--- Packaging: {mod_name} v{mod_version} (Factorio {factorio_version}) ---"
    )
    print(f"Source: {src_dir}")
    print(f"Target: {target_zip_path}")

    file_count = 0
    total_uncompressed_bytes = 0

    with zipfile.ZipFile(target_zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, _, files in os.walk(src_dir):
            for file in files:
                full_path = Path(root) / file
                rel_path = full_path.relative_to(src_dir)
                archive_internal_path = Path(archive_folder_name) / rel_path
                arcname = str(archive_internal_path).replace("\\", "/")

                if file == "info.json":
                    info_bytes = (
                        json.dumps(info_data, indent=2, ensure_ascii=False).encode(
                            "utf-8"
                        )
                        + b"\n"
                    )
                    zipf.writestr(arcname, info_bytes)
                    file_count += 1
                    total_uncompressed_bytes += len(info_bytes)
                else:
                    zipf.write(full_path, arcname=arcname)
                    file_count += 1
                    total_uncompressed_bytes += full_path.stat().st_size

    compressed_bytes = target_zip_path.stat().st_size
    print(f"Built {zip_filename}:")
    print(f"  Files packaged: {file_count}")
    print(f"  Uncompressed:   {total_uncompressed_bytes / 1024:.1f} KB")
    print(f"  Archive size:   {compressed_bytes / 1024:.1f} KB")

    return target_zip_path, info_data


def main():
    parser = argparse.ArgumentParser(
        description="Build and package Factorio mod from src/ directory for Factorio 2.0 and/or 2.1."
    )
    parser.add_argument(
        "-t",
        "--target",
        choices=["2.0", "2.1", "all", "auto"],
        default="auto",
        help="Target Factorio version ('2.0', '2.1', 'all', or 'auto' to detect local game). Default: auto",
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

    detected_local_version = detect_local_factorio_version()
    if detected_local_version:
        print(f"Detected local Factorio installation: {detected_local_version}")

    # Determine which target(s) to build
    targets_to_build = []
    deploy_target = None

    if args.target == "all":
        targets_to_build = ["2.0", "2.1"]
        deploy_target = detected_local_version or "2.0"
    elif args.target in ("2.0", "2.1"):
        targets_to_build = [args.target]
        deploy_target = args.target
    else:  # auto
        effective_target = detected_local_version or "2.0"
        targets_to_build = [effective_target]
        deploy_target = effective_target

    built_packages = {}
    for target in targets_to_build:
        zip_path, info_data = package_mod_for_version(src_dir, target_dir, target)
        built_packages[target] = (zip_path, info_data)

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

    if deploy_target not in built_packages:
        deploy_target = list(built_packages.keys())[0]

    deploy_zip_path, deploy_info = built_packages[deploy_target]
    mod_name = deploy_info["name"]
    zip_filename = deploy_zip_path.name

    # Prompt user or use -y
    copy_confirmed = False
    if args.yes:
        copy_confirmed = True
    else:
        try:
            choice = (
                input(
                    f"\nDeploy {zip_filename} (Factorio {deploy_target}) to local Factorio mods folder ({factorio_mods_dir})? [y/N]: "
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
        shutil.copy2(deploy_zip_path, dest_zip)
        print(f"\nSuccessfully deployed to: {dest_zip}")
    else:
        print("\nSkipped copy to local Factorio mods folder.")


if __name__ == "__main__":
    main()
