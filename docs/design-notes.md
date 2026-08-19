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

## Bayonet joint uses `bayonet-lock-scad` [B]

The joint was hand-rolled with rectangular tabs. It now comes from our own
`bayonet-lock-scad`, which brings a hard end stop, a keyed pattern, and a
thicker socket wall outside the channel. The library has no git tags, so it is
pinned by commit `85c43ae` (v0.11.0); at least 0.9.1 is required, which fixed
the z alignment of the two halves when `entry_depth` is not half of
`part_height`, exactly the case used here.

Four decisions worth recording:

**The locked position is `+sweep_angle`, not a common origin.** The library
README says instantiating both halves at a common origin gives the locked
position. Measured by intersecting the two halves, it does not: a common origin
is the *entry* position, and for `turn_direction = "CCW"` locked is
`+sweep_angle`. At +25° the halves seat with no interference and stay captured
with 99.6 mm³ of overlap when lifted by `entry_depth`; at 0° they lift straight
out. `joint_neck()` is therefore authored pre-rotated, so the body's nominal
orientation is the seated one. Getting this wrong sits the bin 25° skew to the
roof — and note the sign depends on `turn_direction`, so a result measured for
`CW` does not carry over.

**The annular seat stays.** Both library halves span the same z range with
nothing to bottom out on, so the pins would carry the entire pellet load. The
mount keeps the flange top between the pellet bore and the socket bore as a
~430 mm² land. Flat bearing there is well under 1 MPa; sphere-in-trough contact
would be tens of MPa, which does not break but beds in, and every 0.1 mm of
bed-in is 0.1 mm of new axial slop.

**The pattern is keyed.** Four evenly spaced pins give four identical locked
positions, and the bin is rectangular, so half of them mount it crosswise.
`key_angle = 15°` pulls one pin off the even pattern; the resulting margin (15°)
clears the channel half-angle (8.1°), and the smallest gap (75°) clears the
channel-merge floor (49.3°).

**Three asserts are ours, not the library's.** It checks `sweep_angle` against
the raw pin gap but not the sweep's own tangency extension, so adjacent channels
can merge into a continuous slot — no retention at all — with every library
assert passing. It also never checks that the channel stays inside the part, or
that the shell is thinner than the interface radius; either failure yields a
plausible-looking part that does not lock. `hopper_joint()` asserts all three,
plus that the pellet bore does not cut into the pins.

Verified in situ against the assembled mount, not just as two isolated halves:
the body seats at its nominal orientation, is captured when lifted (67 mm³ of
interference at 2 mm, 188 mm³ at 5 mm), and is blocked at 90°, 180° and 270°, so
the keying does prevent a crosswise mount. The annular seat measures 213.5 mm³
over a 0.5 mm probe against 214.1 mm³ predicted, so it is fully intact. Seated,
there is 0.25 mm³ of interference across the whole joint, unchanged at higher
facet counts and therefore real rather than faceting — consistent with the
library's detent sitting just short of the stop, i.e. a light snap-past.

**Anti-rotation is ours too.** The library has an undocumented detent whose size
is welded to `allowance`, so at our 0.30 it is a 0.6 mm post — at or below one
extrusion width. Treated as absent. In its place a self-tapping M4 runs radially
through the socket wall into a 1.2 mm pocket in the neck, which is a positive
lock rather than a friction one: the tip has to be driven out, not merely
slipped. Placed at 140°, above the channel and 40° clear of the entry slots —
which run from the channel *up through the top face* and are the easy thing to
forget when picking an angle. Verified: the pilot passes clean through the
socket wall, and the pocket leaves 1.8 mm of neck wall before the pellet bore.
`hopper_joint()` asserts both the height and the angular clearance.

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
- A `use`d file's own top-level `$fn` is what **its** modules see, overriding
  whatever the consumer set. So no file here assigns `$fn` at top level except
  the driver; standalone previews pass `$fn` on the call instead. Getting this
  wrong is silent: the driver's facet setting simply has no effect, which is how
  a body render sat at 170 s regardless of what it was asked for.

## References

- [C] Conair — *What is Bulk Density?* <https://www.conairgroup.com/resources/resource/what-is-bulk-density/>
- [J] Jenike & Johanson — *Designing bulk material storage and feeding systems* <https://jenike.com/designing-end-to-end-bulk-material-storage-and-feeding-systems-hoppers-silos-mass-flow-feeders/>
- [W] Wijay Systems — *Plastic pellet conveying systems* <https://wijaysystems.com/plastic-pellet-conveying-systems/>
- [P] Prusa Research — *Original Prusa i3 MK3S+* <https://www.prusa3d.com/product/original-prusa-i3-mk3s-3d-printer-3/>
- [B] `bayonet-lock-scad` <https://github.com/CameronBrooks11/bayonet-lock-scad>
- GreenBoy3D sources are listed in [`greenboy3d-extruder.md`](greenboy3d-extruder.md).
