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

- A retaining screw through the socket into a pocket in the neck, since the
  library's own detent is too small to print at our allowance.
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

### Notes

- The restructure is geometry-neutral. All three parts at all three capacity
  presets match the pre-refactor baseline exactly on volume, bounding box and
  triangle count.
- So is the simplification pass that followed it: fifteen printed meshes,
  including both extra plate variants, the upper body segment and the flow
  coupon and its stand, match at zero tolerance rather than within 0.5%.
