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

    if method == "GET" and path == "/" then
        file.open("index.min.html")
        local buf = "HTTP/1.1 200 OK\n\n"
        buf = buf .. file.read() 
        client:send(buf)
        file.close()
    end

    if method == "GET" and path == "/angle" then
        local buf = "HTTP/1.1 200 OK\n\n"
        buf = buf .. "Content-Type: application/json'\n"
        buf = buf .. "27\n"
        client:send(buf)
    end

    if method == "POST" then
        local buf = "HTTP/1.1 200 OK\n\n"
        buf = buf .. "Content-Type: text/html'\n"
        client:send(buf)
    end
    
    client:close()

    return method, path
end

return M
