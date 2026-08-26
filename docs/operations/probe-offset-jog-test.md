# PINDA Probe-Offset Jog Test

Purpose: measure the **true** X/Y offset from the nozzle tip to the PINDA
centre, independent of homing — because a graph-paper measure of 20.4 / 8.6
disagreed with what XYZ calibration showed (PINDA landing ~20 mm right and
~10 mm forward of the target circle). This test settles two questions at once:

- **Is the configured probe offset wrong?**
- **Or is X home shifting?** (heavy toolhead tripping StallGuard off-position)

> **Still outstanding.** The record fields at the bottom are blank. The shipped
> offsets were subsequently set to the mount's CAD nominal, X 2.3 / Y 0.86 mm,
> without this test resolving which of the two causes was real. Until it runs we
> do not know whether mesh and Live-Z drift between runs.

## Why it works

The firmware places the nozzle, and the PINDA rides at a fixed offset from it.
If we put the **nozzle** over a fixed bed mark, then the **PINDA** over the
_same_ mark, the difference in machine coordinates between those two positions
**is** the physical offset — no homing accuracy required.

## What you need

- Steel sheet on the bed.
- A small, precise reference mark near the **center** of the bed (e.g. a fine
  cross on tape at roughly bed X125 / Y105). Center avoids the travel limits so
  nothing clamps during the jog.
- A way to read live machine coordinates: `M114` over serial/terminal, or the
  LCD position readout.

## Procedure

1. **Home** the printer (`G28`) and raise Z a few mm for clearance.
2. Jog X/Y until the **nozzle tip** is dead-center over the mark. Lower Z close
   to confirm alignment by eye.
3. Record the machine position — send `M114`, note **N = (Nx, Ny)**.
4. Raise Z, then jog until the **PINDA center** is dead over the _same_ mark.
5. Record the machine position — `M114`, note **P = (Px, Py)**.

## Compute the true offset

```
X_offset_true = Nx - Px
Y_offset_true = Ny - Py
```

Sign check (Prusa convention: X "-left +right", Y "-front +behind"):

- PINDA is right of nozzle -> Px < Nx -> X_offset_true positive. Good.
- PINDA is behind the nozzle -> Py > Ny... use the formula as written and keep
  the sign; the config field uses the same convention.

## Interpret

| Result                      | Meaning                                                      | Next step                                                                                                            |
| --------------------------- | ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| ~40 / ~-1.4                 | Config offset is wrong (graph paper under-measured X ~20 mm) | Set `X/Y_PROBE_OFFSET_FROM_EXTRUDER` to the measured values; then D10 + mesh over the reachable (right-shifted) area |
| ~20 / ~8.6 (matches config) | Offset is fine; **X home is shifting ~20 mm**                | Investigate X StallGuard homing (toolhead mass) — offset is not the problem                                          |
| something else              | Measure again / re-check the mark alignment                  | Report the numbers                                                                                                   |

## Record here

- N (nozzle over mark): Nx = `______` Ny = `______`
- P (PINDA over mark): Px = `______` Py = `______`
- X_offset_true = Nx - Px = `______`
- Y_offset_true = Ny - Py = `______`

## Reminders

- **Do NOT run "Calibrate XYZ"** — the 4-point cal can't complete on this
  toolhead (X travel too short to span the calibration circles). Use **D10**
  to mark XYZ OK, then Calibrate Z -> Live-Z -> `G80`.
- Measure at a **central** mark so no axis clamps during the jog.
