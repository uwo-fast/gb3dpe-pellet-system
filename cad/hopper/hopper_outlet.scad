// Outlet: twists into the hub's underside and takes the conveyor hose.
// GPL-3.0-or-later
// Units: mm

use <hopper_funnel.scad>
use <hopper_specs.scad>
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
 * The groove a hose's reinforcing rib winds into: the rib's own circular
 * section swept along the helix it is wound on, as one polyhedron. A ROUND
 * thread, so the crest between turns is blunt.
 *
 * NOT linear_extrude(twist=), which is what this was. At this radius and pitch
 * that collapses the section: measured 292 mm3 against the 2557 mm3 of helical
 * rod it should be, i.e. an 11% thread, which no hose would ever screw into.
 * Hulling spheres along the path is also correct and CGAL never finishes it.
 *
 * Handedness has to match the hose or it simply will not start. Generated
 * right-handed; mirroring reverses the helix.
 *
 * `depth` is the socket it has to thread, measured from the mouth at z = 0. The
 * sweep runs a full lead beyond that at BOTH ends, because it begins and ends on
 * a flat cap and a cap that lands inside the part leaves solid material where
 * the groove should be. Half a lead of margin is not enough: at 8.5 mm pitch a
 * cap 0.5 mm below the mouth blocks 57 degrees of the entry -- the rib meets a
 * wall instead of a groove, which is a hose that will not start.
 */
module hose_thread(hose, depth, clearance = 0.2, seg = 64, sec = 32) {
  _r = hose_helix_radius(hose);
  _rs = (hose_helix(hose) + clearance) / 2;
  _lead = hose_pitch(hose);
  _n = round((depth + 2 * _lead) / _lead * seg);

  mirror([hose_handed(hose) == "right" ? 0 : 1, 0, 0])
    polyhedron(
      points=[
        for (i = [0:_n]) let (a = 360 * i / seg, z = i / seg * _lead - _lead) for (j = [0:sec - 1]) let (t = 360 * j / sec) [(_r + _rs * cos(t)) * cos(a), (_r + _rs * cos(t)) * sin(a), z + _rs * sin(t)],
      ],
      faces=concat(
        [[for (j = [sec - 1:-1:0]) j]],
        [[for (j = [0:sec - 1]) _n * sec + j]],
        [
          for (i = [0:_n - 1]) for (j = [0:sec - 1]) let (k = (j + 1) % sec) [i * sec + j, i * sec + k, (i + 1) * sec + k, (i + 1) * sec + j],
        ]
      ),
      convexity=8
    );
}

// Overlap used wherever two solids would otherwise meet on a coincident plane.
_WELD = 0.5;

// Sized on the THREAD clearance, because the rib is the outermost thing the
// socket has to swallow.
function outlet_socket_od(hose, wall = 3, thread_clearance = 0.2) =
  hose_outside(hose) + thread_clearance + 2 * wall;

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
  // Two fits, not one. The tube slides in the bore; the rib winds into the
  // groove. They are different fits on a moulded part nobody has measured a
  // tolerance for, so they tune separately -- see cad/coupons/hose_thread_coupon.scad.
  bore_clearance = 0.2,
  thread_clearance = 0.2
) {
  _socket_od = outlet_socket_od(hose, wall, thread_clearance);
  _cone_h = outlet_cone_height(joint, hose, cone_angle);
  _height = outlet_height(joint, hose, cone_angle, socket_depth);
  _neck_z = _height - joint_neck_height(joint);

  assert(
    socket_depth >= 2 * hose_pitch(hose),
    str(
      "hopper_outlet: socket_depth (", socket_depth,
      ") gives under two turns at a ", hose_pitch(hose),
      " mm pitch; the hose would strip out"
    )
  );
  assert(
    _socket_od < joint_neck_od(joint),
    str(
      "hopper_outlet: hose socket (", _socket_od,
      ") is wider than the neck (", joint_neck_od(joint),
      "), so the outer wall would overhang outward instead of in"
    )
  );

  difference() {
    union() {
      cylinder(h=socket_depth, d=_socket_od);
      // Flares out to meet the neck. Gentle enough to print unsupported.
      translate([0, 0, socket_depth])
        cylinder(h=_cone_h, d1=_socket_od, d2=joint_neck_od(joint));

      // Collar straddling the cone/neck junction. The cone ends exactly where
      // the neck begins, and two solids meeting on a coincident plane are not
      // reliably one volume -- without this the outlet is two disconnected
      // pieces that render clean and slice as two objects.
      translate([0, 0, _neck_z - _WELD])
        cylinder(h=2 * _WELD, d=joint_neck_od(joint));

      translate([0, 0, _neck_z]) joint_neck_inverted(joint);
    }

    // Hose bore and its thread, opening downward at the bed face.
    translate([0, 0, -1])
      cylinder(h=socket_depth + 1, d=hose_tube_od(hose) + bore_clearance);
    hose_thread(hose, socket_depth, thread_clearance);

    // The converging pellet path: hose bore up to the coupling's full bore.
    translate([0, 0, socket_depth])
      cylinder(h=_cone_h, d1=hose_bore(hose), d2=joint_bore_diameter(joint));

    // Straight through the neck.
    translate([0, 0, _neck_z - 0.5])
      cylinder(h=joint_neck_height(joint) + 1, d=joint_bore_diameter(joint));
  }
}

// Standalone preview. A NAMED facet count, not an inline $fn, so drift.py can
// render this and the driver's version of the same part at matched resolution.
preview_facets = $preview ? 48 : 96;
hopper_outlet(joint=hopper_joint(), hose=hose(0), $fn=preview_facets);
