// Roof mount: bolt flange, bayonet socket, and the hose feedthrough below it.
// GPL-3.0-or-later
// Units: mm

use <hopper_joint.scad>
use <hopper_util.scad>

// Printed as one piece. The flange sits on z = 0..mount_thickness, the socket
// rises above it, and the feedthrough hangs below into negative z.

// Four M4 clearance holes on a rectangular pattern centred on the flange.
module _bolt_holes(spacing, diameter, thickness) {
  for (x = [-spacing[0] / 2, spacing[0] / 2])
    for (y = [-spacing[1] / 2, spacing[1] / 2])
      translate([x, y, -1]) cylinder(h = thickness + 2, d = diameter);
}

// Gusset tying the socket wall down to the flange. Dimensions are the imported
// design's; they have no stated derivation. Spaced evenly and independently of
// the pin angles, which are keyed and therefore uneven.
module _socket_gussets(joint, count, socket_outer_d, mount_thickness) {
  _neck_height = joint_neck_height(joint);

  for (i = [0:count - 1]) {
    rotate([0, 0, i * 360 / count]) hull() {
      // Foot, overlapping the flange.
      translate([socket_outer_d / 2 + 6, 0, mount_thickness + 1.25])
        cube([12, 16, 3], center = true);

      // Head, overlapping the socket wall.
      translate([socket_outer_d / 2 - 2.5, 0, mount_thickness + _neck_height * 0.55])
        cube([4, 16, _neck_height * 0.65], center = true);
    }
  }
}

/**
 * The roof mount.
 *
 * `roof_thickness` is the panel this bolts through and `roof_locator_extra` is
 * how far the locating neck protrudes past it. Both are assumptions in the
 * imported design and neither has been measured against the actual enclosure.
 */
module hopper_mount(
  joint,
  mount_size = [90, 90],
  mount_thickness = 8,
  mount_radius = 6,
  bolt_spacing = [70, 70],
  bolt_diameter = 4.5,
  gussets = true,
  roof_thickness = 2,
  roof_locator_extra = 2,
  spigot_od = 24.6,
  spigot_id = 20.6,
  spigot_length = 35,
  transition_height = 20,
  lead_in = 4,
  lead_in_reduction = 1.2
) {
  assert(
    spigot_id < spigot_od,
    str("hopper_mount: spigot_id (", spigot_id, ") must be < spigot_od (", spigot_od, ")")
  );
  assert(lead_in < spigot_length,
    str("hopper_mount: lead_in (", lead_in, ") must be < spigot_length (", spigot_length, ")"));
  assert(
    bolt_spacing[0] < mount_size[0] && bolt_spacing[1] < mount_size[1],
    str("hopper_mount: bolt_spacing ", bolt_spacing, " must fit inside mount_size ", mount_size)
  );

  _socket_outer_d = joint_socket_outer_d(joint);
  _bore = joint_bore_diameter(joint);

  // Square locating section that drops through the roof panel.
  _locator = joint_neck_od(joint) + 2;
  _locator_length = roof_thickness + roof_locator_extra;

  // z stations below the flange, going down.
  _locator_bottom = -_locator_length;
  _transition_bottom = _locator_bottom - transition_height;
  _spigot_bottom = _transition_bottom - spigot_length;

  difference() {
    union() {
      rounded_box(mount_size[0], mount_size[1], mount_thickness, mount_radius);

      // Socket sits at EXACTLY the flange top, on a coincident face rather
      // than sunk in. Sinking it to force a weld, as the rest of this part
      // does, would drop its channels relative to the neck's pins, and the
      // joint only has +/-0.15 mm of axial float to give away.
      translate([0, 0, mount_thickness]) joint_socket(joint);

      translate([0, 0, _locator_bottom])
        rounded_box(_locator, _locator, _locator_length + 0.1, 6);

      // Square locator down to the round spigot. Written as an explicit hull
      // rather than loft() because the imported geometry aligns these two
      // sections differently -- the lower one sits on its station, the upper
      // one straddles it. Normalising that shifts the cone, so it is preserved
      // here and flagged in TODO.md instead.
      hull() {
        translate([0, 0, _locator_bottom - 0.5])
          rounded_box(_locator, _locator, 1, 6);
        translate([0, 0, _transition_bottom]) cylinder(h = 1, d = spigot_od);
      }

      translate([0, 0, _spigot_bottom + lead_in])
        cylinder(h = spigot_length - lead_in, d = spigot_od);

      // Tapered tip, so the hose starts onto the spigot.
      translate([0, 0, _spigot_bottom])
        cylinder(h = lead_in, d1 = spigot_od - lead_in_reduction, d2 = spigot_od);

      if (gussets)
        _socket_gussets(joint, joint_pins(joint), _socket_outer_d, mount_thickness);
    }

    _bolt_holes(bolt_spacing, bolt_diameter, mount_thickness);

    // Nothing is cut for the socket: it arrives hollow and already channelled.
    // What matters is what is NOT cut here. The flange top between the pellet
    // bore and the socket bore is the annular land the neck sits down on, and
    // that land -- not the pins -- carries the pellet weight. The library's two
    // halves span the same z range with nothing to bottom out on, so cutting
    // this seat away would move roughly 98 N onto four sphere contacts at some
    // thirty times the bearing stress.

    // Pellet path: full bore through the flange, necking to the spigot bore.
    translate([0, 0, _locator_bottom - 1])
      cylinder(h = _locator_length + mount_thickness + 2, d = _bore);

    // Same alignment note as the outer transition above.
    hull() {
      translate([0, 0, _locator_bottom - 1]) cylinder(h = 1, d = _bore);
      translate([0, 0, _transition_bottom]) cylinder(h = 1, d = spigot_id);
    }

    translate([0, 0, _spigot_bottom - 1]) cylinder(h = spigot_length + 2, d = spigot_id);
  }
}

// Standalone preview. $fn is passed on the call, never assigned at top level:
// a use'd file's own top-level $fn is what ITS modules see, so assigning it
// here would silently override whatever the driver asked for.
hopper_mount(joint = hopper_joint(), $fn = $preview ? 48 : 120);
