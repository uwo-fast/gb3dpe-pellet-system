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
// turning when the body is twisted into it. Bolts pass right through the flange
// to a nut rather than self-tapping into it: a thread cut in PETG is the weakest
// thing in that load path, and this joint carries the whole hopper.
//
// The bore is not reduced anywhere. The hose is 20 mm, so the path has to
// converge somewhere, and a converging section is where material arches -- so
// that convergence belongs in the outlet, the part that twists off, not in the
// part that is bolted down. That is also why both ends use the same coupling
// rather than a smaller one at the bottom.
//
// See docs/interfaces.md.

// Fixings pass straight through the flange and are counterbored from above, so
// the nut seats on flat material instead of on the 45 degree cone. Where the
// bolt circle sits is the free choice -- squeezed between the plate's clearance
// hole and the skirt edge -- and everything else follows from it.

// Height of the counterbore floor above the bottom face. The cone drops 1 mm
// per mm of radius, so the floor has to clear the OUTER edge of the counterbore
// for the whole seat to come out flat. What is left underneath is what the bolt
// actually clamps.
function hub_seat_z(skirt_diameter, bolt_circle, counterbore) =
  (skirt_diameter - bolt_circle - counterbore) / 2;

// A 45 degree flare, so the skirt never overhangs.
function hub_skirt_height(joint, skirt_diameter) =
  (skirt_diameter - joint_socket_outer_d(joint)) / 2;

// What a plate has to clear: the outlet neck's PINS, not its neck.
function hub_plate_hole(joint, clearance = 1.0) =
  2 * (joint_interface_radius(joint) - joint_allowance(joint) / 2 + joint_pin_radius(joint)) + clearance;

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
  bolt_circle = 79,
  bolt_diameter = 4.5,
  counterbore = 8,
  bolt_angle = 45
) {
  _socket_od = joint_socket_outer_d(joint);
  _half = joint_neck_height(joint);
  _skirt_h = hub_skirt_height(joint, skirt_diameter);
  _bolt_r = bolt_circle / 2;
  _hole_r = hub_plate_hole(joint) / 2;
  _seat_z = hub_seat_z(skirt_diameter, bolt_circle, counterbore);

  assert(
    skirt_diameter > _socket_od,
    str("hopper_hub: skirt_diameter (", skirt_diameter, ") must exceed the socket OD (", _socket_od, ")")
  );
  assert(
    _bolt_r - bolt_diameter / 2 > _hole_r,
    str(
      "hopper_hub: fixings at r ", _bolt_r,
      " would break into the plate's clearance hole at r ", _hole_r,
      ". Move the bolt circle out or widen the skirt."
    )
  );
  assert(
    _seat_z >= 3,
    str(
      "hopper_hub: a ", bolt_circle, " bolt circle with a ", counterbore,
      " counterbore leaves only ", _seat_z,
      " mm under the seat. Move the bolt circle in, or narrow the counterbore."
    )
  );

  difference() {
    union() {
      // Skirt: widest at the bed, tapering IN going up, so it never overhangs.
      // Bored to the same diameter the plate clears, and bored BEFORE the
      // sockets are added -- at the shell diameter it would fill in the lower
      // socket's own channels, since the neck's pins stand proud of its shell.
      difference() {
        cylinder(h=_skirt_h, d1=skirt_diameter, d2=_socket_od);
        translate([0, 0, -1]) cylinder(h=_skirt_h + 2, d=hub_plate_hole(joint));
      }

      // Outlet socket, opening downward at the bed face.
      joint_socket_inverted(joint);

      // Body socket, opening upward.
      translate([0, 0, _half]) joint_socket(joint);
    }

    // Through the flange, with a counterbore from above giving the nut a flat
    // seat on what would otherwise be a 45 degree slope.
    for (i = [0:bolts - 1])
      rotate([0, 0, i * 360 / bolts + bolt_angle]) {
        translate([_bolt_r, 0, -1]) cylinder(h=_skirt_h + 2, d=bolt_diameter);
        translate([_bolt_r, 0, _seat_z]) cylinder(h=_skirt_h + 2, d=counterbore);
      }
  }
}

// Standalone preview. A NAMED facet count, not an inline $fn, so drift.py can
// render this and the driver's version of the same part at matched resolution.
preview_facets = $preview ? 48 : 96;
hopper_hub(joint=hopper_joint(), $fn=preview_facets);
