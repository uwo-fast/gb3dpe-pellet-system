# Printing and assembly

The shipping configuration: 202 × 202, two segments, regrind at 70°, mounted on
the MK3S frame. `just render` writes every part; `just coupon` writes the flow
test piece.

## Print the coupon first

`just coupon` for the funnel and `just coupon-stand` for the stand it sits in.
They print separately: the funnel then has nothing hanging off it, and one stand
is reusable across every angle you want to compare (`just coupon 60` for the
shallower one).

**Print both inverted** — flange down for the funnel, ring down for the stand.
Everything slopes inward that way and nothing overhangs, and each part lands its
widest face on the bed.

The stand's legs splay outward toward their feet, so it has no bottom ring:
in this orientation the carrying ring is the one on the bed, so a second ring at
the far end does nothing for adhesion, and four splayed legs on a 170 mm ring
already tip at about 34° under a coupon weighing well under a kilogram. Its
legs are solid blocks rather than shells, so infill does most of the work —
roughly 90 g rather than the 310 g its solid volume suggests.

**Print them on the machine and in the material that will print the hopper**, at
the same layer height. The surface finish is the experiment: a coupon printed
some other way answers a question nobody asked.

Roughly 210 g of feedstock and a couple of hours on the bed.
It is the real angle, throat, wall and corner radii, so it presents the surface
the hopper will. Fill it and watch whether it empties completely and whether
material moves across the whole wall rather than draining a channel down the
middle. That question is worth answering before committing two twenty-hour
prints. See [`loads.md`](loads.md) and [`design-notes.md`](design-notes.md) for
why the wall angle is the assumption most worth testing.

## Parts

| Part | Qty | Size (mm) | PETG | Orientation |
| ---- | --- | --------- | ---- | ----------- |
| body segment 0 | 1 | 173 × 173 × 205 | ~0.37 kg | **flip** — flange down |
| body segment 1 | 1 | 202 × 202 × 205 | ~0.66 kg | as modelled |
| cap | 1 | 209 × 209 × 19 | ~0.22 kg | **flip** — top face down |
| hub | 1 | 95 × 95 × 36 | ~0.08 kg | as modelled |
| plate (MK3S) | 1 | 130 × 130 × 42 | ~0.16 kg | **flip** — plate face down |
| outlet | 1 | 59 × 61 × 83 | ~0.06 kg | as modelled |

About 1.5 kg of PETG all told. Segment 1 at 202 × 202 leaves 4 mm either side
on an MK3S bed, and the cap at 209 leaves half a millimetre — check first layer
placement rather than trusting it.

### Why those orientations

Measured, not guessed: downward-facing flat area above the bed, per part.

- **Segment 0** has 8 280 mm² of it — the split flange's underside, which is a
  12 mm horizontal ledge all the way round. Flipped, that lands on the bed and
  everything else slopes inward.
- **The cap** has 41 225 mm² — the whole cavity ceiling. Printed as modelled it
  would be one enormous unsupported span.
- **The MK3S plate** has 10 229 mm², mostly the plate underside outside the
  saddle's footprint. Flipped, the plate is on the bed and the saddle legs point
  up with the slot opening upward.
- **Segment 1 has none at all**, and the hub 67 mm². Both print as modelled.
- **The outlet** has about 1 000 mm², a narrow annulus where the cone meets the
  neck. Small enough to bridge; watch it on the first one.

## Settings

Print in the material and layer height you intend to keep — for the coupon that
is the point, since layer lines are the wall texture being tested.

Perimeters matter more than infill here. Everything structural in
[`loads.md`](loads.md) is bending in a thin wall, so shell thickness is what
carries it; the bin wall governs at a safety factor of 6.7 and creep is the
thing that factor does not cover. Four perimeters is a better spend than more
infill.

## Hardware

| Where | Fastener | Notes |
| ----- | -------- | ----- |
| hub → plate | 4 × M4 × 20 + nuts | straight through both; the nut seats in the hub's counterbore, which spotfaces the skirt's cone flat |
| split joint | 6 × M4 × 20 + nuts | plus 2 × Ø4 dowels, which locate while the bolts clamp |
| split joint seal | closed-cell foam tape, ~2 mm × 10 mm | one face only, inside the bolt circle |
| MK3S clamp | 2 × M4 grub | pinch the frame; the saddle roof carries the weight |
| panel variant | 4 × M4 + washers | **washers or a backing plate**, not bare heads on sheet |

### The split joint seal

Closed-cell foam tape — EPDM or neoprene, around 2 mm thick and 10 mm wide —
run round one flange face inside the bolt circle. Deliberately a consumable
rather than a groove and an O-ring: what leaks here is flake dust rather than
liquid, printed flanges are never flat enough to seal metal-to-metal anyway,
and foam takes up that error where a hard seal would need the flatness it
cannot get. It also costs no geometry, so nothing has to be reprinted to
change it.

Compress it with the bolts, not beyond about half its thickness. The dowels set
the alignment, so the tape is not being asked to hold anything in place.

## Assembly order

1. Bolt the **hub** down to the **plate**: bolts up from under the plate, nuts
   into the hub's counterbores. There is 4 mm of flange under each seat.
2. Mount the plate: MK3S clamp over the frame's top edge and pinch, or bolt
   through the drilled panel. Panel hole is **Ø65**.
3. Twist the **outlet** up into the hub's lower socket.
4. Screw the **hose** into the outlet — it threads, the reinforcing rib is the
   thread. Handedness is unconfirmed; if it will not start, flip
   `hose_handedness` and reprint the outlet.
5. Bolt the two **body segments** together, dowels first.
6. Turn the body back by the sweep angle, drop it into the hub, and turn it
   forward to seat.
7. **Cap** on last.

Steps 3 and 6 are quarter-turns by hand. That is the point of the couplings:
clearing a jam is twisting the outlet off, not undoing the assembly.
