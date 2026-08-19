# GB3DPE Pellet System

> Bulk pellet feed system, mounts, and operating docs for the GreenBoy3D pellet
> extruder running on a Prusa MK3S.

[![License: GPL-3.0](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Contributions welcome](https://img.shields.io/badge/Contributions-welcome-brightgreen.svg)](https://github.com/uwo-fast/.github/blob/main/CONTRIBUTING.md)

## Overview

We run a [GreenBoy3D Pellet Extruder V1](docs/greenboy3d-extruder.md) on a Prusa
MK3S, printing from virgin pellets and from shredded regrind. The machine works
and prints well, but the extruder's own hopper is a 43 × 40 × 45 mm cup holding
roughly 20–30 g of pellets — under an hour of printing before it needs
refilling by hand.

This repository holds the bulk feed system that fixes that: a roof-mounted
hopper on the printer enclosure, gravity-feeding the toolhead through the
extruder's supplied conveyor tube, matching the feed architecture the stock
hopper already uses. It also collects the mounts and operating documentation
for the extruder that GreenBoy3D does not supply.

Firmware lives separately, in
[`uwo-fast/Prusa-Firmware-GB3DPE`](https://github.com/uwo-fast/Prusa-Firmware-GB3DPE).

**Status: early.** The hopper CAD in `cad/hopper/` is an imported first draft
under active review — see [the design review](docs/hopper-design-review.md) for
what does and does not hold up, and [`TODO.md`](TODO.md) for what is being
worked. Do not print from it yet.

## Repository layout

- `cad/hopper/` — parametric bulk hopper: body, roof mount, and cap
- `docs/` — extruder hardware reference and design review
- `scripts/` — geometry regression harness
- `tests/` — committed geometry baseline

## Getting started

Requires [OpenSCAD](https://openscad.org/) (tested on 2021.01),
[just](https://github.com/casey/just), and
[`bayonet-lock-scad`](https://github.com/CameronBrooks11/bayonet-lock-scad)
installed as an OpenSCAD library:

```sh
git clone https://github.com/CameronBrooks11/bayonet-lock-scad \
  ~/.local/share/OpenSCAD/libraries/bayonet-lock-scad
git -C ~/.local/share/OpenSCAD/libraries/bayonet-lock-scad checkout 85c43ae
```

That library carries no git tags, so pin it by commit. Version 0.9.1 or later is
required.

```sh
just            # list recipes
just check      # compile every part at every size, any diagnostic fails
just geom       # check rendered geometry against the committed baseline
just render     # write STLs for every part and size to build/
just edit       # open the assembly in the OpenSCAD GUI Customizer
```

The design is driven from `cad/hopper/pellet_hopper.scad`, which holds every
tunable parameter and hands them to the part modules. Pick a part with
`render_part`, a footprint with `hopper_size`, and what it will hold with
`feedstock_type`.

The funnel angle is an input, not a consequence. Set `funnel_angle` in degrees
from horizontal and the drop is solved from it; capacity is then whatever falls
out, and is echoed on every render along with a build-volume fit report. The
angle is measured on the **diagonal corner**, which on a rectangular funnel runs
further out than either flat face over the same drop and is therefore the
shallowest surface and the one pellets bridge on. Each feedstock carries the
shallowest angle it will still flow at, and a render below it is an error rather
than a quiet under-performing hopper.

Note that the presets are named for their footprint rather than a capacity. The
imported design worked the other way round — capacity first, wall angle whatever
was left — which is how it ended up at 27 to 36 degrees at the corner.

Each of the other files under `cad/hopper/` defines one part or one concern and
renders on its own, so you can open `hopper_mount.scad` directly and iterate on
the mount without the rest of the model in the way.

`just geom` exists because OpenSCAD does not emit STL facets in a stable order,
so a mesh cannot be compared by hash. It compares signed volume, bounding box
and triangle count instead, which is enough to prove a refactor changed
nothing. Re-baseline with `just geom-baseline` only after an intended geometry
change.

## Documentation

- [GreenBoy3D Pellet Extruder V1 — hardware reference](docs/greenboy3d-extruder.md)
- [Design notes](docs/design-notes.md) — why the geometry is the way it is, and where the numbers came from
- [Review of the imported hopper design](docs/hopper-design-review.md)

## Contributing

Contributions are welcome. See the organization
[contribution guide](https://github.com/uwo-fast/.github/blob/main/CONTRIBUTING.md).

## Citation

If you use this project in your work, please cite it. Use the **Cite this
repository** button on GitHub, or see [`CITATION.cff`](CITATION.cff).

## Acknowledgements

The bulk hopper was initially designed by [Hadden Christ](https://github.com/HaddenChrist),
whose body, roof mount, cap and bayonet coupling are the basis of `cad/hopper/`.

## License

Released under the [GPL-3.0](LICENSE) license.

GreenBoy3D is an independent vendor; this project is not affiliated with
GreenBoy3D or Prusa Research. Vendor CAD files are not redistributed here.

## Contact

Maintained by the [FAST research group](https://uwo-fast.github.io/). For
research collaboration inquiries, contact Dr. Joshua Pearce
(<joshua.pearce@uwo.ca>).
