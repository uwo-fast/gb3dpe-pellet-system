// Lid that slips over the top of the hopper body.
// GPL-3.0-or-later
// Units: mm

use <hopper_util.scad>

/**
 * A plain slip-on lid, sitting on z = 0 at its own rim.
 *
 * It has no seal and no latch, so it keeps debris out but does nothing to keep
 * pellets dry. Tracked in TODO.md.
 */
module hopper_cap(
  top_x,
  top_y,
  funnel_radius = 8,
  clearance = 0.6,
  wall = 3,
  skirt_height = 16,
  top_thickness = 3
) {
  assert(clearance > 0, str("hopper_cap: clearance must be > 0, got: ", clearance));
  assert(wall > 0, str("hopper_cap: wall must be > 0, got: ", wall));
  assert(skirt_height > 0, str("hopper_cap: skirt_height must be > 0, got: ", skirt_height));

  _inner_x = top_x + 2 * clearance;
  _inner_y = top_y + 2 * clearance;

  difference() {
    rounded_box(
      _inner_x + 2 * wall,
      _inner_y + 2 * wall,
      skirt_height + top_thickness,
      funnel_radius + wall
    );

    translate([0, 0, -1])
      rounded_box(_inner_x, _inner_y, skirt_height + 1, funnel_radius + clearance);
  }
}

// Standalone preview. $fn is passed on the call, never assigned at top level:
// a use'd file's own top-level $fn is what ITS modules see, so assigning it
// here would silently override whatever the driver asked for.
hopper_cap(top_x = 220, top_y = 180, $fn = $preview ? 48 : 120);
