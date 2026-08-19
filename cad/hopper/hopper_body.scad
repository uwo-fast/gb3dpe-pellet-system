// Hopper body: storage bin, funnel, and the bayonet neck beneath it.
// GPL-3.0-or-later
// Units: mm

use <hopper_joint.scad>
use <hopper_util.scad>

/**
 * The hopper body, sitting on z = 0 at the bottom of its bayonet neck.
 *
 * Built as one outer solid differenced by one inner cavity. Both are lofted
 * through the same z stations, so the two surfaces stay parallel and the wall
 * keeps a constant thickness along each face.
 *
 * Note that `wall` is a HORIZONTAL inset. On a face sloped at theta from
 * horizontal the material measured perpendicular to the surface is
 * wall * sin(theta), so the funnel is thinner than the number suggests. See
 * docs/hopper-design-review.md; this is preserved here deliberately and is
 * fixed alongside the funnel-angle work.
 */
module hopper_body(
  joint,
  top_x,
  top_y,
  bin_height,
  funnel_height,
  throat = 44,
  wall = 3,
  throat_radius = 4,
  funnel_radius = 8,
  neck_transition_height = 10
) {
  assert(wall > 0, str("hopper_body: wall must be > 0, got: ", wall));
  assert(
    throat > 2 * wall,
    str("hopper_body: throat (", throat, ") must exceed 2 * wall (", 2 * wall, ")")
  );
  assert(
    top_x > throat && top_y > throat,
    str("hopper_body: top_x and top_y must exceed throat, got: ", [top_x, top_y, throat])
  );
  assert(funnel_height > 0, str("hopper_body: funnel_height must be > 0, got: ", funnel_height));
  assert(bin_height > 0, str("hopper_body: bin_height must be > 0, got: ", bin_height));

  _neck_height = joint_neck_height(joint);
  _bore = joint_bore_diameter(joint);

  // z stations, bottom up.
  _throat_z = _neck_height + neck_transition_height;
  _bin_z = _throat_z + funnel_height;

  // Inner surfaces, inset horizontally by one wall.
  _inner_x = top_x - 2 * wall;
  _inner_y = top_y - 2 * wall;
  _inner_throat = throat - 2 * wall;

  // A corner radius cannot follow the wall inward past zero, so it floors.
  // The consequence is a sharper inside corner than outside, which is where a
  // pellet bridge anchors.
  _inner_throat_radius = max(throat_radius - wall, 0.8);
  _inner_funnel_radius = max(funnel_radius - wall, 0.8);

  difference() {
    union() {
      cylinder(h = _neck_height, d = joint_neck_od(joint));
      joint_tabs_solid(joint);

      // Round neck out to the square throat.
      loft(_neck_height, _throat_z) {
        circle(d = joint_neck_od(joint));
        rounded_square(throat, throat, throat_radius);
      }

      // Throat out to the full bin section.
      loft(_throat_z, _bin_z) {
        rounded_square(throat, throat, throat_radius);
        rounded_square(top_x, top_y, funnel_radius);
      }

      translate([0, 0, _bin_z]) rounded_box(top_x, top_y, bin_height, funnel_radius);
    }

    // Pellet path, matching the outer stations one wall in.
    translate([0, 0, -1]) cylinder(h = _neck_height + 2, d = _bore);

    // The lower section is thickened because it is buried inside the bore
    // above, where extra thickness cannot reach an exposed surface.
    loft(_neck_height, _throat_z, slab0 = 2) {
      circle(d = _bore);
      rounded_square(_inner_throat, _inner_throat, _inner_throat_radius);
    }

    loft(_throat_z, _bin_z) {
      rounded_square(_inner_throat, _inner_throat, _inner_throat_radius);
      rounded_square(_inner_x, _inner_y, _inner_funnel_radius);
    }

    // Open to the top: the cap closes it.
    translate([0, 0, _bin_z - 0.5])
      rounded_box(_inner_x, _inner_y, bin_height + 2, _inner_funnel_radius);
  }
}

// Standalone preview.
$fn = $preview ? 48 : 120;
hopper_body(joint = hopper_joint(), top_x = 220, top_y = 180, bin_height = 75, funnel_height = 80);
