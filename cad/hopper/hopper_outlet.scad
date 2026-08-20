// Outlet: twists into the hub's underside and takes the conveyor hose.
// GPL-3.0-or-later
// Units: mm

use <hopper_funnel.scad>
use <hopper_hose.scad>
use <hopper_joint.scad>

// This is the part that converges. The hub runs a straight 50 mm bore and the
// hose is 20 mm, so the path has to neck down somewhere, and a converging
// section is where material arches. Putting it here — in the part that twists
// off in seconds — means the one place likely to block is also the one place
// trivial to clear. That is the whole reason interface B reuses the same
// coupling as A rather than a smaller one.
//
// It also means swapping to a different hose is a reprint of this part alone.
//
// Prints standing on the hose socket, neck upward. The outer wall flares from
// the socket out to the neck at roughly 15 degrees off vertical, which is a
// gentle overhang; the helical groove bridges over about one rib width.

/**
 * Helical groove matching a hose's reinforcing rib, as a cut tool.
 *
 * Swept by twisting an offset circle up the extrusion — the rib pitch converts
 * straight to degrees of twist per mm. Handedness has to match the hose or it
 * simply will not screw in.
 */
module _hose_thread(hose, depth, clearance = 0.4, segments_per_turn = 48) {
  _turns = depth / hose_pitch(hose);
  _sign = hose_handed(hose) == "right" ? -1 : 1;

  linear_extrude(
    height = depth,
    twist = _sign * 360 * _turns,
    slices = max(8, ceil(_turns * segments_per_turn)),
    convexity = 10
  )
    translate([hose_helix_radius(hose), 0])
      circle(d = hose_helix(hose) + clearance);
}

function outlet_socket_od(hose, wall = 3, clearance = 0.4) =
  hose_outside(hose) + clearance + 2 * wall;

/**
 * Height of the converging section, so its wall sits at `angle` from
 * horizontal — the same rule the hopper funnel is held to, since this is a
 * converging section carrying the same material.
 */
function outlet_cone_height(joint, hose, angle) =
  (joint_bore_diameter(joint) - hose_bore(hose)) / 2 * tan(angle);

function outlet_height(joint, hose, angle, socket_depth) =
  socket_depth + outlet_cone_height(joint, hose, angle) + joint_neck_height(joint);

module hopper_outlet(
  joint,
  hose,
  cone_angle = 70,
  socket_depth = 24,
  wall = 3,
  clearance = 0.4
) {
  _socket_od = outlet_socket_od(hose, wall, clearance);
  _cone_h = outlet_cone_height(joint, hose, cone_angle);
  _height = outlet_height(joint, hose, cone_angle, socket_depth);
  _neck_z = _height - joint_neck_height(joint);

  assert(
    socket_depth >= 2 * hose_pitch(hose),
    str(
      "hopper_outlet: socket_depth (", socket_depth, ") gives under two turns at a ",
      hose_pitch(hose), " mm pitch; the hose would strip out"
    )
  );
  assert(
    _socket_od < joint_neck_od(joint),
    str(
      "hopper_outlet: hose socket (", _socket_od, ") is wider than the neck (",
      joint_neck_od(joint), "), so the outer wall would overhang outward instead of in"
    )
  );

  difference() {
    union() {
      cylinder(h = socket_depth, d = _socket_od);
      // Flares out to meet the neck. Gentle enough to print unsupported.
      translate([0, 0, socket_depth])
        cylinder(h = _cone_h, d1 = _socket_od, d2 = joint_neck_od(joint));
      translate([0, 0, _neck_z]) joint_neck_inverted(joint);
    }

    // Hose bore and its thread, opening downward at the bed face.
    translate([0, 0, -1])
      cylinder(h = socket_depth + 1, d = hose_tube_od(hose) + clearance);
    translate([0, 0, -0.5]) _hose_thread(hose, socket_depth + 0.5, clearance);

    // The converging pellet path: hose bore up to the coupling's full bore.
    translate([0, 0, socket_depth])
      cylinder(h = _cone_h, d1 = hose_bore(hose), d2 = joint_bore_diameter(joint));

    // Straight through the neck.
    translate([0, 0, _neck_z - 0.5])
      cylinder(h = joint_neck_height(joint) + 1, d = joint_bore_diameter(joint));

    // Pocket the hub's retaining screw seats into.
    translate([0, 0, _neck_z]) joint_retainer_pocket_inverted(joint);
  }
}

// Standalone preview.
hopper_outlet(joint = hopper_joint(), hose = hose(0), $fn = $preview ? 48 : 96);
