include <hopper_sizes.scad>

$fn = $preview ? 48 : 120;


/* [Render] */
render_part = "assembly"; // [body,mount,cap,assembly,all]


/* [Hopper Size] */
hopper_size = 0; // [0:2.5 kg,1:5 kg,2:10 kg]


// ============================================================
// SIZE
// ============================================================

P = HOPPERS[hopper_size];

top_x    = P[1];
top_y    = P[2];
bin_h    = P[3];
funnel_h = P[4];


// ============================================================
// HOPPER
// ============================================================

/* [Hopper] */

wall = 3;

throat = 44;

throat_radius = 4;

funnel_radius = 8; // [0:1:20]

// Short round-to-square transition above lock
neck_transition_h = 10;


// ============================================================
// BAYONET LOCK
// ============================================================

/* [Bayonet Lock] */

// Circular body neck
lock_neck_od = 44;

lock_neck_h = 18;


// Four locking tabs

lock_tab_w = 10;

lock_tab_d = 3;

lock_tab_h = 4;

// Height of tabs from bottom of neck
lock_tab_z = 4;


// Quarter-turn amount
lock_rotation = 25; // [15:1:35]


// Radial fit between body neck and socket
lock_clearance = 0.30;


// Vertical clearance around bayonet tabs
lock_z_clearance = 0.25;


// Material around bayonet socket
socket_wall = 4;


// ============================================================
// ROOF MOUNT
// ============================================================

/* [Roof Mount] */

mount_x = 90;

mount_y = 90;

mount_t = 8;

mount_radius = 6;


// Keep reinforcement on mount
mount_supports = true;


// ============================================================
// M4 HARDWARE
// ============================================================

/* [M4 Mounting] */

// 70 x 70 mm pattern
bolt_x = 35;

bolt_y = 35;


// M4 clearance
bolt_d = 4.5;


// ============================================================
// ENCLOSURE
// ============================================================

/* [Enclosure] */

// Approximate enclosure roof thickness
roof_t = 2;


// Locating neck extends slightly below roof
roof_locator_extra = 2;


// ============================================================
// HOSE CONNECTION
// ============================================================

/* [Hose Connection] */

// Hose ID
pipe_id = 25;


// Clearance between hose and printed spigot
pipe_clearance = 0.4;


// 24.6 mm default
spigot_od = pipe_id - pipe_clearance;


// Pellet passage
spigot_id = 20.6;


// Hose engagement length
spigot_len = 35;


// Square/large passage to round outlet transition
transition_h = 20;


// Tip taper
lead_in = 4;

lead_in_reduction = 1.2;


// ============================================================
// CAP
// ============================================================

/* [Cap] */

cap_clearance = 0.6;

cap_wall = 3;

cap_h = 16;

cap_top = 3;


// ============================================================
// DERIVED HOPPER DIMENSIONS
// ============================================================

inner_x = top_x - 2*wall;

inner_y = top_y - 2*wall;

inner_throat = throat - 2*wall;


inner_throat_r =
    max(
        throat_radius - wall,
        0.8
    );


inner_funnel_r =
    max(
        funnel_radius - wall,
        0.8
    );


// Circular pellet bore through locking neck
lock_bore_d =
    lock_neck_od - 2*wall;


// Complete hopper height
body_h =
    lock_neck_h +
    neck_transition_h +
    funnel_h +
    bin_h;


// ============================================================
// BAYONET SOCKET DIMENSIONS
// ============================================================

socket_inner_d =
    lock_neck_od +
    2*lock_clearance;


socket_outer_d =
    lock_neck_od +
    2*(lock_tab_d + socket_wall);


// Entry slot width
slot_w =
    lock_tab_w +
    2*lock_clearance;


// Radial depth required for tabs
slot_radial =
    lock_tab_d +
    lock_clearance +
    0.8;


// Vertical locking groove
groove_h =
    lock_tab_h +
    2*lock_z_clearance;


// Angular allowance for physical width of each tab
tab_half_angle =
    atan(
        (slot_w/2) /
        (lock_neck_od/2 + lock_tab_d/2)
    );


// ============================================================
// ROOF FEEDTHROUGH
// ============================================================

// Square locating section through enclosure
feed_outer =
    lock_neck_od + 2;


// Total length below mounting flange before taper
feed_neck_len =
    roof_t +
    roof_locator_extra;


// ============================================================
// CAP DIMENSIONS
// ============================================================

cap_inner_x =
    top_x +
    2*cap_clearance;


cap_inner_y =
    top_y +
    2*cap_clearance;


cap_outer_x =
    cap_inner_x +
    2*cap_wall;


cap_outer_y =
    cap_inner_y +
    2*cap_wall;


cap_total_h =
    cap_h +
    cap_top;


// ============================================================
// HELPERS
// ============================================================

module rounded_box(x, y, z, r=0) {

    rr =
        min(
            r,
            min(x,y)/2 - 0.01
        );

    if (rr <= 0)

        translate([
            -x/2,
            -y/2,
            0
        ])

            cube([
                x,
                y,
                z
            ]);

    else

        linear_extrude(height=z)

            offset(r=rr)

                offset(delta=-rr)

                    square(
                        [x,y],
                        center=true
                    );
}


module bolt_pattern(h, z0=0) {

    for (x=[-bolt_x, bolt_x])

        for (y=[-bolt_y, bolt_y])

            translate([
                x,
                y,
                z0 - 1
            ])

                cylinder(
                    h=h+2,
                    d=bolt_d
                );
}


// ============================================================
// LOAD GEOMETRY
// ============================================================

include <hopper_body.scad>

include <hopper_mount.scad>


// ============================================================
// ASSEMBLY
// ============================================================

module assembly() {

    roof_mount();


    // This shows the hopper in its FINAL locked position.
    // To physically install it:
    //
    // 1. Rotate body ~25 degrees counter-clockwise.
    // 2. Insert downward.
    // 3. Rotate clockwise to this position.

    translate([
        0,
        0,
        mount_t
    ])

        hopper_body();


    // Cap
    translate([
        0,
        0,
        mount_t +
        body_h -
        cap_h
    ])

        hopper_cap();
}


// ============================================================
// RENDER
// ============================================================

if (render_part == "body")

    hopper_body();


else if (render_part == "mount")

    roof_mount();


else if (render_part == "cap")

    hopper_cap();


else if (render_part == "assembly")

    assembly();


else if (render_part == "all") {

    hopper_body();


    // Mount is raised only so the downward outlet
    // sits above Z=0 in the separated preview.

    translate([
        top_x/2 +
        mount_x/2 +
        40,

        0,

        feed_neck_len +
        transition_h +
        spigot_len
    ])

        roof_mount();


    translate([
        0,

        top_y/2 +
        cap_outer_y/2 +
        40,

        0
    ])

        hopper_cap();
}