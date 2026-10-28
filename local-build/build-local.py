from pathlib import Path
import subprocess
root = Path(__file__).resolve().parents[1]
sources = sorted(str(p) for p in (root / "Sources/SharePad").rglob("*.swift"))
out = root / "local-build/SharePad.app"
subprocess.run(["swiftc", "-swift-version", "6", "-D", "LOCAL_BUILD", "-parse-as-library", "-O", "-whole-module-optimization", "-num-threads", "2", "-target", "arm64-apple-macosx14.0", "-module-name", "SharePad", *sources, "-o", str(out / "Contents/MacOS/SharePad")], check=True)
subprocess.run(["codesign", "--force", "--sign", "-", "--options", "runtime", "--entitlements", str(root / "Sources/SharePad/SharePad.entitlements"), str(out)], check=True)
subprocess.run(["codesign", "--verify", "--strict", str(out)], check=True)
print(out)
