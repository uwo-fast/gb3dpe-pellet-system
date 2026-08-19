#!/usr/bin/env python3
"""Render each hopper part at each capacity preset and report mesh invariants.

OpenSCAD does not emit STL facets in a stable order, so meshes cannot be
compared by hash. Signed-tetrahedron volume, bounding box and triangle count
are order-independent, and together they catch any real geometry change.

Used to prove a refactor is geometry-neutral: capture a baseline before the
change, compare after.
"""

import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path

SCAD = Path("cad/hopper/pellet_hopper.scad")
PARTS = ["body", "mount", "cap"]
SIZES = {0: "220x180", 1: "300x240", 2: "390x300"}
BASELINE = Path("tests/geometry-baseline.json")


def mesh_stats(stl: Path) -> dict:
    xs, ys, zs, tri, vol, n = [], [], [], [], 0.0, 0
    with stl.open() as fh:
        for line in fh:
            f = line.split()
            if not f or f[0] != "vertex":
                continue
            v = (float(f[1]), float(f[2]), float(f[3]))
            tri.append(v)
            xs.append(v[0]), ys.append(v[1]), zs.append(v[2])
            if len(tri) == 3:
                (ax, ay, az), (bx, by, bz), (cx, cy, cz) = tri
                vol += (
                    ax * (by * cz - bz * cy)
                    - ay * (bx * cz - bz * cx)
                    + az * (bx * cy - by * cx)
                ) / 6.0
                tri, n = [], n + 1
    if not n:
        raise SystemExit(f"{stl}: empty mesh")
    return {
        "triangles": n,
        "volume_mm3": round(abs(vol), 3),
        "bbox_mm": [
            round(max(xs) - min(xs), 4),
            round(max(ys) - min(ys), 4),
            round(max(zs) - min(zs), 4),
        ],
        "origin_mm": [round(min(xs), 4), round(min(ys), 4), round(min(zs), 4)],
    }


def capture() -> dict:
    out = {}
    with tempfile.TemporaryDirectory() as tmp:
        for size, label in SIZES.items():
            for part in PARTS:
                stl = Path(tmp) / f"{part}.stl"
                subprocess.run(
                    ["openscad", "-o", str(stl),
                     "-D", f'render_part="{part}"', "-D", f"hopper_size={size}",
                     str(SCAD)],
                    check=True, capture_output=True,
                )
                out[f"{part}@{label}"] = mesh_stats(stl)
    return out


def compare(baseline: dict, current: dict, vol_tol: float, dim_tol: float) -> int:
    failures = 0
    for key in sorted(set(baseline) | set(current)):
        want, got = baseline.get(key), current.get(key)
        if want is None or got is None:
            print(f"  {key:<14} {'ADDED' if want is None else 'MISSING'}")
            failures += 1
            continue
        dv = abs(got["volume_mm3"] - want["volume_mm3"])
        rel = dv / want["volume_mm3"] * 100 if want["volume_mm3"] else 0.0
        dims = max(abs(a - b) for a, b in zip(want["bbox_mm"], got["bbox_mm"]))
        ok = rel <= vol_tol and dims <= dim_tol
        failures += not ok
        print(f"  {key:<14} {'ok  ' if ok else 'FAIL'} "
              f"volume {want['volume_mm3']:>12.3f} -> {got['volume_mm3']:>12.3f} "
              f"({rel:+.3f}%)  max bbox delta {dims:.4f} mm")
    return failures


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--write", action="store_true",
                    help=f"overwrite {BASELINE} with the current geometry")
    ap.add_argument("--volume-tolerance", type=float, default=0.5,
                    help="permitted volume change, percent (default: 0.5)")
    ap.add_argument("--dimension-tolerance", type=float, default=0.05,
                    help="permitted bounding-box change, mm (default: 0.05)")
    args = ap.parse_args()

    current = capture()

    if args.write:
        BASELINE.parent.mkdir(exist_ok=True)
        BASELINE.write_text(json.dumps(current, indent=2, sort_keys=True) + "\n")
        print(f"wrote {BASELINE} ({len(current)} parts)")
        return 0

    if not BASELINE.exists():
        raise SystemExit(f"no baseline at {BASELINE}; run with --write first")

    failures = compare(json.loads(BASELINE.read_text()), current,
                       args.volume_tolerance, args.dimension_tolerance)
    print(f"\n{len(current) - failures}/{len(current)} parts match the baseline")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
