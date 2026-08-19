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
- [x] **Printability solved.** The body splits into bolted segments, so no part
      exceeds the MK3S envelope. `require_printable` is now on by default, so the
      gate enforces it rather than reporting it.
- [x] **Capacity presets re-derived.** Presets are footprints only; the funnel
      comes from the wall angle and the bin from whatever height the segments
      leave. At 202 x 202 in two segments that is **3.03 kg regrind / 5.38 kg
      virgin** — against a 20-30 g stock cup, roughly 100-200x, or 15-24 hours of
      printing per fill.
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
- [x] **Anti-rotation added.** A self-tapping M4 runs radially through the
      socket wall into a 1.2 mm pocket in the neck at 140°, above the channel
      and clear of the entry slots. Positive lock, not friction. Set
      `lock_retainer_pilot = 0` to omit it.
- [ ] **We are past the bayonet library's exercised range.** Its examples all use
      `interface_radius` <= 15 and its angular corrections are documented as
      empirically tuned for `pin_radius` <= 3.0; we now run 29.15. Verified
      correct by rendering, but the detent's snap-past grew four-fold with the
      radius because it is placed by angle. Re-verify if the coupling grows
      again, and consider feeding a fix back upstream.
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
- [ ] Hand-calculate the loading and record a safety factor. Now covers three
      things with no analysis behind them: the roof flange and its four M4s, the
      wall under a 3 kg column, and the split joint's six M4s carrying the whole
      upper segment plus its contents.
- [ ] Choose and specify a gasket for the split joint. The flanges are flat and
      bolted at six points; nothing is specified to seal flake dust between them.
- [x] **Restructure the SCAD.** Parameterised modules under `use <>` instead of
      globals through `include <>`, one concern per file, each previewing
      standalone, with asserts throughout.
- [ ] Add an `examples/` directory — the one part of the restructure not done.
      House convention is one file per configuration, `use <>`-ing the library.

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
- [x] **Rescued `working.tmp/`.** The hardware notes are in
      [`docs/greenboy3d-extruder.md`](docs/greenboy3d-extruder.md) and the two
      operational procedures are in [`docs/operations/`](docs/operations/),
      with their stale numbers corrected to the landed config. Deliberately not
      brought over: GreenBoy3D's own STL/STEP files, whose licence is unstated
      and which ship with the kit, and a shallow clone of an unrelated fork.

## Admin

- [ ] Add ORCIDs to `CITATION.cff` if the authors have them.
