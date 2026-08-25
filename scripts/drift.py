#!/usr/bin/env python3
"""Check that a part rendered from the driver matches its standalone module.

Every part exists in two places: the driver builds it from its own parameters,
and the module file previews it from its own defaults. Nothing forces those to
agree, and when they drift the driver quietly builds a different part from the
one being looked at — which is exactly how an 80 mm saddle ended up carrying
braces sized for a 134 mm one.

Only parts whose standalone preview takes no geometry arguments are checked;
the body and cap previews deliberately show a different size from the shipping
preset, so there is nothing to compare.
"""

import argparse
import subprocess
import sys
import tempfile
from pathlib import Path

DRIVER = Path("cad/hopper/pellet_hopper.scad")
PAIRS = [
    ("hub", Path("cad/hopper/hopper_hub.scad")),
    ("outlet", Path("cad/hopper/hopper_outlet.scad")),
    ("plate", Path("cad/hopper/hopper_plate.scad")),
]


def mesh(stl: Path):
    tri, vol, n = [], 0.0, 0
    xs, ys, zs = [], [], []
    for line in stl.open():
        f = line.split()
        if not f or f[0] != "vertex":
            continue
        p = (float(f[1]), float(f[2]), float(f[3]))
        tri.append(p)
        xs.append(p[0]), ys.append(p[1]), zs.append(p[2])
        if len(tri) == 3:
            (a, b, c) = tri
            vol += (a[0] * (b[1] * c[2] - b[2] * c[1])
                    - a[1] * (b[0] * c[2] - b[2] * c[0])
                    + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6
            tri, n = [], n + 1
    if not n:
        raise SystemExit(f"{stl}: empty mesh")
    return abs(vol), n, (round(max(xs) - min(xs), 3),
                         round(max(ys) - min(ys), 3),
                         round(max(zs) - min(zs), 3))


def render(scad: Path, out: Path, defines):
    args = ["openscad", "-o", str(out)]
    for d in defines:
        args += ["-D", d]
    args.append(str(scad))
    r = subprocess.run(args, capture_output=True, text=True)
    if not out.exists():
        raise SystemExit(f"{scad}: no mesh\n{r.stderr[:400]}")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--facets", type=int, default=48)
    args = ap.parse_args()

    failures = 0
    with tempfile.TemporaryDirectory() as tmp:
        for part, module in PAIRS:
            a, b = Path(tmp) / f"{part}_drv.stl", Path(tmp) / f"{part}_std.stl"
            render(DRIVER, a, [f'render_part="{part}"', f"render_facets={args.facets}"])
            render(module, b, [f"preview_facets={args.facets}"])
            va, na, ba = mesh(a)
            vb, nb, bb = mesh(b)
            same = abs(va - vb) < 0.01 and ba == bb
            failures += not same
            print(f"  {part:<8} {'ok' if same else 'DRIFTED'}"
                  f"   driver {va:12.3f} mm3 {ba}"
                  f"   standalone {vb:12.3f} mm3 {bb}")
    if failures:
        print(f"\n{failures} part(s) differ between the driver and their own module.")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
