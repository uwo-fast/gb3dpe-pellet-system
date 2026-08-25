#!/usr/bin/env python3
"""Render every printed part and report mesh invariants.

OpenSCAD does not emit STL facets in a stable order, so meshes cannot be
compared by hash. Signed-tetrahedron volume, bounding box and triangle count
are order-independent, and together they catch any real geometry change.

Used to prove a refactor is geometry-neutral: capture a baseline before the
change, compare after. What is not rendered here is not protected, so the case
list is everything that gets printed, not everything that is convenient to
render -- a refactor is otherwise free to change the parts left out.
"""

import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path

SCAD = Path("cad/hopper/pellet_hopper.scad")
COUPON = Path("cad/coupons/flow_coupon.scad")
SIZES = {0: "150x150", 1: "175x175", 2: "202x202"}
BASELINE = Path("tests/geometry-baseline.json")


def cases():
    """Every distinct printed mesh, as (key, file, defines).

    Only the body and the cap change with the footprint preset. The hub, outlet
    and plate are identical at all three, so sweeping them spends three renders
    proving one thing -- and at these facet counts that is most of the runtime.
    """
    for size, label in SIZES.items():
        for part in ("body", "cap"):
            yield f"{part}@{label}", SCAD, [f'render_part="{part}"', f"hopper_size={size}"]

    # The upper segment. A cut that lands badly shows up only on the segment it
    # lands on, and segment 0 is what every other body case renders.
    yield "body-seg1", SCAD, ['render_part="body"', "hopper_size=2", "segment=1"]

    for part in ("hub", "outlet"):
        yield part, SCAD, [f'render_part="{part}"']

    # Each plate variant, since only the default one is reachable from the
    # driver's own defaults.
    for variant in ("mk3s", "universal", "panel"):
        yield f"plate-{variant}", SCAD, ['render_part="plate"', f'plate_variant="{variant}"']

    # The coupon at both angles worth comparing, and the stand that carries them.
    for angle in (70, 60):
        yield f"coupon-{angle}deg", COUPON, ['render_part="coupon"', f"angle={angle}"]
    yield "coupon-stand", COUPON, ['render_part="stand"']


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


def capture(facets: int) -> dict:
    out = {}
    with tempfile.TemporaryDirectory() as tmp:
        for key, scad, defines in cases():
            # The driver takes its facet count from render_facets; the coupon
            # is a standalone file and names its own preview_facets.
            facet_var = "preview_facets" if scad == COUPON else "render_facets"
            stl = Path(tmp) / "part.stl"
            stl.unlink(missing_ok=True)
            args = ["openscad", "-o", str(stl)]
            for d in defines + [f"{facet_var}={facets}"]:
                args += ["-D", d]
            subprocess.run(args + [str(scad)], check=True, capture_output=True)
            out[key] = mesh_stats(stl)
    return out


def compare(baseline: dict, current: dict, vol_tol: float, dim_tol: float) -> int:
    failures = 0
    for key in sorted(set(baseline) | set(current)):
        want, got = baseline.get(key), current.get(key)
        if want is None or got is None:
            print(f"  {key:<16} {'ADDED' if want is None else 'MISSING'}")
            failures += 1
            continue
        dv = abs(got["volume_mm3"] - want["volume_mm3"])
        rel = dv / want["volume_mm3"] * 100 if want["volume_mm3"] else 0.0
        dims = max(abs(a - b) for a, b in zip(want["bbox_mm"], got["bbox_mm"]))
        ok = rel <= vol_tol and dims <= dim_tol
        failures += not ok
        print(f"  {key:<16} {'ok  ' if ok else 'FAIL'} "
              f"volume {want['volume_mm3']:>12.3f} -> {got['volume_mm3']:>12.3f} "
              f"({rel:+.3f}%)  max bbox delta {dims:.4f} mm")
    return failures


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--write", action="store_true",
                    help=f"overwrite {BASELINE} with the current geometry")
    # Zero by default. A refactor that changes no geometry reproduces the mesh
    # exactly -- measured, not assumed -- so any slack here is slack a real
    # change can hide in. Pass a tolerance explicitly if a toolchain bump ever
    # perturbs the meshes.
    ap.add_argument("--volume-tolerance", type=float, default=0.0,
                    help="permitted volume change, percent (default: 0)")
    ap.add_argument("--dimension-tolerance", type=float, default=0.0,
                    help="permitted bounding-box change, mm (default: 0)")
    ap.add_argument("--facets", type=int, default=64,
                    help="render_facets to compare at; must match the baseline")
    args = ap.parse_args()

    current = capture(args.facets)

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
