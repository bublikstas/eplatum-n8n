import json
from pathlib import Path

in_dir = Path("workflows")
out_dir = Path("workflows_sanitized")

def strip_ids(obj):
    if isinstance(obj, list):
        return [strip_ids(x) for x in obj]
    if isinstance(obj, dict):
        return {k: strip_ids(v) for k, v in obj.items() if k != "id"}
    return obj

if not in_dir.exists():
    raise SystemExit(f"Missing folder: {in_dir.resolve()}")

out_dir.mkdir(parents=True, exist_ok=True)

files = [p for p in in_dir.iterdir() if p.suffix == ".json"]
if not files:
    print("No workflow JSON files found in ./workflows")
    raise SystemExit(0)

for p in files:
    with p.open("r", encoding="utf-8") as f:
        data = json.load(f)
    sanitized = strip_ids(data)
    out_path = out_dir / p.name
    with out_path.open("w", encoding="utf-8") as f:
        json.dump(sanitized, f, ensure_ascii=False, indent=2)
    print(f"Sanitized: {p.name}")

print("Done.")
