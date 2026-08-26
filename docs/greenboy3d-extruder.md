# GreenBoy3D Pellet Extruder V1 — hardware reference

Reference notes for the toolhead this project feeds. Compiled from public
GreenBoy3D sources, press coverage, and our own measurements of the supplied
CAD. We are not affiliated with GreenBoy3D or Prusa Research.

## Why this file exists

**GreenBoy3D ships no firmware and effectively no technical documentation.**
On the vendor wiki, both `Marlin Firmware Setup` and `Klipper Firmware Setup`
are "Coming Soon" stubs, as are all six `Pellet 3D Printing Basics` and
`Recycling` pages. Only `Getting Started` (a thin intro) and the shop product
page carry real content, and even the product page omits the gearbox ratio and
any e-steps figure.

Everything we run is therefore self-derived. This file is the hardware half of
that; the firmware half lives in
[`uwo-fast/Prusa-Firmware-GB3DPE`](https://github.com/uwo-fast/Prusa-Firmware-GB3DPE).

## What it is

A gravity-fed auger toolhead: a planetary-geared stepper turns a screw inside a
heated barrel, melting plastic pellets and pushing them out an M6 nozzle. It
replaces the stock hotend and extruder entirely. Unlike industrial pellet heads
it uses no pneumatic feed — pellets fall into a small hopper on the head.

## Specifications

From the [shop product page](https://shop.greenboy3d.de/products/greenboy3d-pellet-extruder-v1):

| Parameter       | Value                                                         |
| --------------- | ------------------------------------------------------------- |
| System voltage  | 24 V                                                          |
| Heat cartridge  | 70 W, 24 V                                                    |
| Thermistor      | 1x, type not specified                                        |
| Fans            | 2x                                                            |
| Drive           | planetary-geared stepper, ratio not published                 |
| Max hotend temp | 330 °C stock; ~300 °C with PLA-printed parts; 420 °C upgraded |
| Max ambient     | 80 °C                                                         |
| Nozzle          | M6 thread, 0.4–2.5 mm                                         |
| Flow rate       | 125–200 g/h at 1 mm nozzle                                    |
| Pellet size     | 0.3–5 mm                                                      |
| Retraction      | mechanical (reversing screw), no firmware values              |
| Net weight      | ~700 g                                                        |
| Price           | €389                                                          |

Kit contents: barrel, screw (improved version), heating block, coupling,
fasteners, planetary geared stepper, 70 W/24 V cartridge, thermistor, 2 fans,
**1 m pellet conveyor tube**, 200 g PLA test pellets, and printable adapters.

## Deviations on our unit

- **Fans replaced.** The kit ships two 24 V 2-pin blowers. The Einsy cannot
  power those, so both were swapped for identical 5 V units we sourced
  separately.
- **PINDA bracket replaced.** GreenBoy3D's proximity-sensor adapters put the
  probe outside the MK3S X and Y travel limits. We designed a replacement that
  returns the probe near its original position; CAD is on Onshape under
  `Pellet-Extruder-Fan-Duct > PINDA Back Right Mount`.

## Supplied CAD, as measured

Bounding boxes measured from the vendor STL files. These are not redistributed
here — they come with the kit and their licence is unstated. Download from the
[vendor wiki](https://wiki.greenboy3d.de/) and keep them alongside your kit.

| Part                          | Bounding box (mm)      |
| ----------------------------- | ---------------------- |
| Pellet-Extruder-Hopper        | 43.11 × 40.18 × 45.50  |
| Pellet-Extruder-Hopper-Cap    | 43.22 × 54.30 × 6.99   |
| Pellet-Extruder-Fan-Duct      | 104.38 × 44.16 × 68.42 |
| Prusa-MK3S+Adapter            | 78.37 × 60.45 × 85.23  |
| Proximity-Sensor-Adapter 8/12 | 31.00 × 24.00 × 35.00  |
| Internal-Sliding-Pit          | 37.40 × 19.77 × 11.47  |
| External-Sliding-Pit          | 46.59 × 50.75 × 12.50  |

Two findings from those measurements drive this project:

1. **The stock hopper is tiny.** A 43 × 40 × 45 mm envelope holds roughly
   20–30 g of pellets. At the quoted 125–200 g/h it empties in well under an
   hour, which is why the printer needs constant attention and why we are
   building a bulk feed.
2. **The stock hopper has no mounting bolt pattern.** Its STEP file contains no
   M4-sized holes at all — only two Ø7.2 mm features in the cap. Any bolt
   pattern in our own parts is ours to define and justify, not inherited.

## Sources

- Wiki — <https://wiki.greenboy3d.de/>
- Shop, V1 — <https://shop.greenboy3d.de/products/greenboy3d-pellet-extruder-v1>
- Homepage — <https://greenboy3d.de/>
- Fabbaloo overview — <https://www.fabbaloo.com/news/greenboy3ds-pellet-extruder-a-low-cost-toolhead-aims-to-transform-fff-3d-printing>
- All3DP release — <https://all3dp.com/4/greenboy3d-diy-pellet-extruder-set-to-release-july-28/>
- 3DPrinting.com — <https://3dprinting.com/news/greenboy3ds-budget-pellet-extruder-coming-soon/>
