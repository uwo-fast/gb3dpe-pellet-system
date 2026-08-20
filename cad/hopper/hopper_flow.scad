// Bulk-solids flow rules, as functions.
// GPL-3.0-or-later
// Units: mm

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
