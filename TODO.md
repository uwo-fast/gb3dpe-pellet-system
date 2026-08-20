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
      tuning. **Needs the vendor STEP files**, which are still only in the local
      untracked scratch directory — see the note under Firmware below.
- [ ] **Revisit the step from outlet to spigot.** The outlet is now 50 mm and
      the spigot bore is still 20.6 mm, so the path more than halves in one
      step. The spigot is a parallel section and 20.6 mm clears the parallel
      rule at 5 mm flake, so this is not urgent — but the step is abrupt, it is
      the narrowest thing in the path, and it is what caps the reported spec at
      exactly 5 mm. Size it against the real hose once measured.

## Hopper CAD — measurements needed

- [ ] **Measure the GreenBoy3D 1 m conveyor tube ID.** `pipe_id = 25` is a
      guess; the vendor does not publish it.
- [ ] **Measure the Original Prusa Enclosure top panel** — thickness and
      material. `roof_t = 2` assumes thin plastic, but the panel is metal.
- [ ] **Resolve the roof bolt pattern.** Confirmed *not* inherited from
      GreenBoy3D: the vendor hopper STEP has no M4-sized holes anywhere. It was
      invented with no stated source, and the coupling resize has since moved it
      — the flange grew 90 → 110 mm and the pattern 70 → 90 mm to stop the
      socket gussets overhanging the edge. So it is now an invented number that
      has also been changed twice. Re-derive it from the actual enclosure panel.

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
      bore that clears the pins is 52.0 mm and ours is 50.0, so there is 2 mm in
      hand — no longer zero, since the coupling resize bought some. Still worth
      remembering that raising pin radius for strength spends it one for one.
      `hopper_joint()` asserts it either way.
- [ ] **Measure the auger inlet port on the toolhead.** Unpublished and
      unmeasured, and it is the true hard minimum of the whole feed path — every
      other opening upstream can be sized freely, this one cannot. If it is well
      under the parallel-flow rule for 5 mm flake then no amount of hopper
      sizing fixes bridging at the head, and that changes the architecture
      rather than a parameter.
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
- [x] **Colours assigned, one per printed part.** `hopper_colours.scad` hands
      out slots bottom-up through the stack so touching parts differ. No part
      module contains a `color()` call at all — parts are coloured only at the
      driver's call sites, so one cannot end up with two colours by
      construction rather than by discipline.
- [x] **`examples/` added** — one file per configuration, driving the modules
      directly rather than through the Customizer, and covered by `just check`
      so they cannot drift from the API they demonstrate.

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
- [ ] **Move the vendor STEP/STL files somewhere durable.** They are still only
      in `working.tmp/greenboy3d/3d-files/`, which is gitignored scratch on one
      machine, and the downstream adapter needs the hopper cap geometry to mate
      against. They should not go in this public repo (unstated licence), so put
      them on lab storage or a private location before that directory is
      cleared.

## Admin

- [ ] Add ORCIDs to `CITATION.cff` if the authors have them.
