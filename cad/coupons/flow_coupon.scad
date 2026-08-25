// Flow test coupon: the bottom of the funnel, printed to be poured through.
// GPL-3.0-or-later
// Units: mm

// include, not use: the feedstock rows are variables, and variables do not
// cross a use<> boundary -- only modules and functions do.
include <../hopper/hopper_specs.scad>
use <../hopper/hopper_funnel.scad>
use <../hopper/hopper_util.scad>

// The whole design rests on the funnel wall angle, and those angles are design
// targets from general practice rather than measurements. The critical
// mass-flow angle depends on the wall friction of the surface the material
// slides on, which for a printed part -- layer lines running horizontally round
// the funnel -- is nothing like the steel those figures assume.
//
// This is the cheapest way to find out. Real angle, real throat, real wall
// inset, real corner radii. PRINT IT ON THE MACHINE AND IN THE MATERIAL THAT
// WILL PRINT THE HOPPER, at the same layer height: the surface finish IS the
// experiment, and a coupon printed some other way answers a question nobody
// asked.
//
// Fill it, let it discharge, and watch three things: whether it starts without
// a tap, whether it empties completely, and whether the whole surface moves or
// it drains a channel down the middle and leaves the rest standing. That last
// one is ratholing, and it is the failure that matters -- a hopper that
// ratholes holds far less than its volume says.
//
// The funnel and the stand print SEPARATELY. The funnel is then a simple
// tapered shell with nothing hanging off it, and one stand serves every angle
// you want to compare, which is the point of testing more than one.

// One stand has to fit every funnel, so the flange is a FIXED outer size
// regardless of angle -- only its width changes. Deriving it from the funnel
// instead would give each angle its own flange and defeat the sharing.
FLOW_FLANGE_OUTER = 150;
FLOW_STAND_OPENING = 132;

/**
 * Top opening that puts the funnel at `angle` for a given drop, so the coupon
 * reproduces the production wall rather than approximating it.
 */
function coupon_top(throat, angle, height) =
  throat + 2 * (height / tan(angle)) / sqrt(2);

/**
 * The funnel alone. Sits on z = 0 at its throat.
 *
 * PRINTS INVERTED -- flange flat on the bed, throat upward. Every surface then
 * slopes inward going up and nothing overhangs, and the flange gives the
 * largest possible first layer.
 */
module flow_coupon(
  angle = 70,
  height = 80,
  throat = 58,
  min_wall = 3,
  throat_radius = 6,
  funnel_radius = 8,
  flange_outer = FLOW_FLANGE_OUTER,
  flange_thickness = 6
) {
  _top = coupon_top(throat, angle, height);
  _inset = funnel_wall_inset(min_wall, angle);
  _it = throat - 2 * _inset;
  _ix = _top - 2 * _inset;

  assert(
    throat_radius - _inset >= 0.8,
    str(
      "flow_coupon: throat_radius (", throat_radius, ") must exceed the wall inset (",
      _inset, ") by 0.8 or the inner corner cannot follow the wall in"
    )
  );
  assert(
    _top + 2 <= FLOW_STAND_OPENING,
    str(
      "flow_coupon: at ", angle, " degrees the funnel is ", _top,
      " across, which will not pass the stand's ", FLOW_STAND_OPENING,
      " mm opening. Shallower angles need a taller stand opening, or a shorter drop."
    )
  );
  assert(
    flange_outer - _top >= 16,
    str(
      "flow_coupon: at ", angle, " degrees the flange is only ",
      (flange_outer - _top) / 2, " mm wide; it has to land on the stand's ring"
    )
  );

  _volume = funnel_volume_l(_ix, _ix, _it, height);
  echo(str(
    "flow coupon: ", angle, " deg corner, ", _top, " mm top, ", height, " mm drop, throat ",
    throat, "; holds ", _volume, " L = ",
    _volume * feedstock_bulk_density(FEEDSTOCK_REGRIND), " kg regrind"
  ));

  difference() {
    union() {
      loft(0, height) {
        rounded_square(throat, throat, throat_radius);
        rounded_square(_top, _top, funnel_radius);
      }
      // Flange: rests on the stand, and stops it overfilling.
      translate([0, 0, height])
        rounded_box(flange_outer, flange_outer, flange_thickness, funnel_radius);
    }

    loft(-1, height) {
      rounded_square(_it, _it, throat_radius - _inset);
      rounded_square(_ix, _ix, funnel_radius - _inset);
    }
    translate([0, 0, height - 0.5])
      rounded_box(_ix, _ix, flange_thickness + 1, funnel_radius - _inset);
  }
}

