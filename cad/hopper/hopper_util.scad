// Shared geometry helpers.
// GPL-3.0-or-later
// Units: mm

// These names are deliberately unprefixed because this project carries no
// library that defines them. A local module silently shadows a library one of
// the same name with no warning at all, so check for collisions before adding
// BOSL2, NopSCADlib or anything else global to this repo.

// This file never sets $fn: it is the consumer's to choose, and it crosses a
// `use <>` boundary as a special variable.

/**
 * Largest corner radius a rounded_square of this size can actually take.
 * offset() silently produces degenerate geometry once the radius exceeds half
 * the short side, so the request is clamped rather than left to misbehave.
 */
function fitted_radius(x, y, radius) = min(radius, min(x, y) / 2 - 0.01);

// Rectangle of x by y centred on the origin, corners rounded to `radius`.
module rounded_square(x, y, radius = 0) {
  assert(x > 0 && y > 0, str("rounded_square: x and y must be > 0, got: ", [x, y]));
  assert(radius >= 0, str("rounded_square: radius must be >= 0, got: ", radius));

  _radius = fitted_radius(x, y, radius);

  if (_radius <= 0) {
    square([x, y], center = true);
  } else {
    // offset out then in leaves the outer corners rounded and the size intact.
    offset(r = _radius) offset(delta = -_radius) square([x, y], center = true);
  }
}

// Extrusion of rounded_square, sitting on z = 0.
module rounded_box(x, y, z, radius = 0) {
  assert(z > 0, str("rounded_box: z must be > 0, got: ", z));

  linear_extrude(height = z) rounded_square(x, y, radius);
}

/**
 * Loft between two 2D sections, the first at z0 and the second at z1.
 *
 * Each section is extruded into a thin slab centred on its z and the two are
 * hulled. The slab has thickness so that adjoining lofts overlap and weld into
 * one solid instead of meeting on a coincident face, which CGAL will not always
 * resolve. Because the hull is taken between the slab EDGES, the resulting
 * taper runs from the bottom of the lower slab to the bottom of the upper one,
 * so z1 - z0 is the true rise of the sloped face.
 *
 * The two slabs are sized independently because a section that is already
 * buried inside an adjoining solid can be given extra thickness to guarantee
 * the weld without disturbing the exposed profile.
 */
module loft(z0, z1, slab0 = 1, slab1 = 1) {
  assert(z1 > z0, str("loft: z1 must be > z0, got: ", [z0, z1]));
  assert(slab0 > 0 && slab1 > 0, str("loft: slabs must be > 0, got: ", [slab0, slab1]));

  hull() {
    translate([0, 0, z0 - slab0 / 2]) linear_extrude(height = slab0) children(0);
    translate([0, 0, z1 - slab1 / 2]) linear_extrude(height = slab1) children(1);
  }
}

// Standalone preview. `use <>` does not run this; `include <>` would.
$fn = $preview ? 48 : 120;
rounded_box(40, 25, 6, 4);
translate([60, 0, 0]) loft(0, 30) {
  circle(d = 12);
  rounded_square(40, 25, 6);
}
