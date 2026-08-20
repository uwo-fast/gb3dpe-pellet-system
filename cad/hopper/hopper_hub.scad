// Hub: the double-ended coupling the body and the outlet both twist into.
// GPL-3.0-or-later
// Units: mm

use <hopper_joint.scad>

// The hub exists so that nothing has to connect to the plate. A bayonet socket
// accepts from one end only, so a plate with a connection on each face always
// has one facing the bed and cannot be printed either way up. Moving both
// sockets onto a short tube leaves the plate as a flat piece of material with
// holes in it.
//
// It is bolted down rather than clamped by the outlet. That keeps the hopper
// retained when the outlet is twisted off to clear a jam, and stops the hub
// turning when the body is twisted into it.
//
// The bore is not reduced anywhere. The hose is 20 mm, so the path has to
// converge somewhere, and a converging section is where material arches -- so
// that convergence belongs in the outlet, the part that twists off, not in the
// part that is bolted down. That is also why both ends use the same coupling
// rather than a smaller one at the bottom.
//
// See docs/interfaces.md.

// Fixings are squeezed from both sides: outboard of the plate's clearance hole,
// and deep enough into the skirt to actually hold a screw. At a 45 degree flare
// the available depth at a given radius is simply skirt_radius - bolt_radius.
function hub_bolt_circle(skirt_diameter, bolt_depth) = skirt_diameter - 2 * bolt_depth;

// A 45 degree flare, so the skirt never overhangs.
function hub_skirt_height(joint, skirt_diameter) =
  (skirt_diameter - joint_socket_outer_d(joint)) / 2;

// What a plate has to clear: the outlet neck's PINS, not its neck.
function hub_plate_hole(joint, clearance = 1.0) =
  2 * (joint_interface_radius(joint) - joint_allowance(joint) / 2 + joint_pin_radius(joint))
  + clearance;

function hub_height(joint) = 2 * joint_neck_height(joint);

/**
 * The hub, sitting on z = 0 on its bottom face.
 *
 * Outlet socket at the bottom, body socket at the top, straight through.
 * Prints standing on that bottom face: the skirt is widest at the bed and
 * tapers inward going up, so nothing overhangs and both sockets are internal.
 */
module hopper_hub(
  joint,
  skirt_diameter = 95,
  bolts = 4,
  bolt_diameter = 4.2,
  bolt_depth = 8,
  bolt_angle = 45
) {
  _socket_od = joint_socket_outer_d(joint);
  _half = joint_neck_height(joint);
  _skirt_h = hub_skirt_height(joint, skirt_diameter);
  _bolt_r = hub_bolt_circle(skirt_diameter, bolt_depth) / 2;
  _hole_r = hub_plate_hole(joint) / 2;

  assert(
    skirt_diameter > _socket_od,
    str("hopper_hub: skirt_diameter (", skirt_diameter, ") must exceed the socket OD (", _socket_od, ")")
  );
  assert(
    _bolt_r - bolt_diameter / 2 > _hole_r,
    str(
      "hopper_hub: fixings at r ", _bolt_r, " would break into the plate's clearance hole at r ",
      _hole_r, ". Widen the skirt or shorten bolt_depth."
    )
  );
  // Depth is exact by construction: the bolt circle is placed bolt_depth in
  // from the skirt edge, and the flare is 45 degrees, so the material above a
  // fixing is always exactly bolt_depth deep.

  difference() {
    union() {
      // Skirt: widest at the bed, tapering IN going up, so it never overhangs.
      // Bored to the same diameter the plate clears, and bored BEFORE the
      // sockets are added -- at the shell diameter it would fill in the lower
      // socket's own channels, since the neck's pins stand proud of its shell.
      difference() {
        cylinder(h = _skirt_h, d1 = skirt_diameter, d2 = _socket_od);
        translate([0, 0, -1]) cylinder(h = _skirt_h + 2, d = hub_plate_hole(joint));
      }

      // Outlet socket, opening downward at the bed face.
      joint_socket_inverted(joint);

      // Body socket, opening upward.
      translate([0, 0, _half]) joint_socket(joint);
    }

    // Blind fixings up into the bottom face, for self-tapping screws or inserts.
    for (i = [0:bolts - 1])
      rotate([0, 0, i * 360 / bolts + bolt_angle])
        translate([_bolt_r, 0, -1])
          cylinder(h = bolt_depth + 1, d = bolt_diameter);
  }
}

// Standalone preview. $fn passed on the call, never assigned at top level.
hopper_hub(joint = hopper_joint(), $fn = $preview ? 64 : 160);
