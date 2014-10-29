#!/bin/bash
set -e -E -u

XRANDR_STATUS_PROGRAM=${XRANDR_STATUS_PROGRAM:-xrandr}
XRANDR_SET_PROGRAM=${XRANDR_SET_PROGRAM:-xrandr}

PRIMARY_DISPLAY=${AUTOMIRROR_PRIMARY_DISPLAY:-LVDS1}
NOTIFY_SEND=( ${AUTOMIRROR_NOTIFY_COMMAND:-notify-send -a automirror -i automirror "Automatic Mirror Configuration"} )

# force called programs to english output
LANG=C LC_ALL=C

function die {
    echo 1>&2 "$*"
    exit 10
}


function get_display_resolution {
    local find_display="$1" ; shift
    local display_list="$1"
    while read display width_mm height_mm width height  ; do
        if [[ "$display" == "$find_display" ]] ; then
            echo ${width}x${height}
            return 0
        fi
    done <<<"$display_list"
    die "Could not determine resolution for '$find_display'. Display Data:
$display_list"
}

function get_highest_display {
    local display_list="$1" ; shift
    local data=( $(sort -r -n -k 5 <<<"$display_list") )
    echo $data
}

xrandr_current="$($XRANDR_STATUS_PROGRAM)"

# find connected displays by filtering those that are connected and have a size set in millimeters (mm)
connected_displays=( $(sed -n -e 's/^\(.*\) connected.*mm$/\1/p' <<<"$xrandr_current") )

# See http://stackoverflow.com/a/1252191/2042547 for how to use sed to replace newlines
# display_list is a list of displays with their maximum/optimum pixel and physical dimensions
#                                                                                                         thanks to the first sed I know that here is only a SINGLE space
#                                                                                                                                          |
display_list="$(sed ':a;N;$!ba;s/\n   / /g' <<<"$xrandr_current" | sed -n -e 's/^\([A-Z0-9_-]\+\) connected.* \([0-9]\+\)mm.* \([0-9]\+\)mm \([0-9]\+\)x\([0-9]\+\).*$/\1 \2 \3 \4 \5/p' )"
: connected_displays: ${connected_displays[@]}
: display_list: "$display_list"

if [[ -z "$display_list" ]] ; then
    die "Could not find any displays connected. XRANDR output:
$xrandr_current"
fi


# if the primary display is NOT connected then use the highest display as primary
if [[ "${connected_displays[*]}" != *$PRIMARY_DISPLAY* ]] ; then
    PRIMARY_DISPLAY=$(get_highest_display "$display_list")
fi
frame_buffer_resolution=$(get_display_resolution $PRIMARY_DISPLAY "$display_list")

: $frame_buffer_resolution

xrandr_set_args=( --fb $frame_buffer_resolution )
notify_string=""
if (( ${#connected_displays[@]} == 1 )) ; then
    xrandr_set_args+=( --output $connected_displays --mode $frame_buffer_resolution --scale 1x1 )
    notify_string="$connected_displays reset to $frame_buffer_resolution"
else
    other_display_list="$(grep -v ^$PRIMARY_DISPLAY <<<"$display_list")"
    $XRANDR_SET_PROGRAM $(while read display junk ; do echo " --output $display --scale 1x1 --off" ; done <<<"$other_display_list")
    xrandr_set_args+=( --output $PRIMARY_DISPLAY --mode $frame_buffer_resolution --scale 1x1 )
    notify_string="$PRIMARY_DISPLAY is primary at $frame_buffer_resolution"
    while read display junk ; do
        mode="$(get_display_resolution $display "$other_display_list")"
        xrandr_set_args+=( --output $display --same-as $PRIMARY_DISPLAY --mode "$mode" --scale-from $frame_buffer_resolution  )
        notify_string="$notify_string\n$display is scaled mirror at $mode"
    done <<<"$other_display_list"
fi

#logger -s -t "$0" -- Running $XRANDR_SET_PROGRAM "${xrandr_set_args[@]}"

$XRANDR_SET_PROGRAM "${xrandr_set_args[@]}"
ret=$?
"${NOTIFY_SEND[@]}" "$notify_string"
exit $ret
