# Review of the imported hopper design

Review of `cad/hopper/` as imported in commit `f59360a`, before any changes.
Numbers below are measured from the imported source and from STLs rendered off
it, not estimated. Actions are tracked in [`TODO.md`](../TODO.md).

## Summary

The imported design is a sound starting point, not a throwaway. It compiles
clean in OpenSCAD across all three parts and all three capacity presets, the
Customizer parameterisation is well organised, the bayonet clearances are
internally consistent, and the capacity labels are honest. The problems are in
the physics of pellet flow, in printability, and in unverified interfaces —
not in the code working.

## What holds up

**Capacity labels are accurate.** Computing internal volume from the imported
parameters and taking 0.62 kg/L for virgin PLA pellets:

| Preset | Bin volume | Funnel volume | Total   | Mass at 0.62 kg/L |
| ------ | ---------- | ------------- | ------- | ----------------- |
| 2.5 kg | 2.79 L     | 1.23 L        | 4.02 L  | 2.49 kg           |
| 5 kg   | 5.85 L     | 2.67 L        | 8.52 L  | 5.28 kg           |
| 10 kg  | 11.29 L    | 4.66 L        | 15.95 L | 9.89 kg           |

Note these hold for virgin pellets. Shredded regrind runs nearer 0.3–0.5 kg/L,
so the same box holds roughly half the labelled mass.

**It builds.** `just check` renders all nine part/size combinations with
`--hardwarnings` and zero output.

## Blocking issues

### 1. Funnel walls are far too shallow for pellets

Wall angle measured from horizontal, derived from the imported parameters:

| Preset | X face | Y face | **Diagonal corner** |
| ------ | ------ | ------ | ------------------- |
| 2.5 kg | 42.3°  | 49.6°  | **35.7°**           |
| 5 kg   | 38.0°  | 45.6°  | **31.8°**           |
| 10 kg  | 32.4°  | 40.7°  | **27.1°**           |

Target is >=60° from horizontal for virgin pellets and >=70° for shredded
regrind. Every preset is below that on every measure.

**The corner is the number that matters, and it is much worse than the faces.**
On a rectangular-to-square funnel the diagonal corner runs out further than
either face over the same drop, so it is always the shallowest surface in the
part. At 27.1° the 10 kg corner is closer to a shelf than a chute. Pellets
bridge and rathole at the shallowest surface, not the average one, so the
design target has to be set on the corner and the faces allowed to fall out
steeper — not the other way round.

A second consequence: a rectangular bin **cannot** have equal X and Y wall
angles for a given drop, because the two runs differ. Fixing the drop from the
X face at 65° puts the Y face at 70.2° and the corner at 59.5°. Any parameter
scheme that lets the user set "the" wall angle has to say which surface it
means, and the honest choice is the corner.

Regrind — irregular, high friction, low bulk density — is worse than virgin
pellets on all of this.

The square-to-round transition compounds it. Internal corner radius is
`funnel_radius - wall`, floored at 0.8 mm, so the funnel has near-sharp
internal corners, which is exactly where a bridge anchors.

Wall angle is currently an emergent consequence of `top_x`, `top_y`, `throat`
and `funnel_h`. It should become an explicit input with the drop solved around
it, so the geometry cannot silently violate the target.

### 2. Two of the three presets cannot be printed

Bounding boxes measured from rendered STLs, against the MK3S envelope of
250 × 210 × 210 mm:

| Part        | 2.5 kg          | 5 kg            | 10 kg           |
| ----------- | --------------- | --------------- | --------------- |
| body        | 220 × 180 × 183 | 300 × 240 × 213 | 390 × 300 × 238 |
| cap         | 227 × 187 × 19  | 307 × 247 × 19  | 397 × 307 × 19  |
| mount       | 90 × 90 × 85    | 90 × 90 × 85    | 90 × 90 × 85    |

Only the 2.5 kg body and cap fit, and the body is a multi-day print at that.
The 5 kg and 10 kg presets are unbuildable on the printer they are meant to
feed, and the design has no split-and-join option. The mount fits at every
size but has features on both faces, so one end needs support whichever way up
it goes.

### 3. Interface dimensions are unverified assumptions

