# Interfaces

The hopper is a set of modules joined at three defined interfaces, not a set of
parts. Anything that satisfies an interface can be swapped in, which is what
lets one hopper serve a bare MK3S, an enclosed one, and machines we have never
seen — someone with a different printer makes one small adapter, not a new
hopper.

| Interface | Between | Varies with |
| --------- | ------- | ----------- |
| **A — hopper** | body ↔ hub | never |
| **B — outlet** | hub ↔ outlet module | the hose |
| **C — mount** | hub ↔ machine plate | the machine |

## Why the mount is a bulkhead, not a flange

The obvious layout — a plate carrying the hopper socket above and the outlet
below — cannot be printed. A bayonet socket only accepts from one end, so a
plate with a connection on both faces always has one facing the bed: a recess
facing down is unprintable, and flipping it puts the other connection into the
bed instead. **You can have quick-release on one face of a plate, not both.**
The imported mount had exactly this problem, which is why it printed badly in
every orientation.

So no connection lives on the plate. The hub is a plain vertical tube that
passes *through* the plate and is clamped by a collar underneath, the way a
bulkhead tank fitting works. Every part then prints in its natural orientation
with no support:

| Part | Prints |
| ---- | ------ |
| **hub** | standing on its bottom face. Body socket at the top, shoulder mid-height, plain barrel below it, outlet socket at the bottom. No flange, so nothing overhangs — the shoulder is chamfered. |
| **plate** | flat. One hole, one machine bolt pattern, no features on either face. Could as easily be laser-cut, acrylic or plywood as printed. |
| **collar** | flat. Goes on under the plate and clamps the hub down. |
| **outlet** | bayonets into the hub's bottom. |

It also means the plate — the only machine-specific part — is the simplest and
cheapest thing in the stack to get wrong and reprint, which is the right place
for the uncertainty to sit.

## A — hopper

The existing coupling, unchanged: 58 mm neck in a 72 mm socket, 18 mm deep,
25° quarter turn, keyed. 50 mm pellet bore. Sized by the converging-outlet flow
rule — see [`design-notes.md`](design-notes.md).

## B — outlet

A second bayonet on the same library, sized from the hose rather than from the
hopper. **Bore 24 mm**, giving neck 30 mm in a socket 39.3 mm at `pin_radius`
3.0. The hose is 20 mm ID and the toolhead's own feed bore caps the system at
4.58 mm regardless, so 24 mm carries headroom without bulking out the outlet.

Quick-release here is the point: clearing a jam by twisting the outlet off beats
undoing fasteners, and swapping hose types becomes a small reprint.

## C — mount

Ours to define, so it is a documented number rather than an inherited one. The
hub's barrel and shoulder plus the collar thread are the whole interface; a
plate satisfies it by having the right hole and clearance for the collar.

Planned plates:

- **MK3S frame** — grips the 370 × 370 × 6.2 mm aluminium plate, the way the
  spool holder does. First, because that is the machine as it stands and it is
  what most people have.
- **Enclosure panel** — flat, bolts through the drilled top sheet. Needed within
  about a month.
- **Stand** — decouples the load from the printer entirely. Worth having, since
  410 mm of body on a 370 mm frame puts roughly 3 kg at around 800 mm on a
  machine that slings its bed in Y.
