x_testcase_output 'nil' ''
x_testcase_output '{}' ''
x_testcase_output '{nil}' ''
x_testcase_output '{{}}' '[{"name":"0"}]'
x_testcase_output '{{},nil,{}}' '[{"name":"0"},{"name":"0"}]'
x_testcase_output '{full_text = "Hello, world"}' '[{"name":"0","full_text":"Hello, world"}]'
x_testcase_output '{{full_text = "Hello, world"}}' '[{"name":"0","full_text":"Hello, world"}]'
x_testcase_output '{{fpval = 1234.5}}' '[{"name":"0","fpval":1234.5}]'
x_testcase_output '{{intval = -12345}}' '[{"name":"0","intval":-12345}]'
x_testcase_output '{{name = "abc"}}' '[{"name":"0"}]'
x_testcase_output '{{name = 123}}' '[{"name":"0"}]'
x_testcase_output '{{separator = true}}' '[{"name":"0","separator":true}]'
x_testcase_output '{{separator = false}}' '[{"name":"0","separator":false}]'
x_testcase_output '{{foo = true, bar = false}}' '[{"name":"0","foo":true,"bar":false}]'

O_NO_SEPARATORS=1 x_testcase_output '{{}}' '[{"name":"0","separator":false}]'
O_NO_SEPARATORS=1 x_testcase_output '{{separator = true}}' '[{"name":"0","separator":true}]'
O_NO_SEPARATORS=1 x_testcase_output '{{separator = false}}' '[{"name":"0","separator":false}]'

O_NO_CLICK_EVENTS=1 x_testcase_output 'nil' ''

O_ALLOW_STOPPING=1 x_testcase_output 'nil' ''
