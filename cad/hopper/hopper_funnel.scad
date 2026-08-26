// Funnel geometry and capacity maths.
// GPL-3.0-or-later
// Units: mm, degrees, litres

// Angles here are measured from HORIZONTAL. A steeper funnel is a larger angle.
// Hopper literature usually quotes the angle from VERTICAL, which is 90 minus
// these. Rationale and sources: docs/design-notes.md.

/**
 * Horizontal distance the DIAGONAL CORNER travels from the throat out to the
 * bin, which is the longest run in the funnel.
 *
 * The corner is what governs. On a rectangular funnel it runs further out than
 * either flat face over the same drop, so it is always the shallowest surface
 * in the part, and pellets bridge on the shallowest surface rather than the
 * average one. Setting the target on a face leaves the corner well below it.
 */
function funnel_corner_run(top_x, top_y, throat) =
  norm([(top_x - throat) / 2, (top_y - throat) / 2]);

// Drop required for the corner to sit at `angle`. This is the design direction:
// choose the angle, get the height.
function funnel_height_for_angle(top_x, top_y, throat, angle) =
  funnel_corner_run(top_x, top_y, throat) * tan(angle);

// Angle of one flat face, given the full span across it. Always steeper than
// the corner, and the two faces differ whenever the footprint is not square.
function funnel_face_angle(span, throat, height) = atan(height / ( (span - throat) / 2));

/**
 * Horizontal inset that yields `min_wall` of material measured PERPENDICULAR to
 * the surface.
 *
 * Wall thickness is applied by insetting the inner surface horizontally, but on
 * a face sloped at theta the material perpendicular to it is only
 * inset * sin(theta). Compensating on the corner angle -- the shallowest
 * surface -- means no surface finishes thinner than min_wall. The flat faces
 * and the vertical bin come out somewhat thicker, which is the cost of one
 * horizontal inset having to serve surfaces at three different angles.
 *
 * A single inset also keeps every inner surface parallel to its outer, so the
 * funnel meets the bin with no internal ledge for pellets to catch on.
 */
function funnel_wall_inset(min_wall, corner_angle) = min_wall / sin(corner_angle);

function _lerp(a, b, t) = a + (b - a) * t;

/**
 * Outer section of the body at absolute height `z`: [span_x, span_y, radius].
 * Above the taper it is the constant bin section. Only meaningful at or above
 * the base of the taper — below that the body is round, not rectangular.
 *
 * The taper is built as a hull between two thin slabs, and its sloped face runs
 * from the bottom edge of the lower slab to the bottom edge of the upper, so
 * the section is linear in that range. Splitting the body needs to know it
 * exactly, because both halves of the joint are cut from it.
 */
function funnel_body_section(
  throat,
  top_x,
  top_y,
  throat_radius,
  funnel_radius,
  throat_z,
  funnel_height,
  z
) =
  // The taper's sloped face starts half a slab BELOW the nominal throat
  // station, because loft() centres each slab on its z. Correcting here rather
  // than at the call sites keeps it in the one place that knows the shape.
  let (base = throat_z - 0.5, t = min(1, (z - base) / funnel_height)) [
      _lerp(throat, top_x, t),
      _lerp(throat, top_y, t),
      _lerp(throat_radius, funnel_radius, t),
  ];

// Volume of the tapered section, as a prismatoid between the two rectangles.
// Corner rounding is ignored, so this reads slightly high.
function funnel_volume_l(inner_x, inner_y, inner_throat, height) =
  let (a1 = inner_throat * inner_throat, a2 = inner_x * inner_y) height / 3 * (a1 + a2 + sqrt(a1 * a2)) / 1e6;

function bin_volume_l(inner_x, inner_y, bin_height) = inner_x * inner_y * bin_height / 1e6;

// Usable volume, ignoring the neck and its transition.
function hopper_volume_l(inner_x, inner_y, inner_throat, bin_height, funnel_height) =
  bin_volume_l(inner_x, inner_y, bin_height) + funnel_volume_l(inner_x, inner_y, inner_throat, funnel_height);

function hopper_capacity_kg(volume_l, bulk_density) = volume_l * bulk_density;
