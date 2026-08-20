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

// MEASURED on the bench, not taken from documentation: the MK3S frame's top
// bar is STEEL, 6.3 mm thick and 40.5 mm tall. Public sources describe the
// frame as 6.2 mm aluminium; both differ from what is actually on this machine.
// Steel changes nothing structurally here -- the clamp does not care and the
// frame was never the weak part -- but it is worth recording as measured.
MK3S_FRAME_THICKNESS = 6.3;
MK3S_FRAME_BAR_HEIGHT = 40.5;

/**
 * Smallest offset from the frame plane to the hopper axis.
 *
 * TWO constraints, and the second is the one that bites. The outlet hangs below
 * the plate and must pass beside the frame — that sets a floor of about 39 mm.
 * But the SADDLE also has to sit clear of the plate's own clearance hole, and
 * with its jaws and fillet it is wider than the frame it grips, so it needs
 * more. Missing the second one leaves the saddle hanging over the hole, partly
 * filling the opening the outlet passes through.
 */
function mk3s_outlet_offset(joint, frame_thickness = MK3S_FRAME_THICKNESS, margin = 3) =
  frame_thickness / 2 + margin +
  max(hub_plate_hole(joint) / 2, joint_neck_od(joint) / 2);

// Defaults here MUST match hopper_plate_mk3s()'s own, or the figure it reports
// is not the figure it enforces.
function mk3s_saddle_offset(joint, frame_thickness = MK3S_FRAME_THICKNESS,
                            frame_clearance = 0.3, jaw = 7, fillet = 4) =
  hub_plate_hole(joint) / 2 + (frame_thickness + frame_clearance) / 2 + jaw + fillet;

function mk3s_min_offset(joint, frame_thickness = MK3S_FRAME_THICKNESS,
                         frame_clearance = 0.3, jaw = 7, fillet = 4) =
  max(
    mk3s_outlet_offset(joint, frame_thickness),
    mk3s_saddle_offset(joint, frame_thickness, frame_clearance, jaw, fillet)
  );

module hopper_plate_mk3s(
  joint,
  size = [130, 130],
  thickness = 6,
  corner_radius = 6,
  skirt_diameter = 95,
  bolt_depth = 8,
  bolts = 4,
  bolt_diameter = 4.5,
  frame_thickness = MK3S_FRAME_THICKNESS,
  frame_clearance = 0.3,
  frame_bar_height = MK3S_FRAME_BAR_HEIGHT,
  offset = 47,
  // Well inside the bar rather than most of the way down it. At 40 the saddle
  // reached within half a millimetre of the bar's lower edge, which leaves
  // nothing for tolerance and puts the jaw tips where the bar ends.
  grip_depth = 30,
  // Thicker than the frame needs, because the jaw is a cantilever taking the
  // mount's overturning couple and its stress goes as 1/thickness^2. Widening
  // it pushes the offset out a little, which raises the couple -- but only
  // linearly, so it wins comfortably.
  jaw = 7,
  // Fillet where the saddle meets the plate. That junction is where the
  // cantilever's bending moment is highest and a sharp re-entrant corner is a
  // stress raiser; it also prints as a supported slope in the flipped
  // orientation rather than a right angle.
  fillet = 4,
  saddle_length = 80,
  saddle_roof = 6,
  clamp_screws = 2,
  clamp_screw_diameter = 3.4,
  clamp_screw_spacing = 44
) {
  _slot = frame_thickness + frame_clearance;
  _saddle_w = _slot + 2 * jaw;
  _saddle_h = grip_depth + saddle_roof;
  _min_offset = mk3s_min_offset(joint, frame_thickness, frame_clearance, jaw, fillet);

  assert(
    offset >= _min_offset,
    str(
      "hopper_plate_mk3s: offset (", offset, ") is under the minimum ", _min_offset,
      ". Either the outlet hanging below the plate fouls the frame (needs ",
      mk3s_outlet_offset(joint, frame_thickness),
      "), or the saddle and its fillet overhang the plate's clearance hole (needs ",
      mk3s_saddle_offset(joint, frame_thickness, frame_clearance, jaw, fillet), ")"
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
  assert(
    grip_depth < frame_bar_height,
    str(
      "hopper_plate_mk3s: grip_depth (", grip_depth, ") must stay inside the frame bar (",
      frame_bar_height, ") or the jaws hang off its lower edge"
    )
  );
  assert(
    offset + _saddle_w / 2 + fillet <= size[0] / 2,
    str("hopper_plate_mk3s: the fillet would run off the plate edge")
  );

  difference() {
    union() {
      hopper_plate(
        joint=joint, size=size, thickness=thickness, corner_radius=corner_radius,
        skirt_diameter=skirt_diameter, bolt_depth=bolt_depth, bolts=bolts,
        bolt_diameter=bolt_diameter
      );

      // Fillet blending the saddle into the plate. Hulled between the saddle's
      // own section and a larger one at the plate face, so it flares outward
      // going up -- no overhang once the part is printed plate-face-down.
      if (fillet > 0)
        hull() {
          translate([-offset, 0, -fillet])
            rounded_box(_saddle_w, saddle_length, 0.01, 3);
          translate([-offset, 0, -0.01])
            rounded_box(_saddle_w + 2 * fillet, saddle_length + 2 * fillet, 0.01, 3 + fillet);
        }

      // Saddle, hanging from the plate's UNDERSIDE. rounded_box sits on z = 0
      // and extends upward, so the plate occupies 0..thickness and its
      // underside is z = 0 -- not -thickness. Hanging the saddle from
      // -thickness leaves it floating a plate's thickness below, which renders
      // and slices perfectly well as two separate objects.
      translate([-offset, 0, -_saddle_h])
        rounded_box(_saddle_w, saddle_length, _saddle_h + 0.1, 3);
    }

    // The frame slot, open at the bottom.
    translate([-offset, 0, -_saddle_h - 1 + (grip_depth + 1) / 2])
      cube([_slot, saddle_length + 2, grip_depth + 1], center = true);

    // Clamp screws through the outboard jaw only, so they pinch the frame
    // against the inboard one rather than pulling the saddle apart.
    for (i = [0:clamp_screws - 1])
      translate([
        -offset - _slot / 2 - jaw - 1,
        -clamp_screw_spacing / 2 + i * clamp_screw_spacing / max(1, clamp_screws - 1),
        -saddle_roof - grip_depth / 2,
      ])
        rotate([0, 90, 0])
          cylinder(h = jaw + 2, d = clamp_screw_diameter);
  }
}

// Standalone preview.
hopper_plate_mk3s(joint = hopper_joint(), $fn = $preview ? 48 : 96);
