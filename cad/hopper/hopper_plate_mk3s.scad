// Machine plate: clamps to the MK3S frame.
// GPL-3.0-or-later
// Units: mm

use <hopper_hub.scad>
use <hopper_joint.scad>
use <hopper_plate.scad>
use <hopper_util.scad>

// The first of the machine-specific plates. It adds a saddle to the universal
// plate and nothing else; everything the hopper bolts to is inherited.
//
// TWO THINGS DRIVE THE SHAPE.
//
// It clamps rather than hooks. Prusa's own spool holder hangs on this frame,
// so it is the obvious reference — but scanning its mesh for opposed parallel
// faces four to nine millimetres apart finds none anywhere, which means it has
// no frame slot at all. It is a cantilever hook that stays put because the
// spool's weight holds it down. That is fine for a kilogram of filament and
// wrong for three kilograms of pellets, which is why this straddles the plate
// and pinches it instead.
//
// The hopper axis is offset from the frame, not over it. The outlet hangs below
// the plate and has to pass beside the frame rather than through it, so the
// plate is a cantilever — which is also why Prusa's holder is an L-arm.
//
// The frame carries the vertical load on the saddle's roof, sitting on the top
// edge. The screws only stop it sliding and tipping, so they are not holding
// three kilograms in friction.
//
// PRINTS UPSIDE DOWN: plate face on the bed, saddle legs pointing up, slot
// opening upward. Nothing overhangs in that orientation.

// Documented figure for the MK3/MK3S frame: a 370 x 370 mm aluminium plate,
// 6.2 mm thick. Worth a caliper check, and parametric so it does not matter
// much if it is a little off.
MK3S_FRAME_THICKNESS = 6.2;

/**
 * Smallest offset from the frame plane to the hopper axis that still clears
 * both the plate's hole and the outlet hanging through it.
 */
function mk3s_min_offset(joint, frame_thickness = MK3S_FRAME_THICKNESS, margin = 3) =
  frame_thickness / 2 + margin +
  max(hub_plate_hole(joint) / 2, joint_neck_od(joint) / 2);

module hopper_plate_mk3s(
  joint,
  size = [120, 120],
  thickness = 6,
  corner_radius = 6,
  skirt_diameter = 95,
  bolt_depth = 8,
  bolts = 4,
  bolt_diameter = 4.5,
  frame_thickness = MK3S_FRAME_THICKNESS,
  frame_clearance = 0.4,
  offset = 40,
  grip_depth = 40,
  jaw = 5,
  saddle_length = 80,
  saddle_roof = 6,
  clamp_screws = 2,
  clamp_screw_diameter = 3.4,
  clamp_screw_spacing = 44
) {
  _slot = frame_thickness + frame_clearance;
  _saddle_w = _slot + 2 * jaw;
  _saddle_h = grip_depth + saddle_roof;
  _min_offset = mk3s_min_offset(joint, frame_thickness);

  assert(
    offset >= _min_offset,
    str(
      "hopper_plate_mk3s: offset (", offset, ") is under the minimum ", _min_offset,
      " — the outlet hanging below the plate would foul the frame"
    )
  );
  assert(
    offset + _saddle_w / 2 <= size[0] / 2,
    str(
      "hopper_plate_mk3s: the saddle reaches ", offset + _saddle_w / 2,
      " but the plate only spans ", size[0] / 2, ". Widen the plate."
    )
  );
  assert(
    clamp_screw_spacing + clamp_screw_diameter < saddle_length,
    str("hopper_plate_mk3s: clamp screws do not fit within saddle_length ", saddle_length)
  );

  difference() {
    union() {
      hopper_plate(
        joint=joint, size=size, thickness=thickness, corner_radius=corner_radius,
        skirt_diameter=skirt_diameter, bolt_depth=bolt_depth, bolts=bolts,
        bolt_diameter=bolt_diameter
      );

      // Saddle, hanging below the plate.
      translate([-offset, 0, -thickness - _saddle_h])
        rounded_box(_saddle_w, saddle_length, _saddle_h + 0.1, 3);
    }

    // The frame slot, open at the bottom.
    translate([-offset, 0, -thickness - _saddle_h - 1 + (grip_depth + 1) / 2])
      cube([_slot, saddle_length + 2, grip_depth + 1], center = true);

    // Clamp screws through the outboard jaw only, so they pinch the frame
    // against the inboard one rather than pulling the saddle apart.
    for (i = [0:clamp_screws - 1])
      translate([
        -offset - _slot / 2 - jaw - 1,
        -clamp_screw_spacing / 2 + i * clamp_screw_spacing / max(1, clamp_screws - 1),
        -thickness - saddle_roof - grip_depth / 2,
      ])
        rotate([0, 90, 0])
          cylinder(h = jaw + 2, d = clamp_screw_diameter);
  }
}

// Standalone preview.
hopper_plate_mk3s(joint = hopper_joint(), $fn = $preview ? 48 : 96);
