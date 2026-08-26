// Bayonet joint between the hopper body and the roof mount.
// GPL-3.0-or-later
// Units: mm, degrees

use <bayonet-lock-scad/bayonet_lock.scad>

// Built on bayonet-lock-scad, installed as a global OpenSCAD library. It has no
// git tags, so pin it by commit: 85c43ae (v0.11.0). At least 0.9.1 is required,
// which fixed the z alignment of the two halves when entry_depth is not half of
// part_height -- exactly the case used here.
//
// Both halves come from ONE joint spec built by the driver, so a mismatch is
// impossible by construction rather than by discipline.
//
// TWO THINGS THE LIBRARY WILL NOT DO FOR YOU, both verified here by rendering:
//
// 1. MATING CONVENTION. The library README says instantiating both halves at a
//    common origin gives the locked position. It does not: a common origin is
//    the ENTRY position, pins sitting at the channel mouths. For
//    turn_direction "CCW" the locked position is +sweep_angle. Measured by
//    intersecting the halves -- at +25 they seat with no interference and, when
//    lifted by entry_depth, stay captured with 99.6 mm3 of overlap; at 0 they
//    lift straight out. So joint_neck() is authored pre-rotated, which is what
//    lets the driver place the body at its nominal orientation and have it be
//    seated. Get this wrong and the bin sits 25 degrees skew to the roof.
//
// 2. THE ASSERTS BELOW. The library checks sweep_angle against the raw pin gap
//    but not the sweep's own tangency extension, so adjacent channels can merge
//    into a continuous slot -- leaving no retention at all -- while every
//    library assert passes. It also never checks that the channel stays inside
//    the part, nor that the shell is thinner than the interface radius, and
//    either failure produces a plausible-looking part with no locking.
//
// See docs/design-notes.md.

_JOINT_INTERFACE_RADIUS = 0;
_JOINT_SHELL_THICKNESS = 1;
_JOINT_ALLOWANCE = 2;
_JOINT_PART_HEIGHT = 3;
_JOINT_ENTRY_DEPTH = 4;
_JOINT_PIN_RADIUS = 5;
_JOINT_SWEEP_ANGLE = 6;
_JOINT_PINS = 7;
_JOINT_KEY_ANGLE = 8;
_JOINT_BORE_DIAMETER = 9;

/**
 * Build a joint spec.
 *
 * Defaults are a 58 mm neck turning inside a 72 mm socket, 18 mm deep, on a
 * 25 degree quarter turn, with a 50 mm pellet bore.
 *
 * The bore is why the coupling is this size. It is the hopper's converging
 * outlet, so it is where arches form, and 50 mm is ten times the 5 mm flake the
 * build is specified for. The imported 44 mm neck capped the outlet at 38 mm,
 * which is under that. Sizing runs outlet -> interface_radius, not the reverse.
 *
 * `key_angle` pulls one pin off the even pattern so the joint has a single
 * locked orientation. The bin is rectangular, so an unkeyed four-pin pattern
 * would seat it crosswise on the roof just as happily as along it.
 */
function hopper_joint(
  interface_radius = 29.15,
  shell_thickness = 6.85,
  allowance = 0.30,
  part_height = 18,
  entry_depth = 12,
  pin_radius = 3.0,
  sweep_angle = 25,
  pins = 4,
  key_angle = 15,
  bore_diameter = 50
) =
  let (
    channel_half = bayonet_channel_half_angle(interface_radius, pin_radius, allowance),
    angles = bayonet_keyed_pin_angles(pins, key_angle),
    max_bore = 2 * (interface_radius - allowance / 2 - pin_radius)
  )
  assert(
    shell_thickness < interface_radius,
    str("hopper_joint: shell_thickness (", shell_thickness,
      ") must be < interface_radius (", interface_radius,
      ") or the half renders as a solid rod instead of a tube")
  )
  assert(
    part_height - entry_depth > pin_radius + allowance / 2,
    str("hopper_joint: the channel would break out of the bottom face. Needs ",
      "part_height - entry_depth (", part_height - entry_depth,
      ") > pin_radius + allowance/2 (", pin_radius + allowance / 2, ")")
  )
  assert(
    bore_diameter <= max_bore,
    str("hopper_joint: bore_diameter (", bore_diameter,
      ") would cut into the pins. Maximum is ", max_bore, " at pin_radius ",
      pin_radius)
  )
  assert(
    bayonet_pin_pattern_min_gap(angles) > sweep_angle + 3 * channel_half,
    str("hopper_joint: adjacent channels would merge into a continuous slot, ",
      "leaving no retention. Needs min gap (",
      bayonet_pin_pattern_min_gap(angles),
      ") > sweep_angle + 3 * channel half-angle (",
      sweep_angle + 3 * channel_half, ")")
  )
  assert(
    bayonet_pin_pattern_margin(angles) > channel_half,
    str("hopper_joint: the key is too shallow to block a wrong seating. Needs ",
      "margin (", bayonet_pin_pattern_margin(angles),
      ") > channel half-angle (", channel_half, ")")
  )
  [
    interface_radius, shell_thickness, allowance, part_height, entry_depth,
    pin_radius, sweep_angle, pins, key_angle, bore_diameter,
  ];