/**
 * The stand. Reusable across every angle, because the flange it carries is a
 * fixed size.
 *
 * PRINTS INVERTED -- ring flat on the bed, legs upward. Nothing overhangs that
 * way; printed the other way up the ring is a horizontal ledge on four legs.
 */
module flow_stand(
  opening = FLOW_STAND_OPENING,
  // Wider than the flange it carries, so the legs have a band of ring to stand
  // on. Sized to the flange instead leaves a 9 mm band and the legs hang off it.
  outer = 170,
  ring = 8,
  height = 90,
  legs = 4,
  leg_width = 16,
  // Legs splay outward toward the feet. It widens the base, stiffens them
  // against splaying under load, and costs nothing to print: a few millimetres
  // over the leg height is only a couple of degrees off vertical.
  leg_draft = 5,
  corner_radius = 8
) {
  assert(outer > opening, str("flow_stand: outer (", outer, ") must exceed opening (", opening, ")"));
  assert(
    leg_width <= (outer - opening) / 2,
    str(
      "flow_stand: legs are ", leg_width, " wide but the ring band is only ",
      (outer - opening) / 2, ". Widen the stand or narrow the legs."
    )
  );
  assert(
    outer > FLOW_FLANGE_OUTER,
    str("flow_stand: outer (", outer, ") must exceed the coupon flange (",
        FLOW_FLANGE_OUTER, ") it has to carry")
  );

  assert(
    atan(leg_draft / height) < 30,
    str("flow_stand: leg_draft ", leg_draft, " over ", height,
        " mm is ", atan(leg_draft / height), " degrees off vertical -- too much to print clean")
  );

  _leg_r = (opening + outer) / 4;

  union() {
    difference() {
      rounded_box(outer, outer, ring, corner_radius);
      translate([0, 0, -1]) rounded_box(opening, opening, ring + 2, corner_radius);
    }

    // Legs at the mid-faces, overlapping the ring so they are one solid.
    //
    // No ring tying their far ends. In the print orientation the CARRYING ring
    // is the one on the bed, so a second ring at the other end does nothing for
    // adhesion -- its only job was stiffening the leg ends, and four splayed
    // legs on a 170 mm ring already tip at about 34 degrees under a coupon that
    // weighs well under a kilogram. Dropping it is one less feature and a
    // cleaner print.
    for (i = [0:legs - 1])
      rotate([0, 0, i * 360 / legs])
        hull() {
          translate([_leg_r, 0, 0]) rounded_box(leg_width, leg_width, 0.01, 2);
          translate([_leg_r, 0, height - 0.01])
            rounded_box(leg_width + 2 * leg_draft, leg_width + 2 * leg_draft, 0.01, 2);
        }
  }
}

// Standalone preview and export.
render_part = "coupon"; // [coupon,stand,both]
angle = 70; // [40:1:80]
height = 80;
preview_facets = $preview ? 48 : 96;

if (render_part == "coupon")
  flow_coupon(angle = angle, height = height, $fn = preview_facets);
else if (render_part == "stand")
  flow_stand($fn = preview_facets);
else {
  flow_coupon(angle = angle, height = height, $fn = preview_facets);
  translate([FLOW_FLANGE_OUTER + 30, 0, 0]) flow_stand($fn = preview_facets);
}
