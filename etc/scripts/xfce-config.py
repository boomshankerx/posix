#!/usr/bin/env python3
"""
Minimal XFCE custom shortcuts script: add/update + remove specific ones
"""

from pathlib import Path
import xml.etree.ElementTree as ET
import sys

FILE = Path.home() / ".config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"

# 1. Shortcuts you WANT (add or update to these commands)
want = {
    "<Primary><Alt>t": "exo-open --launch TerminalEmulator",
    "<Primary><Alt>d": "thunar Downloads",
    "<Primary><Alt>w": "thunar w",
}

# 2. Shortcuts you want to REMOVE completely (even if they exist)
remove = [
    "F4"
]

if not FILE.is_file():
    print(f"Missing: {FILE}", file=sys.stderr)
    sys.exit(1)

tree = ET.parse(FILE)
root = tree.getroot()

cmds = root.find("./property[@name='commands']")
if cmds is None:
    print("No commands section", file=sys.stderr)
    sys.exit(1)

custom = cmds.find("./property[@name='custom']")
if custom is None:
    custom = ET.SubElement(cmds, "property", {"name": "custom", "type": "empty"})

changed = False

# ──────────────── Remove unwanted keys ────────────────
for key in remove:
    prop = custom.find(f"./property[@name='{key}']")
    if prop is not None:
        custom.remove(prop)
        print(f"Removed → {key}")
        changed = True
    # else: already gone → skip quietly

# ──────────────── Add / update wanted keys ────────────────
for key, cmd in want.items():
    prop = custom.find(f"./property[@name='{key}']")
    if prop is not None:
        if prop.get("value") != cmd:
            prop.set("value", cmd)
            print(f"Updated → {key} = {cmd}")
            changed = True
    else:
        ET.SubElement(custom, "property", {
            "name":  key,
            "type":  "string",
            "value": cmd
        })
        print(f"Added   → {key} = {cmd}")
        changed = True

if changed:
    tree.write(FILE, encoding="utf-8", xml_declaration=True)
    print("\nFile updated.")
    print("Apply changes:   log out/in   or")
    print("  xfce4-panel --restart &  xfwm4 --replace &")
else:
    print("No changes needed.")
