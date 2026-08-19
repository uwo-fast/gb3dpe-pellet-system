// Bulk pellet hopper for the GreenBoy3D pellet extruder: driver and parameters.
// GPL-3.0-or-later
// Units: mm, degrees
//
// This file exists to expose parameters to the OpenSCAD Customizer and to hand
// them to the part modules. It defines no geometry of its own.
//
// Customizer rule for OpenSCAD 2021.01, verified rather than assumed: only
// top-level assignments in THIS file, textually before the first module
// definition, reach the parameter panel. Parameters in an included file never
// appear. Hence the dummy module below, which fences the tunable parameters off
// from the derived values beneath it.

include <hopper_sizes.scad>
use <hopper_body.scad>
use <hopper_cap.scad>
use <hopper_joint.scad>
use <hopper_mount.scad>

/* [Render] */

// Which part to emit. "assembly" shows it built; "all" lays the parts out flat.
render_part = "assembly"; // [body,mount,cap,assembly,all]

/* [Hopper Size] */

hopper_size = 0; // [0:2.5 kg,1:5 kg,2:10 kg]

/* [Hopper] */

wall = 3;
// Square opening at the bottom of the funnel
throat = 44;
throat_radius = 4;
funnel_radius = 8; // [0:1:20]
// Short round-to-square transition above the bayonet neck
neck_transition_height = 10;

/* [Bayonet Lock] */

lock_neck_od = 44;
lock_neck_height = 18;
lock_tabs = 4; // [2:1:8]
lock_tab_width = 10;
lock_tab_depth = 3;
lock_tab_height = 4;
// Height of the tabs above the bottom of the neck
lock_tab_z = 4;
// Quarter-turn travel from insertion to seated
lock_rotation = 25; // [15:1:35]
// Radial fit between body neck and socket
lock_clearance = 0.30;
// Vertical slack around the tabs
lock_z_clearance = 0.25;
// Material outboard of the tab groove
socket_wall = 4;

/* [Roof Mount] */

mount_size = [90, 90];
mount_thickness = 8;
mount_radius = 6;
mount_gussets = true;

/* [M4 Mounting] */

bolt_spacing = [70, 70];
// M4 clearance
bolt_diameter = 4.5;

/* [Enclosure] */

// Enclosure roof panel thickness. NOT MEASURED -- the Original Prusa Enclosure
// top panel is metal, not thin plastic. Tracked in TODO.md.
roof_thickness = 2;
// How far the locating neck protrudes past the panel
roof_locator_extra = 2;

/* [Hose Connection] */

// Inside diameter of the extruder's conveyor tube. NOT MEASURED -- the vendor
// does not publish it. Tracked in TODO.md.
pipe_id = 25;
pipe_clearance = 0.4;
// Pellet passage through the spigot
spigot_id = 20.6;
// Hose engagement length
spigot_length = 35;
// Square locator to round spigot
transition_height = 20;
lead_in = 4;
lead_in_reduction = 1.2;

/* [Cap] */

cap_clearance = 0.6;
cap_wall = 3;
cap_skirt_height = 16;
cap_top_thickness = 3;

/* [Quality] */

preview_facets = 48; // [12:4:96]
render_facets = 120; // [24:8:240]

module dummy() {} // Customizer fence: nothing below here reaches the panel.

$fn = $preview ? preview_facets : render_facets;

_preset = hopper_preset(hopper_size);
_top_x = hopper_top_x(_preset);
_top_y = hopper_top_y(_preset);
_bin_height = hopper_bin_height(_preset);
_funnel_height = hopper_funnel_height(_preset);

// One joint spec, shared by both halves so they cannot drift apart.
_joint = hopper_joint(
  neck_od=lock_neck_od,
  neck_height=lock_neck_height,
  tab_width=lock_tab_width,
  tab_depth=lock_tab_depth,
  tab_height=lock_tab_height,
  tab_z=lock_tab_z,
  tabs=lock_tabs,
  rotation=lock_rotation,
  clearance=lock_clearance,
  z_clearance=lock_z_clearance,
  socket_wall=socket_wall,
  bore_diameter=lock_neck_od - 2 * wall
);

_spigot_od = pipe_id - pipe_clearance;

// Overall body height, and how far the feedthrough hangs below the flange.
_body_height = lock_neck_height + neck_transition_height + _funnel_height + _bin_height;
_drop_below_flange = roof_thickness + roof_locator_extra + transition_height + spigot_length;
_cap_outer_y = _top_y + 2 * cap_clearance + 2 * cap_wall;

echo(str(
  "hopper: ", hopper_name(_preset),
  "  bin ", _top_x, "x", _top_y, "x", _bin_height,
  "  funnel rise ", _funnel_height,
  "  body height ", _body_height
));

module _body() {
  hopper_body(
    joint=_joint,
    top_x=_top_x,
    top_y=_top_y,
    bin_height=_bin_height,
    funnel_height=_funnel_height,
    throat=throat,
    wall=wall,
    throat_radius=throat_radius,
    funnel_radius=funnel_radius,
    neck_transition_height=neck_transition_height
  );
}

module _mount() {
  hopper_mount(
    joint=_joint,
    mount_size=mount_size,
    mount_thickness=mount_thickness,
    mount_radius=mount_radius,
    bolt_spacing=bolt_spacing,
    bolt_diameter=bolt_diameter,
    gussets=mount_gussets,
    roof_thickness=roof_thickness,
    roof_locator_extra=roof_locator_extra,
    spigot_od=_spigot_od,
    spigot_id=spigot_id,
    spigot_length=spigot_length,
    transition_height=transition_height,
    lead_in=lead_in,
    lead_in_reduction=lead_in_reduction
  );
}

module _cap() {
  hopper_cap(
    top_x=_top_x,
    top_y=_top_y,
    funnel_radius=funnel_radius,
    clearance=cap_clearance,
    wall=cap_wall,
    skirt_height=cap_skirt_height,
    top_thickness=cap_top_thickness
  );
}

if (render_part == "body") {
  _body();
} else if (render_part == "mount") {
  _mount();
} else if (render_part == "cap") {
  _cap();
} else if (render_part == "assembly") {
  // Shown seated. To fit it: turn the body anticlockwise by lock_rotation,
  // drop it in, then turn it clockwise back to here.
  _mount();
  translate([0, 0, mount_thickness]) _body();
  translate([0, 0, mount_thickness + _body_height - cap_skirt_height]) _cap();
} else if (render_part == "all") {
  _body();
  // Raised so the downward spigot clears z = 0 in the laid-out view.
  translate([_top_x / 2 + mount_size[0] / 2 + 40, 0, _drop_below_flange]) _mount();
  translate([0, _top_y / 2 + _cap_outer_y / 2 + 40, 0]) _cap();
} else {
  assert(false, str("pellet_hopper: unknown render_part: ", render_part));
}