- `pipe_id = 25` — the GreenBoy3D conveyor tube ID is not published anywhere.
  Needs measuring off the actual tube.
- `spigot_id = 20.6` — necks the 38 mm throat down to 20.6 mm, making the
  spigot the narrowest point in the whole path and a second bridging site,
  downstream of the one that is already too shallow.
- `roof_t = 2` — the Original Prusa Enclosure has a **metal** top panel, not
  2 mm plastic. Good news structurally, but the number is wrong until measured.
- **M4 at 70 × 70 has no source.** The vendor hopper STEP contains no M4-sized
  holes at all, so this was not inherited from GreenBoy3D. It needs deriving
  from the actual enclosure panel or replacing with a documented pattern.

### 4. The feed path is missing its downstream half

The mount terminates in a hose spigot pointing down. Nothing in the design
connects the far end of that hose to the toolhead. The vendor hopper is a
43 × 40 × 45 mm cup with a separate cap, and feeding it from a bulk hopper
needs an adapter that either replaces that cap or seats into it. That part
does not exist yet, and its geometry constrains the spigot bore upstream.

## Non-blocking issues

### Bayonet duplicates an existing library

`hopper_body.scad` and `hopper_mount.scad` hand-roll a four-tab bayonet.
[`bayonet-lock-scad`](https://github.com/CameronBrooks11/bayonet-lock-scad)
already does this parametrically, with configurable pin count, keying,
direction and allowance, plus examples and a changelog. The hand-rolled version
is geometrically valid but has **no detent or anti-rotation feature** — nothing
resists the quarter-turn backing off under vibration, with up to 10 kg of
pellets hanging on it.

### The coupling has four identical locked positions

Four evenly spaced tabs give the joint fourfold rotational symmetry, so it
seats just as happily at 0, 90, 180 and 270 degrees. The bin hanging off it is
rectangular — 390 x 300 mm at the largest preset — so half those positions
mount it crosswise on the roof, and nothing in the geometry resists or even
signals it. A keyed pattern with one uneven gap fixes it.

### No operational features

No shutoff gate, so the feed cannot be stopped to service the hose or change
material — and material changeover is a routine operation on a pellet machine.
No bridge-breaker or vibrator boss, no sight window, no level sensing. The cap
is a plain slip box at 0.6 mm clearance with no seal or latch, which does
nothing to keep pellets dry.

### The funnel wall is thinner than the `wall` parameter says

`wall = 3` is applied as a *horizontal* offset: the inner funnel runs from
`throat - 2*wall` to `top_x - 2*wall` over the same Z span as the outer. On a
sloped face the thickness measured perpendicular to the surface is
`wall * sin(theta)`, so the funnel is nowhere near 3 mm:

| Preset | X wall (true) | Y wall (true) |
| ------ | ------------- | ------------- |
| 2.5 kg | 2.02 mm       | 2.29 mm       |
| 5 kg   | 1.85 mm       | 2.14 mm       |
| 10 kg  | **1.61 mm**   | 1.96 mm       |

At 1.61 mm the 10 kg funnel is close to three perimeters at 0.45 mm line width,
on the part carrying the most load. The near-vertical sections keep their 3 mm,
so the shell is thinnest exactly where the pellet column bears on it.

Steepening the funnel for flow also fixes this: at 60 deg the true wall is
2.60 mm and at 70 deg it is 2.82 mm. The two problems have the same cure, which
is a good reason to treat wall angle as the primary input.

### Structure is unverified

3 mm walls on a 390 mm span holding 10 kg, hanging off a 90 × 90 × 8 mm flange
on four M4 bolts, with no backing plate and no load spreading into the panel.
No hand calculation or stated safety factor exists for any of it.

### Code structure

`pellet_hopper.scad` declares every global, then `include`s `hopper_body.scad`
and `hopper_mount.scad`, which silently consume those globals. Neither
sub-file can be opened, previewed or tested on its own, and the include order
is load-bearing. There are no module parameters, no `assert()` on derived
geometry, and no examples. Formatting runs one argument per line with blank
lines throughout — 443 lines for roughly 150 lines of geometry, which diffs
badly and hides real changes.
