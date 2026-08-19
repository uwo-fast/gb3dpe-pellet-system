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
//
// Neither bin height nor funnel height is stored: it is solved from the funnel angle and the
// footprint by hopper_funnel.scad. Capacity therefore falls out of the geometry
// rather than dictating it, which is the whole point -- the imported presets
// got their names by fixing capacity first and letting the wall angle be
// whatever was left over, which was 27 to 36 degrees at the corner.
//
// the funnel from the wall angle, the bin from whatever height is left in the
// segments. Only the footprint is a free choice, so only the footprint is here.
//
// 202 x 202 is the largest that fits an MK3S once the cap's clearance and wall
// are added: 202 + 7.2 = 209.2 against a 210 mm bed.

HOPPER_SMALL = ["150x150", 150, 150];
HOPPER_MEDIUM = ["175x175", 175, 175];
HOPPER_LARGE = ["202x202", 202, 202];

hopper_size_registry = [HOPPER_SMALL, HOPPER_MEDIUM, HOPPER_LARGE];

function hopper_name(type) = type[0]; //! Label for the customizer and exported file names
function hopper_top_x(type) = type[1]; //! Outside width of the straight storage section
function hopper_top_y(type) = type[2]; //! Outside depth of the straight storage section


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
