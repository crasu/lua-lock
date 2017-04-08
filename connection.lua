local M, module = {}, ...

function M.handle(client, request)
    package.loaded[module]=nil

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

    local http_auth = require("config").HTTP_AUTH
    if not(string.match(request, "Authorization: Basic " .. http_auth)) then
        local buf = "HTTP/1.0 401 Access Denied\n"
        buf = buf .. "WWW-Authenticate: Basic realm=\"lua-lock\"\n"
        buf = buf .. "Content-Length: 0\n"
        client:send(buf)
        client:on("sent", function(sck) sck:close() end)
        return 401, nil, nil
    end

    if method == "GET" and path == "/" then
        file.open("index.min.html")
        local buf = "HTTP/1.1 200 OK\n\n"
        buf = buf .. file.read() 

        function sendMore(client)
            local buf = file.read()
            if buf == nil then
                file.close()
                client:close()
            else
                client:send(buf, sendMore)
            end
        end

        client:send(buf, sendMore)
    end

    if method == "GET" and path == "/angle" then
        local buf = "HTTP/1.0 200 OK\n"
        buf = buf .. "Content-Type: application/json\n\n"
        buf = buf .. getAngle()
        client:send(buf)
        client:on("sent", function(sck) sck:close() end)
    end

    if method == "POST" then
        local buf = "HTTP/1.0 200 OK\n"
        buf = buf .. "Content-Type: text/html\n\n"
        client:send(buf)
        client:on("sent", function(sck) sck:close() end)
    end

    return 200, method, path
end


return M
