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
sizes := "0:220x180 1:300x240 2:390x300"
parts := "body mount cap"

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
        printf '  %-5s %-6s ' "$p" "$label"
        out=$(openscad --hardwarnings -o "$tmp/$p.stl" \
                -D "render_part=\"$p\"" -D "hopper_size=$i" \
                -D "render_facets={{check_facets}}" {{hopper}} 2>&1)
        rc=$?
        if [ "$rc" -ne 0 ] || grep -qE 'ERROR:|WARNING:|DEPRECATED:' <<<"$out"; then
          echo FAIL
          grep -hE 'ERROR:|WARNING:|DEPRECATED:|TRACE:' <<<"$out" | sed 's/^/      /'
          [ "$rc" -ne 0 ] && [ -z "$out" ] && echo "      exit $rc"
          fail=1
        else
          echo ok
        fi
      done
    done
    # Composite views at one size only: they render the same solids again, so
    # sweeping every size buys nothing but minutes.
    for p in assembly all; do
      printf '  %-5s %-6s ' "$p" "default"
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
