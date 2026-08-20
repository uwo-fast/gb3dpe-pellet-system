#!/usr/bin/env python3
"""Hand load cases for the hopper, so the numbers can be re-run when geometry moves.

Simple closed-form models, not FEA. Each is chosen to be conservative; where a
model ignores something that would help, that is noted in docs/loads.md.
"""

import argparse
import math

G = 9.81
# Printed and loaded across layers. Bulk PETG yields near 50 MPa; this is the
# number worth designing to, and it is an assumption, not a measurement.
PETG_EFFECTIVE_MPA = 30.0


def report(name, sigma_mpa, note=""):
    print(f"  {name:<42} {sigma_mpa:8.2f} MPa   SF {PETG_EFFECTIVE_MPA / sigma_mpa:7.1f}  {note}")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--top", type=float, default=202.0)
    ap.add_argument("--throat", type=float, default=58.0)
    ap.add_argument("--angle", type=float, default=70.0)
    ap.add_argument("--min-wall", type=float, default=3.0)
    ap.add_argument("--body-height", type=float, default=410.0)
    ap.add_argument("--segments", type=int, default=2)
    ap.add_argument("--density", type=float, default=0.489, help="feedstock, kg/L (measured, see docs/feedstock.md)")
    ap.add_argument("--mount-offset", type=float, default=40.0)
    ap.add_argument("--grip-depth", type=float, default=30.0)
    args = ap.parse_args()

    inset = args.min_wall / math.sin(math.radians(args.angle))
    run = math.hypot((args.top - args.throat) / 2, (args.top - args.throat) / 2)
    funnel_h = run * math.tan(math.radians(args.angle))
    inner_top = args.top - 2 * inset
    bin_h = args.body_height - 18 - 10 - funnel_h
    split = args.body_height / args.segments
    funnel_base = 18 + 10 - 0.5
    section = args.throat + (args.top - args.throat) * min(1, (split - funnel_base) / funnel_h)
    inner_section = section - 2 * inset

    v_funnel_above = (
        (funnel_base + funnel_h - split) / 3
        * (inner_section ** 2 + inner_top ** 2 + inner_section * inner_top) / 1e6
    )
    v_bin = inner_top ** 2 * bin_h / 1e6
    mass_above = (v_funnel_above + v_bin) * args.density
    mass_total = (v_funnel_above + v_bin) * args.density  # conservative for the mount

    print(f"\nfunnel {funnel_h:.0f} mm, bin {bin_h:.0f} mm, split at {split:.0f} "
          f"(section {section:.0f} mm)")
    print(f"feedstock above the split: {v_funnel_above + v_bin:.2f} L = {mass_above:.2f} kg\n")

    # Segments stack, so the flange bears in compression; bolts resist prying only.
    flange_area = (section + 24) ** 2 - inner_section ** 2
    report("split flange bearing", (mass_above + 0.5) * G / flange_area)

    # Bin wall: hydrostatic pressure on a strip, simply supported across the span.
    pressure = args.density * 1000 * G * (args.body_height / 1000)
    span = inner_top / 1000
    moment = pressure * span * span / 8
    modulus = (args.min_wall / 1000) ** 2 / 6
    report("bin wall bending (strip model)", moment / modulus / 1e6, "governs")

    for kg in (3.0, 4.0):
        force = kg * G
        couple = force * (args.mount_offset / 1000) / (args.grip_depth / 1000)
        z_jaw = 0.080 * 0.005 ** 2 / 6
        report(f"clamp jaw bending, {kg:.0f} kg",
               couple * (args.grip_depth / 1000) / z_jaw / 1e6, f"({couple:.0f} N couple)")
        z_plate = 0.120 * 0.006 ** 2 / 6
        report(f"plate cantilever, {kg:.0f} kg",
               force * (args.mount_offset / 1000) / z_plate / 1e6)

    seat = math.pi * ((72 / 2) ** 2 - (65.3 / 2) ** 2)
    report("hub annular seat, 4 kg", 4.0 * G / seat)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
