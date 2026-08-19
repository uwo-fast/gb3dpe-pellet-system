# TODO

Running bank of open work and unanswered questions for the GB3DPE pellet
system. Items move out of here into commits, issues, or docs as they resolve.

## Hopper CAD — blocking

- [ ] **Make funnel wall angle an explicit parameter** and solve capacity around
      it, rather than letting it fall out of `top_x`/`top_y`/`throat`/`funnel_h`.
      Target ≥60° from horizontal for virgin pellets, ≥70° for regrind, and
      **measure it on the diagonal corner, not the faces** — the corner is
      always the shallowest surface on a rectangular funnel and is what
      actually bridges. Imported presets sit at 27–36° on the corner against
      32–50° on the faces. Add an `assert()` so the geometry cannot silently
      violate the target.
- [ ] **Parameterise for both feedstocks.** We run virgin pellets *and* shredded
      regrind. Regrind wants the steeper angle and has roughly half the bulk
      density, so the capacity presets need a feedstock input rather than one
      hardcoded density assumption.
- [ ] **Solve printability on the MK3S** (250 × 210 × 210). Only the 2.5 kg body
      and cap fit today; 5 kg and 10 kg do not. Either split the body into
      bolted/bonded segments or drop the presets we cannot build. The MK3S is
      the largest printer we have for the foreseeable future.
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

- [ ] Replace the hand-rolled bayonet with
      [`bayonet-lock-scad`](https://github.com/CameronBrooks11/bayonet-lock-scad),
      which is already parametric and keyable. The current one has no detent or
      anti-rotation feature holding the quarter turn against vibration.
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

- [ ] Add the co-op student to `CITATION.cff` and the README credits — needs
      their full name and, if they have one, an ORCID.
