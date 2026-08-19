# Design notes

Why the geometry is the way it is, and where the numbers came from. Decisions
only — the hardware itself is in [`greenboy3d-extruder.md`](greenboy3d-extruder.md)
and open work is in [`../TODO.md`](../TODO.md).

## Funnel angle is measured on the diagonal corner

On a rectangular funnel the corner runs further out than either flat face over
the same drop, so it is always the shallowest surface. Pellets bridge on the
shallowest surface, not the average one, so constraining a face leaves the
corner well under target — the imported design sat at 32–50° on its faces but
27–36° at the corner.

A rectangular bin also cannot hold equal X and Y angles for one drop, so a
single "wall angle" has to name a surface. The corner is the honest choice: set
it, and both faces come out steeper.

Hopper literature usually quotes the angle from **vertical**; ours is from
**horizontal**, which is 90 minus theirs. 60° here is 30° from vertical.

## Feedstock minimum angles: 60° virgin, 70° regrind

Design targets from general bulk-solids practice, **not measurements**. The
critical mass-flow angle depends on the material *and* on the wall friction of
the surface it slides on [J], so a printed wall is not interchangeable with the
steel these figures assume. Regrind is set steeper because irregular flake nests
and bridges where free-flowing pellets do not [W].

Treat these as provisional. A hopper that bridges in service wants a measured
wall friction angle against an actual printed surface, not a nudge to these.

## Bulk densities: 0.62 kg/L virgin, 0.35 kg/L regrind

Pellet bulk density spans roughly 450–850 kg/m³ across resin types [C]; virgin
PLA sits near the middle of that. Regrind flake is markedly lighter and its
density is variable rather than a property [W], so 0.35 kg/L is an estimate.

These only affect the reported capacity, never the geometry. Every capacity
figure in this repo inherits their uncertainty.

## `min_wall` is perpendicular material, compensated on the corner

Wall thickness is applied by insetting the inner surface horizontally, but on a
face sloped at θ the material perpendicular to it is only `inset · sin θ`. The
imported design applied 3 mm horizontally, which is 1.61 mm of real material on
the 10 kg funnel.

The inset is sized on the corner angle — the shallowest surface — so nothing
finishes thinner than asked; flat faces and the vertical bin come out thicker.
One inset for the whole profile also keeps every inner surface parallel to its
outer, so the funnel meets the bin with no internal ledge to catch pellets.

Verified on the rendered mesh rather than by trig: at the funnel corner a
1.44 mm sphere sits entirely inside the wall and a 1.56 mm one breaks out,
bracketing the 3.00 mm target.

## Inner corner radii must follow the wall inward

An inner radius clamped at a floor is no longer a parallel offset, and it thins
the wall exactly at the corner that is already shallowest — about 8% in the
imported geometry. So the radii subtract the inset and the geometry **asserts**
the result stays at or above 0.8 mm, roughly two 0.4 mm extrusions, rather than
clamping quietly.

## Build volume 250 × 210 × 210 mm

The Original Prusa i3 MK3S envelope [P], and the largest printer available here
for the foreseeable future. Reported on every render; `require_printable` turns
it into a hard error, and is off until the presets are re-derived, since no
preset currently fits at a workable funnel angle.

## No BOSL2

BOSL2 is installed globally and its `prismoid(xang=)` is close to the feature we
needed, but it does not solve the shell problem — its only true 3D offset uses
`minkowski()` and its own docs advise against it — so an inner solid still has
to be subtracted and the `sin θ` compensation still has to be written by hand.
Measured on this geometry the plain-OpenSCAD version rendered slightly faster.
Not worth a second dependency and ~1850 global symbols for one `tan()`.

Revisit if rounded *horizontal* edges (a bin rim, a funnel-to-bin fillet) or
threads are ever needed; those are genuinely painful to hand-roll.

## OpenSCAD behaviour this repo depends on

All established by compiling on 2021.01, not from documentation.

- `use <>` imports modules and functions but **not variables**, and is not
  transitive through another `use`. Hence accessor functions on every registry.
- A module reading a caller's global across `use <>` is a **warning, exit 0**,
  and silently coerces `undef` into geometry — it ships a wrong part rather than
  failing. Hence `--hardwarnings` in the gate, and modules that never read
  globals.
- Customizer parameters must be top-level assignments in the **main file**,
  textually before the first `module` definition. Parameters in an included file
  never reach the panel. Hence the dummy-module fence in `pellet_hopper.scad`.
- A failing `assert()` exits 1 on STL export and writes no file, so asserts are
  usable as a gate — but `-o file.echo` exits 0 through the same failure.
- A reversed range `[begin:end]` with `begin > end` reports only `DEPRECATED`,
  exits 0 **even under `--hardwarnings`**, and iterates backwards instead of
  empty. The gate greps for it. Soft diagnostics must therefore never echo the
  literal tokens `ERROR:`, `WARNING:` or `DEPRECATED:`.
- STL facets are not emitted in a stable order, so meshes cannot be compared by
  hash. `just geom` compares signed volume, bounding box and triangle count.

## References

- [C] Conair — *What is Bulk Density?* <https://www.conairgroup.com/resources/resource/what-is-bulk-density/>
- [J] Jenike & Johanson — *Designing bulk material storage and feeding systems* <https://jenike.com/designing-end-to-end-bulk-material-storage-and-feeding-systems-hoppers-silos-mass-flow-feeders/>
- [W] Wijay Systems — *Plastic pellet conveying systems* <https://wijaysystems.com/plastic-pellet-conveying-systems/>
- [P] Prusa Research — *Original Prusa i3 MK3S+* <https://www.prusa3d.com/product/original-prusa-i3-mk3s-3d-printer-3/>
- [B] `bayonet-lock-scad` <https://github.com/CameronBrooks11/bayonet-lock-scad>
- GreenBoy3D sources are listed in [`greenboy3d-extruder.md`](greenboy3d-extruder.md).
