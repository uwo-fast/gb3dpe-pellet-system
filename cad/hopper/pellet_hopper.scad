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

include <hopper_colours.scad>
include <hopper_specs.scad>
use <hopper_body.scad>
use <hopper_cap.scad>
use <hopper_funnel.scad>
use <hopper_joint.scad>
use <hopper_hub.scad>
use <hopper_outlet.scad>
use <hopper_plate.scad>

/* [Render] */

// Which part to emit. "assembly" shows it built; "all" lays the parts out flat.
render_part = "assembly"; // [body,cap,hub,plate,outlet,assembly,all]

/* [Hopper Size] */

// Footprint preset. Capacity is not fixed by this: it falls out of the
// footprint, the funnel angle and the feedstock, and is echoed on render.
hopper_size = 2; // [0:150x150,1:175x175,2:202x202]

/* [Feedstock] */

// What this hopper will actually hold. Sets the minimum workable funnel angle,
// the bulk density used to report capacity, and how much room a particle needs.
feedstock_type = 1; // [0:virgin pellets,1:regrind flake]

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
// Defaults to the regrind minimum, which is also fine for virgin pellets --
// steeper is never worse for flow. It is not a neutral choice: a shallower
// funnel is shorter, which pushes the split up into the full-width bin, and the
// flange there stands proud of the envelope. The fit assert will say so.
funnel_angle = 70; // [40:1:80]

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

// Retaining screw: a positive lock rather than a nicety, and the only thing
// resisting a hose pull -- see hopper_joint.scad. Sized to self-tap M4 in PETG;
// 0 omits it.
lock_retainer_pilot = 3.4; // [0:0.1:6]
// Clear of the entry slots and the socket gussets; hopper_joint asserts it.
lock_retainer_angle = 140; // [0:5:355]
lock_retainer_z = 13.5;

// Pellet bore through the coupling. This is the hopper's outlet, so it is the
// opening that has to clear design_particle_size; both are asserted below.
lock_bore_diameter = 50;

/* [Mount] */

// Which machine this mounts to. "universal" is the bare interface with no
// machine features -- the starting point for a new adapter. "mk3s" clamps to
// the printer's own frame bar, measured on this machine as 6.3 mm steel.
plate_variant = "mk3s"; // [universal,mk3s,panel]

// How far the hopper's axis sits from the frame plane. The outlet hangs below
// the plate so it must pass BESIDE the frame, and the saddle must clear the
// plate's own clearance hole. The plate asserts both minimums and says which
// one bound.
frame_offset = 47;

// MEASURED on this machine: 6.3 mm steel with a 40.5 mm top bar. Public sources
// describe the frame as 6.2 mm aluminium; both differ from what is there.
frame_thickness = 6.3;
frame_clearance = 0.3;

// Well inside the 40.5 mm bar rather than most of the way down it.
frame_grip_depth = 30;

// Jaw stress goes as 1/thickness^2, while the offset a thicker jaw forces out
// raises the couple only linearly -- so a thick jaw is cheap stiffness.
frame_jaw = 7;
frame_fillet = 4;

// The MK3S plate sizes ITSELF from the offset, the saddle and the hub skirt, so
// this margin is the only handle on how big it comes out. There is deliberately
// no separate plate width or saddle length to set inconsistently with them.
frame_plate_margin = 6;

// For the "panel" variant: where it bolts through the sheet. Parametric because
// the panel is drilled to suit -- there is no fixed pattern to match.
panel_bolt_spacing = [100, 100];

// Used by the universal and panel variants; the mk3s one derives its own.
plate_size = [130, 130];
plate_thickness = 6;
plate_corner_radius = 6;

// The skirt is what the hub's fixings bite into, so its width is squeezed
// between the plate's clearance hole and the depth a screw needs.
hub_skirt_diameter = 95;
hub_bolt_depth = 8;
hub_bolts = 4;
// Into the hub: blind, sized for a self-tapping screw or an insert.
hub_bolt_diameter = 4.2;
// Through the plate: clearance.
plate_bolt_diameter = 4.5;

/* [Hose] */

hose_type = 0; // [0:GB3D 1 m conveyor]

// NOT CONFIRMED. The socket is threaded to match the hose's reinforcing rib, so
// this has to match the real hose or it simply will not screw in. Flip it and
// reprint the outlet -- it is a small part.
hose_handedness = "right"; // [right,left]