function joint_interface_radius(joint) = joint[_JOINT_INTERFACE_RADIUS]; //! Virtual radius the two shells straddle
function joint_shell_thickness(joint) = joint[_JOINT_SHELL_THICKNESS]; //! Radial thickness from the interface radius
function joint_allowance(joint) = joint[_JOINT_ALLOWANCE]; //! Total radial gap between the shells
function joint_neck_height(joint) = joint[_JOINT_PART_HEIGHT]; //! Height of both halves
function joint_entry_depth(joint) = joint[_JOINT_ENTRY_DEPTH]; //! Insertion travel down from the top face
function joint_pin_radius(joint) = joint[_JOINT_PIN_RADIUS]; //! Radius of one pin sphere
function joint_sweep_angle(joint) = joint[_JOINT_SWEEP_ANGLE]; //! Quarter-turn travel to lock
function joint_pins(joint) = joint[_JOINT_PINS]; //! Number of pins
function joint_bore_diameter(joint) = joint[_JOINT_BORE_DIAMETER]; //! Pellet bore through the joint

// Pin angles, keyed so the joint has exactly one locked orientation.
function joint_pin_angles(joint) =
  bayonet_keyed_pin_angles(joint_pins(joint), joint[_JOINT_KEY_ANGLE]);

// Outside of the body's neck.
function joint_neck_od(joint) =
  2 * (joint_interface_radius(joint) - joint_allowance(joint) / 2);

// Bore of the socket the neck turns inside.
function joint_socket_inner_d(joint) =
  2 * (joint_interface_radius(joint) + joint_allowance(joint) / 2);

function joint_socket_outer_d(joint) =
  2 * (joint_interface_radius(joint) + joint_shell_thickness(joint));

// Largest pellet bore that does not cut into the pins.
function joint_max_bore_diameter(joint) =
  2 * (
    joint_interface_radius(joint) - joint_allowance(joint) / 2 -
    joint_pin_radius(joint)
  );

module _bayonet_half(joint, which) {
  bayonet(
    half=which,
    interface_radius=joint_interface_radius(joint),
    shell_thickness=joint_shell_thickness(joint),
    allowance=joint_allowance(joint),
    part_height=joint_neck_height(joint),
    entry_depth=joint_entry_depth(joint),
    pin_angles=joint_pin_angles(joint),
    pin_radius=joint_pin_radius(joint),
    sweep_angle=joint_sweep_angle(joint),
    pin_direction="outer",
    turn_direction="CCW"
  );
}

/**
 * The body's neck: a tube sitting on z = 0, pins outward.
 *
 * Pre-rotated by the sweep angle so that this orientation IS the seated one.
 * To fit it, turn the body back by sweep_angle, drop it in, and turn it
 * forward to here. Its natural bore is narrow; the body opens it out to the
 * pellet bore afterwards, which joint_max_bore_diameter bounds.
 */
module joint_neck(joint) {
  rotate([0, 0, joint_sweep_angle(joint)]) _bayonet_half(joint, "pin");
}

// The mount's socket: a tube sitting on z = 0, channels cut into its bore.
module joint_socket(joint) {
  _bayonet_half(joint, "lock");
}

/**
 * The same pair turned end for end: a socket that opens DOWNWARD and the neck
 * that enters it from below. Both still occupy z = 0 to part_height.
 *
 * Turned with rotate, never mirror. Mirroring reverses a bayonet's handedness,
 * so a mirrored socket needs a neck built to the opposite turn direction to
 * mate — which renders perfectly and simply never locks. Keeping the flip in
 * here means no caller has to know that.
 */
module joint_socket_inverted(joint) {
  translate([0, 0, joint_neck_height(joint)]) rotate([180, 0, 0]) joint_socket(joint);
}

module joint_neck_inverted(joint) {
  translate([0, 0, joint_neck_height(joint)]) rotate([180, 0, 0]) joint_neck(joint);
}


// Standalone preview: the neck at the origin, the socket beside it, at the size
// the 50 mm pellet outlet demands. $fn is passed on the call, never assigned at
// top level -- that would override the driver's choice for this file's modules.
//
// The neck is authored PRE-ROTATED, so this orientation is the SEATED one, not
// the insertion one: turn it back by the sweep angle to fit it.
_demo = hopper_joint();

echo(str(
  "joint: neck OD ", joint_neck_od(_demo),
  ", socket bore ", joint_socket_inner_d(_demo),
  ", socket OD ", joint_socket_outer_d(_demo),
  ", pellet bore ", joint_bore_diameter(_demo),
  " (max ", joint_max_bore_diameter(_demo), ")"
));

joint_neck(_demo, $fn = $preview ? 64 : 160);
translate([joint_socket_outer_d(_demo) + 10, 0, 0])
  joint_socket(_demo, $fn = $preview ? 64 : 160);
