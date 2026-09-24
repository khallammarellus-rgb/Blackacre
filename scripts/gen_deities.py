import openpyxl
import re

wb = openpyxl.load_workbook(
    r"C:\Users\kvebe\Downloads\Blackacre Deities and Patrons.xlsx",
    data_only=True,
)
ws = wb["Deity Sheet"]
rows = []
seen = set()


def cell(v):
    if v is None:
        return ""
    return str(v).strip()


for row in ws.iter_rows(min_row=2, values_only=True):
    name = cell(row[0])
    if not name:
        continue
    key = name.lower()
    if key in seen:
        continue
    seen.add(key)
    rows.append(
        {
            "name": name,
            "discipline": cell(row[1]),
            "alignment": cell(row[2]),
            "status": cell(row[3]),
            "classification": cell(row[5]),
            "sub": cell(row[6]),
            "realm": cell(row[7]),
            "blurb": cell(row[8])[:400],
        }
    )

rows.sort(key=lambda r: r["name"].lower())


def esc(t):
    return (
        t.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", " ")
        .replace("\r", "")
    )


lines = [
    "-- Generated from Blackacre Deities and Patrons.xlsx. Alphabetical.",
    "Blackacre = Blackacre or {}",
    "Blackacre.Deities = {",
]
for r in rows:
    idk = re.sub(r"[^A-Za-z0-9]+", "_", r["name"]).strip("_")
    if not idk:
        continue
    lines.append(
        '    { id = "%s", name = "%s", discipline = "%s", alignment = "%s", '
        'status = "%s", classification = "%s", sub = "%s", realm = "%s", blurb = "%s" },'
        % (
            esc(idk),
            esc(r["name"]),
            esc(r["discipline"]),
            esc(r["alignment"]),
            esc(r["status"]),
            esc(r["classification"]),
            esc(r["sub"]),
            esc(r["realm"]),
            esc(r["blurb"]),
        )
    )
lines.append("}")
path = r"C:\Users\kvebe\InCharacter\Blackacre_Tome\Data\Deities.lua"
with open(path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")
print("wrote", len(rows), "deities to", path)
