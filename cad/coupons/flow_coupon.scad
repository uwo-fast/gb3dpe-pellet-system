// Flow test coupon: the bottom of the funnel, printed to be poured through.
// GPL-3.0-or-later
// Units: mm

// include, not use: the feedstock rows are variables, and variables do not
// cross a use<> boundary -- only modules and functions do.
include <../hopper/hopper_feedstock.scad>
use <../hopper/hopper_funnel.scad>
use <../hopper/hopper_util.scad>

// The whole design rests on the funnel wall angle, and those angles are design
// targets from general practice rather than measurements. The critical
// mass-flow angle depends on the wall friction of the surface the material
// slides on, which for a printed part is nothing like the steel those figures
// assume — and the shredder's output varies, which is the other half of the
// uncertainty.
//
// This is the cheapest way to find out. It is the real angle, the real throat,
// the real wall inset and the real corner radii, printed in the real material
// on the real machine, so the surface it presents is the surface the hopper
// will present. A couple of hours on the bed against two twenty-hour segments.
//
// Fill it, let it discharge, and watch for the funnel emptying completely
// rather than leaving material clinging to the walls, and for material moving
// across the whole surface rather than draining a channel down the middle and
// leaving the rest standing. If it will not start without a tap, the angle is
// too shallow for that feedstock and every capacity figure downstream needs
// revisiting.
//
// Print it in the same material and with the same layer height as the hopper
// itself: layer lines are the wall texture, and that is the thing being tested.

/**
 * Top opening that puts the funnel at `angle` for a given drop, so the coupon
 * reproduces the production wall rather than approximating it.
 */
function coupon_top(throat, angle, height) =
  throat + 2 * (height / tan(angle)) / sqrt(2);

module flow_coupon(
  angle = 70,
  height = 80,
  throat = 58,
  min_wall = 3,
  throat_radius = 6,
  funnel_radius = 8,
  rim = 6,
  legs = 4,
  leg_height = 70,
  leg_width = 12,
  base_ring = 4
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

  _volume = funnel_volume_l(_ix, _ix, _it, height);
  echo(str(
    "flow coupon: ", angle, " deg corner, ", _top, " mm top, ", height, " mm drop, throat ",
    throat, "; holds ", _volume, " L = ",
    _volume * feedstock_bulk_density(FEEDSTOCK_REGRIND), " kg regrind"
  ));

  // Legs hang from a rim flange, OUTSIDE the funnel's outer surface. Putting
  // them any closer in means the cavity cut runs straight through them: they
  // are unioned before it, so it eats whatever passes through the funnel's
  // interior, and the result is a mesh in two disconnected pieces that still
  // renders and slices happily.
  _flange = _top + 2 * leg_width;
  // Legs sit at the MID-FACES, not the corners. A rounded square reaches
  // furthest along its diagonal, so a corner leg is still inside the cavity's
  // reach even when it looks well outside the funnel -- and the cut then eats
  // it where it passes the flange. At a mid-face the cavity is nearest the
  // axis, so just outside the funnel's outer surface is genuinely clear.
  _leg_r = _top / 2 + leg_width / 2;

  difference() {
    union() {
      // The funnel itself, identical in construction to the hopper's.
      loft(0, height) {
        rounded_square(throat, throat, throat_radius);
        rounded_square(_top, _top, funnel_radius);
      }

      // Rim flange: stops it overfilling, and carries the legs.
      translate([0, 0, height]) rounded_box(_flange, _flange, rim, funnel_radius);

      for (i = [0:legs - 1])
        rotate([0, 0, i * 360 / legs])
          translate([_leg_r, 0, -leg_height])
            // Run through the flange rather than stopping on its underside:
            // two solids meeting on a coincident plane are not reliably one
            // volume, and the result is a mesh in disconnected pieces.
            rounded_box(leg_width, leg_width, leg_height + height + rim, 2);

      // Base ring tying the feet together. Without it the coupon stands on four
      // small pads under a funnel of feedstock, and the first layers are four
      // islands.
      difference() {
        translate([0, 0, -leg_height])
          rounded_box(_flange, _flange, base_ring, funnel_radius);
        translate([0, 0, -leg_height - 1])
          rounded_box(
            _flange - 2 * leg_width - 4, _flange - 2 * leg_width - 4,
            base_ring + 2, funnel_radius
          );
      }
    }

    // Pellet path, one inset in, matching the outer stations.
    loft(-1, height) {
      rounded_square(_it, _it, throat_radius - _inset);
      rounded_square(_ix, _ix, funnel_radius - _inset);
    }

    // Straight through the rim, so its wall stays one inset like the funnel's.
    translate([0, 0, height - 0.5])
      rounded_box(_ix, _ix, rim + 1, funnel_radius - _inset);
  }
}

// Standalone preview and export. Exposed so `just coupon` can sweep the angle
// without editing the file -- testing 60 against 70 on the same feedstock is
// the point of having it.
angle = 70; // [40:1:80]
height = 80;

flow_coupon(angle = angle, height = height, $fn = $preview ? 48 : 96);
