# gb3dpe-pellet-system — CAD tasks
# Requires: openscad (tested on 2021.01)

hopper := "cad/hopper/pellet_hopper.scad"
build  := "build"

# Capacity preset index:label — must match HOPPERS in cad/hopper/hopper_sizes.scad
sizes := "0:2.5kg 1:5kg 2:10kg"
parts := "body mount cap"

default:
    @just --list

# Compile every part at every size, failing on any OpenSCAD warning. CI gate.
check:
    #!/usr/bin/env bash
    set -uo pipefail
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
    fail=0
    for s in {{sizes}}; do
      i=${s%%:*}; label=${s##*:}
      for p in {{parts}}; do
        printf '  %-5s %-6s ' "$p" "$label"
        if out=$(openscad --hardwarnings -o "$tmp/$p.stl" \
                   -D "render_part=\"$p\"" -D "hopper_size=$i" {{hopper}} 2>&1); then
          echo ok
        else
          echo FAIL; printf '%s\n' "$out" | sed 's/^/      /'; fail=1
        fi
      done
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
