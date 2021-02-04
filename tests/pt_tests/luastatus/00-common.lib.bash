main_fifo_file=./tmp-main-fifo

hang_timeout=${PT_HANG_TIMEOUT:-7}

mock_barlib="$PT_BUILD_DIR"/tests/barlib-mock.so
mock_plugin="$PT_BUILD_DIR"/tests/plugin-mock.so

if [[ "$(uname -s)" == Linux ]]; then
    is_process_sleeping() {
        local state
        state=$(awk '$1 == "State:" { print $2 }' /proc/"$1"/status) || return 3
        [[ $state == S ]]
    }
else
    is_process_sleeping() {
        true
    }
fi

assert_exits_with_code() {
    local expected_c=$1
    shift
    pt_spawn_luastatus_directly "$@"
    local actual_c
    pt_wait_luastatus; actual_c=$?
    if (( expected_c != actual_c )); then
        pt_fail "Expected exit code $expected_c, found $actual_c."
    fi
}

assert_succeeds() {
    assert_exits_with_code 0 "$@"
}

assert_fails() {
    assert_exits_with_code 1 "$@"
}

assert_hangs() {
    pt_spawn_luastatus_directly "$@"
    local pid=$(pt_spawned_thing_pid luastatus)
    is_process_sleeping "$pid" || pt_fail "luastatus (PID $pid) does not appear to be sleeping."
    sleep "$hang_timeout" || pt_fail "Cannot sleep for hang_timeout=$hang_timeout seconds."
    pt_kill_thing luastatus
}

assert_works() {
    assert_hangs "$@"
    assert_succeeds -e "$@"
}

testcase_assert_fails() {
    pt_testcase_begin
    assert_fails "$@"
    pt_testcase_end
}

testcase_assert_succeeds() {
    pt_testcase_begin
    assert_succeeds "$@"
    pt_testcase_end
}

testcase_assert_works() {
    pt_testcase_begin
    assert_works "$@"
    pt_testcase_end
}
