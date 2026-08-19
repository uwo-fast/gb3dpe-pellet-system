// Feedstock properties that drive hopper geometry.
// GPL-3.0-or-later
// Units: mm, degrees, kg/L

// We run this printer on both virgin pellets and shredded regrind, and they are
// not interchangeable inputs. Regrind is irregular, higher friction and roughly
// half the bulk density, so it needs a steeper funnel to flow and stores much
// less mass in the same box.
//
// Row fields:
//   0  name              label for the customizer
//   1  min_funnel_angle  shallowest funnel that still flows, degrees from HORIZONTAL
//   2  bulk_density      kg per litre, for capacity reporting
//
// SOURCES -- see docs/design-notes.md for the reasoning and full citations.
//   Angles are design targets from general bulk-solids practice, NOT measured.
//   The critical mass-flow angle depends on the material and on the wall
//   friction of the surface it slides on (Jenike & Johanson), so a printed wall
//   is not interchangeable with the steel those figures assume. Regrind is set
//   steeper because irregular flake nests and bridges (Wijay Systems).
//   Bulk density spans roughly 450-850 kg/m3 across resin types (Conair);
//   virgin PLA sits mid-range, and the regrind figure is an estimate because
//   flake density is variable rather than a property.
//   A hopper that bridges in service wants a measured wall friction angle
//   against an actual printed surface, not a nudge to these. Tracked in TODO.md.
//
// Note the convention: hopper literature usually quotes the angle from
// VERTICAL, which is 90 minus these. 60 degrees from horizontal is 30 from
// vertical.

FEEDSTOCK_VIRGIN = ["virgin pellets", 60, 0.62];
FEEDSTOCK_REGRIND = ["regrind flake", 70, 0.35];

feedstock_registry = [FEEDSTOCK_VIRGIN, FEEDSTOCK_REGRIND];

function feedstock_name(type) = type[0]; //! Label for the customizer
function feedstock_min_funnel_angle(type) = type[1]; //! Shallowest funnel that flows, deg from horizontal
function feedstock_bulk_density(type) = type[2]; //! kg per litre

/**
 * The feedstock at `index`. Asserts rather than returning undef, which would
 * otherwise propagate into the funnel angle and silently flatten the hopper.
 */
function feedstock(index) =
  assert(
    is_num(index) && index >= 0 && index < len(feedstock_registry),
    str("feedstock: index must be 0..", len(feedstock_registry) - 1, ", got: ", index)
  ) feedstock_registry[index];
