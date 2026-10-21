#!/bin/bash
# Rebuild the focused workspace as a balanced dwindle layout: [1 | [2 / [3 | ...]]]
export PATH="/opt/homebrew/bin:$PATH"
# Commands below must follow focus, not the window that triggered the binding
unset AEROSPACE_WINDOW_ID AEROSPACE_WORKSPACE

focused=$(aerospace list-windows --focused --format '%{window-id}')
aerospace flatten-workspace-tree
aerospace layout --root tiles

case $(aerospace list-workspaces --focused --format '%{workspace-root-container-layout}') in
    v_*) dir=down ;;
    *) dir=right ;;
esac

# After flattening, DFS index == position in the row. Joining from the right end inwards keeps
# that order, and normalization alternates the orientation of each nested container.
n=$(aerospace list-windows --workspace focused --format '%{window-layout}' | grep -vc floating)
for ((i = n - 2; i >= 1; i--)); do
    aerospace focus --dfs-index "$i" && aerospace join-with "$dir"
done

aerospace balance-sizes
[[ -n $focused ]] && aerospace focus --window-id "$focused"
