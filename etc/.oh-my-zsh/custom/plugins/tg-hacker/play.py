#!/usr/bin/env python3

import argparse
import os
from subprocess import Popen, PIPE
from dotenv import load_dotenv
from pathlib import Path

import yaml
from jinja2 import Environment, meta
from pyfzf.pyfzf import FzfPrompt

PATH_TOOLS = Path.home() / "tools"
PATH_COMMANDS = Path(__file__).resolve().parent / "commands"
PATH_VARS = Path(__file__).resolve().parent / "variables"

# Shared fzf flags for a tab-delimited "label<TAB>value" list: show only the
# label, preview the value in a small pane below.
FZF_TABLE = (
    "--delimiter='\\t' --with-nth=1 "
    "--preview='echo {2}' --preview-window=down,3,wrap"
)


def load_commands():
    commands = {}
    for path in sorted(PATH_COMMANDS.glob("*.yml")):
        if path.name.startswith("_"):
            continue
        data = yaml.safe_load(path.read_text())
        if not data:
            continue
        tool = data.get("tool", path.stem)
        for action in data.get("actions", []):
            command = action.get("command") or action.get("template")
            if not command:
                continue
            commands[f"{tool}/{action['title']}"] = command
    return commands

def get_command():
    fzf = FzfPrompt()
    lines = [f"{key}\t{command}" for key, command in commands.items()]
    selection = fzf.prompt(lines, f"{FZF_TABLE} --prompt='Command> '")
    if not selection:
        return ""
    return selection[0].split("\t", 1)[0]


def get_file():
    files = sorted([p.name for p in PATH_TOOLS.iterdir()], key=str.lower)
    fzf = FzfPrompt()
    selection = fzf.prompt(files, "--prompt='File> '")
    if not selection:
        return ""
    return selection[0]


def load_options(name):
    """Return (options, default) for a variable, or None if there is no list.

    Looks for variables/<name>.yml (a list of strings, or of
    {title, value} mappings; add `default: true` to one to make it the
    fallback) or variables/<name>.txt (one value per line).
    """
    for ext in (".yml", ".yaml"):
        path = PATH_VARS / f"{name}{ext}"
        if path.exists():
            data = yaml.safe_load(path.read_text()) or []
            options = []
            default = None
            for item in data:
                if isinstance(item, dict):
                    value = str(item.get("value", ""))
                    options.append((str(item.get("title", value)), value))
                    if item.get("default"):
                        default = value
                else:
                    options.append((str(item), str(item)))
            return options, default
    path = PATH_VARS / f"{name}.txt"
    if path.exists():
        lines = path.read_text().splitlines()
        values = [ln.strip() for ln in lines if ln.strip() and not ln.startswith("#")]
        return [(v, v) for v in values], None
    return None


def get_variable(name, options):
    fzf = FzfPrompt()
    if any(label != value for label, value in options):
        lines = [f"{label}\t{value}" for label, value in options]
        selection = fzf.prompt(
            lines, f"--print-query {FZF_TABLE} --prompt='{name}> '"
        )
        if not selection:
            return ""
        # With --print-query the typed query is the first line; a chosen row
        # (if any) follows. Prefer the row, else fall back to the raw query.
        if len(selection) > 1:
            chosen = selection[1].split("\t", 1)[0]
            return dict(options).get(chosen, chosen)
        return selection[0]
    selection = fzf.prompt(
        [value for _, value in options],
        f"--print-query --prompt='{name}> '",
    )
    if not selection:
        return ""
    return selection[-1]


def load_vars():
    load_dotenv("./.env")
    names = (
        "LHOST",
        "LPORT",
        "RHOST",
        "RPORT",
        "dn",
        "dc",
        "ns",
        "fqdn",
        "un",
        "pw",
    )
    vars = {}
    for name in names:
        value = os.environ.get(name, "")
        if value:
            vars[name.lower()] = value
    return vars


def main(args):
    cmd = args.cmd
    vars = load_vars()

    # Variable overrides
    if args.lhost:
        vars["lhost"] = args.lhost
    if args.lport:
        vars["lport"] = args.lport
        vars["lhost"] = f"{vars.get('lhost', '')}:{args.lport}"
    if args.rhost:
        vars["rhost"] = args.rhost
    if args.user:
        vars["un"] = args.user
    if args.password:
        vars["pw"] = args.password
    if args.file:
        vars["file"] = args.file

    env = Environment()

    # A custom template passed on the command line bypasses the command menu.
    if args.template:
        template = args.template
    else:
        if cmd == "":
            cmd = get_command()
        if cmd not in commands:
            print("Command not found")
            return
        template = commands[cmd]

    compiled = env.from_string(template)
    referenced = meta.find_undeclared_variables(env.parse(template))
    for name in sorted(referenced):
        if name in vars:
            continue
        if name == "file":
            vars["file"] = get_file()
            continue
        loaded = load_options(name)
        if loaded:
            options, default = loaded
            value = get_variable(name, options) or default
        else:
            # No variables/<name> list: ask for the value directly. A blank
            # answer leaves it unset so any Jinja `default(...)` still applies.
            value = input(f"{name}> ").strip()
        if value:
            vars[name] = value

    command = compiled.render(**vars)
    if args.proxychains:
        command = f"proxychains {command}"
    p1 = Popen(["xclip", "-selection", "clipboard", "-f"], stdin=PIPE)
    p1.communicate(input=(command.encode()))


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Command player")
    parser.add_argument("-f", "--file", default="", dest="file", action="store", type=str, help="File name")
    parser.add_argument("-l", "--lhost", default="", dest="lhost", action="store", type=str, help="local host")
    parser.add_argument("-lp", "--lport", default="", dest="lport", action="store", type=str, help="local port")
    parser.add_argument("-pc", "--proxychains", action="store_true", default=False, help="Use proxychains")
    parser.add_argument("-pw", "--password", default="", dest="password", action="store", type=str, help="Password")
    parser.add_argument("-r", "--rhost", default="", dest="rhost", action="store", type=str, help="remote port")
    parser.add_argument("-t", "--template", default="", dest="template", action="store", type=str, help="Process a custom template instead of a saved command")
    parser.add_argument("-un", "--user", default="", dest="user", action="store", type=str, help="Username")
    parser.add_argument("cmd", default="", nargs="?", type=str, help="Choose a command to play")
    args = parser.parse_args()
    commands = load_commands()
    main(args)
