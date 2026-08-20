// Mounting plate: the only machine-specific part in the stack.
// GPL-3.0-or-later
// Units: mm

use <hopper_hub.scad>
use <hopper_joint.scad>
use <hopper_util.scad>

// Deliberately the dumbest part here. It is flat, it has holes, and it has no
// features on either face — which is what lets it print flat, and equally lets
// it be laser-cut, milled, or made from acrylic or plywood if that suits the
// machine better than printing.
//
// Being the only machine-specific part, it is also the cheapest thing in the
// stack to get wrong and remake. That is deliberate: the measurements we are
// least sure of should land on the part that costs least to redo.
//
// Machine-specific plates difference their own pattern out of this one rather
// than reimplementing it. See docs/interfaces.md.

/**
 * The universal half of a mounting plate: outline, the hub's clearance hole,
 * and the hub's fixings.
 *
 * The clearance hole passes the OUTLET NECK'S PINS, which stand proud of the
 * neck itself — sizing it to the neck would trap the outlet.
 */
module hopper_plate(
  joint,
  size = [120, 120],
  thickness = 6,
  corner_radius = 6,
  skirt_diameter = 95,
  bolt_depth = 8,
  bolts = 4,
  bolt_diameter = 4.5,
  bolt_angle = 45
) {
  _hole = hub_plate_hole(joint);
  _bolt_r = hub_bolt_circle(skirt_diameter, bolt_depth) / 2;

  assert(
    size[0] > skirt_diameter && size[1] > skirt_diameter,
    str("hopper_plate: size ", size, " must exceed the hub skirt (", skirt_diameter, ")")
  );
  assert(
    _bolt_r - bolt_diameter / 2 > _hole / 2,
    str("hopper_plate: fixings at r ", _bolt_r, " would break into the clearance hole at r ", _hole / 2)
  );

  difference() {
    rounded_box(size[0], size[1], thickness, corner_radius);

    translate([0, 0, -1]) cylinder(h = thickness + 2, d = _hole);

    for (i = [0:bolts - 1])
      rotate([0, 0, i * 360 / bolts + bolt_angle])
        translate([_bolt_r, 0, -1])
          cylinder(h = thickness + 2, d = bolt_diameter);
  }
}

// Standalone preview.
hopper_plate(joint = hopper_joint(), $fn = $preview ? 48 : 96);
