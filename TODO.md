# TODO

Open work for the GB3DPE pellet system. Finished work is **not** kept here — it
lands in commits, [`CHANGELOG.md`](CHANGELOG.md) and the docs, which is where to
look for what has been settled and why. An item leaves this file when it is
done, not when it is ticked.

## On the bench

Nothing here can be settled at the keyboard.

- [ ] **Run the flow coupon.** `just coupon` exports it, `just coupon 60` the
      shallower one to compare against. Print it in the hopper's own material and
      layer height — the layer lines are the wall texture being tested — then
      fill it and watch three things: whether it starts without a tap, whether it
      empties completely, and whether the whole surface moves or it drains a
      channel down the middle and leaves the rest standing. That last one is
      ratholing, and it is the failure that matters. Two hours on the bed against
      two twenty-hour segments.

- [ ] **Measure the wall friction angle of a printed surface** against both
      feedstocks. The 60°/70° minimums in `hopper_specs.scad` are design targets
      from general practice, not measurements, and the critical mass-flow angle
      depends on the wall finish as much as on the material. Bulk density is the
      settled half of this — regrind is measured at 0.489 kg/L, see
      [`docs/feedstock.md`](docs/feedstock.md); virgin is still general-practice
      0.62 and worth measuring the same way if it becomes the main feedstock.

- [ ] **Caliper the toolhead's feed bore.** Ø18.30 mm was taken off the vendor
      STEP rather than measured. It is the narrowest section in the whole path,
      so it — not anything we draw — is what caps the system: the spec echo
      reports 4.575 mm against the 5 mm the build is otherwise sized for. A
      30-second check on the hole under the vendor hopper confirms it.

- [ ] **Decide whether the bare-MK3S mount is wise, and test it before trusting
      it.** It works, but it puts ~3 kg at roughly 800 mm — a 410 mm body on a
      370 mm frame — on a machine that slings its bed in Y. That is several times
      a full spool and much higher up, so watch frame resonance on fast moves
      before running it loaded. Two ways out if it misbehaves: the `panel`
      variant puts the load on the enclosure instead, and a `stand` variant would
      decouple it from the printer entirely and is not much work now that the
      mount interface exists.

- [ ] **Establish the enclosure's actual construction.** Prusa says the frame and
      the top and bottom panels are metal with PETG sides, but whether that frame
      is folded sheet or profile is not something public sources settle — and an
      earlier claim here that it was 3030 extrusion was wrong, having come from a
      result about the MK3S's own Y-axis frame. Needs looking at rather than
      searching.

## Blocked on the vendor

- [ ] **Get the CURRENT vendor hopper CAD.** The installed part has a square
      pellet opening *and* a circular port the spiral hose threads into. The
      hopper in our July scrape has neither — zero circular features in its STEP
      — so the vendor has revised it. If the current one already carries a hose
      port, most of the downstream adapter below is already solved. The vendor
      wiki is a JS app that cannot be fetched, so this needs pulling by hand.

- [ ] **Design the downstream adapter.** Nothing connects the far end of the hose
      to the toolhead. Needs a part that replaces or seats into the vendor hopper
      cap (43.22 × 54.30 × 6.99 mm, two Ø7.2 mm features). Blocked on the vendor
      STEP files below, and on the item above — a revised vendor hopper may
      already solve most of it.

- [ ] **Put the vendor STEP/STL files somewhere durable.** They were only ever in
      `working.tmp/greenboy3d/3d-files/`, untracked scratch on one machine, and
      that directory is not present in this checkout. The downstream adapter
      needs the hopper cap geometry to mate against. They should not go in this
      public repo — their licence is unstated and they ship with the kit — so put
      them on lab storage or somewhere private.

## Not built yet

- [ ] **Seal and latch the cap.** The current slip fit keeps debris out and does
      nothing to keep pellets dry.

- [ ] **Add a shutoff gate** so the feed can be stopped for hose service and
      material changeover.

- [ ] **Consider a bridge-breaker or vibrator boss, a sight window, and level
      sensing.** None are needed to print; all are cheap to add while the body is
      still being revised. The flow coupon result should decide the first one.

## Watch items

Built, verified and working. Nothing to do unless something changes.

- [ ] **We are past the bayonet library's exercised range.** Every example it
      ships uses `interface_radius` ≤ 15, and its angular corrections are
      documented as empirically tuned for `pin_radius` ≤ 3.0; we run 29.15 at
      3.0. Verified correct by rendering — it seats, captures and keys — but the
      detent's snap-past grew four-fold with the radius, because it is placed by
      angle and its arc length scales. Re-verify if the coupling grows again, and
      consider feeding a fix back upstream.

- [ ] **Pellet bore margin.** At `lock_pin_radius = 3.0` the largest bore that
      clears the pins is 52.0 mm and ours is 50.0, so there is 2 mm in hand.
      Raising pin radius for strength spends that one for one.
      `hopper_joint()` asserts it either way.

- [ ] **Bin wall creep.** The safety factors in [`docs/loads.md`](docs/loads.md)
      are against short-term yield and say little about a sustained load on a
      thermoplastic in a warm enclosure over months. The failure mode would be
      slow bowing, not a break. Cheapest fixes in order: raise `min_wall`, more
      perimeters, or a stiffening rib at mid-height.

## Firmware — `uwo-fast/Prusa-Firmware-GB3DPE`

- [ ] **Re-fork the repo cleanly** and land our changes as a single commit on top
      of a known upstream tag, instead of the current 15-commit iteration history
      on a full upstream clone.

- [ ] **Run the PINDA probe-offset jog test.** The protocol is written up in
      [`docs/operations/probe-offset-jog-test.md`](docs/operations/probe-offset-jog-test.md)
      but its record fields are blank, so we never settled whether the probe
      offset was wrong or whether X StallGuard homing shifts under the 700 g
      toolhead. The offsets were then set to CAD nominal (X 2.3 / Y 0.86 mm)
      without that answer. Until it runs, we do not know whether mesh and Live-Z
      drift run to run.

- [ ] **Run `M303` and set PID gains for the 70 W cartridge.** Current gains are
      stock values for a 40 W E3D, and `THERMAL_MODEL` is disabled, so
      `TEMP_RUNAWAY` is the only remaining hotend protection.

- [ ] **Reconcile `FANCHECK` and `FILAMENT_SENSOR`** — the docs claim both are
      disabled, the variant headers still enable both. Proposed on a branch for
      review.

- [ ] **Fix stale numbers in `GB3DPE_TUNING.md`** — the slicer section still
      quotes a 12 mm³/s flow ceiling from the abandoned 8000 steps/mm config; the
      landed 1187 steps/mm gives roughly 81 mm³/s. Proposed on the same branch.

## Admin

- [ ] Add ORCIDs to [`CITATION.cff`](CITATION.cff) if the authors have them.
