// Example: the MK3S frame mount, shown clamped to a stub of the printer's
// frame, with the hub and outlet in place around it.
// GPL-3.0-or-later

use <../cad/hopper/hopper_specs.scad>;
use <../cad/hopper/hopper_hub.scad>;
use <../cad/hopper/hopper_joint.scad>;
use <../cad/hopper/hopper_outlet.scad>;
use <../cad/hopper/hopper_plate.scad>;
include <../cad/hopper/hopper_colours.scad>;

$fn = $preview ? 48 : 96;

joint = hopper_joint();
conveyor = hose(0);

plate_thickness = 6;
frame_thickness = 6.3;
frame_offset = 47;

// Datum is the plate's top face, matching the driver.
outlet_drop = joint_neck_height(joint) - outlet_height(joint, conveyor, 70, 24);

// Solved rather than chosen, exactly as the driver does it: the saddle stands
// the mount off the frame by whatever puts the outlet's mouth this far above
// the top bar, which is the highest anything that travels can reach.
outlet_clearance = 3;
saddle_roof = -outlet_drop - plate_thickness + outlet_clearance;

echo(
  str(
    "hopper axis sits ", frame_offset, " mm from the frame plane. Two minimums: ",
    mk3s_outlet_offset(joint, frame_thickness), " so the outlet clears the frame, and ",
    mk3s_saddle_offset(joint, frame_thickness), " so the saddle clears the plate's hole"
  )
);

echo(
  str(
    "saddle roof ", saddle_roof, " puts the outlet mouth ",
    saddle_roof + plate_thickness + outlet_drop,
    " mm above the frame's top edge"
  )
);

color(colour_plate())
  translate([0, 0, -plate_thickness])
    hopper_plate_mk3s(
      joint=joint, thickness=plate_thickness,
      frame_thickness=frame_thickness, offset=frame_offset,
      saddle_roof=saddle_roof
    );

color(colour_hub()) hopper_hub(joint);
color(colour_outlet()) translate([0, 0, outlet_drop]) hopper_outlet(joint, conveyor);

// The printer's frame, at the measured thickness set above: its top edge seats
// on the saddle roof.
// Shown as a background object -- it is not part of what you print.
%translate([-frame_offset - frame_thickness / 2, -110, -plate_thickness - saddle_roof - 300])
  cube([frame_thickness, 220, 300]);
