// Four-tab bayonet joint between the hopper body and the roof mount.
// GPL-3.0-or-later
// Units: mm, degrees

use <hopper_util.scad>

// The body's tabs and the mount's slots are cut from ONE joint spec, passed to
// both parts by the driver. Handing each part its own copy of a dozen loose
// dimensions makes a joint that does not mate a silent, buildable mistake.
//
// This whole file is the seam for replacing the hand-rolled joint with
// bayonet-lock-scad: it is the only place the coupling geometry is defined.

// Field order matches the constructor.
_JOINT_NECK_OD = 0;
_JOINT_NECK_HEIGHT = 1;
_JOINT_TAB_WIDTH = 2;
_JOINT_TAB_DEPTH = 3;
_JOINT_TAB_HEIGHT = 4;
_JOINT_TAB_Z = 5;
_JOINT_TABS = 6;
_JOINT_ROTATION = 7;
_JOINT_CLEARANCE = 8;
_JOINT_Z_CLEARANCE = 9;
_JOINT_SOCKET_WALL = 10;
_JOINT_BORE_DIAMETER = 11;

/**
 * Build a joint spec. Every dimension the two halves must agree on lives here,
 * so a mismatch is impossible by construction rather than by discipline.
 *
 * `rotation` is the quarter-turn travel: the body is inserted that many degrees
 * counter-clockwise of its seated position, then turned clockwise to lock.
 */
function hopper_joint(
  neck_od = 44,
  neck_height = 18,
  tab_width = 10,
  tab_depth = 3,
  tab_height = 4,
  tab_z = 4,
  tabs = 4,
  rotation = 25,
  clearance = 0.30,
  z_clearance = 0.25,
  socket_wall = 4,
  bore_diameter = 38
) =
  assert(neck_od > 0, str("hopper_joint: neck_od must be > 0, got: ", neck_od))
  assert(
    bore_diameter > 0 && bore_diameter < neck_od,
    str("hopper_joint: bore_diameter must be 0..", neck_od, ", got: ", bore_diameter)
  )
  assert(tabs >= 2, str("hopper_joint: tabs must be >= 2, got: ", tabs))
  assert(
    tab_z + tab_height < neck_height,
    str(
      "hopper_joint: tab_z + tab_height (",
      tab_z + tab_height,
      ") must be < neck_height (",
      neck_height,
      ") or the tab runs off the top of the neck"
    )
  )
  assert(clearance > 0, str("hopper_joint: clearance must be > 0, got: ", clearance))
  assert(z_clearance > 0, str("hopper_joint: z_clearance must be > 0, got: ", z_clearance))
  [
    neck_od, neck_height, tab_width, tab_depth, tab_height, tab_z,
    tabs, rotation, clearance, z_clearance, socket_wall, bore_diameter,
  ];

function joint_neck_od(joint) = joint[_JOINT_NECK_OD]; //! Outside diameter of the body's locking neck
function joint_neck_height(joint) = joint[_JOINT_NECK_HEIGHT]; //! Height of the locking neck
function joint_tab_width(joint) = joint[_JOINT_TAB_WIDTH]; //! Circumferential width of one tab
function joint_tab_depth(joint) = joint[_JOINT_TAB_DEPTH]; //! Radial projection of one tab
function joint_tab_height(joint) = joint[_JOINT_TAB_HEIGHT]; //! Axial height of one tab
function joint_tab_z(joint) = joint[_JOINT_TAB_Z]; //! Height of the tab above the neck bottom
function joint_tabs(joint) = joint[_JOINT_TABS]; //! Number of tabs, evenly spaced
function joint_rotation(joint) = joint[_JOINT_ROTATION]; //! Quarter-turn travel to lock
function joint_clearance(joint) = joint[_JOINT_CLEARANCE]; //! Radial fit between neck and socket
function joint_z_clearance(joint) = joint[_JOINT_Z_CLEARANCE]; //! Vertical slack around a tab
function joint_socket_wall(joint) = joint[_JOINT_SOCKET_WALL]; //! Material outboard of the tab groove
function joint_bore_diameter(joint) = joint[_JOINT_BORE_DIAMETER]; //! Pellet bore through the joint

