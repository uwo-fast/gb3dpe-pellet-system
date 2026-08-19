// Example: the shipping configuration -- 202 x 202 for regrind flake, in two
// bolted segments, laid out as they are printed rather than as they stack.
// GPL-3.0-or-later

use <../cad/hopper/hopper_body.scad>;
use <../cad/hopper/hopper_funnel.scad>;
use <../cad/hopper/hopper_joint.scad>;
use <../cad/hopper/hopper_split.scad>;
include <../cad/hopper/hopper_colours.scad>;
include <../cad/hopper/hopper_feedstock.scad>;

$fn = $preview ? 64 : 128;

top_x = 202;
top_y = 202;
throat = 58;
min_wall = 3;
segments = 2;
segment_height = 205;
lock_height = 18;
neck_transition_height = 10;

stock = FEEDSTOCK_REGRIND;
funnel_angle = feedstock_min_funnel_angle(stock);

joint = hopper_joint();

// The angle is the input and the drop follows; storage takes what is left of
// the segment height. This is the same derivation the driver does.
funnel_height = funnel_height_for_angle(top_x, top_y, throat, funnel_angle);
body_height = segments * segment_height;
bin_height = body_height - lock_height - neck_transition_height - funnel_height;

echo(str(
  feedstock_name(stock), " at ", funnel_angle, " deg: funnel ", funnel_height,
  " mm, bin ", bin_height, " mm, ", segments, " segments of ", segment_height, " mm"
));

// Each segment dropped to z = 0, side by side, the way they go on the bed.
for (i = [0:segments - 1])
  translate([i * (top_x + 40), 0, -split_z(body_height, segments, i)])
    color(colour_body_segment(i))
      hopper_body(
        joint=joint,
        top_x=top_x,
        top_y=top_y,
        bin_height=bin_height,
        funnel_height=funnel_height,
        throat=throat,
        min_wall=min_wall,
        segments=segments,
        segment=i
      );
