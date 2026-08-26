// Mounting plates: the universal interface, and the machine-specific variants
// that difference their own pattern out of it.
// GPL-3.0-or-later
// Units: mm, degrees

use <hopper_hub.scad>
use <hopper_joint.scad>
use <hopper_util.scad>

// One part in three versions, not three parts: every variant is the universal
// plate plus a machine's own features, so all three share the outline, the
// clearance hole and the hub fixings by construction. See docs/interfaces.md.

// ===== Universal =====

// Deliberately the dumbest part here. It is flat, it has holes, and it has no
// features on either face — which is what lets it print flat, and equally lets
// it be laser-cut, milled, or made from acrylic or plywood if that suits the
// machine better than printing.
//
// Being the only machine-specific part, it is also the cheapest thing in the
// stack to get wrong and remake. That is deliberate: the measurements we are
// least sure of should land on the part that costs least to redo.

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
  bolt_circle = 79,
  bolts = 4,
  bolt_diameter = 4.5,
  bolt_angle = 45
) {
  _hole = hub_plate_hole(joint);
  _bolt_r = bolt_circle / 2;

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

    translate([0, 0, -1]) cylinder(h=thickness + 2, d=_hole);

    for (i = [0:bolts - 1])
      rotate([0, 0, i * 360 / bolts + bolt_angle])
        translate([_bolt_r, 0, -1])
          cylinder(h=thickness + 2, d=bolt_diameter);
  }
}

// ===== MK3S frame =====

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
// the hopper in friction.
//
// STIFFNESS, not strength, is what sizes this part. A bare 6 mm plate is well
// inside yield, but it deflects half a millimetre at the hub -- and with 450 mm
// of hopper standing above that, half a millimetre at the plate is nearly five
// at the top, on a machine that slings its bed in Y. Hence two things: the
// saddle runs the full width of the plate rather than a stub in the middle, so
// load does not funnel into its ends and it cannot tilt on the bar; and braces
// turn the flat cantilever into a T-section, which is worth about four times
// the stiffness for a few grams.
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
  frame_thickness / 2 + margin + max(hub_plate_hole(joint) / 2, joint_neck_od(joint) / 2);

// Defaults here MUST match hopper_plate_mk3s()'s own, or the figure it reports
// is not the figure it enforces.
function mk3s_saddle_offset(
  joint,
  frame_thickness = MK3S_FRAME_THICKNESS,
  frame_clearance = 0.3,
  jaw = 7,
  fillet = 4
) =
  hub_plate_hole(joint) / 2 + (frame_thickness + frame_clearance) / 2 + jaw + fillet;

function mk3s_min_offset(
  joint,
  frame_thickness = MK3S_FRAME_THICKNESS,
  frame_clearance = 0.3,
  jaw = 7,
  fillet = 4
) =
  max(
    mk3s_outlet_offset(joint, frame_thickness),
    mk3s_saddle_offset(joint, frame_thickness, frame_clearance, jaw, fillet)
  );

// One brace: a wedge running inboard from the saddle, full height where it
// meets it and tapering to nothing. Built as a hull between a tall thin slab
// and a flat one, which keeps the sloped face a single plane.
/**
 * Plate size, derived rather than chosen.
 *
 * Everything about this part follows from the offset, the saddle's own width
 * and the hub's skirt, so making the plate a free parameter only creates the
 * chance to set it inconsistently with them -- which is exactly how the saddle
 * ended up shorter than the braces that were meant to sit on it.
 *
 * Square, because the saddle spans the full width and a longer grip on the bar
 * is what resists the mount tilting.
 */
function mk3s_plate_size(
  joint,
  offset = 47,
  jaw = 7,
  fillet = 4,
  frame_thickness = MK3S_FRAME_THICKNESS,
  frame_clearance = 0.3,
  skirt_diameter = 95,
  margin = 6
) =
  let (
    saddle_w = frame_thickness + frame_clearance + 2 * jaw,
    half = max(offset + saddle_w / 2 + fillet, skirt_diameter / 2) + margin
  ) [2 * half, 2 * half];

module _mk3s_brace(x0, y, height, reach, thickness) {
  hull() {
    translate([x0, y - thickness / 2, -height]) cube([0.1, thickness, height]);
    translate([x0 + reach, y - thickness / 2, -0.1]) cube([0.1, thickness, 0.1]);
  }
}

// Brace positions, spread between the clearance hole and the plate edge and
// mirrored either side. Inboard of the hole there is no plate to attach to.
function _mk3s_brace_positions(count, inner, outer) =
  count < 1 ? []
  : count == 1 ? [inner, -inner]
  : [
    for (i = [0:count - 1]) each let (y = inner + (outer - inner) * i / (count - 1)) [y, -y],
  ];

