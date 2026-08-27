# Interfaces

The hopper is a set of modules joined at three defined interfaces, not a set of
parts. Anything that satisfies an interface can be swapped in, which is what
lets one hopper serve a bare MK3S, an enclosed one, and machines we have never
seen — someone with a different printer makes one small adapter, not a new
hopper.

| Interface      | Between             | Varies with |
| -------------- | ------------------- | ----------- |
| **A — hopper** | body ↔ hub          | never       |
| **B — outlet** | hub ↔ outlet module | the hose    |
| **C — mount**  | hub ↔ machine plate | the machine |

## Why nothing connects to the plate

The obvious layout — a plate carrying the hopper socket above and the outlet
below — cannot be printed. A bayonet socket only accepts from one end, so a
plate with a connection on both faces always has one facing the bed: a recess
facing down is unprintable, and flipping it puts the other connection into the
bed instead. **You can have quick-release on one face of a plate, not both.**
The imported mount had exactly this problem, which is why it printed badly in
every orientation.

So the connections move off the plate and onto a **hub**: a short tube with a
bayonet socket at each end, bolted down to the plate from underneath. The body
twists into the top, the outlet twists into the bottom, and the plate stays a
flat piece of material with holes in it.

| Part       | Prints                                                                                                                                                                     |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **hub**    | standing on its bottom face. A skirt flares out to 85 mm at the bed and tapers _in_ to the 72 mm tube, so there is no overhang anywhere — both sockets are internal bores. |
| **plate**  | flat. A clearance hole, four holes for the hub, and the machine's own pattern. No features on either face, so it can equally be laser-cut, acrylic or plywood.             |
| **outlet** | neck upward. Converges to the hose socket, which sits on the bed.                                                                                                          |

Two things fall out of bolting the hub down rather than clamping it:

- **The hopper stays retained with the outlet removed.** If the outlet were what
  held the stack together, twisting it off to clear a jam would leave 3 kg of
  full hopper loose on the plate.
- **The hub cannot rotate** when the body is twisted into it, so no separate
  anti-rotation feature is needed.

The plate — the only machine-specific part — is then also the simplest and
cheapest thing in the stack to get wrong and reprint, which is the right place
for the uncertainty to sit.

## A — hopper

The existing coupling, unchanged: 58 mm neck in a 72 mm socket, 18 mm deep,
25° quarter turn, keyed. 50 mm pellet bore. Sized by the converging-outlet flow
rule — see [`design-notes.md`](design-notes.md).

## B — outlet

**The same coupling as A**, not a smaller one. That looks wasteful until you
follow the bore: the hose is 20 mm, so the path has to converge from 50 mm to
20 mm _somewhere_, and a converging section is exactly where material arches.
Putting a second, smaller coupling in the hub would move that convergence into
the part that is bolted down. Keeping the coupling identical lets the hub run a
straight 50 mm bore and puts the whole convergence inside the outlet module —
which is the part you can twist off in seconds.

**The jam-prone geometry belongs in the quick-release part.** That is the reason
for the choice, and reusing the coupling also means one interface to verify
instead of two.

Quick-release here is the point: clearing a jam by twisting the outlet off beats
undoing fasteners, and swapping hose types becomes a small reprint.

### As built

| Part   | Size                                                            | Prints                      |
| ------ | --------------------------------------------------------------- | --------------------------- |
| hub    | 95 skirt, 72 tube, 36 tall, straight 50 bore                    | standing on its bottom face |
| plate  | derived (134.6 × 134.6 for the MK3S), Ø65.0 hole, 4 × M4 at Ø79 | flat                        |
| outlet | Ø64 over the pins, 83 tall                                      | standing on the hose socket |

Verified by intersection rather than by eye: every coupling in the stack seats
free and captures at an identical 115.31 mm³ when displaced 3 mm, a bolt passes
cleanly from under the plate through the hub's fixings. The outlet's bore
widens monotonically from the hose end up to the coupling, so in the flow
direction it converges with no ledge.

The hose-into-socket fit was settled on a printed coupon rather than in CGAL,
which is what `cad/coupons/hose_thread_coupon.scad` is for. It had to be: the
check that CGAL passed had been run against a thread cutting a tenth of its
groove, so it was measuring a hose through what was nearly a plain bore.

Three of the four numbers moved once a coupon existed to try. The tube is
21.5 mm, not 21; the pitch is 8.5 mm, not 7.6; and 0.2 mm of clearance is
enough on both the bore and the groove, where 0.4 was assumed. The rib is
3.5 mm as measured, and the thread is right-handed as guessed.