// The outlet is where the path converges from the coupling's bore down to the
// hose, so it is held to the same wall angle as the funnel.
outlet_cone_angle = 70; // [40:1:80]
outlet_socket_depth = 24;
outlet_wall = 3;

/* [Cap] */

cap_clearance = 0.6;
cap_wall = 3;
cap_skirt_height = 16;
cap_top_thickness = 3;

/* [Segments] */

// The body is taller than the printer, so it is cut into segments that bolt
// together. Bin height is whatever is left over once the funnel has taken its
// share, so this is what actually sets capacity.
segments = 2; // [1:1:4]
// Which one to emit. "assembly" and "all" show every segment regardless.
segment = 0; // [0:1:3]
// Usable Z per segment, a little under the build envelope.
segment_height = 205;

/* [Split Joint] */

flange_width = 12;
flange_thickness = 6;
// How far the fixings sit in from the flange edge.
flange_inset = 6;
flange_bolt_diameter = 4.5;
flange_dowel_diameter = 4;

/* [Build Volume] */

// Printer envelope used for the fit report. Original Prusa i3 MK3S is
// 250 x 210 x 210 mm and is the largest printer available here.
build_volume = [250, 210, 210];
// Turn on to make a part that does not fit the envelope a hard error.
require_printable = true;

/* [Quality] */

preview_facets = 48; // [12:4:96]
render_facets = 120; // [24:8:240]

module dummy() {} // Customizer fence: nothing below here reaches the panel.

$fn = $preview ? preview_facets : render_facets;

// Footprint presets, index-matched to the hopper_size dropdown above. Only the
// footprint is a free choice -- the funnel comes from the wall angle and the bin
// from whatever height the segments leave -- so it is all a preset carries.
// 202 x 202 is the largest an MK3S will take once the cap's clearance and wall
// are added: 202 + 7.2 = 209.2 against a 210 mm bed.
_footprints = [[150, 150], [175, 175], [202, 202]];

// The assert sits in the expression, not on a line of its own. A top-level
// assert STATEMENT runs after OpenSCAD has evaluated the assignments, so an
// out-of-range index gets as far as the funnel maths and reports itself as
// "undefined operation" from inside norm() -- three files from the cause.
_footprint =
  assert(
    hopper_size >= 0 && hopper_size < len(_footprints),
    str("pellet_hopper: hopper_size must be 0..", len(_footprints) - 1, ", got: ", hopper_size)
  )
  _footprints[hopper_size];

_top_x = _footprint[0];
_top_y = _footprint[1];


_feedstock = feedstock(feedstock_type);
_min_angle = feedstock_min_funnel_angle(_feedstock);

assert(
  funnel_angle >= _min_angle,
  str("pellet_hopper: funnel_angle ", funnel_angle, " is below the minimum ",
    _min_angle, " degrees for ", feedstock_name(_feedstock),
    ". Raise the angle or pick a different feedstock.")
);

// The angle is the input; the drop is solved from it.
_funnel_height = funnel_height_for_angle(_top_x, _top_y, throat, funnel_angle);
_inset = funnel_wall_inset(min_wall, funnel_angle);

// Bin height is the remainder: the segments give a total height, the funnel
// takes what its angle demands, and storage gets the rest. Capacity is
// therefore an output of the flow requirement, never an input competing with it.
_bin_height = segments * segment_height - lock_height - neck_transition_height - _funnel_height;

assert(
  _bin_height > 0,
  str("pellet_hopper: a ", funnel_angle, " degree funnel on a ", _top_x, "x",
    _top_y, " footprint needs ", _funnel_height,
    " mm of drop, leaving no room for storage in ", segments, " x ",
    segment_height, " mm. Use more segments or a smaller footprint.")
);

// One joint spec, shared by both halves so they cannot drift apart.
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

_neck_od = joint_neck_od(_joint);

assert(
  (_neck_od - lock_bore_diameter) / 2 >= min_wall,
  str("pellet_hopper: a ", lock_bore_diameter, " mm bore leaves only ",
    (_neck_od - lock_bore_diameter) / 2, " mm of neck wall, under min_wall ",
    min_wall, ". Raise lock_interface_radius or lower the bore.")
);

// Handedness is overridden here rather than in the registry, so the registry
// keeps describing the part as bought and this stays a one-switch change.
_hose_row = hose(hose_type);
_hose = [
  hose_name(_hose_row), hose_bore(_hose_row), hose_tube_od(_hose_row),
  hose_helix(_hose_row), hose_pitch(_hose_row), hose_handedness,
];

