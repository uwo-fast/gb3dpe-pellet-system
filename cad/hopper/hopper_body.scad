// Hopper body: storage bin, funnel, the bayonet neck beneath it, and the flanged
// joint that cuts it into printable segments.
// GPL-3.0-or-later
// Units: mm

use <hopper_funnel.scad>
use <hopper_joint.scad>
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
  funnel_angle,
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
  assert(
    funnel_angle > 0 && funnel_angle < 90,
    str("hopper_body: funnel_angle is degrees from HORIZONTAL and must be in 0..90, got: ", funnel_angle)
  );
  assert(bin_height > 0, str("hopper_body: bin_height must be > 0, got: ", bin_height));

  _neck_height = joint_neck_height(joint);
  _bore = joint_bore_diameter(joint);

  // The angle is measured on the funnel's diagonal corner -- its shallowest
  // surface -- so the drop follows from it, and so does the inset that gives
  // min_wall perpendicular to that corner.
  _funnel_height = funnel_height_for_angle(top_x, top_y, throat, funnel_angle);
  _inset = funnel_wall_inset(min_wall, funnel_angle);

  assert(
    throat > 2 * _inset,
    str(
      "hopper_body: throat (", throat, ") must exceed twice the wall inset (",
      2 * _inset, ") needed for min_wall ", min_wall, " at a ", funnel_angle,
      " degree corner"
    )
  );

  // z stations, bottom up.
  _throat_z = _neck_height + neck_transition_height;
  _bin_z = _throat_z + _funnel_height;

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
      "hopper_body: throat_radius (", throat_radius,
      ") must be at least 0.8 more than the wall inset (", _inset,
      "). Raise throat_radius to ", _inset + 0.8, " or more."
    )
  );
  assert(
    _inner_funnel_radius >= 0.8,
    str(
      "hopper_body: funnel_radius (", funnel_radius,
      ") must be at least 0.8 more than the wall inset (", _inset,
      "). Raise funnel_radius to ", _inset + 0.8, " or more."
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
      "hopper_body: a cut at ", _lo,
      " falls in the neck or its transition, below ", _throat_z,
      ", where the section is round. Use fewer segments or a taller body."
    )
  );

  module _flange_at(z, up) {
    _sec = funnel_body_section(
      throat, top_x, top_y, throat_radius, funnel_radius,
      _throat_z, _funnel_height, z
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
      cube([4 * top_x, 4 * top_y, _hi - _lo], center=true);
  }

  module _whole()
    difference() {
      union() {
        // Neck comes from the library pre-rotated into its seated orientation.
        // Its own bore is narrow; the pellet bore is opened out below.
        joint_neck(joint);

        // Round neck out to the square throat.
        loft(_neck_height, _throat_z) {
          circle(d=joint_neck_od(joint));
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
      translate([0, 0, -1]) cylinder(h=_neck_height + 2, d=_bore);

      // The lower section is thickened because it is buried inside the bore
      // above, where extra thickness cannot reach an exposed surface.
      loft(_neck_height, _throat_z, slab0=2) {
        circle(d=_bore);
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

// ===== Splitting into segments =====

// A hopper tall enough to flow flake is taller than the printer, so the body is
// cut into segments that bolt back together. The cut lands wherever the height
// divides, which is part way up the funnel rather than at any natural boundary,
// so the joint is a tapered rectangular perimeter rather than a neat square.
//
// Each segment carries an outward flange at its cut face. The flanges extend
// radially only and sit inside each segment's own z range, so splitting a body
// does not make it taller.

// Height of a cut above the body base, for `index` in 1..segments-1.
function split_z(body_height, segments, index) = body_height * index / segments;

/**
 * The eight perimeter positions on a rectangular flange: four corners and the
 * middle of each side. Eight is enough to stop a printed flange bowing between
 * fixings, which is what lets a gasket seal.
 *
 * The first and last are diagonally opposite corners, and those two are DOWELS
 * rather than bolts. Bolts in clearance holes leave the shells free to slide
 * before they pull up, and a millimetre of slide steps the inside wall and
 * gives flake an edge to catch on. Dowels locate, bolts clamp. Asking the bolts
 * to do both would mean holding a reamed fit in eight printed holes, which is
 * not realistic.
 */
function split_fixing_positions(x, y, inset) =
  let (hx = x / 2 - inset, hy = y / 2 - inset) [
      [-hx, -hy],
      [0, -hy],
      [hx, -hy],
      [-hx, 0],
      [hx, 0],
      [-hx, hy],
      [0, hy],
      [hx, hy],
  ];

/**
 * The flange collar at one cut face.
 *
 * `span` and `radius` describe the body's outer section at the cut. The collar
 * grows outward from that by `width`, and is bored by the cavity so feedstock
 * still passes. `up` selects whether it hangs below the cut (the upper
 * segment's underside) or sits above it (the lower segment's top).
 */
module split_flange(
  span,
  radius,
  cavity,
  cavity_radius,
  width,
  thickness,
  bolt_diameter,
  bolt_inset,
  dowel_diameter,
  up = true
) {
  _outer = [span[0] + 2 * width, span[1] + 2 * width];
  _fixings = split_fixing_positions(_outer[0], _outer[1], bolt_inset);

  translate([0, 0, up ? 0 : -thickness]) difference() {
      rounded_box(_outer[0], _outer[1], thickness, radius + width);

      translate([0, 0, -1])
        rounded_box(cavity[0], cavity[1], thickness + 2, cavity_radius);

      for (i = [0:len(_fixings) - 1])
        translate([_fixings[i][0], _fixings[i][1], -1])
          cylinder(
            h=thickness + 2,
            // The two diagonally opposite corners locate; the other six clamp.
            d=(i == 0 || i == len(_fixings) - 1) ? dowel_diameter : bolt_diameter
          );
    }
}

// Standalone preview. $fn is passed on the call, never assigned at top level --
// see docs/design-notes.md for why that is not optional.
hopper_body(
  joint=hopper_joint(), top_x=220, top_y=180, bin_height=75,
  funnel_angle=40, $fn=$preview ? 48 : 120
);
