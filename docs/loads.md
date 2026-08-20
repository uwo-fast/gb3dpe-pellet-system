# Load cases

Hand calculations, re-runnable with `python3 scripts/loads.py`. Closed-form
models, not FEA — each chosen to be conservative, with what it ignores stated.

Figures below are the shipping configuration: 202 × 202, two segments, regrind
at 70°, 3 mm minimum wall, mounted on the MK3S frame, at the **measured**
regrind density of 0.489 kg/L — see [`feedstock.md`](feedstock.md).

| Case | Stress | Safety factor |
| ---- | ------ | ------------- |
| Split flange bearing | 0.003 MPa | >1000 |
| **Bin wall bending** | **6.27 MPa** | **4.8 — governs** |
| Clamp jaw bending, 4.24 kg | 2.99 MPa | 10.0 |
| Clamp jaw bending, 6.36 kg | 4.49 MPa | 6.7 |
| Plate cantilever, 4.24 kg | 2.51 MPa | 12.0 |
| Hub annular seat, 4 kg | 0.05 MPa | >500 |

Against **30 MPa**, not PETG's ~50 MPa bulk yield. These parts are printed and
loaded across layers, so the bulk figure flatters them. That 30 is an
assumption and not a measurement.

## What each model assumes

**The split joint is in compression, not tension.** The segments stack, so the
upper one bears on the lower through the flange faces and the bolts resist
prying rather than carrying weight. That is why the number is so small — and
why it would be badly wrong to reason about it as six bolts holding 2.4 kg.

**The bin wall** is treated as a strip spanning the wall's width, simply
supported, under hydrostatic pressure over the full body height. Two things
make that conservative: the wall is supported on four sides rather than two,
and in a real silo Janssen wall friction carries much of the column so lateral
pressure is well below hydrostatic. The real stress is lower than 6.27 MPa; how
much lower is not worth computing until something says it matters.

**The clamp jaw** is a cantilever of the grip depth, taking the couple that the
mount's offset generates. The saddle roof carries the vertical load on the
frame's top edge, so the jaw sees only the overturning couple.

The jaw is 7 mm — thicker than gripping a 6.3 mm bar needs. Its stress goes as
1/thickness², while thickening it pushes the offset out and raises the couple
only linearly, so it wins comfortably: 5 mm gave a safety factor of 5.3 at the
loaded mass, 7 mm gives 10.0.

## The thing safety factors do not cover

**Creep.** These are sustained loads on a thermoplastic, in an enclosure that
runs warm, for months. PETG creeps under constant stress well below its yield,
and a factor of 4.8 against short-term yield says little about that. Measuring
the feedstock rather than assuming it moved this from 6.7 to 4.8, which makes
the point sharper rather than changing it. The bin
wall is the part to watch, and the failure mode is bowing over time rather than
anything sudden.

If bowing shows up, the cheap fixes in order are: raise `min_wall`, print more
perimeters rather than more infill, or add a stiffening rib around the bin at
mid-height. Raising the wall is the least effort and costs capacity slowly.

**Dynamics.** Nothing here covers the MK3S mount case, where roughly 3 kg sits
at around 800 mm on a machine that slings its bed in Y. That is not a strength
question — the frame is 6.3 mm steel and 30 N is nothing to it — but a
resonance one, and it wants watching on fast travel before being trusted.
The `stand` plate variant sidesteps it entirely.

**Impact.** A knock while full is not modelled. The clamp jaw at 6.4 is the
lowest number in that scenario.
