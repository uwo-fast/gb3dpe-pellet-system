// Conveyor hose specifications.
// GPL-3.0-or-later
// Units: mm

// A bought part, so its dimensions are a registry entry rather than something
// derived. Swapping hose becomes a row here plus a reprint of the outlet.
//
// Row fields:
//   0  name        label for the customizer
//   1  bore        inside diameter -- the flow path
//   2  tube_od     outside diameter over the tube wall alone
//   3  helix       diameter of the reinforcing rib wound around it
//   4  pitch       axial distance between turns of that rib
//   5  handed      "right" or "left"
//
// The rib standing proud of the wall is what lets the hose screw into a
// matching socket instead of being pushed on and clamped: the hose IS the
// thread.
//
// Note how the rib sits: its centreline lies ON the tube's outside surface, so
// only its RADIUS protrudes. Overall diameter is therefore tube_od + helix,
// not tube_od + 2 * helix -- 21 + 4 = 25, which is what a caliper reads across
// the ribs.

// Supplied with the GreenBoy3D kit. Measured on the bench, not published:
// 20 mm bore, 21 mm over the tube wall, a 2 mm-radius rib giving 25 mm overall,
// 8 mm pitch, right-handed. All confirmed by caliper and eye.
HOSE_GB3D = ["GB3D 1 m conveyor", 20, 21, 4, 8, "right"];

hose_registry = [HOSE_GB3D];

function hose_name(type) = type[0]; //! Label for the customizer
function hose_bore(type) = type[1]; //! Inside diameter, the flow path
function hose_tube_od(type) = type[2]; //! Outside diameter over the tube wall
function hose_helix(type) = type[3]; //! Diameter of the reinforcing rib
function hose_pitch(type) = type[4]; //! Axial distance between turns
function hose_handed(type) = type[5]; //! "right" or "left"

// Overall diameter across the reinforcing rib.
function hose_outside(type) = hose_tube_od(type) + hose_helix(type);

// Radius the rib's centreline sits at: on the tube's outside surface.
function hose_helix_radius(type) = hose_tube_od(type) / 2;

function hose(index) =
  assert(
    is_num(index) && index >= 0 && index < len(hose_registry),
    str("hose: index must be 0..", len(hose_registry) - 1, ", got: ", index)
  ) hose_registry[index];
