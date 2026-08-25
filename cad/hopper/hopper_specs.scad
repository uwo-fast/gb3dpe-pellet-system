// Specifications the geometry is sized FROM rather than sized BY: what the
// feedstock does, the flow rules it obeys, and the parts bought rather than
// drawn.
// GPL-3.0-or-later
// Units: mm, degrees, kg/L

// Accessors exist because variables do not cross a `use <>` boundary but
// functions do: `use` this file to read one row, `include` it to reach a
// registry itself. Each registry validates its index inside the accessor rather
// than beside it, because a top-level assert cannot guard an assignment. See
// docs/design-notes.md.

// ===== Flow rules =====

// Physical behaviour belongs in functions, not in a comment next to a magic
// number. Then the same rule can be read in either direction: give it a
// feedstock and it sizes the geometry, or give it the geometry and it reports
// what feedstock the build can actually pass.
//
// These are rules of thumb from general bulk-solids practice, not measurements.
// The real critical dimension depends on the material AND on the wall friction
// of the surface it slides on, which for a printed part is not the steel those
// figures assume. See docs/design-notes.md for sources and caveats.

// A CONVERGING outlet is where arches form: material funnels inward and can
// key together across the opening. Needs the most room.
FLOW_RATIO_CONVERGING_PELLET = 6; //! Round, free-flowing pellets
FLOW_RATIO_CONVERGING_FLAKE = 10; //! Irregular flake, which interlocks

// A PARALLEL section -- a hose, a spigot -- has no convergence driving an arch,
// so it can run considerably smaller than an outlet for the same material.
FLOW_RATIO_PARALLEL_PELLET = 3; //! Round, free-flowing pellets
FLOW_RATIO_PARALLEL_FLAKE = 4; //! Irregular flake

// The GreenBoy3D toolhead's own feed bore, where material drops onto the screw.
// Measured off the vendor STEP files: 18.30 mm, centred on the extruder axis,
// appearing identically in both sliding-pit parts. It is metal and it is the one
// opening in the whole path we cannot size, so it caps the system regardless of
// how generous everything upstream is.
GB3DPE_FEED_BORE = 18.30;

/**
 * Smallest opening that will pass `particle_size` without arching, at `ratio`.
 * Use this to drive geometry from a requirement.
 */
function flow_min_opening(particle_size, ratio) =
  assert(particle_size > 0, str("flow_min_opening: particle_size must be > 0, got: ", particle_size))
  assert(ratio > 0, str("flow_min_opening: ratio must be > 0, got: ", ratio))
  particle_size * ratio;

/**
 * Largest particle an opening will pass, at `ratio`. The inverse of the above.
 * Use this to report what a finished build can handle.
 */
function flow_max_particle(opening, ratio) =
  assert(opening > 0, str("flow_max_particle: opening must be > 0, got: ", opening))
  opening / ratio;

// The narrowest point governs, so a path is only as good as its worst section.
// Each entry is [opening, ratio]; returns the largest particle the whole path
// will pass.
function flow_path_max_particle(sections) =
  min([for (s = sections) flow_max_particle(s[0], s[1])]);

// ===== Feedstock =====

// We run this printer on both virgin pellets and shredded regrind, and they are
// not interchangeable inputs. Regrind is irregular, higher friction and roughly
// half the bulk density, so it needs a steeper funnel to flow and stores much
// less mass in the same box.
//
// Row fields:
//   0  name              label for the customizer
//   1  min_funnel_angle  shallowest funnel that still flows, degrees from HORIZONTAL
//   2  bulk_density      kg per litre, for capacity reporting
//   3  converging_ratio  outlet size as a multiple of the largest particle
//   4  parallel_ratio    same, for a hose or spigot where nothing converges
//
// SOURCES -- see docs/design-notes.md for the reasoning and full citations.
//   Angles are design targets from general bulk-solids practice, NOT measured.
//   The critical mass-flow angle depends on the material and on the wall
//   friction of the surface it slides on (Jenike & Johanson), so a printed wall
//   is not interchangeable with the steel those figures assume. Regrind is set
//   steeper because irregular flake nests and bridges (Wijay Systems).
//   Bulk density spans roughly 450-850 kg/m3 across resin types (Conair);
//   virgin PLA sits mid-range. The REGRIND figure is MEASURED, not estimated:
//   342 g settled to the 700 mL line of a beaker = 0.489 kg/L, on shredded
//   black Polymaker PolyLite PLA. See docs/feedstock.md for provenance -- bulk
//   density is a property of the shred, not of the polymer, so it travels with
//   the machine and the material together.
//   A hopper that bridges in service wants a measured wall friction angle
//   against an actual printed surface, not a nudge to these. Tracked in TODO.md.
//
// Note the convention: hopper literature usually quotes the angle from
// VERTICAL, which is 90 minus these. 60 degrees from horizontal is 30 from
// vertical.

FEEDSTOCK_VIRGIN = ["virgin pellets", 60, 0.62, FLOW_RATIO_CONVERGING_PELLET, FLOW_RATIO_PARALLEL_PELLET];
FEEDSTOCK_REGRIND = ["regrind flake", 70, 0.489, FLOW_RATIO_CONVERGING_FLAKE, FLOW_RATIO_PARALLEL_FLAKE];

feedstock_registry = [FEEDSTOCK_VIRGIN, FEEDSTOCK_REGRIND];

function feedstock_name(type) = type[0]; //! Label for the customizer
function feedstock_min_funnel_angle(type) = type[1]; //! Shallowest funnel that flows, deg from horizontal
function feedstock_bulk_density(type) = type[2]; //! kg per litre
function feedstock_converging_ratio(type) = type[3]; //! Outlet opening as a multiple of particle size
function feedstock_parallel_ratio(type) = type[4]; //! Hose or spigot opening as a multiple of particle size

/**
 * The feedstock at `index`. Asserts rather than returning undef, which would
 * otherwise propagate into the funnel angle and silently flatten the hopper.
 */
function feedstock(index) =
  assert(
    is_num(index) && index >= 0 && index < len(feedstock_registry),
    str("feedstock: index must be 0..", len(feedstock_registry) - 1, ", got: ", index)
  ) feedstock_registry[index];

// ===== Conveyor hose =====

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
