# gb3dpe-pellet-system — CAD tasks
# Requires: openscad (tested on 2021.01)

hopper := "cad/hopper/pellet_hopper.scad"

# Facet counts are set per purpose. The gate proves the model compiles and its
# asserts hold, which facet count has no bearing on, and the bayonet library's
# swept channels are expensive: a body is ~3 s at 32 facets and ~100 s at 120.
# geom uses a fixed count so the baseline is reproducible. Exported meshes use
# the file default, which is high enough for the bayonet fit to be real.
check_facets := "32"
geom_facets := "64"
build  := "build"

# Capacity preset index:label — must match _footprints in cad/hopper/pellet_hopper.scad
sizes := "0:150x150 1:175x175 2:202x202"

# The body prints as segments that bolt together, and each is its own
# render_part entry — so they need no special handling here, only listing. Must
# match `segments` in cad/hopper/pellet_hopper.scad.
body_parts := "body0 body1"

# Only the body and the cap change with the footprint preset. The hub, plate and
# outlet come out identical at all three, so the gate renders them once —
# sweeping them spent three renders proving one thing, and the driver's
# size-dependent asserts run on every render whichever part is asked for.
sized_parts := body_parts + " cap"
fixed_parts := "hub plate outlet"
parts := sized_parts + " " + fixed_parts
plate_variants := "mk3s universal panel"
coupon_scad := "cad/coupons/flow_coupon.scad"
hose_coupon_scad := "cad/coupons/hose_thread_coupon.scad"

default:
    @just --list

