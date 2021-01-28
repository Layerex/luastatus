pt_testcase_begin
pt_add_fifo "$main_fifo_file"
for f in havoc alligator za all cucumber; do
    touch "$globtest_dir/$f" || pt_fail "Cannot touch $globtest_dir/$f."
    pt_add_file_to_remove "$globtest_dir/$f"
done
pt_write_widget_file <<__EOF__
f = assert(io.open('$main_fifo_file', 'w'))
f:setvbuf('line')
f:write('init\n')
$preface
widget = {
    plugin = '$PT_BUILD_DIR/plugins/fs/plugin-fs.so',
    opts = {
        globs = {'$globtest_dir/*?a*'},
    },
    cb = function(t)
        _validate_t(t, {'$globtest_dir/havoc', '$globtest_dir/alligator', '$globtest_dir/za'})
        f:write('cb glob seems to work...\n')
    end,
}
__EOF__
pt_spawn_luastatus
exec 3<"$main_fifo_file"
measure_start
pt_expect_line 'init' <&3
pt_expect_line 'cb glob seems to work...' <&3
exec 3<&-
pt_testcase_end
