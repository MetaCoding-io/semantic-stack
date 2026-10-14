#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["pillow>=10"]
# ///
"""Copy screenshots from screenshots/out (or a downloaded `screenshots` artifact) into docs/screenshots,
shrunk so they can live in git: resized to WIDTH, cropped to at most MAX_RATIO times the width, and
quantised to a 256-colour palette. A second set of top crops (16:10) goes to docs/screenshots/readme for
the README grid.

    uv run scripts/publish-screenshots.py                      # screenshots/out -> docs/screenshots
    uv run scripts/publish-screenshots.py ~/Downloads/screenshots docs/screenshots
    uv run scripts/publish-screenshots.py --readme landing,fuseki,trifid-sparql
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image

WIDTH = 1200
MAX_RATIO = 1.6  # tallest gallery image: 1.6 x width (full-page captures are cropped to this)
README_RATIO = 0.625  # 16:10 top crop for the README grid
README_WIDTH = 960
DEFAULT_README = "landing,fuseki,trifid-sparql,trifid-resource,webvowl,skosmos,qlever-ui,jupyterlab"
GROUPS = ("default", "stores", "apis", "workbench")


def shrink(src: Path, dst: Path, width: int, max_ratio: float) -> int:
    im = Image.open(src).convert("RGB")
    w, h = im.size
    if w != width:
        im = im.resize((width, round(h * width / w)), Image.LANCZOS)
        w, h = im.size
    max_h = round(w * max_ratio)
    if h > max_h:
        im = im.crop((0, 0, w, max_h))
    im = im.quantize(colors=256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.FLOYDSTEINBERG)
    dst.parent.mkdir(parents=True, exist_ok=True)
    im.save(dst, format="PNG", optimize=True)
    return dst.stat().st_size


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src", nargs="?", default="screenshots/out", help="folder with <group>/<name>.png")
    ap.add_argument("dst", nargs="?", default="docs/screenshots")
    ap.add_argument("--width", type=int, default=WIDTH)
    ap.add_argument("--max-ratio", type=float, default=MAX_RATIO)
    ap.add_argument("--readme", default=DEFAULT_README, help="comma-separated target names to crop for the README")
    args = ap.parse_args()

    src, dst = Path(args.src), Path(args.dst)
    pngs = sorted(p for p in src.glob("*/*.png") if p.parent.name in GROUPS)
    if not pngs:
        print(f"no <group>/<name>.png under {src} (groups: {', '.join(GROUPS)})", file=sys.stderr)
        return 1
    readme = {n.strip() for n in args.readme.split(",") if n.strip()}
    total = 0
    for p in pngs:
        out = dst / p.parent.name / p.name
        size = shrink(p, out, args.width, args.max_ratio)
        total += size
        print(f"{size // 1024:>5} KB  {out}")
        if p.stem in readme:
            thumb = dst / "readme" / p.name
            size = shrink(p, thumb, README_WIDTH, README_RATIO)
            total += size
            print(f"{size // 1024:>5} KB  {thumb}")
            readme.discard(p.stem)
    if readme:
        print(f"warning: README picks not found in {src}: {', '.join(sorted(readme))}", file=sys.stderr)
    print(f"total {total / 1024 / 1024:.1f} MB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