module hopper_plate_mk3s(
  joint,
  // Omit to let it size itself from the offset, the saddle and the hub skirt.
  size = undef,
  margin = 6,
  thickness = 6,
  corner_radius = 6,
  skirt_diameter = 95,
  bolt_circle = 79,
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
  saddle_roof = 6,
  // Braces running inboard from the saddle, standing off the plate's underside.
  // Placed outboard of the clearance hole, where there is plate to attach to.
  braces_per_side = 2,
  brace_thickness = 4,
  // Omit to run the braces from the saddle to under the hopper's axis.
  brace_reach = undef,
  brace_height = undef,
  clamp_screws = 4,
  clamp_screw_diameter = 3.4,
  clamp_screw_spacing = undef
) {
  _slot = frame_thickness + frame_clearance;
  _saddle_w = _slot + 2 * jaw;
  _saddle_h = grip_depth + saddle_roof;
  _size =
    is_undef(size) ? mk3s_plate_size(
        joint, offset, jaw, fillet, frame_thickness, frame_clearance,
        skirt_diameter, margin
      )
    : size;
  // The saddle is ALWAYS the full plate width. A stub in the middle makes its
  // ends a stress concentration, lets the mount tilt on the bar, and leaves the
  // outer braces standing on nothing.
  _saddle_len = _size[1];
  _reach = is_undef(brace_reach) ? offset - _saddle_w / 2 : brace_reach;
  _brace_h = is_undef(brace_height) ? _saddle_h : brace_height;
  _screw_span = is_undef(clamp_screw_spacing) ? _saddle_len - 4 * jaw : clamp_screw_spacing;
  _brace_inner = hub_plate_hole(joint) / 2 + brace_thickness / 2 + 2;
  _brace_outer = _size[1] / 2 - corner_radius - brace_thickness / 2;
  _min_offset = mk3s_min_offset(joint, frame_thickness, frame_clearance, jaw, fillet);

  assert(
    offset >= _min_offset,
    str(
      "hopper_plate_mk3s: offset (", offset, ") is under the minimum ",
      _min_offset,
      ". Either the outlet hanging below the plate fouls the frame (needs ",
      mk3s_outlet_offset(joint, frame_thickness),
      "), or the saddle and its fillet overhang the plate's clearance hole (needs ",
      mk3s_saddle_offset(joint, frame_thickness, frame_clearance, jaw, fillet),
      ")"
    )
  );
  assert(
    offset + _saddle_w / 2 <= _size[0] / 2,
    str(
      "hopper_plate_mk3s: the saddle reaches ", offset + _saddle_w / 2,
      " but the plate only spans ", _size[0] / 2, ". Widen the plate."
    )
  );
  assert(
    _screw_span + clamp_screw_diameter < _saddle_len,
    str("hopper_plate_mk3s: clamp screws do not fit within the saddle length ", _saddle_len)
  );
  // A brace outboard of the saddle has nothing to brace against: it starts in
  // mid-air at the saddle's inner face and is joined to the plate alone, which
  // is worse than no brace because it looks like one.
  assert(
    braces_per_side == 0 || _brace_outer <= _saddle_len / 2,
    str(
      "hopper_plate_mk3s: braces reach y ", _brace_outer,
      " but the saddle only spans +/-", _saddle_len / 2,
      ". Lengthen the saddle, or narrow the plate so the braces stay over it."
    )
  );
  assert(
    braces_per_side == 0 || _brace_outer > _brace_inner,
    str(
      "hopper_plate_mk3s: no room for braces between the clearance hole (r ",
      _brace_inner, ") and the plate edge (r ", _brace_outer,
      "). Widen the plate."
    )
  );
  assert(
    grip_depth < frame_bar_height,
    str(
      "hopper_plate_mk3s: grip_depth (", grip_depth,
      ") must stay inside the frame bar (", frame_bar_height,
      ") or the jaws hang off its lower edge"
    )
  );
  assert(
    offset + _saddle_w / 2 + fillet <= _size[0] / 2,
    str("hopper_plate_mk3s: the fillet would run off the plate edge")
  );

  difference() {
    union() {
      hopper_plate(
        joint=joint, size=_size, thickness=thickness, corner_radius=corner_radius,
        skirt_diameter=skirt_diameter, bolt_circle=bolt_circle, bolts=bolts,
        bolt_diameter=bolt_diameter
      );

      // Everything below the plate, clipped to the plate's own outline. With a
      // full-width saddle the fillet would otherwise stand proud of the edge;
      // clipping means the width is set in one place and nothing overhangs.
      intersection() {
        union() {
          // Fillet blending the saddle into the plate. Hulled between the
          // saddle's own section and a larger one at the plate face, so it
          // flares outward going up -- no overhang once printed face-down.
          if (fillet > 0)
            hull() {
              translate([-offset, 0, -fillet])
                rounded_box(_saddle_w, _saddle_len, 0.01, 3);
              translate([-offset, 0, -0.01])
                rounded_box(_saddle_w + 2 * fillet, _saddle_len + 2 * fillet, 0.01, 3 + fillet);
            }

          // Saddle, hanging from the plate's UNDERSIDE. rounded_box sits on
          // z = 0 and extends upward, so the plate occupies 0..thickness and
          // its underside is z = 0 -- not -thickness. Hanging it from
          // -thickness leaves it floating a plate's thickness below, which
          // renders and slices perfectly well as two separate objects.
          translate([-offset, 0, -_saddle_h])
            rounded_box(_saddle_w, _saddle_len, _saddle_h + 0.1, 3);

          // Braces, running inboard from the saddle's inner face.
          for (y = _mk3s_brace_positions(braces_per_side, _brace_inner, _brace_outer))
            _mk3s_brace(-offset + _saddle_w / 2 - 0.1, y, _brace_h, _reach, brace_thickness);
        }

        translate([0, 0, -_saddle_h - 1])
          rounded_box(_size[0], _size[1], _saddle_h + 2, corner_radius);
      }
    }

    // The frame slot, open at the bottom.
    translate([-offset, 0, -_saddle_h - 1 + (grip_depth + 1) / 2])
      cube([_slot, _saddle_len + 2, grip_depth + 1], center=true);

    // Clamp screws through the outboard jaw only, so they pinch the frame
    // against the inboard one rather than pulling the saddle apart.
    for (i = [0:clamp_screws - 1])
      translate(
        [
          -offset - _slot / 2 - jaw - 1,
          -_screw_span / 2 + i * _screw_span / max(1, clamp_screws - 1),
          -saddle_roof - grip_depth / 2,
        ]
      )
        rotate([0, 90, 0])
          cylinder(h=jaw + 2, d=clamp_screw_diameter);
  }
}

