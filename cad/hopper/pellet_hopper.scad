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
// from the derived values beneath it. See docs/design-notes.md.

include <hopper_feedstock.scad>
include <hopper_sizes.scad>
use <hopper_body.scad>
use <hopper_cap.scad>
use <hopper_flow.scad>
use <hopper_funnel.scad>
use <hopper_joint.scad>
use <hopper_mount.scad>

/* [Render] */

// Which part to emit. "assembly" shows it built; "all" lays the parts out flat.
render_part = "assembly"; // [body,mount,cap,assembly,all]

/* [Hopper Size] */

// Footprint preset. Capacity is not fixed by this: it falls out of the
// footprint, the funnel angle and the feedstock, and is echoed on render.
hopper_size = 0; // [0:220x180,1:300x240,2:390x300]

/* [Feedstock] */

// What this hopper will actually hold. Sets the minimum workable funnel angle,
// the bulk density used to report capacity, and how much room a particle needs.
feedstock_type = 0; // [0:virgin pellets,1:regrind flake]

// Largest particle the build must pass. This is a REQUIREMENT: the outlet is
// checked against it, and the spec echo reports what the build actually
// manages. Size it for the coarsest the shredder produces, not for what is
// being sieved today.
design_particle_size = 5; // [1:0.5:12]

/* [Hopper] */

// Funnel steepness, degrees from HORIZONTAL, measured on the DIAGONAL CORNER.
// The corner is the shallowest surface in a rectangular funnel and is where
// pellets bridge, so it is what gets constrained; the flat faces come out
// steeper. Must be at least the selected feedstock's minimum.
funnel_angle = 60; // [40:1:80]

// Least material anywhere, measured perpendicular to the surface. Applied as a
// horizontal inset sized on the corner, so flat and vertical walls end up
// thicker than this.
min_wall = 3;
// Square opening at the bottom of the funnel. Sized so the inner throat still
// clears the outlet after the wall inset comes off it.
throat = 58;
// Must exceed the wall inset by at least 0.8, or the inner corner cannot
// follow the wall inward and the corner finishes thin.
throat_radius = 6;
funnel_radius = 8; // [0:1:20]
// Short round-to-square transition above the bayonet neck
neck_transition_height = 10;

/* [Bayonet Lock] */

// Built on bayonet-lock-scad. The neck outside diameter is
// 2 * (interface_radius - allowance/2) and the socket outside diameter is
// 2 * (interface_radius + shell_thickness), so these defaults give the 44 mm
// neck in a 72 mm socket. The imported design used 22.15/44/58, which capped
// the outlet at 38 mm -- too small for 5 mm flake at a converging outlet.
lock_interface_radius = 29.15;
lock_shell_thickness = 6.85;
// Total radial gap between the two shells. Also sets the axial float, at half
// this either way, and the size of the library's detent.
lock_allowance = 0.30;
lock_height = 18;
// Insertion travel measured down from the top of the neck.
lock_entry_depth = 12;
lock_pin_radius = 3.0; // [1:0.1:4]
// Quarter-turn travel from insertion to seated.
lock_sweep_angle = 25; // [15:1:35]
lock_pins = 4; // [2:1:7]
// Pulls one pin off the even pattern so the joint has a single locked
// orientation. Zero leaves the bin free to seat crosswise on the roof.
lock_key_angle = 15; // [0:1:40]

// Retaining screw. Nothing else resists the coupling backing off under a hose
// pull, so this is a positive lock rather than a nicety: the tip seats in a
// pocket in the neck. Pilot is sized to self-tap M4 in PETG; 0 omits it.
lock_retainer_pilot = 3.4; // [0:0.1:6]
// Clear of the entry slots and the socket gussets; hopper_joint asserts it.
lock_retainer_angle = 140; // [0:5:355]
lock_retainer_z = 13.5;

// Pellet bore through the coupling. This is the hopper's outlet, so it is the
// opening that has to clear design_particle_size; both are asserted below.
lock_bore_diameter = 50;

/* [Roof Mount] */

mount_size = [110, 110];
mount_thickness = 8;
mount_radius = 6;
mount_gussets = true;

/* [M4 Mounting] */

bolt_spacing = [90, 90];
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

/* [Build Volume] */

// Printer envelope used for the fit report. Original Prusa i3 MK3S is
// 250 x 210 x 210 mm and is the largest printer available here.
build_volume = [250, 210, 210];
// Turn on to make a part that does not fit the envelope a hard error.
require_printable = false;

/* [Quality] */

preview_facets = 48; // [12:4:96]
render_facets = 120; // [24:8:240]

module dummy() {} // Customizer fence: nothing below here reaches the panel.

$fn = $preview ? preview_facets : render_facets;

_preset = hopper_preset(hopper_size);
_top_x = hopper_top_x(_preset);
_top_y = hopper_top_y(_preset);
_bin_height = hopper_bin_height(_preset);

_feedstock = feedstock(feedstock_type);
_min_angle = feedstock_min_funnel_angle(_feedstock);

assert(
  funnel_angle >= _min_angle,
  str(
    "pellet_hopper: funnel_angle ", funnel_angle, " is below the minimum ",
    _min_angle, " degrees for ", feedstock_name(_feedstock),
    ". Raise the angle or pick a different feedstock."
  )
);

