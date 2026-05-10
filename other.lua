local httpService = game:GetService("HttpService")

local function getServerToJoin()
    local success, result = pcall(function()
        local servers = httpService:JSONDecode(readfile("asset taker/servers.json"))
        return servers
    end)
    
    if not success then
        warn("Failed to read servers.json: " .. tostring(result))
        return nil
    end
    
    local servers = result
    local join = nil
    for key, val in pairs(servers) do
        if val == false then
            join = key
            break
        end
    end
    
    if not join then
        warn("No available servers found to join")
        return nil
    end
    
    servers[join] = true
    
    local writeSuccess, writeErr = pcall(function()
        writefile("asset taker/servers.json", httpService:JSONEncode(servers))
    end)
    
    if not writeSuccess then
        warn("Failed to write servers.json: " .. tostring(writeErr))
    end
    
    print(join, servers[join])
    return join
end

local function joinServer(key)
    if not key then
        warn("No server key provided to joinServer")
        return
    end
    
    local q = queue_on_teleport or queueonteleport or queueteleport
    if not q then
        warn("No teleport queue function available")
        return
    end
    
    local success, err = pcall(function()
        q(
            [[
                local q = queue_on_teleport or queueonteleport or queueteleport
                local c = clearqueueonteleport or clear_teleport_queue
                q('loadstring(game:HttpGet("https://raw.githubusercontent.com/qaxss/test/refs/heads/main/other.lua"))()')
                c()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/qaxss/test/refs/heads/main/main.lua"))()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/qaxss/test/refs/heads/main/other.lua"))()
            ]]
        )
    end)
    
    if not success then
        warn("Failed to queue teleport scripts: " .. tostring(err))
    end
    
    print(key)
    
    local joinSuccess, joinResult = pcall(function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        return replicatedStorage:WaitForChild("PrivateServers"):WaitForChild("JoinServer"):InvokeServer(key, false, false)
    end)
    
    if not joinSuccess then
        warn("Failed to join server: " .. tostring(joinResult))
        local c = clearqueueonteleport or clear_teleport_queue
        if c then
            local clearSuccess, clearErr = pcall(c)
            if not clearSuccess then
                warn("Failed to clear teleport queue: " .. tostring(clearErr))
            end
        end
        loadstring(game:HttpGet("https://raw.githubusercontent.com/qaxss/test/refs/heads/main/other.lua"))()
        return
    end
    
    local j = joinResult
    if j == "Success" or j == "Queue" then
        print(j)
    else
        local c = clearqueueonteleport or clear_teleport_queue
        local leaveSuccess, leaveResult = pcall(function()
            return game:GetService("ReplicatedStorage"):WaitForChild("PrivateServers"):WaitForChild("LeaveQueue"):InvokeServer()
        end)
        
        if not leaveSuccess then
            warn("Failed to leave queue: " .. tostring(leaveResult))
        else
            print(leaveResult)
        end
        
        if c then
            local clearSuccess, clearErr = pcall(c)
            if not clearSuccess then
                warn("Failed to clear teleport queue: " .. tostring(clearErr))
            end
        end
        
        print(j)
        
        local loadSuccess, loadErr = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/qaxss/test/refs/heads/main/other.lua"))()
        end)
        
        if not loadSuccess then
            warn("Failed to load other.lua: " .. tostring(loadErr))
        end
    end
    
    task.wait(60)
    
    local c = clearqueueonteleport or clear_teleport_queue
    if c then
        local clearSuccess, clearErr = pcall(c)
        if not clearSuccess then
            warn("Failed to clear teleport queue after wait: " .. tostring(clearErr))
        end
    end
    
    print(j)
    
    local loadSuccess, loadErr = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/qaxss/test/refs/heads/main/other.lua"))()
    end)
    
    if not loadSuccess then
        warn("Failed to load other.lua at end: " .. tostring(loadErr))
    end
end

local function checkServerList()
    local folderSuccess, folderErr = pcall(function()
        makefolder("asset taker")
    end)
    
    if not folderSuccess then
        warn("Failed to create asset taker folder: " .. tostring(folderErr))
    end
    
    local existingFiles = listfiles("asset taker")
    local out = {}
    local found = false
    
    for _, file in existingFiles do
        if string.find(file, "servers.json") then
            found = true
            break
        end
    end
    
    if not found then
        local serverSuccess, servers = pcall(function()
            return game:GetService("ReplicatedStorage").PrivateServers.GetServers:InvokeServer()
        end)
        
        if not serverSuccess then
            warn("Failed to get servers list: " .. tostring(servers))
            return
        end
        
        for _, server in pairs(servers) do
            if type(server) == "table" and server.LiveryPack and not server.Locked and server.TierRequirement == 0 and server.GroupJoin == 0 then
                out[server.CurrKey] = false
            end
        end
        
        local writeSuccess, writeErr = pcall(function()
            writefile("asset taker/servers.json", httpService:JSONEncode(out))
        end)
        
        if not writeSuccess then
            warn("Failed to write servers.json: " .. tostring(writeErr))
            return
        end
    end
    
    local key = getServerToJoin()
    if not key then
        warn("Failed to get server to join")
        return
    end
    
    joinServer(key)
end

local mainSuccess, mainErr = pcall(checkServerList)
if not mainSuccess then
    warn("Script failed: " .. tostring(mainErr))
end
