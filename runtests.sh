#!/bin/bash
#
set -e -E -u

function do_test {
    local xrandr_output="$1" ; shift
    local script_output="$1" ; shift
    res="$( XRANDR_STATUS_PROGRAM="cat $xrandr_output" XRANDR_SET_PROGRAM=echo AUTOMIRROR_NOTIFY_COMMAND=: ./automirror.sh)"
    if [[ "$res" == "$(< $script_output)" ]] ; then
        return 0
    else
        echo "Difference:"
        diff -u --label EXPECTED_RESULT --label ACTUAL_RESULT -- $script_output - <<<"$res"
        return 1
    fi
}

failed=0

for test_case in testdata/*.txt ; do
    [[ "$test_case" == *result.txt ]] && continue
    script_output=${test_case%.txt}_result.txt
    if [[ "$script_output" && -r "$script_output" ]] ; then
        if do_test "$test_case" "$script_output" ; then
           echo "OK $test_case" 
        else
            let failed++ 1
            echo "FAILED $test_case"
        fi
    else
        echo "Missing test result file '$script_output'"
    fi
done

if (( failed == 0 )) ; then
    exit 0
else
    echo $failed TESTS FAILED
    exit 1
fi
