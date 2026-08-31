# Changelog

All notable changes to this project are documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Parametric bulk hopper CAD (body, roof mount, cap) with three capacity
  presets, imported as received.
- `just check` gate compiling every part at every size with OpenSCAD warnings
  treated as errors, plus `render`, `edit` and `clean` recipes.
- Hardware reference for the GreenBoy3D Pellet Extruder V1, including
  measurements taken from the vendor CAD.
- Design review of the imported hopper, and `TODO.md` tracking open work.
- Geometry regression harness (`scripts/geom_stats.py`, `just geom`) with a
  committed baseline, comparing meshes by volume, bounding box and triangle
  count rather than by hash.

### Changed

- Body segments are their own `render_part` entries -- `body0`, `body1` and so
  on -- rather than one `body` plus a separate `segment` index to say which. A
  segment is a separate print, so it is a separate part; asking for one the
  current `segments` count does not have now names itself. `just render` and the
  geometry baseline needed no special handling for the body once it was ordinary.
- Each part now lives in its own file and takes explicit named parameters.
  `pellet_hopper.scad` is a driver that defines no geometry, and every other
  file under `cad/hopper/` renders standalone.
- Capacity presets became a registry with accessor functions, so a preset can
  be read across a `use <>` boundary, where plain variables do not travel.
- The bayonet is built from a single joint spec shared by both halves, so the
  body and the mount cannot drift into a joint that does not mate.
- The render gate greps for `DEPRECATED:` as well as errors and warnings: a
  reversed range reports only that, exits 0, and iterates backwards instead of
  empty.

- Funnel wall angle is an input rather than an accident. It is measured on the
  diagonal corner, the drop is solved from it, and capacity is reported rather
  than promised — the imported presets were named for a capacity that fixed the
  angle at 27-36 degrees at the corner.
- Feedstock is selectable between virgin pellets and regrind flake, carrying the
  minimum workable funnel angle and the bulk density used to report capacity.
- `wall` became `min_wall`: the least material anywhere, measured perpendicular
  to the surface rather than horizontally. Inner corner radii now follow the
  wall inward instead of clamping, which had been thinning the corner.
- A build-volume fit report on every render, and an opt-in `require_printable`
  assert.

- The bayonet joint is now built on `bayonet-lock-scad` rather than hand-rolled,
  keyed so the rectangular bin cannot seat crosswise on the roof. This adds a
  required external library, pinned by commit.

- Operating procedures (first flash, PINDA jog test) rescued out of untracked
  scratch into `docs/operations/`.

- Preview colours, one per printed part, assigned bottom-up through the stack.
- `examples/`, covered by the gate.

- The CAD is eleven module files rather than seventeen. The three plate
  variants share one file, the feedstock, flow and hose registries became
  `hopper_specs.scad`, splitting lives with the body it splits, and the
  footprint presets are three pairs of numbers in the driver rather than a
  registry with accessors. Examples went from four to two.
- `hopper_body()` takes the funnel angle rather than a height that it had to
  `atan()` back into the angle the driver had already solved it from. The same
  pass removed three other places where one file re-derived what another owns.
- Assert messages are wrapped as sentences rather than split mid-phrase to fit
  a column. No message text changed.
- The hub's fixings pass through the flange to a nut, counterbored so the nut
  seats flat, instead of self-tapping into blind holes. Where the bolt circle
  sits is now the input and the depth follows from the 45 degree flare, rather
  than the reverse.

### Fixed

- The MK3S mount hung the outlet into the gantry's path, so the toolhead met it
  at full Z. The saddle's roof now doubles as a riser and is solved, not chosen:
  it stands the mount off the frame by whatever puts the outlet's mouth clear of
  the top bar, which is the highest anything that travels can reach. That works
  out to a 62.2 mm roof and a 98 mm tall plate, and it re-solves itself for a
  different hose rather than holding a hardcoded number.
- The MK3S plate's braces grew downward with the riser instead of outward,
  turning a 44 degree wedge into a 68 degree fin: their height was tied to the
  saddle's, their reach was not. That left 6.49 cm3 of brace hanging 30 mm below
  the frame's top bar and inboard of it -- a second thing in the gantry's column,
  which is what the riser exists to keep clear. Height now follows the riser and
  stops at the bar; reach now spans the whole hub footprint instead of ending at
  its axis, where the bolts furthest from the saddle had no brace under them.
- The build-fit report measured the MK3S plate as a flat 6 mm sheet, ignoring
  the saddle hanging off its underside -- a part `docs/printing.md` had listed
  at 42 mm all along. Harmless until the riser above made the saddle the term
  that grows, at which point a tall mount would have sailed past the check.
- `just render` never wrote the upper body segment. It emitted one STL per part
  at the driver's default segment, so the only body file it produced was the
  lower one -- under a name that read like the whole body -- while
  `docs/printing.md` listed two prints. Both now come out, named for the part.
- The assembly preview drew the whole body in one colour. Each segment is built
  as the entire body clipped to its own slab, so every segment's tree still
  carries a full-height funnel that the clip removes; preview resolves CSG by
  depth peeling, and a hollow lofted body inside an intersection is deeper than
  the default single layer, so the upper segment's discarded funnel drew over
  the lower one. Exported meshes were never affected.
- The hose thread was cutting 11% of its groove. `linear_extrude(twist=)`
  collapses the swept section at this radius and pitch -- 292 mm3 against the
  2557 mm3 of helical rod it should be -- so the outlet's socket was a smooth
  bore with a scratch in it and no hose would ever have wound into it. It is now
  the rib's section swept along its own helix as one polyhedron.
- The conveyor hose's rib was recorded as 4 mm at 8 mm pitch. Measured, it is a
  semicircular 3.5 mm section, and a printed coupon then settled the rest: a
  21.5 mm tube at 8.5 mm pitch, right-handed, 0.2 mm clearance on both the bore
  and the groove. The rib is the thread, so a wrong pitch means the hose does
  not start at all.
- The outlet's thread swept from 0.5 mm below the socket mouth. A swept
  polyhedron begins on a flat cap, and that cap landed inside the part, leaving
  solid material across 57 degrees of the entry — measured as a third less
  groove open at the mouth face than the coupon has. It now sweeps a full lead
  past the socket at both ends, which is what the coupon had been doing all
  along and the reason the coupon threaded when the outlet would not have.

### Removed

- The two coupling retaining screws, and the whole apparatus behind them: three
  spec fields, three asserts, four modules, three accessors and three driver
  parameters. Gravity already prevents the upper joint releasing -- rotation
  alone leaves a loaded bin sitting where it was -- and the lower screw could
  only ever exit on the skirt's 45 degree cone, where no head seats. The
  outlet's retention now rests on the bayonet and on the hose thread, which
  `cad/coupons/hose_thread_coupon.scad` exists to settle.

### Notes

- The restructure is geometry-neutral. All three parts at all three capacity
  presets match the pre-refactor baseline exactly on volume, bounding box and
  triangle count.
- So is the simplification pass that followed it: fifteen printed meshes,
  including both extra plate variants, the upper body segment and the flow
  coupon and its stand, match at zero tolerance rather than within 0.5%.
- The design changes after it are NOT geometry-neutral, deliberately: the
  retainer removal, the hose profile, the thread fix and the hub's through-bolts
  each moved the parts they were meant to move and nothing else, which the
  baseline is what proves.
