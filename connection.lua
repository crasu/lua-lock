local M, module = {}, ...

function M.handle(client, request)
    package.loaded[module]=nil

    local buf = ""
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
        file.open("index.html")
        local data = file.read() 
        client:send(data)
    end
    
    file.close()
    client:close()

    if method == "POST" then
        return path:gsub("^/", "")
    else 
        return nil
    end
end

return M
