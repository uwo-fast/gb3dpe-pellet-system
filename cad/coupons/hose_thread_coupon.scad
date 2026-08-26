// Hose thread test coupon: the outlet's socket on its own, to print and screw
// the real hose into. Prints as modelled -- socket mouth on the bed.
// GPL-3.0-or-later
// Units: mm

/* [Hose] */

// Measured on the bench: 21 mm over the tube, with a semicircular rib of 3.5 mm
// diameter wound at 7.6 mm pitch. The rib's centreline sits ON the tube's
// surface, so only its radius stands proud -- 24.5 mm overall across the ribs.
tube_od = 21;
rib = 3.5;
pitch = 7.6;
// Unconfirmed. Print one of each; whichever starts is the answer.
handed = "right"; // [right,left]

/* [Coupon] */

clearance = 0.4; // [0:0.05:1.2]
turns = 3; // [2:0.5:6]
wall = 3;

$fn = $preview ? 48 : 96;

_h = turns * pitch;
_cut = _h + 1;

difference() {
  cylinder(h = _h, d = tube_od + rib + 2 * wall);

  translate([0, 0, -0.5]) cylinder(h = _cut, d = tube_od + clearance);

  // The groove is the rib's own section swept up the bore: an offset circle
  // twisted at one turn per pitch, so the pitch converts straight to degrees.
  translate([0, 0, -0.5])
    linear_extrude(
      height = _cut,
      twist = (handed == "right" ? -1 : 1) * 360 * _cut / pitch,
      slices = ceil(_cut / pitch * 48),
      convexity = 10
    )
      translate([tube_od / 2, 0]) circle(d = rib + clearance);
}
