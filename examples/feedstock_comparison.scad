// Example: what the feedstock costs in height. The same footprint at the
// shallowest angle each material will flow at, side by side.
// GPL-3.0-or-later

use <../cad/hopper/hopper_body.scad>;
use <../cad/hopper/hopper_funnel.scad>;
use <../cad/hopper/hopper_joint.scad>;
include <../cad/hopper/hopper_colours.scad>;
include <../cad/hopper/hopper_specs.scad>;

$fn = $preview ? 48 : 96;

top_x = 202;
top_y = 202;
throat = 58;
min_wall = 3;
bin_height = 60;

joint = hopper_joint();

// Virgin on the left, regrind on the right. Regrind needs the steeper wall, so
// its funnel is markedly taller for the same footprint -- which is why the body
// has to be split at all.
for (i = [0:len(feedstock_registry) - 1]) {
  stock = feedstock_registry[i];
  angle = feedstock_min_funnel_angle(stock);
  funnel_height = funnel_height_for_angle(top_x, top_y, throat, angle);

  echo(str(feedstock_name(stock), ": ", angle, " deg -> funnel ", funnel_height, " mm"));

  translate([i * (top_x + 50), 0, 0])
    color(part_colour(i))
      hopper_body(
        joint=joint,
        top_x=top_x,
        top_y=top_y,
        bin_height=bin_height,
        funnel_height=funnel_height,
        throat=throat,
        min_wall=min_wall
      );
}