// ===== Panel =====

// For the Original Prusa Enclosure, or any flat sheet you are willing to drill.
// It is the universal plate plus a mounting pattern and nothing else, because
// that is all a flat panel needs — the panel carries the load in bending and
// the plate just spreads it.
//
// The pattern is parametric because the panel is drilled to suit the
// installation. There is no fixed pattern to match and nothing to measure: pick
// a spacing that clears whatever is behind the sheet, and drill for it.
//
// Drill the panel for the OUTLET first and the bolts second. The outlet's neck
// passes through, so the panel needs a clearance hole matching the plate's,
// which panel_hole() reports.
//
// WASHERS OR A BACKING PLATE, NOT BARE BOLTS. Four M4 heads pulling directly on
// thin sheet is a small bearing area under a sustained few kilograms, and sheet
// dimples long before anything breaks. Spread it.

// What the panel itself has to be drilled to, to clear the outlet's neck.
function panel_hole(joint, clearance = 1.0) = hub_plate_hole(joint, clearance);

module hopper_plate_panel(
  joint,
  size = [120, 120],
  thickness = 6,
  corner_radius = 6,
  skirt_diameter = 95,
  bolt_circle = 79,
  bolts = 4,
  bolt_diameter = 4.5,
  panel_bolt_spacing = [100, 100],
  panel_bolt_diameter = 4.5,
  counterbore = 8,
  counterbore_depth = 3
) {
  _hub_bolt_r = bolt_circle / 2;

  assert(
    panel_bolt_spacing[0] < size[0] && panel_bolt_spacing[1] < size[1],
    str(
      "hopper_plate_panel: panel_bolt_spacing ", panel_bolt_spacing,
      " must fit inside the plate ", size
    )
  );
  assert(
    min(panel_bolt_spacing[0], panel_bolt_spacing[1]) / 2 - panel_bolt_diameter / 2 > _hub_bolt_r + bolt_diameter / 2,
    str(
      "hopper_plate_panel: the panel bolts would run into the hub's fixings at r ",
      _hub_bolt_r, ". Spread them further out."
    )
  );

  difference() {
    hopper_plate(
      joint=joint, size=size, thickness=thickness, corner_radius=corner_radius,
      skirt_diameter=skirt_diameter, bolt_circle=bolt_circle, bolts=bolts,
      bolt_diameter=bolt_diameter
    );

    for (x = [-panel_bolt_spacing[0] / 2, panel_bolt_spacing[0] / 2])
      for (y = [-panel_bolt_spacing[1] / 2, panel_bolt_spacing[1] / 2]) {
        translate([x, y, -thickness - 1])
          cylinder(h=thickness + 2, d=panel_bolt_diameter);
        // Counterbored from ABOVE so heads sit flush with the plate's top
        // face. rounded_box sits on z = 0 and extends upward, so the top face
        // is at +thickness -- not 0.
        translate([x, y, thickness - counterbore_depth])
          cylinder(h=counterbore_depth + 1, d=counterbore);
      }
  }
}

// Standalone preview: the MK3S variant, which is what the driver defaults to
// and what drift.py compares against it -- hence a named facet count rather
// than an inline $fn, so both render at a matched resolution. The universal and
// panel variants are rendered through the driver by `just check`.
preview_facets = $preview ? 48 : 96;
hopper_plate_mk3s(joint=hopper_joint(), $fn=preview_facets);
