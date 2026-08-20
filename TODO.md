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
- [ ] **Run the flow coupon.** `just coupon` exports it; `just coupon 60`
      exports the shallower one for comparison. Print in the hopper's material
      and layer height — the layer lines are the wall texture being tested —
      fill it, and watch whether the funnel empties completely and whether
      material moves across the whole surface rather than draining a channel
      down the middle. Two hours on the bed against two twenty-hour segments.
- [ ] **Measure the wall friction angle of a printed surface** against both
      feedstocks. The 60°/70° minimums in `hopper_feedstock.scad` are design
      targets taken from general practice, not measurements, and the critical
      mass-flow angle depends on the wall finish as much as the material. Also
      measure the regrind bulk density; **0.35 kg/L is a retained assumption**,
      not a measurement, and it drives every capacity figure in the repo
      including the 3.03 kg headline. Weigh a known volume when convenient.
- [x] **Printability solved.** The body splits into bolted segments, so no part
      exceeds the MK3S envelope. `require_printable` is now on by default, so the
      gate enforces it rather than reporting it.
- [x] **Capacity presets re-derived.** Presets are footprints only; the funnel
      comes from the wall angle and the bin from whatever height the segments
      leave. At 202 x 202 in two segments that is **3.03 kg regrind / 5.38 kg
      virgin** — against a 20-30 g stock cup, roughly 100-200x, or 15-24 hours of
      printing per fill.
- [ ] **Get the CURRENT vendor hopper CAD.** The installed part has a square
      pellet opening *and* a circular port the spiral hose threads into. The
      hopper in our July scrape has neither — zero circular features in its
      STEP — so the vendor has revised it. If the current one already carries a
      hose port, most of the downstream adapter below is already solved. The
      vendor wiki is a JS app that cannot be fetched, so this needs pulling by
      hand.
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

- [ ] **Register the real conveyor tube dimensions and redesign the spigot.**
      Reported from the bench, not yet committed to the geometry: **ID 20, OD 21
      over the tube, 25 over a 2 mm-radius helix at 8 mm pitch** — a standard
      spiral-reinforced suction hose, DN20. The hose is a bought-in part so it
      is not in the vendor CAD; only a port that accepts it would be.

      Feeding ID 20 into the current design fails its own assert:
      `spigot_id (20.6) must be < spigot_od (19.6)`. Both spigot numbers are
      wrong, not just `pipe_id`, because `spigot_od` was derived from the bad
      `pipe_id`.

      Do **not** simply shrink them. A push-in spigot at 2 mm wall gives a
      15.6 mm bore = 3.9 mm max flake, which would become the tightest section
      in the whole path — tighter than the vendor's own 18.30 mm feed bore. A
      **thread-in socket** keeps the full 20 mm bore (5.0 mm max flake) and
      matches how the vendor already connects it: the helix is the thread.
- [x] **Mount split into a hub, a plate and an outlet.** `hopper_mount.scad` is
      retired. See [`docs/interfaces.md`](docs/interfaces.md).
- [x] **MK3S frame plate built.** Clamps rather than hooks — Prusa's spool
      holder turns out to have no frame slot at all, so it is a cantilever hook
      and not a pattern to carry 3 kg. Hopper axis offset 40 mm so the outlet
      passes beside the frame.
- [ ] **Confirm the frame thickness with calipers.** 6.2 mm is documented and
      the slot is cut at 6.6, which accepts 6.2–6.5 and rejects 6.8. If the real
      frame is at the top of that band the fit will be tight; `frame_clearance`
      is the knob.
- [ ] **Build the enclosure panel plate.** The universal plate already is one
      bar the hole pattern, which is blocked on measuring the panel.
- [ ] **Decide whether the bare-MK3S mount is actually wise.** It works, but it
      puts ~3 kg at roughly 800 mm on a machine that slings its bed in Y. The
      `stand` variant would decouple that entirely and is not much work now the
      interface exists.
- [ ] ~~Split the mount into a feed head plus a swappable adapter~~ — superseded: It has to
      work on a bare MK3S *and* on the Original Prusa Enclosure (which means
      drilling its top sheet). One part cannot do both, and `hopper_mount()`
      currently does five jobs at once.

      - **Feed head, invariant**: bayonet socket, gussets, feedthrough, hose
        socket. Identical in every installation.
      - **Mounting adapter, swappable**: bolts to the feed head on a pattern we
        define, and presents the target interface — `panel` (flat, bolts
        through the drilled enclosure sheet), `frame` (grips the MK3S's
        370 x 370 x 6.2 mm aluminium plate, the way the spool holder does), or
        `stand` (separate bench stand).

      This also settles the roof bolt-pattern item below: the feed-head-to-
      adapter pattern becomes ours to define and document, and only the
      adapter's outer face has to match anything real — which is the cheap part
      to reprint once a measurement lands.

- [ ] **Check what 3 kg on top does to the bare-MK3S case.** The body is 410 mm
      on a 370 mm frame, so roughly 800 mm overall with the mass at the top, on
      a machine that slings its bed in Y. The frame is stiff enough (6.2 mm
      aluminium, already carries a spool holder) but this is several times a
      full spool and much higher up. Worth watching frame resonance on fast
      moves before trusting it. The enclosure case puts the load on the
      enclosure instead, and the `stand` adapter decouples it entirely.

- [ ] **Establish the enclosure's actual construction.** Prusa says the frame
      and the top and bottom panels are metal with PETG sides, but whether that
      frame is folded sheet or profile is not something public sources settle,
      and an earlier claim here that it was 3030 extrusion was wrong — that came
      from a result about the MK3S's own Y-axis frame. Needs looking at rather
      than searching.
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
- [x] **Auger feed bore resolved from the vendor CAD: Ø18.30 mm**, on the
      extruder axis, identical in both sliding-pit parts. Now in the flow path,
      so the spec reports the true system ceiling — 6.1 mm virgin, 4.6 mm
      regrind — rather than only what our own parts manage. Worth a 30-second
      caliper check on the hole under the vendor hopper to confirm.
- [ ] Add a shutoff gate so the feed can be stopped for hose service and
      material changeover.
- [ ] Consider a bridge-breaker or vibrator boss, a sight window, and level
      sensing.
- [ ] Seal and latch the cap — the current slip fit does nothing to keep
      pellets dry.
- [x] **Load cases calculated** — [`docs/loads.md`](docs/loads.md), re-runnable
      via `scripts/loads.py`. The bin wall governs at SF 6.7 against 30 MPa;
      everything else is an order of magnitude clear. Note the split joint is in
      compression, not tension — the segments stack.
- [ ] **Watch the bin wall for creep.** Safety factors are against short-term
      yield and say little about a sustained load on a thermoplastic in a warm
      enclosure over months. Failure mode would be slow bowing, not a break.
      Cheapest fixes in order: raise `min_wall`, more perimeters, or a
      stiffening rib at mid-height.
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

- [ ] Confirm the hose's handedness and, if it is left-hand, flip
      `hose_handedness` and reprint the outlet.

## Admin

- [ ] Add ORCIDs to `CITATION.cff` if the authors have them.
