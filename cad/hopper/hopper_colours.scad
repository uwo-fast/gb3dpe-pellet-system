// Preview colours, one per printed part.
// GPL-3.0-or-later

// A printed part is exactly one colour. Never colour features within a part
// differently: none of these are multi-material prints, and shading a flange or
// a neck separately from the shell it belongs to says otherwise.
//
// Colours may repeat between parts. Slots are handed out bottom-up through the
// stack -- mount, then each body segment, then the cap -- so parts that touch
// get different ones, which is the only place it matters.
//
// This is presentation only: `color()` affects preview and render display and
// has no effect on an exported mesh.

PART_COLOURS = [
  [0.42, 0.51, 0.62], // slate
  [0.85, 0.66, 0.35], // amber
  [0.47, 0.61, 0.49], // sage
  [0.72, 0.45, 0.40], // terracotta
  [0.55, 0.48, 0.64], // heather
];

// Wraps round rather than running off the end, so any segment count is valid.
function part_colour(index) = PART_COLOURS[index % len(PART_COLOURS)];

// Slots are handed out bottom-up through the assembled stack.
function colour_outlet() = part_colour(0); //! Outlet, below the plate
function colour_plate() = part_colour(1); //! Mounting plate
function colour_hub() = part_colour(2); //! Hub
function colour_body_segment(index) = part_colour(3 + index); //! One body segment
function colour_cap(segments) = part_colour(3 + segments); //! Cap, above the topmost segment
