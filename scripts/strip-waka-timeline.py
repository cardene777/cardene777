#!/usr/bin/env python3
"""Strip the Timeline (Lines of Code chart) section from the waka block in README.md.

waka-readme-stats outputs a Timeline section even when SHOW_LOC_CHART is False
(seems to be an upstream bug). The PNG bar_graph.png it embeds has a white
matplotlib background that clashes with our dark/green theme, so we delete it
post-generation.

Removed pattern (within the <!--START_SECTION:waka--> ~ <!--END_SECTION:waka-->
block):
  - Any line containing "**Timeline**"
  - Any line containing "bar_graph.png"
  - Surrounding blank lines that become orphans after the deletion
"""

from __future__ import annotations

from pathlib import Path

README = Path(__file__).resolve().parent.parent / "README.md"
START = "<!--START_SECTION:waka-->"
END = "<!--END_SECTION:waka-->"


def strip(text: str) -> str:
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    inside = False
    skip_blank = 0  # consume up to N blanks after a removed line

    for line in lines:
        if START in line:
            inside = True
            out.append(line)
            continue
        if END in line:
            inside = False
            out.append(line)
            continue

        if not inside:
            out.append(line)
            continue

        if "**Timeline**" in line or "bar_graph.png" in line:
            skip_blank = 2
            continue

        if skip_blank > 0 and line.strip() == "":
            skip_blank -= 1
            continue

        skip_blank = 0
        out.append(line)

    return "".join(out)


def main() -> None:
    original = README.read_text(encoding="utf-8")
    stripped = strip(original)
    if stripped == original:
        print("No Timeline section found, nothing to strip.")
        return
    README.write_text(stripped, encoding="utf-8")
    print("Timeline section stripped.")


if __name__ == "__main__":
    main()
