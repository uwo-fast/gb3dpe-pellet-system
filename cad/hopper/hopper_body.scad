// Hopper body: storage bin, funnel, and the bayonet neck beneath it.
// GPL-3.0-or-later
// Units: mm

use <hopper_funnel.scad>
use <hopper_joint.scad>
use <hopper_split.scad>
use <hopper_util.scad>

/**
 * The hopper body, sitting on z = 0 at the bottom of its bayonet neck.
 *
 * Built as one outer solid differenced by one inner cavity. Both are lofted
 * through the same z stations, so the two surfaces stay parallel and the wall
 * keeps a constant thickness along each face.
 *
 * `min_wall` is the LEAST material anywhere, measured perpendicular to the
 * surface. It is applied as a single horizontal inset sized on the funnel's
 * corner -- the shallowest surface -- so nothing finishes thinner than asked.
 * Flat faces and the vertical bin come out somewhat thicker. One inset also
 * keeps every inner surface parallel to its outer, so the funnel meets the bin
 * with no internal ledge for pellets to catch on.
 */
module hopper_body(
  joint,
  top_x,
  top_y,
  bin_height,
  funnel_height,
  throat = 58,
  min_wall = 3,
  throat_radius = 6,
  funnel_radius = 8,
  neck_transition_height = 10,
  segments = 1,
  segment = 0,
  flange_width = 12,
  flange_thickness = 6,
  flange_inset = 6,
  flange_bolt_diameter = 4.5,
  flange_dowel_diameter = 4
) {
  assert(min_wall > 0, str("hopper_body: min_wall must be > 0, got: ", min_wall));
  assert(segments >= 1, str("hopper_body: segments must be >= 1, got: ", segments));
  assert(
    segment >= 0 && segment < segments,
    str("hopper_body: segment must be 0..", segments - 1, ", got: ", segment)
  );
  assert(
    top_x > throat && top_y > throat,
    str("hopper_body: top_x and top_y must exceed throat, got: ", [top_x, top_y, throat])
  );
  assert(funnel_height > 0, str("hopper_body: funnel_height must be > 0, got: ", funnel_height));
  assert(bin_height > 0, str("hopper_body: bin_height must be > 0, got: ", bin_height));

  _neck_height = joint_neck_height(joint);
  _bore = joint_bore_diameter(joint);

  // The funnel's shallowest surface, and the inset that gives min_wall on it.
  _corner_angle = funnel_corner_angle(top_x, top_y, throat, funnel_height);
  _inset = funnel_wall_inset(min_wall, _corner_angle);

  assert(
    throat > 2 * _inset,
    str(
      "hopper_body: throat (", throat, ") must exceed twice the wall inset (",
      2 * _inset, ") needed for min_wall ", min_wall, " at a ", _corner_angle,
      " degree corner"
    )
  );

  // z stations, bottom up.
  _throat_z = _neck_height + neck_transition_height;
  _bin_z = _throat_z + funnel_height;

  // Inner surfaces, parallel to their outer at one inset.
  _inner_x = top_x - 2 * _inset;
  _inner_y = top_y - 2 * _inset;
  _inner_throat = throat - 2 * _inset;

  // Corner radii follow the wall inward so the inner profile stays a true
  // parallel offset of the outer. Clamping one instead would quietly thin the
  // wall at that corner -- which is both the shallowest surface and where a
  // pellet bridge anchors -- so it is asserted rather than floored. The 0.8 mm
  // limit is roughly two 0.4 mm extrusions. See docs/design-notes.md.
  _inner_throat_radius = throat_radius - _inset;
  _inner_funnel_radius = funnel_radius - _inset;

  assert(
    _inner_throat_radius >= 0.8,
    str(
      "hopper_body: throat_radius (", throat_radius, ") must be at least 0.8 more ",
      "than the wall inset (", _inset, "). Raise throat_radius to ",
      _inset + 0.8, " or more."
    )
  );
  assert(
    _inner_funnel_radius >= 0.8,
    str(
      "hopper_body: funnel_radius (", funnel_radius, ") must be at least 0.8 more ",
      "than the wall inset (", _inset, "). Raise funnel_radius to ",
      _inset + 0.8, " or more."
    )
  );

  _height = _bin_z + bin_height;
  _lo = split_z(_height, segments, segment);
  _hi = split_z(_height, segments, segment + 1);

  // Every cut has to land where the body is rectangular, so the two flanges
  // share a section. Below the taper it is round and there is nothing to bolt.
  assert(
    segments == 1 || _lo == 0 || _lo > _throat_z,
    str(
      "hopper_body: a cut at ", _lo, " falls in the neck or its transition, ",
      "below ", _throat_z, ", where the section is round. Use fewer segments ",
      "or a taller body."
    )
  );

  module _flange_at(z, up) {
    _sec = funnel_body_section(
      throat, top_x, top_y, throat_radius, funnel_radius,
      _throat_z - 0.5, funnel_height, z
    );
    translate([0, 0, z]) split_flange(
      span=[_sec[0], _sec[1]],
      radius=_sec[2],
      cavity=[_sec[0] - 2 * _inset, _sec[1] - 2 * _inset],
      cavity_radius=_sec[2] - _inset,
      width=flange_width,
      thickness=flange_thickness,
      bolt_diameter=flange_bolt_diameter,
      bolt_inset=flange_inset,
      dowel_diameter=flange_dowel_diameter,
      up=up
    );
  }

  intersection() {
    union() {
      if (segment > 0) _flange_at(_lo, true);
      if (segment < segments - 1) _flange_at(_hi, false);
      _whole();
    }
    // Slab for this segment. Generous in plan; the body bounds it.
    translate([0, 0, (_lo + _hi) / 2])
      cube([4 * top_x, 4 * top_y, _hi - _lo], center = true);
  }

  module _whole()
  difference() {
    union() {
      // Neck comes from the library pre-rotated into its seated orientation.
      // Its own bore is narrow; the pellet bore is opened out below.
      joint_neck(joint);

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

    // Pocket the retaining screw seats into. Cut after the neck is unioned in,
    // so it lands on the finished outside of the shell.
    joint_retainer_pocket(joint);

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

// Standalone preview. $fn is passed on the call, never assigned at top level:
// a use'd file's own top-level $fn is what ITS modules see, so assigning it
// here would silently override whatever the driver asked for.
hopper_body(
  joint = hopper_joint(), top_x = 220, top_y = 180, bin_height = 75,
  funnel_height = 80, $fn = $preview ? 48 : 120
);
