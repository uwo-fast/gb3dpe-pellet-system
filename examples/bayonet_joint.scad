// Example: the coupling on its own -- the body's neck beside the mount's
// socket, at the size the 50 mm pellet outlet demands.
// GPL-3.0-or-later

use <../cad/hopper/hopper_joint.scad>;
include <../cad/hopper/hopper_colours.scad>;

$fn = $preview ? 64 : 160;

joint = hopper_joint();

echo(str(
  "neck OD ", joint_neck_od(joint),
  ", socket bore ", joint_socket_inner_d(joint),
  ", socket OD ", joint_socket_outer_d(joint),
  ", pellet bore ", joint_bore_diameter(joint),
  " (max ", joint_max_bore_diameter(joint), ")"
));

// Neck at the origin. It is authored pre-rotated, so this orientation is the
// SEATED one, not the insertion one -- turn it back by the sweep angle to fit.
color(colour_body_segment(0)) joint_neck(joint);

// Socket beside it, for comparison.
translate([joint_socket_outer_d(joint) + 15, 0, 0])
  color(colour_mount()) joint_socket(joint);
