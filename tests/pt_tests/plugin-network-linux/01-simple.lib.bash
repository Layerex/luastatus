pt_testcase_begin
pt_add_fifo "$main_fifo_file"
pt_write_widget_file <<__EOF__
f = assert(io.open('$main_fifo_file', 'w'))
f:setvbuf('line')
f:write('init\n')
local function _fmt_t(t)
    local s = {}
    for k, v in pairs(t) do
        for _, x in ipairs(v.ipv4 or {}) do
            s[#s + 1] = string.format('%s ipv4 %s', k, x)
        end
        for _, x in ipairs(v.ipv6 or {}) do
            s[#s + 1] = string.format('%s ipv6 %s', k, x)
        end
    end
    table.sort(s)
    return table.concat(s, ';') .. ';'
end
widget = {
    plugin = '$PT_BUILD_DIR/plugins/network-linux/plugin-network-linux.so',
    opts = {new_ip_fmt = true},
    cb = function(t)
        if t == nil then
            f:write('cb nil\n')
        else
            f:write('cb table ' .. _fmt_t(t) .. '\n')
        end
    end,
}
__EOF__
pt_spawn_luastatus
exec {pfd}<"$main_fifo_file"
pt_expect_line 'init' <&$pfd

listnets_binary=$PT_BUILD_DIR/tests/listnets
c=0; nets=$("$listnets_binary") || c=$?
case "$c" in
0)
    nets=$(printf '%s\n' "$nets" | sort | tr '\n' ';')
    expect_str="cb table $nets"
    ;;
1)
    expect_str="cb nil"
    ;;
*)
    pt_fail "listnets binary ('$listnets_binary') failed with code $c."
    ;;
esac

pt_expect_line "$expect_str" <&$pfd

pt_close_fd "$pfd"
pt_testcase_end
