"""Builds assets/data/cards.json from the Kairos Archive registry export.

Usage: python3 tool/build_cards.py path/to/registry.json
Source: https://github.com/sadkinglabs/sorcery-registry (export/registry.json)
"""
import json
import sys

reg = json.load(open(sys.argv[1], encoding="utf-8"))
sets = {s["set_code"]: s["set_name"] for s in reg["sets"]}
printings = {p["printing_id"]: p for p in reg["printings"]}


def img(urls):
    if not urls:
        return None
    return {"small": urls["small"], "normal": urls["normal"]}


cards = []
for c in reg["cards"]:
    prints = []
    for pid in c["printing_ids"]:
        p = printings[pid]
        if p.get("retired_at"):
            continue
        prints.append({
            "id": pid,
            "set": p["set_name"],
            "product": p["product"],
            "finish": p["finish"],
            "artist": p["artist"],
            "flavour": p["flavour_text"] or None,
            "typeline": p["typeline"],
            "image": img(p["image_urls"]),
        })
    cards.append({
        "id": c["codex_id"],
        "name": c["name"],
        "type": c["type"],
        "rarity": c["rarity"],
        "subtypes": c["subtypes"],
        "elements": [e for e in c["elements"] if e != "None"],
        "keywords": c["keywords"],
        "cost": c["cost"],
        "attack": c["attack"],
        "defense": c["defense"],
        "life": c["life"],
        "thresholds": {k: c["thr_" + k] for k in ("air", "earth", "fire", "water")},
        "rules": c["rules_text"] or "",
        "sets": [sets[s] for s in c["set_codes"]],
        "default_printing": c["default_printing_id"],
        "image": img(c["image_urls"]),
        "printings": prints,
    })

out = {
    "source": "Kairos Archive (kairosarchive.net) - card data and images (c) Erik's Curiosa",
    "sets": [s["set_name"] for s in reg["sets"]],
    "cards": cards,
}
json.dump(out, open("assets/data/cards.json", "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
print(len(cards), "cards")