// The angle is the input; the drop is solved from it.
_funnel_height = funnel_height_for_angle(_top_x, _top_y, throat, funnel_angle);
_inset = funnel_wall_inset(min_wall, funnel_angle);

// One joint spec, shared by both halves so they cannot drift apart.
_neck_od = 2 * (lock_interface_radius - lock_allowance / 2);
_bore = lock_bore_diameter;

_joint = hopper_joint(
  interface_radius=lock_interface_radius,
  shell_thickness=lock_shell_thickness,
  allowance=lock_allowance,
  part_height=lock_height,
  entry_depth=lock_entry_depth,
  pin_radius=lock_pin_radius,
  sweep_angle=lock_sweep_angle,
  pins=lock_pins,
  key_angle=lock_key_angle,
  retainer_angle=lock_retainer_angle,
  retainer_z=lock_retainer_z,
  retainer_pilot=lock_retainer_pilot,
  bore_diameter=lock_bore_diameter
);

assert(
  (_neck_od - lock_bore_diameter) / 2 >= min_wall,
  str(
    "pellet_hopper: a ", lock_bore_diameter, " mm bore leaves only ",
    (_neck_od - lock_bore_diameter) / 2, " mm of neck wall, under min_wall ", min_wall,
    ". Raise lock_interface_radius or lower the bore."
  )
);

_spigot_od = pipe_id - pipe_clearance;

// Requirement -> geometry. The converging outlet is where arches form, so it
// governs; the spigot and hose are parallel sections and need less.
_required_outlet = flow_min_opening(design_particle_size, feedstock_converging_ratio(_feedstock));
_required_parallel = flow_min_opening(design_particle_size, feedstock_parallel_ratio(_feedstock));

assert(
  _bore >= _required_outlet,
  str(
    "pellet_hopper: outlet ", _bore, " mm is too small for ", design_particle_size,
    " mm ", feedstock_name(_feedstock), ". Needs at least ", _required_outlet,
    " mm (", feedstock_converging_ratio(_feedstock), "x particle at a converging outlet)."
  )
);

// Geometry -> capability. The narrowest section governs the whole path.
_path_max_particle = flow_path_max_particle([
  [throat - 2 * _inset, feedstock_converging_ratio(_feedstock)],
  [_bore, feedstock_converging_ratio(_feedstock)],
  [spigot_id, feedstock_parallel_ratio(_feedstock)],
  [pipe_id, feedstock_parallel_ratio(_feedstock)],
]);

// Overall body height, and how far the feedthrough hangs below the flange.
_body_height = lock_height + neck_transition_height + _funnel_height + _bin_height;
_drop_below_flange = roof_thickness + roof_locator_extra + transition_height + spigot_length;
_cap_outer_y = _top_y + 2 * cap_clearance + 2 * cap_wall;

_volume_l = hopper_volume_l(
  _top_x - 2 * _inset, _top_y - 2 * _inset, throat - 2 * _inset,
  _bin_height, _funnel_height
);
_capacity_kg = hopper_capacity_kg(_volume_l, feedstock_bulk_density(_feedstock));

// Largest footprint and height of any single printed part.
_cap_outer_x = _top_x + 2 * cap_clearance + 2 * cap_wall;
_part_x = max(_cap_outer_x, mount_size[0]);
_part_y = max(_cap_outer_y, mount_size[1]);
_part_z = max(_body_height, _drop_below_flange + mount_thickness + lock_height);
_fits = _part_x <= build_volume[0] && _part_y <= build_volume[1] && _part_z <= build_volume[2];

echo(str(
  "hopper ", hopper_name(_preset), " / ", feedstock_name(_feedstock),
  ": funnel corner ", funnel_angle,
  " deg, faces ", funnel_face_angle(_top_x, throat, _funnel_height),
  " / ", funnel_face_angle(_top_y, throat, _funnel_height),
  " deg; funnel rise ", _funnel_height,
  "; body height ", _body_height,
  "; wall inset ", _inset,
  "; volume ", _volume_l, " L = ", _capacity_kg, " kg"
));

echo(str(
  "spec: outlet ", _bore, " mm (needs ", _required_outlet, " for ",
  design_particle_size, " mm ", feedstock_name(_feedstock),
  "); narrowest parallel section ", min(spigot_id, pipe_id),
  " mm (needs ", _required_parallel,
  "); whole path passes up to ", _path_max_particle, " mm"
));

echo(str(
  "build fit: largest part ", [_part_x, _part_y, _part_z],
  " vs envelope ", build_volume,
  _fits ? " -- fits" : " -- DOES NOT FIT"
));

assert(
  !require_printable || _fits,
  str(
    "pellet_hopper: largest part ", [_part_x, _part_y, _part_z],
    " exceeds build_volume ", build_volume,
    ". Reduce the footprint, lower funnel_angle, or split the body."
  )
);

module _body() {
  hopper_body(
    joint=_joint,
    top_x=_top_x,
    top_y=_top_y,
    bin_height=_bin_height,
    funnel_height=_funnel_height,
    throat=throat,
    min_wall=min_wall,
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
  // Shown seated: joint_neck() is authored pre-rotated, so the body's nominal
  // orientation is the locked one. To fit it, turn the body back by
  // lock_sweep_angle, drop it in, then turn it forward to here.
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