// Requirement -> geometry. The converging outlet is where arches form, so it
// governs; the spigot and hose are parallel sections and need less.
_required_outlet = flow_min_opening(design_particle_size, feedstock_converging_ratio(_feedstock));
_required_parallel = flow_min_opening(design_particle_size, feedstock_parallel_ratio(_feedstock));

assert(
  _bore >= _required_outlet,
  str("pellet_hopper: outlet ", _bore, " mm is too small for ",
    design_particle_size, " mm ", feedstock_name(_feedstock),
    ". Needs at least ", _required_outlet, " mm (",
    feedstock_converging_ratio(_feedstock),
    "x particle at a converging outlet).")
);

// Geometry -> capability. The narrowest section governs the whole path.
_path_max_particle = flow_path_max_particle([
  [throat - 2 * _inset, feedstock_converging_ratio(_feedstock)],
  [_bore, feedstock_converging_ratio(_feedstock)],
  [hose_bore(_hose), feedstock_parallel_ratio(_feedstock)],
  // The toolhead's own bore. Not ours to size, and it is the binding section,
  // so leaving it out would report a system limit we do not actually have.
  [GB3DPE_FEED_BORE, feedstock_parallel_ratio(_feedstock)],
]);

// Overall body height, and how far the feedthrough hangs below the flange.
_body_height = lock_height + neck_transition_height + _funnel_height + _bin_height;
_hub_height = hub_height(_joint);
_body_base = lock_height;
_outlet_h = outlet_height(_joint, _hose, outlet_cone_angle, outlet_socket_depth);
_cap_outer = [
  _top_x + 2 * cap_clearance + 2 * cap_wall,
  _top_y + 2 * cap_clearance + 2 * cap_wall,
];

_volume_l = hopper_volume_l(
  _top_x - 2 * _inset, _top_y - 2 * _inset, throat - 2 * _inset,
  _bin_height, _funnel_height
);
_capacity_kg = hopper_capacity_kg(_volume_l, feedstock_bulk_density(_feedstock));

// The body's widest point is not the bin: it is the flange at a split, which
// stands proud of whatever section the cut lands on. Missing this let a
// configuration 16 mm over the envelope report as fitting.
_cut_sections = segments < 2 ? [] : [
  for (i = [1:1:segments - 1])
    funnel_body_section(
      throat, _top_x, _top_y, throat_radius, funnel_radius,
      lock_height + neck_transition_height, _funnel_height,
      split_z(_body_height, segments, i)
    )
];
_flange_x = segments < 2 ? 0 : max([for (c = _cut_sections) c[0] + 2 * flange_width]);
_flange_y = segments < 2 ? 0 : max([for (c = _cut_sections) c[1] + 2 * flange_width]);

// Largest footprint and height of any single printed part.
// The MK3S plate sizes itself, so ask it rather than assume plate_size.
_plate_actual = plate_variant == "mk3s"
  ? mk3s_plate_size(_joint, frame_offset, frame_jaw, frame_fillet,
                    frame_thickness, frame_clearance, hub_skirt_diameter,
                    frame_plate_margin)
  : plate_size;

_part_x = max([_cap_outer[0], _plate_actual[0], hub_skirt_diameter, _top_x, _flange_x]);
_part_y = max([_cap_outer[1], _plate_actual[1], hub_skirt_diameter, _top_y, _flange_y]);
// The largest PART, not the largest assembly: a segment, not the whole body.
_part_z = max(
  max(segments > 1 ? segment_height : _body_height, _outlet_h),
  max(_hub_height, plate_thickness)
);
_fits = _part_x <= build_volume[0] && _part_y <= build_volume[1] && _part_z <= build_volume[2];

