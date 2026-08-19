# TODO

Running bank of open work and unanswered questions for the GB3DPE pellet
system. Items move out of here into commits, issues, or docs as they resolve.

## Hopper CAD — blocking

- [x] **Funnel wall angle is now an explicit parameter**, measured on the
      diagonal corner, with the drop solved from it and capacity falling out.
      Asserted against the selected feedstock's minimum.
- [x] **Both feedstocks are parameterised** — `hopper_feedstock.scad` carries the
      minimum workable funnel angle and the bulk density for virgin pellets and
      for regrind flake.
- [x] **Wall thickness is now honest.** `min_wall` is the least material
      anywhere, measured perpendicular to the surface, compensated on the
      corner. Verified by probing the rendered mesh at the shallowest surface.
- [ ] **Measure the wall friction angle of a printed surface** against both
      feedstocks. The 60°/70° minimums in `hopper_feedstock.scad` are design
      targets taken from general practice, not measurements, and the critical
      mass-flow angle depends on the wall finish as much as the material. Also
      measure the regrind bulk density; 0.35 kg/L is an estimate and it drives
      every capacity figure.
- [ ] **Solve printability on the MK3S** (250 × 210 × 210) — now the binding
      constraint, and it is much tighter than it looked. Holding the corner at
      the target angle makes the imported footprints far too tall to print:

      | Footprint | Body height @60° | @70° |
      | --------- | ---------------- | ---- |
      | 220 × 180 | 296 mm           | 409 mm |
      | 300 × 240 | 392 mm           | 556 mm |
      | 390 × 300 | 501 mm           | 719 mm |

      Against a 210 mm envelope, nothing fits. The largest single-piece hopper
      that does fit holds **1.50 kg of virgin pellets** (184 × 184 mm footprint)
      or **0.47 kg of regrind** (132 × 132 mm) — against a 2.5 kg nameplate that
      was never achievable at a workable wall angle.

      Splitting the body into two stacked segments changes the picture
      completely: **6.31 kg virgin / 2.69 kg regrind** at a 202 × 202 mm
      footprint. Splitting looks close to mandatory rather than optional.
      Set `require_printable = true` once the presets are re-derived, so the
      gate enforces it.
- [ ] **Re-derive the capacity presets** once the split decision is made. The
      preset names are currently footprints (`220x180`), not capacities,
      because capacity now depends on the funnel angle and the feedstock and is
      reported on render rather than promised in the name.
- [ ] **Design the downstream adapter.** Nothing connects the far end of the
      hose to the toolhead. Needs a part that replaces or seats into the vendor
      hopper cap (43.22 × 54.30 × 6.99 mm, two Ø7.2 mm features). Its geometry
      constrains the spigot bore upstream, so it should come before spigot
      tuning.

## Hopper CAD — measurements needed

- [ ] **Measure the GreenBoy3D 1 m conveyor tube ID.** `pipe_id = 25` is a
      guess; the vendor does not publish it.
- [ ] **Measure the Original Prusa Enclosure top panel** — thickness and
      material. `roof_t = 2` assumes thin plastic, but the panel is metal.
- [ ] **Resolve the M4 @ 70 × 70 bolt pattern.** Confirmed *not* inherited from
      GreenBoy3D: the vendor hopper STEP has no M4-sized holes anywhere. It was
      invented with no stated source. Re-derive it from the actual enclosure
      panel, or replace it with a documented pattern.

## Hopper CAD — improvements

