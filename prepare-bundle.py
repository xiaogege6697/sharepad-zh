from pathlib import Path
import shutil

root = Path(__file__).resolve().parent
output = root / "local-build" / "SharePad.app"
if output.exists():
    raise SystemExit("Output already exists. Use a fresh extracted source folder to avoid overwriting it.")
shutil.copytree(root / "bundle-template", output)
(output / "Contents" / "MacOS").mkdir(exist_ok=True)
print("Bundle template prepared. Next: python3 local-build/build-local.py")
