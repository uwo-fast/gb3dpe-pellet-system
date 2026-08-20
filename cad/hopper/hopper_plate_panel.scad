// Machine plate: bolts through a drilled flat panel.
// GPL-3.0-or-later
// Units: mm

use <hopper_hub.scad>
use <hopper_joint.scad>
use <hopper_plate.scad>

// For the Original Prusa Enclosure, or any flat sheet you are willing to drill.
// It is the universal plate plus a mounting pattern and nothing else, because
// that is all a flat panel needs — the panel carries the load in bending and
// the plate just spreads it.
//
// The pattern is deliberately parametric rather than fixed. Where the holes can
// go depends on what is behind the panel, and that has not been measured; the
// numbers here are a starting point, not a specification.
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
  bolt_depth = 8,
  bolts = 4,
  bolt_diameter = 4.5,
  panel_bolt_spacing = [100, 100],
  panel_bolt_diameter = 4.5,
  counterbore = 8,
  counterbore_depth = 3
) {
  _hub_bolt_r = hub_bolt_circle(skirt_diameter, bolt_depth) / 2;

  assert(
    panel_bolt_spacing[0] < size[0] && panel_bolt_spacing[1] < size[1],
    str("hopper_plate_panel: panel_bolt_spacing ", panel_bolt_spacing,
        " must fit inside the plate ", size)
  );
  assert(
    min(panel_bolt_spacing[0], panel_bolt_spacing[1]) / 2 - panel_bolt_diameter / 2
      > _hub_bolt_r + bolt_diameter / 2,
    str("hopper_plate_panel: the panel bolts would run into the hub's fixings at r ",
        _hub_bolt_r, ". Spread them further out.")
  );

  difference() {
    hopper_plate(
      joint=joint, size=size, thickness=thickness, corner_radius=corner_radius,
      skirt_diameter=skirt_diameter, bolt_depth=bolt_depth, bolts=bolts,
      bolt_diameter=bolt_diameter
    );

    for (x = [-panel_bolt_spacing[0] / 2, panel_bolt_spacing[0] / 2])
      for (y = [-panel_bolt_spacing[1] / 2, panel_bolt_spacing[1] / 2]) {
        translate([x, y, -thickness - 1])
          cylinder(h = thickness + 2, d = panel_bolt_diameter);
        // Counterbored from ABOVE so heads sit flush with the plate's top
        // face. rounded_box sits on z = 0 and extends upward, so the top face
        // is at +thickness -- not 0.
        translate([x, y, thickness - counterbore_depth])
          cylinder(h = counterbore_depth + 1, d = counterbore);
      }
  }
}

// Standalone preview.
hopper_plate_panel(joint = hopper_joint(), $fn = $preview ? 48 : 96);
