coproc "$PT_PARROT" --reuseaddr --print-line-when-ready TCP-SERVER "$port" \
    || pt_fail "coproc failed"

pt_add_spawned_thing parrot "$COPROC_PID"

pt_expect_line 'parrot: ready' <&${COPROC[0]}

pt_testcase_begin
pt_write_widget_file <<__EOF__
widget = {
    plugin = '$PT_BUILD_DIR/plugins/mpd/plugin-mpd.so',
    opts = {
        port = $port,
        hostname = '255.255.255.255',
        retry_in = -1,
    },
    cb = function(t) end,
}
__EOF__
pt_spawn_luastatus -e
pt_wait_luastatus || pt_fail "luastatus exited with non-zero code"

pt_kill_thing parrot

pt_testcase_end
