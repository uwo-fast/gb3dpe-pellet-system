// Hopper capacity presets.
// GPL-3.0-or-later
// Units: mm

// Accessors exist because variables do not cross a `use <>` boundary but
// functions do. A consumer that only needs to read a preset can `use` this
// file; one that needs the registry itself to build a customizer dropdown
// must `include` it.

// Row fields:
//   0  name           label used in the customizer and in exported file names
//   1  top_x          outside width of the straight storage section
//   2  top_y          outside depth of the straight storage section
//   3  bin_height     height of the straight storage section
//
// Funnel height is NOT stored: it is solved from the funnel angle and the
// footprint by hopper_funnel.scad. Capacity therefore falls out of the geometry
// rather than dictating it, which is the whole point -- the imported presets
// got their names by fixing capacity first and letting the wall angle be
// whatever was left over, which was 27 to 36 degrees at the corner.
//
// The names are the imported footprints, kept so the presets stay recognisable.
// They no longer describe capacity; the driver echoes the real figure.

HOPPER_2K5 = ["220x180", 220, 180, 75];
HOPPER_5K = ["300x240", 300, 240, 85];
HOPPER_10K = ["390x300", 390, 300, 100];

hopper_size_registry = [HOPPER_2K5, HOPPER_5K, HOPPER_10K];

function hopper_name(type) = type[0]; //! Label for the customizer and exported file names
function hopper_top_x(type) = type[1]; //! Outside width of the straight storage section
function hopper_top_y(type) = type[2]; //! Outside depth of the straight storage section
function hopper_bin_height(type) = type[3]; //! Height of the straight storage section

/**
  * The preset at `index` in the registry. Asserts rather than returning undef,
 * because an out-of-range index otherwise propagates as undef through every
 * downstream dimension and renders a silently wrong part.
 */
function hopper_preset(index) =
  assert(
    is_num(index) && index >= 0 && index < len(hopper_size_registry),
    str(
      "hopper_preset: index must be 0..",
      len(hopper_size_registry) - 1,
      ", got: ",
      index
    )
  ) hopper_size_registry[index];
