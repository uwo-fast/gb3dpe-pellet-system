// Spike: hose thread test coupon. Print, screw the real hose in, iterate.
// GPL-3.0-or-later
// Units: mm

// include, not use: the hose row is a variable, and variables do not cross a
// use<> boundary -- only modules and functions do.
include <../hopper/hopper_specs.scad>
use <../hopper/hopper_outlet.scad>
use <../hopper/hopper_util.scad>

// The outlet's hose socket is the least-tested feature in the build. Nothing in
// it has ever been printed: the clearance is a guess, the engagement length is a
// guess, and the handedness is marked NOT CONFIRMED in the driver. It is also
// now the ONLY thing resisting the outlet backing off the hub, since the
// retaining screws are gone -- see docs/design-notes.md.
//
// This coupon is the cheap way to settle all three. It cuts the socket with
// hose_thread() from hopper_outlet.scad -- the production module, not a copy --
// so a clearance that works here is a clearance the outlet will print.
//
// PRINT IT THE WAY THE OUTLET PRINTS: socket mouth down on the bed, which is the
// orientation this model is already in. The thread bridges over about one rib
// width in that orientation, and how well it bridges is part of what is being
// tested. A coupon printed the other way up answers a question nobody asked.
//
// WHAT TO LOOK FOR, in order:
//   1. Does it start by hand, or does it cross-thread?
//   2. Does it wind in the full depth without forcing?
//   3. Does it HOLD -- hang the coupon off a metre of hose and see if it backs
//      off when you twist the hose the way a moving toolhead would.
// Keep the tightest clearance that still passes 1 and 2.
//
// HANDEDNESS: print one coupon of each. Whichever starts is the answer, and it
// goes into hose_handedness in the driver.
//
// Deliberately NOT in tests/geometry-baseline.json. This file exists to change
// between prints; baselining it would mean a rebaseline every iteration for a
// part that is never shipped.

// Engagement, in turns rather than millimetres, because turns are what hold.
// hopper_outlet asserts at least two; three is what the outlet currently uses.
COUPON_TURNS = 3;

// Text is engraved into one flat, so a bench full of near-identical rings can
// still be told apart. This is the whole reason the outer is a hexagon.
COUPON_LABEL_SIZE = 4.5;
COUPON_LABEL_DEPTH = 0.6;

/**
 * One test socket, sitting on z = 0 with the socket mouth AT the bed.
 *
 * Above the socket the bore steps down to the hose's own bore, exactly as the
 * outlet does, so the hose butts against the same shoulder it will in service.
 */
module hose_thread_coupon(
  hose,
  clearance = 0.4,
  turns = COUPON_TURNS,
  wall = 3,
  top = 3,
  label = true
) {
  _depth = turns * hose_pitch(hose);
  _socket_d = hose_tube_od(hose) + clearance;
  // Across flats, matching what the outlet's own socket OD works out to.
  _flats = outlet_socket_od(hose, wall, clearance);
  // cylinder($fn = 6) is sized across CORNERS, so convert.
  _across_corners = _flats / cos(30);

  assert(
    turns >= 2,
    str("hose_thread_coupon: ", turns, " turns is under the two hopper_outlet requires; the hose would strip out")
  );
  assert(
    _flats > _socket_d,
    str("hose_thread_coupon: wall ", wall, " leaves no material around a ", _socket_d, " mm socket")
  );

  echo(str(
    "hose coupon: ", hose_name(hose), ", ", hose_handed(hose), "-handed, clearance ",
    clearance, ", ", turns, " turns = ", _depth, " mm, socket ", _socket_d,
    " mm, across flats ", _flats
  ));

  difference() {
    cylinder(h = _depth + top, d = _across_corners, $fn = 6);

    // The socket the hose winds into, open at the bed face.
    translate([0, 0, -0.5]) cylinder(h = _depth + 0.5, d = _socket_d);
    translate([0, 0, -0.5]) hose_thread(hose, _depth + 0.5, clearance);

    // Through to the hose's own bore, so the shoulder sits where it will in
    // the outlet and you can see daylight when the hose is fully home.
    translate([0, 0, _depth]) cylinder(h = top + 1, d = hose_bore(hose));

    if (label) _coupon_label(clearance, hose, _flats, _depth + top);
  }
}

// Clearance and handedness engraved into one hex flat. Vertical face, so it
// prints without support and stays readable.
module _coupon_label(clearance, hose, flats, height) {
  translate([0, -flats / 2 + COUPON_LABEL_DEPTH, height / 2])
    rotate([90, 0, 0])
      linear_extrude(height = COUPON_LABEL_DEPTH * 2, center = true)
        text(
          str(clearance, hose_handed(hose) == "right" ? "R" : "L"),
          size = COUPON_LABEL_SIZE,
          halign = "center",
          valign = "center"
        );
}

/**
 * A row of coupons across a clearance sweep, laid out for one plate.
 *
 * Print the row, try each, keep the tightest that still winds in by hand.
 */
module hose_thread_sweep(hose, clearances, turns = COUPON_TURNS, wall = 3) {
  _pitch = outlet_socket_od(hose, wall, max(clearances)) / cos(30) + 4;
  for (i = [0:len(clearances) - 1])
    translate([i * _pitch, 0, 0])
      hose_thread_coupon(hose, clearance = clearances[i], turns = turns, wall = wall);
}

// Standalone preview and export. `sweep` is what you print first; `one` is for
// re-printing a single clearance once the sweep has narrowed it down.
render_part = "sweep"; // [sweep,one]
clearance = 0.4; // [0:0.05:1.2]
turns = 3; // [2:1:6]
// Flip to "left" and print one of each to settle which way the hose winds.
handedness = "right"; // [right,left]
sweep_clearances = [0.2, 0.3, 0.4, 0.5, 0.6];
preview_facets = $preview ? 48 : 96;

_row = hose(0);
_hose = [
  hose_name(_row), hose_bore(_row), hose_tube_od(_row),
  hose_helix(_row), hose_pitch(_row), handedness,
];

if (render_part == "one")
  hose_thread_coupon(_hose, clearance = clearance, turns = turns, $fn = preview_facets);
else
  hose_thread_sweep(_hose, sweep_clearances, turns = turns, $fn = preview_facets);
