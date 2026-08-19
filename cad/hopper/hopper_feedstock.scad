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
// The angles are design targets, not measured values. The critical mass-flow
// angle depends on the material AND on the wall friction of the printed
// surface, so a hopper that bridges in service wants a measured wall friction
// angle rather than a nudge to these numbers. Tracked in TODO.md.
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