The fourth thing the coupon settled is not a dimension. The groove is a swept
polyhedron, so it starts and ends on a flat cap, and a cap landing inside the
part leaves solid material exactly where the groove should be. The socket swept
from 0.5 mm below its mouth, which blocked 57 degrees of the entry -- the rib
meeting a wall instead of a groove, which is a hose that will not start. The
sweep now runs a full lead past the socket at both ends, as the coupon does.

## C — mount

Ours to define, so it is a documented number rather than an inherited one. A
plate satisfies it with three things:

| Feature                | Size                       | Why                                                                                                   |
| ---------------------- | -------------------------- | ----------------------------------------------------------------------------------------------------- |
| central clearance hole | **Ø65.0**                  | must clear the outlet neck's **pins** at Ø64.0, not the Ø58 neck                                      |
| hub fixings            | 4 × M4 on a **Ø79** circle | outboard of the hub's 72 mm tube, inboard of its 95 mm skirt; through-bolted, nut in a Ø8 counterbore |
| machine pattern        | machine-specific           | the only part that touches reality                                                                    |

Bearing is a non-issue — the hub seats on a 722 mm² annulus, which is 0.04 MPa
at 3 kg against roughly 50 MPa for PETG. Plate _bending_ around a 65 mm hole is
the thing to size for, and plate thickness is a parameter for that reason.

Plates:

- **MK3S frame** (`hopper_plate.scad`, `plate_variant = "mk3s"`) — clamps the printer's own
  370 × 370 mm frame — measured as **6.3 mm steel**, 40.5 mm across the top
  bar. Built; see below.
- **Panel** (`hopper_plate.scad`, `plate_variant = "panel"`) — bolts through a drilled flat sheet,
  for the Original Prusa Enclosure or anything similar. Built. The pattern is
  parametric because the panel is drilled to suit — there is no fixed pattern
  to match. Drill the panel Ø65 for the outlet neck
  and use washers or a backing plate: four M4 heads on thin sheet under a
  sustained few kilograms will dimple it long before anything breaks.
- **Stand** — decouples the load from the printer entirely. Worth having, since
  410 mm of body on a 370 mm frame puts roughly 3 kg at around 800 mm on a
  machine that slings its bed in Y.

### The MK3S plate clamps rather than hooks

Prusa's own spool holder hangs on this frame, so it is the obvious reference.
Scanning its mesh for opposed parallel faces four to nine millimetres apart
finds **none anywhere** — it has no frame slot at all. It is a cantilever hook
that stays seated because the spool's weight holds it down. Fine for a kilogram
of filament; not a pattern to carry three kilograms of pellets. So this one
straddles the frame and pinches it.

**The hopper axis is offset 47 mm from the frame plane, not over it.** The
outlet hangs below the plate and has to pass _beside_ the frame rather than
through it. There are **two** minimums and the second is the one that bites:
the outlet clearing the frame needs 38.6 mm, but the saddle — jaws and fillet
included — is wider than the bar it grips and must also sit clear of the
plate's own clearance hole, which needs 46.8. Both are asserted, and the error
says which one it was. That offset is also why Prusa's holder is an L-arm: the
same constraint produced the same shape.

The saddle's roof carries the vertical load, sitting on the frame's top edge, so
the clamp screws only resist sliding and tipping rather than holding the weight
in friction.

**Stiffness sizes this part, not strength.** A bare flat plate is well inside
yield but deflects half a millimetre at the hub, and with 450 mm of hopper above
that, half a millimetre becomes nearly five at the top — on a machine that
slings its bed in Y. So the saddle spans the **full plate width** rather than a
stub in the middle, and braces turn the flat cantilever into a T-section. Worth
roughly fifteen to twenty times the stiffness for a few grams.

**The plate sizes itself.** Its width follows from the offset, the saddle's own
width and the hub skirt; the saddle follows the plate; the braces follow the
clearance hole and the plate edge; the clamp screws follow the saddle. A margin
is the only handle. That is not tidiness — a plate width and a saddle length set
independently is precisely how the saddle ended up shorter than the braces meant
to sit on it. At the loaded 4.24 kg on a 47 mm offset, the couple across a
30 mm grip is about 65 N.

Verified: the frame clears the plate, hub and outlet; the slot accepts 6.2 and
6.5 mm and rejects 6.8. It prints upside down — plate face on the bed, saddle
legs up, slot opening upward — with nothing overhanging.
