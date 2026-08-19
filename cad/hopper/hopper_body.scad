// ============================================================
// HOPPER BODY
// Four-tab bayonet locking neck
// ============================================================


// ============================================================
// BAYONET TAB
// ============================================================

module bayonet_tab(a) {

    rotate([
        0,
        0,
        a
    ])

        translate([
            lock_neck_od/2 - 0.2,
            -lock_tab_w/2,
            lock_tab_z
        ])

            cube([
                lock_tab_d + 0.2,
                lock_tab_w,
                lock_tab_h
            ]);
}


// ============================================================
// HOPPER BODY
// ============================================================

module hopper_body() {

    difference() {

        union() {


            // =================================================
            // CIRCULAR LOCKING NECK
            // =================================================

            cylinder(
                h=lock_neck_h,
                d=lock_neck_od
            );


            // Four bayonet tabs
            for (a=[0:90:270])

                bayonet_tab(a);


            // =================================================
            // ROUND → SQUARE TRANSITION
            // =================================================

            hull() {

                translate([
                    0,
                    0,
                    lock_neck_h - 0.5
                ])

                    cylinder(
                        h=1,
                        d=lock_neck_od
                    );


                translate([
                    0,
                    0,
                    lock_neck_h +
                    neck_transition_h -
                    0.5
                ])

                    rounded_box(
                        throat,
                        throat,
                        1,
                        throat_radius
                    );
            }


            // =================================================
            // MAIN FUNNEL
            // =================================================

            hull() {

                translate([
                    0,
                    0,
                    lock_neck_h +
                    neck_transition_h -
                    0.5
                ])

                    rounded_box(
                        throat,
                        throat,
                        1,
                        throat_radius
                    );


                translate([
                    0,
                    0,
                    lock_neck_h +
                    neck_transition_h +
                    funnel_h -
                    0.5
                ])

                    rounded_box(
                        top_x,
                        top_y,
                        1,
                        funnel_radius
                    );
            }


            // =================================================
            // STRAIGHT STORAGE SECTION
            // =================================================

            translate([
                0,
                0,
                lock_neck_h +
                neck_transition_h +
                funnel_h
            ])

                rounded_box(
                    top_x,
                    top_y,
                    bin_h,
                    funnel_radius
                );
        }


        // ====================================================
        // INTERNAL PELLET PATH
        // ====================================================


        // Circular passage through bayonet neck

        translate([
            0,
            0,
            -1
        ])

            cylinder(
                h=lock_neck_h + 2,
                d=lock_bore_d
            );


        // ====================================================
        // INTERNAL ROUND → SQUARE TRANSITION
        // ====================================================

        hull() {

            translate([
                0,
                0,
                lock_neck_h - 1
            ])

                cylinder(
                    h=2,
                    d=lock_bore_d
                );


            translate([
                0,
                0,
                lock_neck_h +
                neck_transition_h -
                0.5
            ])

                rounded_box(
                    inner_throat,
                    inner_throat,
                    1,
                    inner_throat_r
                );
        }


        // ====================================================
        // FUNNEL CAVITY
        // ====================================================

        hull() {

            translate([
                0,
                0,
                lock_neck_h +
                neck_transition_h -
                0.5
            ])

                rounded_box(
                    inner_throat,
                    inner_throat,
                    1,
                    inner_throat_r
                );


            translate([
                0,
                0,
                lock_neck_h +
                neck_transition_h +
                funnel_h -
                0.5
            ])

                rounded_box(
                    inner_x,
                    inner_y,
                    1,
                    inner_funnel_r
                );
        }


        // ====================================================
        // STORAGE CAVITY
        // ====================================================

        translate([
            0,
            0,
            lock_neck_h +
            neck_transition_h +
            funnel_h -
            0.5
        ])

            rounded_box(
                inner_x,
                inner_y,
                bin_h + 2,
                inner_funnel_r
            );
    }
}


// ============================================================
// CAP
// ============================================================

module hopper_cap() {

    difference() {

        rounded_box(
            cap_outer_x,
            cap_outer_y,
            cap_total_h,
            funnel_radius +
            cap_wall
        );


        translate([
            0,
            0,
            -1
        ])

            rounded_box(
                cap_inner_x,
                cap_inner_y,
                cap_h + 1,
                funnel_radius +
                cap_clearance
            );
    }
}