// Angular pitch between tabs.
function joint_tab_pitch(joint) = 360 / joint_tabs(joint);

// Bore of the socket the neck turns inside.
function joint_socket_inner_d(joint) =
  joint_neck_od(joint) + 2 * joint_clearance(joint);

// Outside of the socket, clearing the tab groove plus its wall.
function joint_socket_outer_d(joint) =
  joint_neck_od(joint) + 2 * (joint_tab_depth(joint) + joint_socket_wall(joint));

function joint_slot_width(joint) =
  joint_tab_width(joint) + 2 * joint_clearance(joint);

// Radial depth of the slot and groove. The trailing term is slack beyond the
// tab tip so the tab never bottoms out radially while turning.
function joint_slot_radial(joint) =
  joint_tab_depth(joint) + joint_clearance(joint) + 0.8;

function joint_groove_height(joint) =
  joint_tab_height(joint) + 2 * joint_z_clearance(joint);

/**
 * Half the angle a tab subtends at its own mid-radius. The rotation groove is
 * widened by this at both ends so the tab can travel its full `rotation`
 * without its trailing edge fouling the groove end.
 */
function joint_tab_half_angle(joint) =
  atan(
    (joint_slot_width(joint) / 2) /
    (joint_neck_od(joint) / 2 + joint_tab_depth(joint) / 2)
  );

// Tabs on the body neck. Each is sunk slightly into the neck so it welds to it
// rather than meeting on a coincident face.
module joint_tabs_solid(joint, weld = 0.2) {
  for (i = [0:joint_tabs(joint) - 1]) {
    rotate([0, 0, i * joint_tab_pitch(joint)])
      translate([
        joint_neck_od(joint) / 2 - weld,
        -joint_tab_width(joint) / 2,
        joint_tab_z(joint),
      ])
        cube([joint_tab_depth(joint) + weld, joint_tab_width(joint), joint_tab_height(joint)]);
  }
}

/**
 * The cuts that turn a plain socket into a bayonet receiver, positioned for a
 * mount whose flange top sits at `z`.
 *
 * Each tab needs a vertical slot to drop through and a horizontal groove to
 * turn along. The material left below the groove is what actually carries the
 * hanging load, so the groove is cut to the tab height plus slack and no more.
 */
module joint_socket_cuts(joint, z = 0, weld = 0.3) {
  _pitch = joint_tab_pitch(joint);
  _bottom = z + joint_tab_z(joint) - joint_z_clearance(joint);
  _radius = joint_socket_inner_d(joint) / 2 - weld;

  for (i = [0:joint_tabs(joint) - 1]) {
    _at = i * _pitch;

    // Entry slot, offset counter-clockwise of the seated position by the full
    // turn, running from the tab's seated height up through the top of the neck.
    rotate([0, 0, _at - joint_rotation(joint)])
      translate([_radius, -joint_slot_width(joint) / 2, _bottom])
        cube([
          joint_slot_radial(joint),
          joint_slot_width(joint),
          joint_neck_height(joint) - joint_tab_z(joint) + joint_z_clearance(joint) + 1,
        ]);

    // Rotation groove, swept from the entry slot round to the seated position.
    rotate([0, 0, _at - joint_rotation(joint) - joint_tab_half_angle(joint)])
      rotate_extrude(
        angle = joint_rotation(joint) + 2 * joint_tab_half_angle(joint),
        convexity = 10
      )
        translate([_radius, _bottom])
          square([joint_slot_radial(joint), joint_groove_height(joint)]);
  }
}

// Standalone preview: a neck with tabs beside the socket that receives it.
$fn = $preview ? 48 : 120;
_demo = hopper_joint();
cylinder(h = joint_neck_height(_demo), d = joint_neck_od(_demo));
joint_tabs_solid(_demo);
translate([joint_socket_outer_d(_demo) + 10, 0, 0]) difference() {
  cylinder(h = joint_neck_height(_demo), d = joint_socket_outer_d(_demo));
  translate([0, 0, -1]) cylinder(h = joint_neck_height(_demo) + 2, d = joint_socket_inner_d(_demo));
  joint_socket_cuts(_demo);
}
