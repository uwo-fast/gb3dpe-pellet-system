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

# Capacity preset index:label — must match HOPPERS in cad/hopper/hopper_sizes.scad
sizes := "0:150x150 1:175x175 2:202x202"
parts := "body cap hub plate outlet"

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
    for s in {{sizes}}; do
      i=${s%%:*}; label=${s##*:}
      for p in {{parts}}; do
        printf '  %-5s %-8s ' "$p" "$label"
        out=$(openscad --hardwarnings -o "$tmp/$p.stl" \
                -D "render_part=\"$p\"" -D "hopper_size=$i" \
                -D "render_facets={{check_facets}}" {{hopper}} 2>&1)
        rc=$?
        # CGAL reports one volume for the solid plus one for the space around
        # it, so a single printable part is exactly 2. More means the part is
        # in disconnected pieces -- which renders clean, passes every assert,
        # and slices as several objects. Two solids meeting on a coincident
        # plane do it, and it has caught us three times.
        vols=$(grep -oP 'Volumes:\s*\K\d+' <<<"$out" | head -1)
        if [ "$rc" -ne 0 ] || grep -qE 'ERROR:|WARNING:|DEPRECATED:' <<<"$out"; then
          echo FAIL
          grep -hE 'ERROR:|WARNING:|DEPRECATED:|TRACE:' <<<"$out" | sed 's/^/      /'
          [ "$rc" -ne 0 ] && [ -z "$out" ] && echo "      exit $rc"
          fail=1
        elif [ -n "$vols" ] && [ "$vols" -ne 2 ]; then
          echo "FAIL  $vols volumes -- the part is in disconnected pieces"
          fail=1
        else
          echo ok
        fi
      done
    done
    # Every segment of the body at the default size: a cut that lands badly only
    # shows up on the segment it lands on.
    for g in 0 1; do
      printf '  %-5s %-8s ' "seg$g" "default"
      out=$(openscad --hardwarnings -o "$tmp/seg.stl" -D 'render_part="body"' \
              -D "segment=$g" -D "render_facets={{check_facets}}" {{hopper}} 2>&1)
      rc=$?
      if [ "$rc" -ne 0 ] || grep -qE 'ERROR:|WARNING:|DEPRECATED:' <<<"$out"; then
        echo FAIL; grep -hE 'ERROR:|WARNING:|DEPRECATED:|TRACE:' <<<"$out" | sed 's/^/      /'; fail=1
      else echo ok; fi
    done
    # Composite views at one size only: they render the same solids again, so
    # sweeping every size buys nothing but minutes.
    for p in assembly all; do
      printf '  %-5s %-8s ' "$p" "default"
      out=$(openscad --hardwarnings -o "$tmp/$p.stl" -D "render_part=\"$p\"" \
              -D "render_facets={{check_facets}}" {{hopper}} 2>&1)
      rc=$?
      if [ "$rc" -ne 0 ] || grep -qE 'ERROR:|WARNING:|DEPRECATED:' <<<"$out"; then
        echo FAIL
        grep -hE 'ERROR:|WARNING:|DEPRECATED:|TRACE:' <<<"$out" | sed 's/^/      /'
        fail=1
      else
        echo ok
      fi
    done
    # Every module file, rendered on its own. Uses echo export because the
    # function-only files have no geometry and STL export fails on an empty
    # top-level object -- echo export exits 0 there, and the grep below is what
    # actually catches problems either way.
    for f in cad/*/*.scad; do
      printf '  %-5s %-8s ' "mod" "$(basename "$f" .scad | sed 's/^hopper_//')"
      out=$(openscad -o "$tmp/mod.echo" -D '$fn={{check_facets}}' "$f" 2>&1)
      rc=$?
      if [ "$rc" -ne 0 ] || grep -qE 'ERROR:|WARNING:|DEPRECATED:' <<<"$out" "$tmp/mod.echo"; then
        echo FAIL; grep -hE 'ERROR:|WARNING:|DEPRECATED:|TRACE:' <<<"$out" "$tmp/mod.echo" | head -3 | sed 's/^/      /'; fail=1
      else echo ok; fi
    done
    # Every part exists twice: the driver builds it, and its module file previews
    # it. Nothing forces those to agree, and when they drift the driver quietly
    # builds a different part from the one being looked at.
    printf '  %-5s %-8s ' "drift" "parts"
    if out=$(python3 scripts/drift.py --facets {{check_facets}} 2>&1); then
      echo ok
    else
      echo FAIL; sed 's/^/      /' <<<"$out"; fail=1
    fi

    # Examples set their own $fn as any consumer should, so the gate overrides
    # it -- at their preview quality a sweep takes minutes and proves nothing
    # extra, since this checks that they compile and their asserts hold.
    for f in examples/*.scad; do
      printf '  %-5s %-8s ' "ex" "$(basename "$f" .scad)"
      out=$(openscad --hardwarnings -o "$tmp/ex.stl" -D '$fn={{check_facets}}' "$f" 2>&1)
      rc=$?
      if [ "$rc" -ne 0 ] || grep -qE 'ERROR:|WARNING:|DEPRECATED:' <<<"$out"; then
        echo FAIL; grep -hE 'ERROR:|WARNING:|DEPRECATED:|TRACE:' <<<"$out" | sed 's/^/      /'; fail=1
      else echo ok; fi
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

# Export the flow test coupon. Print it in the hopper's material and layer
# height -- the layer lines ARE the wall texture being tested.
coupon angle="70" height="80":
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{build}}
    out={{build}}/flow-coupon-{{angle}}deg.stl
    openscad --hardwarnings -o "$out" \
      -D 'angle={{angle}}' -D 'height={{height}}' \
      -D '$fn=96' cad/coupons/flow_coupon.scad
    echo "$out"
