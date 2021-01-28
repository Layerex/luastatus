pt_testcase_begin
pt_add_fifo "$main_fifo_file"
myfile=$(mktemp) || pt_fail "Cannot create temporary file."
pt_add_file_to_remove "$myfile"
pt_write_widget_file <<__EOF__
f = assert(io.open('$main_fifo_file', 'w'))
f:setvbuf('line')
f:write('init\n')
$preface
widget = {
    plugin = '$PT_BUILD_DIR/plugins/inotify/plugin-inotify.so',
    opts = {
        watch = {},
        greet = true,
    },
    cb = function(t)
        local line
        if t.what == 'hello' then
            line = 'cb hello'
        else
            assert(t.what == 'event')
            line = 'cb event mask=' .. _fmt_mask(t.mask)
        end
        local wd = luastatus.plugin.add_watch('$myfile', {'close_write', 'delete_self', 'oneshot'})
        if wd then
            f:write(line .. ' (add_watch: ok)\n')
        else
            f:write(line .. ' (add_watch: error)\n')
        end
    end,
}
__EOF__
pt_spawn_luastatus
exec 3<"$main_fifo_file"
pt_expect_line 'init' <&3
pt_expect_line 'cb hello (add_watch: ok)' <&3
for (( i = 0; i < 5; ++i )); do
    echo hello >> "$myfile" || pt_fail "Cannot write to $myfile."
    pt_expect_line 'cb event mask=close_write (add_watch: ok)' <&3
    pt_expect_line 'cb event mask=ignored (add_watch: ok)' <&3
done
rm -f "$myfile" || pt_fail "Cannot rm $myfile."
pt_expect_line 'cb event mask=delete_self (add_watch: error)' <&3
pt_expect_line 'cb event mask=ignored (add_watch: error)' <&3
exec 3<&-
pt_testcase_end
