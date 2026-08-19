// ============================================================
// ONE-PIECE MOUNT
//
// Contains:
//
// - M4 roof mounting flange
// - bayonet receiver
// - four socket supports
// - enclosure locating neck
// - pellet transition
// - hose spigot
// ============================================================

// ============================================================
// SOCKET GUSSET
// ============================================================

module mount_gusset(a) {

  rotate(
    [
      0,
      0,
      a,
    ]
  )

    hull() {

      // Foot overlaps mounting plate

      translate(
        [
          socket_outer_d / 2 + 6,
          0,
          mount_t + 1.25,
        ]
      )

        cube(
          [12, 16, 3],
          center=true
        );

      // Upper end overlaps socket wall

      translate(
        [
          socket_outer_d / 2 - 2.5,
          0,
          mount_t + lock_neck_h * 0.55,
        ]
      )

        cube(
          [
            4,
            16,
            lock_neck_h * 0.65,
          ],
          center=true
        );
    }
}

// ============================================================
// BAYONET ENTRY SLOT
//
// Body is inserted 25 degrees before its final position.
// ============================================================

module bayonet_entry(a) {

  rotate(
    [
      0,
      0,
      a,
    ]
  )

    translate(
      [
        socket_inner_d / 2 - 0.3,
        -slot_w / 2,
        mount_t + lock_tab_z - lock_z_clearance,
      ]
    )

      cube(
        [
          slot_radial,
          slot_w,

          lock_neck_h - lock_tab_z + lock_z_clearance + 1,
        ]
      );
}

// ============================================================
// BAYONET ROTATION GROOVE
// ============================================================

module bayonet_groove(a) {

  rotate(
    [
      0,
      0,

      a - lock_rotation - tab_half_angle,
    ]
  )

    rotate_extrude(
      angle=lock_rotation + 2 * tab_half_angle,
      convexity=10
    )

      translate(
        [
          socket_inner_d / 2 - 0.3,

          mount_t + lock_tab_z - lock_z_clearance,
        ]
      )

        square(
          [
            slot_radial,
            groove_h,
          ]
        );
}

// ============================================================
// LOWER FEEDTHROUGH OUTSIDE
// ============================================================

module feedthrough_outer() {

  // ========================================================
  // ENCLOSURE LOCATING NECK
  // ========================================================

  translate(
    [
      0,
      0,
      -feed_neck_len,
    ]
  )

    rounded_box(
      feed_outer,
      feed_outer,
      feed_neck_len + 0.1,
      6
    );

  // ========================================================
  // TRANSITION TO ROUND HOSE SPIGOT
  // ========================================================

  hull() {

    translate(
      [
        0,
        0,
        -feed_neck_len - 0.5,
      ]
    )

      rounded_box(
        feed_outer,
        feed_outer,
        1,
        6
      );

    translate(
      [
        0,
        0,
        -feed_neck_len - transition_h,
      ]
    )

      cylinder(
        h=1,
        d=spigot_od
      );
  }

  // ========================================================
  // MAIN SPIGOT
  // ========================================================

  translate(
    [
      0,
      0,

      -feed_neck_len - transition_h - (
        spigot_len - lead_in
      ),
    ]
  )

    cylinder(
      h=spigot_len - lead_in,
      d=spigot_od
    );

  // ========================================================
  // HOSE INSERTION TAPER
  // ========================================================

  translate(
    [
      0,
      0,

      -feed_neck_len - transition_h - spigot_len,
    ]
  )

    cylinder(
      h=lead_in,
      d1=spigot_od - lead_in_reduction,
      d2=spigot_od
    );
}

// ============================================================
// INTERNAL PELLET PATH
// ============================================================

module feedthrough_void() {

  // ========================================================
  // CONTINUOUS BORE THROUGH MOUNT
  // ========================================================

  translate(
    [
      0,
      0,
      -feed_neck_len - 1,
    ]
  )

    cylinder(
      h=feed_neck_len + mount_t + 2,
      d=lock_bore_d
    );

  // ========================================================
  // LARGE BORE → SPIGOT BORE
  // ========================================================

  hull() {

    translate(
      [
        0,
        0,
        -feed_neck_len - 1,
      ]
    )

      cylinder(
        h=1,
        d=lock_bore_d
      );

    translate(
      [
        0,
        0,
        -feed_neck_len - transition_h,
      ]
    )

      cylinder(
        h=1,
        d=spigot_id
      );
  }

  // ========================================================
  // SPIGOT BORE
  // ========================================================

  translate(
    [
      0,
      0,

      -feed_neck_len - transition_h - spigot_len - 1,
    ]
  )

    cylinder(
      h=spigot_len + 2,
      d=spigot_id
    );
}

// ============================================================
// COMPLETE ROOF MOUNT
// ============================================================

module roof_mount() {

  difference() {

    union() {

      // =================================================
      // 90 x 90 ROOF FLANGE
      // =================================================

      rounded_box(
        mount_x,
        mount_y,
        mount_t,
        mount_radius
      );

      // =================================================
      // CIRCULAR BAYONET SOCKET
      // =================================================

      translate(
        [
          0,
          0,
          mount_t - 0.1,
        ]
      )

        cylinder(
          h=lock_neck_h + 0.1,
          d=socket_outer_d
        );

      // =================================================
      // ONE-PIECE LOWER OUTLET
      // =================================================

      feedthrough_outer();

      // =================================================
      // FOUR SOCKET SUPPORTS
      // =================================================

      if (mount_supports)

        for (a = [0:90:270])

          mount_gusset(a);
    }

    // ====================================================
    // FOUR M4 CLEARANCE HOLES
    // ====================================================

    bolt_pattern(
      mount_t
    );

    // ====================================================
    // MAIN BODY NECK CAVITY
    // ====================================================

    translate(
      [
        0,
        0,
        mount_t - 0.1,
      ]
    )

      cylinder(
        h=lock_neck_h + 1,
        d=socket_inner_d
      );

    // ====================================================
    // FOUR BAYONET PATHS
    // ====================================================

    for (a = [0:90:270]) {

      // Vertical insertion slot is offset
      // counter-clockwise from final position.

      bayonet_entry(
        a - lock_rotation
      );

      // Horizontal quarter-turn path.

      bayonet_groove(a);
    }

    // ====================================================
    // CONTINUOUS PELLET PATH
    // ====================================================

    feedthrough_void();
  }
}
