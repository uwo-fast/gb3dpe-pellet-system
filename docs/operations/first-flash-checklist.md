# First flash and bring-up

Procedure for flashing the [GB3DPE firmware](https://github.com/uwo-fast/Prusa-Firmware-GB3DPE)
to the MK3S and bringing the pellet toolhead up safely. Do the steps in order.

## 0. Build

```bash
python3 utils/bootstrap.py    # one-time toolchain into .dependencies/
```

On Debian the bootstrap pip step fails under PEP 668. Supply `pyelftools`,
`polib` and `regex` from a virtualenv and point CMake at that interpreter with
`-DPython3_EXECUTABLE=...`.

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_TOOLCHAIN_FILE=cmake/AvrGcc.cmake -DFW_VARIANTS="MK3;MK3S"
ninja -C build MK3S_ENGLISH
```

Output: `build/build_gen/MK3S/MK3S_ENGLISH.hex`.

## 1. Flash

PrusaSlicer → Configuration → Flash printer firmware, select the hex, flash,
wait for reboot. The boot screen must read **"Prusa i3 MK3S GB3DPE"** — that is
the proof the right build is on.

## 2. Thermistor sanity — before any heating

Cold, the hotend must read room temperature. If it is wildly off, **stop**: the
thermistor table is wrong.

Then heat to 180 °C and 240 °C and compare against an independent thermometer
at each. We run **table 5**, verified against a K-type thermocouple; table 11
over-read by 11–28 °C. If yours disagrees by more than a few degrees, record
both readings before changing `TEMP_SENSOR_0`.

## 3. PID tune — 70 W block, not the stock 40 W

```gcode
M303 E0 S210 C8
M500
```

Still outstanding on our printer; the shipped gains are stock 40 W values. With
`THERMAL_MODEL` disabled, `TEMP_RUNAWAY` is the only remaining hotend
protection, so this is worth doing before long unattended prints.

## 4. Turn off what a pellet head does not use

These are **runtime settings in EEPROM, set from the LCD menu** — not firmware
`#define`s. The variant headers deliberately leave the features compiled in so
the menu options still exist.

- **Crash detection** → OFF. The heavy toolhead false-trips StallGuard.
- **Fans check** → OFF. The GB3D blowers (swapped to 5 V) have no tacho.
- **Fil. sensor** → OFF. No filament.

Read them back with `D3 Ax0f87 C1` (fan check) and `D3 Ax0f67 C1` (filament
sensor); `00` is disabled.

## 5. Extrusion direction

Heat to temperature and manually extrude a few mm. The auger must push melt
**out**. If it runs backwards, flip `INVERT_E0_DIR` in the variant header,
rebuild and reflash.

## 6. Calibration

Run XYZ calibration, then mesh bed levelling, then Live-Z.

Probe offsets are currently the mount's CAD nominal, X 2.3 / Y 0.86 mm, and X
travel is capped at 210. **The jog test that would confirm those offsets has not
been run** — see [`probe-offset-jog-test.md`](probe-offset-jog-test.md). Until it
has, treat a probe point that will not reach, or Live-Z that drifts between
runs, as an open question rather than a calibration mistake.

## 7. First print

Prime first — see the priming section in the firmware's `GB3DPE_TUNING.md`.
Retraction is mechanical, so set it in the slicer, not in firmware. Send
`M900 K0` to disable linear advance before the first-layer calibration.

## Watch during early runs

- **Thermal-runaway false trip.** The high-mass block may not reach target
  within the 45 s window. If it nuisance-trips, raise
  `TEMP_RUNAWAY_EXTRUDER_TIMEOUT`.
- **Missed-step beeps** at high extrusion rate. E is capped at 5 mm/s by `M203`
  against 1187 steps/mm; back off flow if you hear them.
- **Heater FET warmth.** 70 W is about 2.9 A against the stock 1.7 A. Glance at
  the board FET during a long heat soak.

## Safety

`HEATER_0_MAXTEMP` is 305 °C and classic thermal-runaway protection is active.
Model-based `THERMAL_MODEL` is intentionally off — Prusa's model is fitted to a
40 W E3D and does not describe this hotend. Do not print above ~300 °C: the
printed parts of the toolhead are the limit, not the sensor.

## Rollback

Keep a copy of the stock `MK3S_ENGLISH.hex`, built from upstream `MK3`, so the
printer can be returned to known-good firmware at any time.
