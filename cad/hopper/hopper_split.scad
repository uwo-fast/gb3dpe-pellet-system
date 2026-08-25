// Splitting the body into stackable segments.
// GPL-3.0-or-later
// Units: mm

use <hopper_util.scad>

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
  let (hx = x / 2 - inset, hy = y / 2 - inset)
    [
      [-hx, -hy], [0, -hy], [hx, -hy],
      [-hx, 0], [hx, 0],
      [-hx, hy], [0, hy], [hx, hy],
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
          h = thickness + 2,
          // The two diagonally opposite corners locate; the other six clamp.
          d = (i == 0 || i == len(_fixings) - 1) ? dowel_diameter : bolt_diameter
        );
  }
}
