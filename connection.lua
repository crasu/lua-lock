local M, module = {}, ...

function M.handle(client, request)
    package.loaded[module]=nil

    local buf = "";
    local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
    if(method == nil)then
        _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
    end
    local _GET = {}
    if (vars ~= nil)then
        for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
            _GET[k] = v
        end
    end
    buf = buf.."<h1> ESP8266 Web Server</h1>";
    buf = buf..[[<p>Door: <a href=\"?cmd=CLOSE\"><button>Close</button></a>&nbsp;
        <a href=\"?cmd=OPEN\"><button>Open</button></a>&nbsp;
        <a href=\"?cmd=TILT\"><button>Tilt</button></a></p>]];
    buf = buf.."<p>Tune: <a href=\"?cmd=TUNECLOSE\"><button>Close</button></a>&nbsp;<a href=\"?cmd=TUNEOPEN\"><button>Open</button></a></p>";
    buf = buf.."<p>Sleep <a href=\"?cmd=MS\"><button>Modem Sleep</button></a>&nbsp;<a href=\"?cmd=LS\"><button>Light Sleep</button></a>&nbsp;<a href=\"?cmd=DS\"><button>Deep Sleep</button></a></p>";
    buf = buf.."<p>ADC: ".. adc.read(0) .. "</p>"
    client:send(buf)
    client:close()

    return _GET.cmd
end

return M
