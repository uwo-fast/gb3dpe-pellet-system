# Feedstock

Bulk density and particle size are properties of the **shred**, not of the
polymer — they depend on the shredder, its screen, and how the material settles.
So they travel with the machine and the material together, and are worth
recording rather than looked up.

## Regrind — measured

| | |
| --- | --- |
| Material | Polymaker PolyLite PLA, black |
| Form | shredded in-house, sieved to 3 mm |
| Method | gently settled in a beaker to the 700 mL line |
| Mass | 342 g |
| **Bulk density** | **0.489 kg/L** |

That is 40% denser than the 0.35 kg/L previously assumed from general practice,
and it moves two numbers that matter:

- **Capacity up.** The 202 × 202 two-segment hopper holds **4.24 kg**, not 3.03.
- **Wall stress up.** Pressure scales with density, so the bin wall goes from
  4.49 MPa to 6.27 MPa — safety factor 6.7 down to **4.8**. Still sound, but it
  is now the number to watch, and creep is what a safety factor does not cover.
  See [`loads.md`](loads.md).

Settling matters: gently settled is the right basis here, because a hopper's
contents settle under their own weight. Poured loose would read lower and
under-predict both capacity and wall load.

## What is still assumed

The **60°/70° wall angles** remain design targets from general bulk-solids
practice, not measurements. The critical mass-flow angle depends on the wall
friction of the surface material slides on, and a printed wall is nothing like
the steel those figures assume. The flow coupon exists to answer that — see
[`printing.md`](printing.md).

**Virgin pellet density** is still the general-practice 0.62 kg/L. Worth
measuring the same way if virgin ever becomes the main feedstock.

## Why record the polymer at all

Bulk density and flow behaviour differ between polymers, between grades, and
between shredder settings. Recording what was measured, on what, and how means
a future comparison — PETG against PLA, a finer screen, a different shredder —
has something to compare against rather than starting over.
