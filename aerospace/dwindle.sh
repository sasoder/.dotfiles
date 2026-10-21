#!/bin/bash
# on-window-detected hook. AeroSpace drops a new window next to the last focused one, so every
# window in that row gets narrower. Once a workspace has more than SPLIT_AFTER tiled windows,
# this joins the new window with that neighbour instead, splitting only its space (BSP/dwindle).
export PATH="/opt/homebrew/bin:$PATH"
SPLIT_AFTER=2

id=$AEROSPACE_WINDOW_ID
read -r layout ws <<<"$(aerospace echo --window-id "$id" -- '%{window-layout} %{workspace}')"

case $layout in
    h_tiles) dir=left ;;
    v_tiles) dir=up ;;
    *) exit 0 ;; # floating or accordion: nothing gets squeezed
esac

tiled=$(aerospace list-windows --workspace "$ws" --format '%{window-layout}' | grep -vc floating)
if ((tiled > SPLIT_AFTER)); then
    aerospace join-with --window-id "$id" "$dir"
fi
