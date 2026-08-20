# Load cases

Hand calculations, re-runnable with `python3 scripts/loads.py`. Closed-form
models, not FEA — each chosen to be conservative, with what it ignores stated.

Figures below are the shipping configuration: 202 × 202, two segments, regrind
at 70°, 3 mm minimum wall, mounted on the MK3S frame.

| Case | Stress | Safety factor |
| ---- | ------ | ------------- |
| Split flange bearing | 0.003 MPa | >1000 |
| **Bin wall bending** | **4.49 MPa** | **6.7 — governs** |
| Clamp jaw bending, 3 kg | 3.53 MPa | 8.5 |
| Clamp jaw bending, 4 kg | 4.71 MPa | 6.4 |
| Plate cantilever, 3 kg | 1.64 MPa | 18.3 |
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
pressure is well below hydrostatic. The real stress is lower than 4.49 MPa; how
much lower is not worth computing until something says it matters.

**The clamp jaw** is a cantilever of the grip depth, taking the couple that the
mount's offset generates. The saddle roof carries the vertical load on the
frame's top edge, so the jaw sees only the overturning couple.

## The thing safety factors do not cover

**Creep.** These are sustained loads on a thermoplastic, in an enclosure that
runs warm, for months. PETG creeps under constant stress well below its yield,
and a factor of 6.7 against short-term yield says little about that. The bin
wall is the part to watch, and the failure mode is bowing over time rather than
anything sudden.

If bowing shows up, the cheap fixes in order are: raise `min_wall`, print more
perimeters rather than more infill, or add a stiffening rib around the bin at
mid-height. Raising the wall is the least effort and costs capacity slowly.

**Dynamics.** Nothing here covers the MK3S mount case, where roughly 3 kg sits
at around 800 mm on a machine that slings its bed in Y. That is not a strength
question — the frame is 6.2 mm aluminium and 30 N is nothing to it — but a
resonance one, and it wants watching on fast travel before being trusted.
The `stand` plate variant sidesteps it entirely.

**Impact.** A knock while full is not modelled. The clamp jaw at 6.4 is the
lowest number in that scenario.