- [x] **Bayonet moved to
      [`bayonet-lock-scad`](https://github.com/CameronBrooks11/bayonet-lock-scad).**
      `cad/hopper/hopper_joint.scad` is the whole of it. Pinned by commit
      `85c43ae` (v0.11.0) — the library has no tags. Rationale, the corrected
      mating convention, and the asserts we had to add ourselves are in
      [`docs/design-notes.md`](docs/design-notes.md).

- [x] **Coupling is keyed** so the bin cannot mount crosswise. `key_angle = 15`
      pulls one pin off the even four-pin pattern, giving a single locked
      orientation.
- [ ] **Add anti-rotation to the coupling.** Nothing resists it backing off
      under a hose pull or a knock. The library's built-in detent is
      undocumented and its size is welded to `allowance`, so at our 0.30 it is a
      0.6 mm post — at or below one extrusion width. Treat it as absent. A
      radial M4 thumbscrew or an R-clip through the socket into the neck at the
      locked position is the simplest fix and can be differenced in without
      touching the library geometry.
- [ ] **Watch the pellet bore margin.** At `lock_pin_radius = 3.0` the largest
      bore that clears the pins is exactly 38.0 mm, and ours is exactly 38.0.
      `hopper_joint()` asserts it, so it fails loudly rather than quietly
      slicing the pins, but any increase in pin radius for strength eats the
      margin one for one.
- [ ] Normalise the feedthrough transition stations in `hopper_mount.scad`.
      The imported geometry aligns the two hull sections inconsistently — the
      lower sits on its station, the upper straddles it — so those two hulls
      are written out longhand rather than through `loft()` to keep the
      refactor geometry-exact. Worth half a millimetre of change to tidy, but
      only when something else is already moving that cone.
- [ ] Add a shutoff gate so the feed can be stopped for hose service and
      material changeover.
- [ ] Consider a bridge-breaker or vibrator boss, a sight window, and level
      sensing.
- [ ] Seal and latch the cap — the current slip fit does nothing to keep
      pellets dry.
- [ ] Hand-calculate the flange and wall loading for the largest preset we keep,
      and record the safety factor. 3 mm walls and four M4 bolts currently carry
      up to 10 kg with no analysis behind them.
- [ ] Restructure the SCAD: parameterised modules with `use <>` instead of
      globals consumed through `include <>`, so each file previews standalone.
      Add `assert()`s and an `examples/` directory. Reformat — 443 lines for
      roughly 150 lines of geometry.

## Firmware — `uwo-fast/Prusa-Firmware-GB3DPE`

- [ ] **Re-fork the Prusa firmware repo cleanly** and land our changes as a
      single commit on top of a known upstream tag, instead of the current
      15-commit iteration history on a full upstream clone.
- [ ] **Run the PINDA probe-offset jog test.** The protocol exists
      (`working.tmp/probe-offset-jog-test.md`, untracked) but its record fields
      are blank, so we never settled whether the probe offset was wrong or
      whether X StallGuard homing shifts under the 700 g toolhead. The offsets
      were then set to CAD nominal (X 2.3 / Y 0.86 mm) without that answer.
      Until it runs, we do not know if mesh and Live-Z drift run to run.
- [ ] **Run `M303` and set PID gains for the 70 W cartridge.** Current gains are
      stock values for a 40 W E3D, and `THERMAL_MODEL` is disabled, so
      `TEMP_RUNAWAY` is the only remaining hotend protection.
- [ ] **Reconcile `FANCHECK` and `FILAMENT_SENSOR`** — the docs claim both are
      disabled, the variant headers still enable both. Proposed on a branch for
      review.
- [ ] **Fix stale numbers in `GB3DPE_TUNING.md`** — the slicer section still
      quotes a 12 mm³/s flow ceiling from the abandoned 8000 steps/mm config;
      the landed 1187 steps/mm gives roughly 81 mm³/s. Proposed on the same
      branch.
- [ ] **Rescue `working.tmp/`.** It is caught by `*.tmp` in `.gitignore`, so the
      research corpus, the jog-test protocol and the first-flash checklist exist
      only on one machine. The hardware notes are now in
      [`docs/greenboy3d-extruder.md`](docs/greenboy3d-extruder.md); the
      operational checklists still need a home.

## Admin

- [ ] Add ORCIDs to `CITATION.cff` if the authors have them.
