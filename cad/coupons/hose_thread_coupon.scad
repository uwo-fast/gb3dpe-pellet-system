// Hose thread test coupon: the outlet's socket on its own, to print and screw
// the real hose into. Prints as modelled -- socket mouth on the bed.
// GPL-3.0-or-later
// Units: mm

/* [Hose] */

// Measured: 21 mm over the tube, with a ROUND rib wound around it -- a
// semicircular section 3.5 mm across, at 7.6 mm pitch. The rib's centreline
// rides on the tube's surface, so only its radius stands proud: 24.5 mm overall
// across the ribs. Round thread, so the crest between turns is blunt.
tube_od = 21;
rib = 3.5;
pitch = 7.6;
// Unconfirmed. Print one of each; whichever starts is the answer.
handed = "right"; // [right,left]

/* [Coupon] */

clearance = 0.4; // [0:0.05:1.2]
turns = 3; // [2:0.5:6]
wall = 3;

$fn = $preview ? 48 : 96;

_h = turns * pitch;

/**
 * The groove the rib winds into: the rib's own circular section swept along the
 * helix it is wound on, as one polyhedron.
 *
 * Not linear_extrude(twist=): at this radius and pitch it collapses the section
 * and cuts a tenth of the volume it should. Not hulled spheres either -- correct,
 * but CGAL will not finish unioning two hundred of them.
 */
module round_thread(r_path, r_sec, lead, sweep, seg = 64, sec = 32) {
  n = round(sweep * seg);
  pts = [
    for (i = [0:n]) let (a = 360 * i / seg, z = i / seg * lead - lead)
      for (j = [0:sec - 1]) let (t = 360 * j / sec)
        [(r_path + r_sec * cos(t)) * cos(a),
         (r_path + r_sec * cos(t)) * sin(a),
         z + r_sec * sin(t)]
  ];
  polyhedron(
    points = pts,
    faces = concat(
      [[for (j = [sec - 1:-1:0]) j]],
      [[for (j = [0:sec - 1]) n * sec + j]],
      [for (i = [0:n - 1]) for (j = [0:sec - 1]) let (k = (j + 1) % sec)
        [i * sec + j, i * sec + k, (i + 1) * sec + k, (i + 1) * sec + j]]
    ),
    convexity = 8
  );
}

difference() {
  cylinder(h = _h, d = tube_od + rib + 2 * wall);
  translate([0, 0, -0.5]) cylinder(h = _h + 1, d = tube_od + clearance);
  // Right-handed as generated; mirroring reverses the helix.
  mirror([handed == "right" ? 0 : 1, 0, 0])
    round_thread(tube_od / 2, (rib + clearance) / 2, pitch, turns + 2);
}