echo(str(
  "hopper ", _top_x, "x", _top_y, " / ", feedstock_name(_feedstock),
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
  "); hose bore ", hose_bore(_hose),
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
  str("pellet_hopper: largest part ", [_part_x, _part_y, _part_z],
    " exceeds build_volume ", build_volume,
    ". Reduce the footprint, lower funnel_angle, or split the body.")
);

module _body(which = undef) {
  hopper_body(
    joint=_joint,
    top_x=_top_x,
    top_y=_top_y,
    bin_height=_bin_height,
    funnel_angle=funnel_angle,
    throat=throat,
    min_wall=min_wall,
    throat_radius=throat_radius,
    funnel_radius=funnel_radius,
    neck_transition_height=neck_transition_height,
    segments=segments,
    segment=is_undef(which) ? segment : which,
    flange_width=flange_width,
    flange_thickness=flange_thickness,
    flange_inset=flange_inset,
    flange_bolt_diameter=flange_bolt_diameter,
    flange_dowel_diameter=flange_dowel_diameter
  );
}

// Every segment, each already at its true height and its own colour.
module _body_all() {
  for (i = [0:segments - 1]) color(colour_body_segment(i)) _body(which = i);
}

module _hub() {
  hopper_hub(
    joint=_joint,
    skirt_diameter=hub_skirt_diameter,
    bolts=hub_bolts,
    bolt_diameter=hub_bolt_diameter,
    bolt_depth=hub_bolt_depth
  );
}

module _plate() {
  // Every variant carries the universal plate's own parameters, because every
  // variant IS the universal plate plus machine features. Only the extras
  // differ, so they are the only thing stated per branch.
  if (plate_variant == "mk3s")
    // No size passed: this variant derives its own, so there is nothing here
    // that can disagree with the saddle it has to carry.
    hopper_plate_mk3s(
      joint=_joint, margin=frame_plate_margin, thickness=plate_thickness,
      corner_radius=plate_corner_radius, skirt_diameter=hub_skirt_diameter,
      bolt_depth=hub_bolt_depth, bolts=hub_bolts, bolt_diameter=plate_bolt_diameter,
      frame_thickness=frame_thickness, frame_clearance=frame_clearance,
      offset=frame_offset, grip_depth=frame_grip_depth, jaw=frame_jaw,
      fillet=frame_fillet
    );
  else if (plate_variant == "panel")
    hopper_plate_panel(
      joint=_joint, size=plate_size, thickness=plate_thickness,
      corner_radius=plate_corner_radius, skirt_diameter=hub_skirt_diameter,
      bolt_depth=hub_bolt_depth, bolts=hub_bolts, bolt_diameter=plate_bolt_diameter,
      panel_bolt_spacing=panel_bolt_spacing
    );
  else
    hopper_plate(
      joint=_joint, size=plate_size, thickness=plate_thickness,
      corner_radius=plate_corner_radius, skirt_diameter=hub_skirt_diameter,
      bolt_depth=hub_bolt_depth, bolts=hub_bolts, bolt_diameter=plate_bolt_diameter
    );
}

module _outlet() {
  hopper_outlet(
    joint=_joint,
    hose=_hose,
    cone_angle=outlet_cone_angle,
    socket_depth=outlet_socket_depth,
    wall=outlet_wall
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

// Single parts carry the same colour they have in the assembly, so a part
// rendered on its own is still recognisable as the one you were looking at.
if (render_part == "body") {
  color(colour_body_segment(segment)) _body();
} else if (render_part == "cap") {
  color(colour_cap(segments)) _cap();
} else if (render_part == "hub") {
  color(colour_hub()) _hub();
} else if (render_part == "plate") {
  color(colour_plate()) _plate();
} else if (render_part == "outlet") {
  color(colour_outlet()) _outlet();
} else if (render_part == "assembly") {
  // Datum is the plate's TOP face. The hub sits on it, the body's neck goes
  // into the hub's upper socket, and the outlet comes up through the plate's
  // clearance hole into the lower one.
  translate([0, 0, -plate_thickness]) color(colour_plate()) _plate();
  color(colour_hub()) _hub();
  translate([0, 0, _body_base]) _body_all();
  translate([0, 0, _body_base + _body_height - cap_skirt_height])
    color(colour_cap(segments)) _cap();
  translate([0, 0, lock_height - _outlet_h]) color(colour_outlet()) _outlet();
} else if (render_part == "all") {
  _body_all();
  translate([_top_x / 2 + plate_size[0] / 2 + 40, 0, 0]) {
    color(colour_plate()) _plate();
    translate([0, 0, plate_thickness + 10]) color(colour_hub()) _hub();
    translate([0, 0, plate_thickness + _hub_height + 20]) color(colour_outlet()) _outlet();
  }
  translate([0, _top_y / 2 + _cap_outer[1] / 2 + 40, 0])
    color(colour_cap(segments)) _cap();
} else {
  assert(false, str("pellet_hopper: unknown render_part: ", render_part));
}
