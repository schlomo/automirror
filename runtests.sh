#!/bin/bash
#
set -e -E -u
unset AUTOMIRROR_PRIMARY_DISPLAY

function do_test {
    local xrandr_output="$1" ; shift
    local script_output="$1" ; shift
    local testarg="${1:-}";
    res="$( XRANDR_STATUS_PROGRAM="cat $xrandr_output" XRANDR_SET_PROGRAM=echo AUTOMIRROR_NOTIFY_COMMAND=: ./automirror.sh $testarg)"
    if [[ "$res" == "$(< $script_output)" ]] ; then
        return 0
    else
        echo "Difference:"
        diff -u --label EXPECTED_RESULT --label ACTUAL_RESULT -- $script_output - <<<"$res"
        return 1
    fi
}

failed=0

function run_tests {
    local testcases_dir="$1"; shift
    local testarg="${1:-}";

    for test_case in $testcases_dir/*.txt ; do
        [[ "$test_case" == *result.txt ]] && continue
        script_output=${test_case%.txt}_result.txt
        if [[ "$script_output" && -r "$script_output" ]] ; then
            if do_test "$test_case" "$script_output" "$testarg" ; then
               echo "OK $test_case"
            else
                let failed++ 1
                echo "FAILED $test_case"
            fi
        else
            echo "Missing test result file '$script_output'"
        fi
    done
}

run_tests testdata/plain
run_tests testdata/HDMI3 HDMI3

if (( failed == 0 )) ; then
    exit 0
else
    echo $failed TESTS FAILED
    exit 1
fi
