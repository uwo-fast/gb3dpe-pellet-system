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

### Notes

- The restructure is geometry-neutral. All three parts at all three capacity
  presets match the pre-refactor baseline exactly on volume, bounding box and
  triangle count.
