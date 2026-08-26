// Example: what the feedstock costs. The same footprint at the shallowest angle
// each material will flow at, split into the segments that height needs, and
// laid out the way the parts go on the bed.
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
segments = 2;
segment_height = 205;
neck_transition_height = 10;

joint = hopper_joint();
lock_height = joint_neck_height(joint);
body_height = segments * segment_height;

// Virgin first, regrind second. Regrind needs the steeper wall, so its funnel is
// markedly taller for the same footprint -- which is why the body has to be
// split at all, and why the shipping configuration is the regrind one.
//
// This is the same derivation the driver does: the angle is the input, the drop
// follows from it, and storage takes whatever the segments have left over.
for (i = [0:len(feedstock_registry) - 1]) {
  stock = feedstock_registry[i];
  angle = feedstock_min_funnel_angle(stock);
  funnel_height = funnel_height_for_angle(top_x, top_y, throat, angle);
  bin_height = body_height - lock_height - neck_transition_height - funnel_height;

  echo(
    str(
      feedstock_name(stock), " at ", angle, " deg: funnel ", funnel_height,
      " mm, bin ", bin_height, " mm, ", segments, " x ", segment_height, " mm segments"
    )
  );

  // Each segment dropped to z = 0, side by side, the way they go on the bed.
  for (g = [0:segments - 1])
    translate([(i * segments + g) * (top_x + 40), 0, -split_z(body_height, segments, g)])
      color(colour_body_segment(i * segments + g))
        hopper_body(
          joint=joint, top_x=top_x, top_y=top_y, bin_height=bin_height,
          funnel_angle=angle, throat=throat, min_wall=min_wall,
          neck_transition_height=neck_transition_height,
          segments=segments, segment=g
        );
}