# Compile every part at every size, failing on any diagnostic. CI gate.
check:
    #!/usr/bin/env bash
    # The exit code alone is not a gate. Verified on OpenSCAD 2021.01: STL export
    # does return non-zero on a failing assert, and --hardwarnings promotes a
    # WARNING to non-zero. But a reversed range [begin:end] with begin > end only
    # says DEPRECATED, exits 0, and silently iterates BACKWARDS rather than empty,
    # so a loop over [1:n] with n <= 0 yields confident wrong geometry through a
    # clean exit. Both streams are therefore grepped as well.
    set -uo pipefail
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
    fail=0

    # One place where a render is judged, so every case below is one line.
    #   solid  a printed part; must also come out as exactly one CGAL volume
    #   mesh   an assembly or example, where several solids are the point
    #   echo   a module file on its own. The function-only ones carry no
    #          geometry and STL export fails on an empty top-level object, where
    #          echo export exits 0 and the grep below is what catches problems.
    run() {
      local kind=$1 col1=$2 col2=$3 file=$4; shift 4
      local args=() d out rc vols
      for d in "$@"; do args+=(-D "$d"); done
      printf '  %-7s %-13s ' "$col1" "$col2"
      if [ "$kind" = echo ]; then
        out=$(openscad -o "$tmp/out.echo" "${args[@]}" "$file" 2>&1); rc=$?
        out="$out"$'\n'"$(cat "$tmp/out.echo")"
      else
        out=$(openscad --hardwarnings -o "$tmp/out.stl" "${args[@]}" "$file" 2>&1); rc=$?
      fi
      if [ "$rc" -ne 0 ] || grep -qE 'ERROR:|WARNING:|DEPRECATED:' <<<"$out"; then
        echo FAIL
        grep -hE 'ERROR:|WARNING:|DEPRECATED:|TRACE:' <<<"$out" | head -3 | sed 's/^/      /'
        [ "$rc" -ne 0 ] && [ -z "$out" ] && echo "      exit $rc"
        fail=1; return
      fi
      # CGAL reports one volume for the solid plus one for the space around it,
      # so a single printable part is exactly 2. More means the part is in
      # disconnected pieces -- which renders clean, passes every assert, and
      # slices as several objects. Two solids meeting on a coincident plane do
      # it, and it has caught us three times.
      vols=$(grep -oP 'Volumes:\s*\K\d+' <<<"$out" | head -1)
      if [ "$kind" = solid ] && [ -n "$vols" ] && [ "$vols" -ne 2 ]; then
        echo "FAIL  $vols volumes -- the part is in disconnected pieces"
        fail=1; return
      fi
      echo ok
    }

    for s in {{sizes}}; do
      i=${s%%:*}; label=${s##*:}
      for p in {{sized_parts}}; do
        run solid "$p" "$label" {{hopper}} "render_part=\"$p\"" "hopper_size=$i" \
          "render_facets={{check_facets}}"
      done
    done
    for p in {{fixed_parts}}; do
      run solid "$p" "any size" {{hopper}} "render_part=\"$p\"" "render_facets={{check_facets}}"
    done

    # Every plate variant. The driver's own defaults reach one of the three, so
    # the other two were compiled only as their standalone previews, never as
    # the driver assembles them.
    for v in {{plate_variants}}; do
      run solid plate "$v" {{hopper}} 'render_part="plate"' "plate_variant=\"$v\"" \
        "render_facets={{check_facets}}"
    done

    # Composite views at one size only: they render the same solids again, so
    # sweeping every size buys nothing but minutes.
    for p in assembly all; do
      run mesh "$p" default {{hopper}} "render_part=\"$p\"" "render_facets={{check_facets}}"
    done

    # The flow coupon at both angles worth comparing, and the stand. The stand
    # is not the coupon file's default part, so nothing else here renders it.
    for a in 70 60; do
      run solid coupon "$a deg" {{coupon_scad}} 'render_part="coupon"' "angle=$a" \
        'preview_facets={{check_facets}}'
    done
    run solid stand "" {{coupon_scad}} 'render_part="stand"' 'preview_facets={{check_facets}}'

    # Every module file, rendered on its own.
    for f in cad/*/*.scad; do
      run echo mod "$(basename "$f" .scad | sed 's/^hopper_//')" "$f" '$fn={{check_facets}}'
    done

    # Every part exists twice: the driver builds it, and its module file previews
    # it. Nothing forces those to agree, and when they drift the driver quietly
    # builds a different part from the one being looked at.
    printf '  %-7s %-13s ' "drift" "parts"
    if out=$(python3 scripts/drift.py --facets {{check_facets}} 2>&1); then
      echo ok
    else
      echo FAIL; sed 's/^/      /' <<<"$out"; fail=1
    fi

    # Examples set their own $fn as any consumer should, so the gate overrides
    # it -- at their preview quality a sweep takes minutes and proves nothing
    # extra, since this checks that they compile and their asserts hold.
    for f in examples/*.scad; do
      run mesh ex "$(basename "$f" .scad)" "$f" '$fn={{check_facets}}'
    done
    exit $fail

# Render every part at every size to build/ as STL.
render:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{build}}
    for s in {{sizes}}; do
      i=${s%%:*}; label=${s##*:}
      for p in {{parts}}; do
        out={{build}}/hopper-$label-$p.stl
        echo "  -> $out"
        openscad -o "$out" -D "render_part=\"$p\"" -D "hopper_size=$i" {{hopper}}
      done
    done

# Open the assembly in the OpenSCAD GUI with the Customizer.
edit:
    openscad {{hopper}}

clean:
    rm -rf {{build}}

# Check rendered geometry against the committed baseline (see the script docstring).
geom:
    @python3 scripts/geom_stats.py --facets {{geom_facets}}

# Overwrite the geometry baseline. Only after an INTENDED geometry change.
geom-baseline:
    @python3 scripts/geom_stats.py --write --facets {{geom_facets}}

# Export the flow test coupon at one funnel angle.
coupon angle="70" height="80":
    #!/usr/bin/env bash
    # PRINT IT INVERTED, flange down. Print it on the machine and in the material
    # that will print the hopper, at the same layer height: the surface finish is
    # the thing being tested. The stand is a separate print -- `just coupon-stand`
    # -- so the funnel has nothing hanging off it and one stand serves every angle.
    set -euo pipefail
    mkdir -p {{build}}
    openscad --hardwarnings -o {{build}}/flow-coupon-{{angle}}deg.stl \
      -D 'render_part="coupon"' -D 'angle={{angle}}' -D 'height={{height}}' \
      -D 'preview_facets=96' cad/coupons/flow_coupon.scad
    echo "{{build}}/flow-coupon-{{angle}}deg.stl"

# Export the flow coupon's stand. One print, reusable across every angle.
coupon-stand:
    #!/usr/bin/env bash
    # PRINT IT INVERTED, ring down on the bed.
    set -euo pipefail
    mkdir -p {{build}}
    openscad --hardwarnings -o {{build}}/flow-coupon-stand.stl \
      -D 'render_part="stand"' -D 'preview_facets=96' cad/coupons/flow_coupon.scad
    echo "{{build}}/flow-coupon-stand.stl"

# Export a hose-thread test coupon at one clearance.
hose-coupon clearance="0.2" handed="right":
    #!/usr/bin/env bash
    # Print socket-mouth-down, as modelled. Screw the real hose in: it should
    # start by hand, wind the full depth without forcing, and hold when you hang
    # the coupon off the hose and twist it. Keep the tightest that manages all
    # three, then put it in hose_bore_clearance / hose_thread_clearance.
    # The defaults here are what the GB3D hose settled on; a different hose
    # starts this over.
    set -euo pipefail
    mkdir -p {{build}}
    out={{build}}/hose-coupon-{{clearance}}-{{handed}}.stl
    openscad --hardwarnings -o "$out" \
      -D 'clearance={{clearance}}' -D 'handed="{{handed}}"' {{hose_coupon_scad}}
    echo "$out"
