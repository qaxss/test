if not game:IsLoaded() then game.Loaded:Wait() end
print("[INIT] game.Loaded fired, script starting...")

local lp = game:GetService("Players").LocalPlayer
print("[INIT] LocalPlayer:", lp.Name, "| UserId:", lp.UserId)

local char = lp.Character or lp.CharacterAdded:Wait()
print("[INIT] Character found:", char.Name)

local httpService = game:GetService("HttpService")
print("[INIT] HttpService acquired")

local replicatedStorage = game:GetService("ReplicatedStorage")
print("[INIT] ReplicatedStorage acquired")

print("[INIT] Requiring Vehicles module...")
local vehicles = require(replicatedStorage.Modules.Vehicles)
print("[INIT] Vehicles module loaded:", tostring(vehicles))

print("[INIT] Requiring GetVehicleSpawnData remote...")
local getVehicleSpawnData = require(replicatedStorage.Remotes.Vehicles.GetVehicleSpawnData)
print("[INIT] GetVehicleSpawnData loaded:", tostring(getVehicleSpawnData))

print("[INIT] Requiring LiveryDenialReasons module...")
local liveryDenialReasons = require(replicatedStorage.Modules.LiveryDenialReasons)
print("[INIT] LiveryDenialReasons loaded:", tostring(liveryDenialReasons))

print("[INIT] Fetching zlib/LibDeflate from GitHub...")
local zlibC = game:HttpGet("https://gist.githubusercontent.com/adamMasMusic/14fd3b8ce7ae1c8ca8aa812d417efa2d/raw/7d0ec70796c2213487d7f94b7d44f49ac1fd2157/zlib.lua")
print("[INIT] zlib fetched, length:", #zlibC, "bytes")
local LibDeflate = loadstring(zlibC)()
print("[INIT] LibDeflate loaded:", tostring(LibDeflate))

local settings = {
    download = true,
    upload = false,
    robloxApiKey = nil,
    robloxId = nil,
    sendToWebhook = false,
    webhookURL = "https://discord.com/api/webhooks/1480245736347140289/i9rMxylUCKaKQVUGJcpvB0eCpgAfP018q7NCaM1QMTa-JCwOlB7Qr5SRxWVkt84zbqPS",
    cookie = ".ROBLOSECURITY=_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_CAEaAhADIhwKBGR1aWQSFDEzMzkyOTEzOTA3MzE3ODc2OTMzKAM.zpuqU6hWRaliTPVnPFmUxkDVDDWLofBB9y80BRbdbHpH1_Dq_fNp7JuVXdFBTnHO9PV6Exk-yFciePJExHz095UL0AEulgaD2vrJl9jeGn0ZfusSwFP-eL6UgsANpQ2-4Y55hoc-pR46pLpUIZ2cOQa7Ez46GOIDpTCvqRkUxOaWgZHrlLXbWYNHyp1Mt7vxUEUYH3rMmpE7sierjJd2vwQzaOStBBK9WTzvGtau9HPWLp3ISiHVdvyNkpYqvfTzuU0Nz4WBzzMuT0YzIrRiIfcOSHg84OVZ9T656Q0txodZbfjB6v7f60I4gE6cLlwr1baE43Usj1yvBvozMGcNRpSKMSrh2nlviqy2yoCDbj7fR2fkaEEWN0dLERD9vy7KBOLhOjhVM9n7gYXdeif70XqssCACWYvwSHFi_SM_UM4yS8XoYLcm2iu91BE4P1ENJE50Tf2W4VkSoPRm6n_LUK2DuGXkGLO3EBsTxSNyDSFrYhjPBhiW1Izu8g75LKYwuvuH9WRFwrp9ksCnAJdFBI_O7a7KV9gd31Mb7KJoFx-mWIrYR23TIjpCJrClb51BO32zrbH4DgQlOS3fdYEIzdeD4T6Dm4M2AtgG6_OHbzyCqaIfyVqPqq7lejBWuUwpDW2Byr_4Wn2yWEzKyLvv0jdmUW1CppbdumqhdBx5r4Anom_RzzMGpVgdYj5PXWMsSuqRwfzmYncq-0n1xw4KHtsGjQniw-BBEWuISMXlax5bCWJYNuwNCzSVRfJXRBEgeL5QI-14gd-RPOkRUFuENo8cTIcJ0mcKNI04t4Po7PFWmJmDJJXCiWRsxDvEmZ83MwZqu6-OcldMqR8TvhVv7D_QAcGy7wLUMLzwSFhTjILAG8lErIFn2pXR67UvWvQFjglq5BZm9ff-YBpoxiCfZezWyYGxE35PYdMnTHU5Id4Xwc97BoLfUuGYVR_qHO-EL2A3dA",
    cookieValid = false,
    baseDownloadLocation = "asset taker/"
}
print("[INIT] Settings table created")
print("[INIT] Settings -> download:", settings.download)
print("[INIT] Settings -> upload:", settings.upload)
print("[INIT] Settings -> sendToWebhook:", settings.sendToWebhook)
print("[INIT] Settings -> webhookURL:", settings.webhookURL)
print("[INIT] Settings -> baseDownloadLocation:", settings.baseDownloadLocation)
print("[INIT] Settings -> cookie length:", #settings.cookie)

local categoryMap = {
    ["JobTrailers"] = "Job",
    ["Police"] = "Law",
    ["SheriffTrailers"] = "Law",
    ["DOT"] = "DOT",
    ["DOTTrailers"] = "DOT",
    ["FireTrailers"] = "Fire",
    ["Sheriff"] = "Law",
    ["Fire"] = "Fire",
    ["PoliceTrailers"] = "Law",
    ["Job"] = "Job"
}
print("[INIT] categoryMap built with", (function() local c=0 for _ in pairs(categoryMap) do c=c+1 end return c end)(), "entries")

local serverName, joinCode = nil, nil
print("[INIT] Fetching private server info...")
local response, _ = pcall(function()
    serverName = replicatedStorage.PrivateServers.Info.ServerName.Value
    joinCode = replicatedStorage.PrivateServers.Info.Code.Value
end)

if not response then
    warn("[INIT] FATAL: Not in a private server — PrivateServers.Info read failed. Aborting.")
    return
end
print("[INIT] Private server info OK — ServerName:", serverName, "| JoinCode:", joinCode)

-- sanitizes a single path segment only, never a full path
local function sanitize(s)
    print("[sanitize] Input:", tostring(s))
    s = tostring(s):match("^%s*(.-)%s*$")
    s = s:gsub('[<>:"/\\|?*]', "_")
    print("[sanitize] Output:", s)
    return s
end

local safeServerName = sanitize(serverName)
print("[INIT] safeServerName:", safeServerName)

-- First cookie test (status code based)
local function testCookie(cookie)
    print("[testCookie] Testing cookie validity via assetdelivery (status check)...")
    local response = request({
        Url = "https://assetdelivery.roblox.com/v1/asset/?id=" .. "116800358210190",
        Method = "GET",
        Headers = {
            ["Cookie"] = cookie
        }
    })
    print("[testCookie] Response StatusCode:", response.StatusCode)
    if tostring(response.StatusCode) ~= "200" then
        print("[testCookie] Cookie INVALID (status != 200)")
        return false
    else
        print("[testCookie] Cookie VALID (status 200)")
        return true
    end
end

print("[INIT] Running initial cookie validation...")
if testCookie(settings.cookie) then
    settings.cookieValid = true
    print("[INIT] Cookie validated successfully, cookieValid = true")
else
    warn("[INIT] FATAL: Cookie is invalid. Aborting script.")
    return
end

--[[
    misc functions
]]

local function extractId(template)
    print("[extractId] Input template:", tostring(template))
    local id = template:match("%d+") or template
    print("[extractId] Extracted id:", id)
    return id
end

local function getColor(color)
    print("[getColor] Input color string:", tostring(color))
    color = color:split(", ")
    print("[getColor] Split parts:", color[1], color[2], color[3])
    local newColor = Color3.new(color[1], color[2], color[3])
    local hex = newColor:ToHex()
    print("[getColor] Result hex:", hex)
    return hex
end

-- Second testCookie (body-based check, used internally)
local function testCookieBody(cookie)
    print("[testCookieBody] Testing cookie via body content check...")
    local response = request({
        Url = "https://assetdelivery.roblox.com/v1/asset/?id=116800358210190",
        Method = "GET",
        Headers = {
            ["Cookie"] = cookie
        }
    })
    print("[testCookieBody] StatusCode:", response.StatusCode, "| Body length:", #response.Body)
    if
        response.Body
        == [[{"errors":[{"code":0,"message":"Authentication required to access Asset."}]}]]
    then
        print("[testCookieBody] Cookie INVALID (auth required body match)")
        return false
    else
        print("[testCookieBody] Cookie appears VALID (no auth-required body)")
        return true
    end
end

local function decompressGzip(data)
    print("[decompressGzip] Input data length:", #data, "bytes")
    local byte1, byte2, byte3, byte4 = data:byte(1, 4)
    print(string.format("[decompressGzip] First 4 bytes: 0x%02X 0x%02X 0x%02X 0x%02X", byte1, byte2, byte3, byte4))

    if
        byte1 == 0x89
        and byte2 == 0x50
        and byte3 == 0x4E
        and byte4 == 0x47
    then
        print("[decompressGzip] Detected PNG magic bytes — returning data as-is (not gzip)")
        return data
    end

    if data:byte(1) ~= 0x1F or data:byte(2) ~= 0x8B then
        warn("[decompressGzip] Not GZIP format (magic bytes mismatch). byte1=0x"..string.format("%02X", data:byte(1)).." byte2=0x"..string.format("%02X", data:byte(2)))
        return nil, "Not GZIP format"
    end
    print("[decompressGzip] GZIP magic bytes confirmed (0x1F 0x8B)")

    local flags = data:byte(4)
    print("[decompressGzip] GZIP flags byte:", flags)
    local pos = 11
    print("[decompressGzip] Starting parse at pos:", pos)

    if bit32.band(flags, 0x04) ~= 0 then
        local xlen = data:byte(pos) + data:byte(pos + 1) * 256
        print("[decompressGzip] FEXTRA flag set, xlen:", xlen)
        pos = pos + 2 + xlen
        print("[decompressGzip] pos after FEXTRA:", pos)
    end

    if bit32.band(flags, 0x08) ~= 0 then
        print("[decompressGzip] FNAME flag set, skipping filename string...")
        local startPos = pos
        while data:byte(pos) ~= 0 do
            pos = pos + 1
        end
        pos = pos + 1
        print("[decompressGzip] Skipped", pos - startPos, "bytes for FNAME, pos:", pos)
    end

    if bit32.band(flags, 0x10) ~= 0 then
        print("[decompressGzip] FCOMMENT flag set, skipping comment string...")
        local startPos = pos
        while data:byte(pos) ~= 0 do
            pos = pos + 1
        end
        pos = pos + 1
        print("[decompressGzip] Skipped", pos - startPos, "bytes for FCOMMENT, pos:", pos)
    end

    if bit32.band(flags, 0x02) ~= 0 then
        print("[decompressGzip] FHCRC flag set, skipping 2-byte CRC...")
        pos = pos + 2
        print("[decompressGzip] pos after FHCRC:", pos)
    end

    local deflateData = data:sub(pos, #data - 8)
    print("[decompressGzip] deflateData slice: pos", pos, "to", #data - 8, "| length:", #deflateData)

    print("[decompressGzip] Attempting LibDeflate.Deflate.Decompress...")
    local success, result = pcall(function()
        return LibDeflate.Deflate.Decompress(deflateData)
    end)

    if success and result then
        print("[decompressGzip] Decompression SUCCESS — output length:", #result, "bytes")
        return result
    else
        warn("[decompressGzip] Decompression FAILED:", tostring(result))
        return nil, "Decompression failed: " .. tostring(result)
    end
end

-- folder and imageName must already be sanitized before calling this
local function getImage(imageId, folder, imageName)
    print("[getImage] Fetching imageId:", imageId, "| folder:", folder, "| imageName:", imageName)
    local response
    if settings.cookieValid then
        print("[getImage] Cookie valid, making authenticated request...")
        response = request({
            Url = "https://assetdelivery.roblox.com/v1/asset/?id=" .. imageId,
            Method = "GET",
            Headers = {
                ["Cookie"] = settings.cookie
            }
        })
        print("[getImage] Response received — StatusCode:", response.StatusCode, "| Body length:", #response.Body)
    else
        warn("[getImage] Cookie not valid! Cannot fetch image.")
        return false, "No valid cookie"
    end

    local data = response.Body
    local contentEncoding =
        response.Headers["Content-Encoding"]
        or response.Headers["content-encoding"]
    print("[getImage] Content-Encoding header:", tostring(contentEncoding))

    if contentEncoding == "gzip" then
        print("[getImage] Gzip encoding detected, decompressing...")
        local decompressed, err = decompressGzip(data)
        if decompressed then
            print("[getImage] Gzip decompression successful, decompressed length:", #decompressed)
            data = decompressed
        else
            warn("[getImage] Gzip decompression failed:", err)
            return false, response, err
        end
    else
        print("[getImage] No gzip encoding, using raw body data")
    end

    local byte1, byte2, byte3, byte4 = data:byte(1, 4)
    print(string.format("[getImage] Data magic bytes: 0x%02X 0x%02X 0x%02X 0x%02X", byte1 or 0, byte2 or 0, byte3 or 0, byte4 or 0))

    if
        byte1 == 0x89
        and byte2 == 0x50
        and byte3 == 0x4E
        and byte4 == 0x47
    then
        local filePath = folder .. "/" .. imageName .. ".png"
        print("[getImage] PNG magic bytes confirmed! Writing to:", filePath, "| Size:", #data, "bytes")
        writefile(filePath, data)
        print("[getImage] Write SUCCESS:", filePath)
        return true, data
    else
        local filePath = folder .. "/" .. imageName .. ".txt"
        warn("[getImage] Not a valid PNG! Writing debug text to:", filePath)
        writefile(filePath, response.StatusCode .. "\n" .. response.Body)
        print("[getImage] Debug text written to:", filePath)
        return false, response
    end
end

local debounce = false
local function sendToDiscord(embed, images, webhook)
    print("[sendToDiscord] Called — embed title:", tostring(embed and embed.title), "| images count:", #images, "| webhook:", webhook)
    print("[sendToDiscord] Waiting for debounce to clear...")
    repeat task.wait() until not debounce
    debounce = true
    print("[sendToDiscord] Debounce acquired, sending embed...")

    local success, response = pcall(function()
        return request({
            Url = webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = httpService:JSONEncode({
                embeds = { embed }
            })
        })
    end)
    print("[sendToDiscord] Embed send pcall success:", success, "| StatusCode:", response and response.StatusCode or "N/A")

    if response and response.StatusCode == 429 then
        warn("[sendToDiscord] Rate limited (429)! Waiting 5 seconds before retry...")
        task.wait(5)
        local success2, response2 = pcall(function()
            return request({
                Url = webhook,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = httpService:JSONEncode({
                    embeds = { embed }
                })
            })
        end)
        print("[sendToDiscord] Embed retry pcall success:", success2, "| StatusCode:", response2 and response2.StatusCode or "N/A")
    end

    task.wait()

    if #images > 0 then
        print("[sendToDiscord] Sending", #images, "image(s) in batches of 10...")
        for i = 1, #images, 10 do
            local boundary =
                "----WebKitFormBoundary" .. httpService:GenerateGUID(false)
            local body = ""
            local endIndex = math.min(i + 9, #images)
            print("[sendToDiscord] Building multipart batch:", i, "to", endIndex)

            for j = i, endIndex do
                local imageData = images[j].data
                local fileName = images[j].name
                print("[sendToDiscord]   Attaching image", j, ":", fileName, "| data length:", #imageData)

                body = body .. "--" .. boundary .. "\r\n"
                body = body
                    .. 'Content-Disposition: form-data; name="file'
                    .. (j - i + 1)
                    .. '"; filename="'
                    .. fileName
                    .. '"\r\n'
                body = body .. "Content-Type: image/png\r\n\r\n"
                body = body .. imageData .. "\r\n"
            end

            body = body .. "--" .. boundary .. "--\r\n"
            print("[sendToDiscord] Multipart body built, total length:", #body, "bytes")

            local imageSuccess, imageResponse = pcall(function()
                return request({
                    Url = webhook,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "multipart/form-data; boundary="
                            .. boundary
                    },
                    Body = body
                })
            end)
            print("[sendToDiscord] Image batch send pcall success:", imageSuccess, "| StatusCode:", imageResponse and imageResponse.StatusCode or "N/A")

            if imageResponse and imageResponse.StatusCode == 429 then
                warn("[sendToDiscord] Image batch rate limited (429)! Waiting 5 seconds before retry...")
                task.wait(5)
                local imageSuccess2, imageResponse2 = pcall(function()
                    return request({
                        Url = webhook,
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "multipart/form-data; boundary="
                                .. boundary
                        },
                        Body = body
                    })
                end)
                print("[sendToDiscord] Image batch retry pcall success:", imageSuccess2, "| StatusCode:", imageResponse2 and imageResponse2.StatusCode or "N/A")
            end

            if endIndex < #images then
                print("[sendToDiscord] More batches remain, waiting 0.2s...")
                task.wait(0.2)
            end
        end
        print("[sendToDiscord] All image batches sent")
    else
        print("[sendToDiscord] No images to send")
    end

    debounce = false
    print("[sendToDiscord] Debounce released")
end

--[[
    taker functions
]]

local function getServerData()
    print("[getServerData] Invoking GetSettings on server...")
    local serverSettings =
        replicatedStorage:WaitForChild("PrivateServers"):WaitForChild("GetSettings"):InvokeServer()
    print("[getServerData] Response received")
    print("[getServerData] Name:", tostring(serverSettings.Data.Name))
    print("[getServerData] CurrKey:", tostring(serverSettings.Data.CurrKey))
    print("[getServerData] IconId:", tostring(serverSettings.Data.IconId))
    print("[getServerData] Rules length:", #tostring(serverSettings.Data.Rules))
    print("[getServerData] Description length:", #tostring(serverSettings.Data.Description))
    local teamCount = 0
    for _ in pairs(serverSettings.Data.CustomTeams) do teamCount = teamCount + 1 end
    print("[getServerData] CustomTeams count:", teamCount)

    return {
        name = serverSettings.Data.Name,
        code = serverSettings.Data.CurrKey,
        icon = serverSettings.Data.IconId,
        rules = serverSettings.Data.Rules,
        description = serverSettings.Data.Description,
        teams = serverSettings.Data.CustomTeams,
        original = serverSettings
    }
end

local function makeLiveryTable(car, liveryData, carId)
    print("[makeLiveryTable] Building livery table for car:", car.Name, "| carId:", carId, "| livery count:", #liveryData)
    local liveryTable = {
        ["car"] = car.Name,
        ["carId"] = carId,
        ["liveryCount"] = #liveryData,
        ["liveries"] = {}
    }
    for i, livery in liveryData do
        print("[makeLiveryTable] Processing livery", i, ":", tostring(livery.liveryName))
        local textureCount = 0
        for _ in pairs(livery.textureIds) do textureCount = textureCount + 1 end
        print("[makeLiveryTable]   textureIds count:", textureCount)

        local approvalResult
        if livery.isApproved == true then
            approvalResult = "Approved"
            print("[makeLiveryTable]   Approval: Approved")
        else
            approvalResult = liveryDenialReasons[livery.isApproved]
            print("[makeLiveryTable]   Approval: DENIED — reason key:", tostring(livery.isApproved), "-> reason:", tostring(approvalResult))
        end

        local outLivery = {
            name = sanitize(tostring(livery.liveryName)),
            vehicleColor = tostring(getColor(livery.vehicleColor)),
            liveryColor = tostring(getColor(livery.liveryColor)),
            liveryTransparency = tostring(livery.liveryTransparency),
            ELS = {
                park = livery.ParkPatterns,
                stg1 = livery.Stage1Patterns,
                stg2 = livery.Stage2Patterns,
                stg3 = livery.Stage3Patterns,
                color = livery.ELSColor
            },
            approved = approvalResult,
            textures = {}
        }
        for side, id in livery.textureIds do
            print("[makeLiveryTable]   Texture side:", side, "-> id:", tostring(id))
            outLivery.textures[side] = tostring(id)
        end
        table.insert(liveryTable.liveries, outLivery)
        print("[makeLiveryTable]   Livery", i, "processed:", outLivery.name)
    end
    print("[makeLiveryTable] Livery table built for:", car.Name, "| Total liveries processed:", #liveryTable.liveries)
    return liveryTable
end

local function makeLiveryEmbed(car, uniqueLivery, category)
    print("[makeLiveryEmbed] Building embed — car:", tostring(car.Name or car), "| livery:", uniqueLivery.name, "| category:", category)
    local embed = {
        title = car.Name,
        description = "",
        fields = {
            { name = "Team", value = categoryMap[category], inline = true },
            {
                name = "Name",
                value = "`" .. uniqueLivery.name .. "`",
                inline = true
            },
            {
                name = "Vehicle Color",
                value = "`" .. uniqueLivery.vehicleColor .. "`",
                inline = true
            },
            {
                name = "Livery Color",
                value = "`" .. uniqueLivery.liveryColor .. "`",
                inline = true
            },
            {
                name = "Livery Transparency",
                value = "`" .. uniqueLivery.liveryTransparency .. "`",
                inline = true
            },
            {
                name = "Approval Status",
                value = uniqueLivery.approved,
                inline = true
            },
            { name = "Server", value = serverName, inline = true },
            { name = "Join code", value = joinCode, inline = true }
        }
    }
    local textureFieldCount = 0
    for side, id in uniqueLivery.textures do
        embed.description = embed.description
            .. side
            .. ": `"
            .. id
            .. "`\n"
        textureFieldCount = textureFieldCount + 1
        print("[makeLiveryEmbed]   Added texture field:", side, "->", id)
    end
    print("[makeLiveryEmbed] Embed built with", textureFieldCount, "texture entries in description")
    return embed
end

local function getLiveryImages(textureIds, downloadLocation)
    local textureAmount = 0
    local passCount = 0
    for _, _ in textureIds do
        textureAmount += 1
    end
    print("[getLiveryImages] Total textures to fetch:", textureAmount, "| downloadLocation:", downloadLocation)

    local images = {}
    for side, id in textureIds do
        print("[getLiveryImages] Spawning task for side:", side, "id:", id)
        task.spawn(function()
            print("[getLiveryImages] [task] Fetching image side:", side, "id:", id)
            local ok, response = getImage(id, downloadLocation, side)
            if ok then
                print("[getLiveryImages] [task] SUCCESS for side:", side, "| data length:", #response)
                table.insert(images, {
                    name = side .. ".png",
                    data = response
                })
            else
                warn("[getLiveryImages] [task] FAILED for side:", side, "| StatusCode:", response and response.StatusCode or "N/A", "| Body:", response and response.Body or "N/A")
            end
            passCount += 1
            print("[getLiveryImages] [task] passCount now:", passCount, "/", textureAmount)
        end)
        task.wait()
    end

    print("[getLiveryImages] Waiting for all", textureAmount, "texture tasks to complete...")
    repeat task.wait() until passCount == textureAmount
    print("[getLiveryImages] All texture tasks completed. images collected:", #images)
    return images
end

local function formatLiveryData(car, liveryData, category)
    print("[formatLiveryData] Formatting — carId:", tostring(car), "| category:", category, "| liveryData count:", #liveryData)
    local livery = ""
    local carId = tonumber(car)
    print("[formatLiveryData] carId as number:", carId)

    local mappedCategory = categoryMap[category]
    print("[formatLiveryData] Mapped category:", mappedCategory)

    local car = vehicles.GetCarById(mappedCategory, tonumber(car))
    print("[formatLiveryData] Vehicle resolved:", tostring(car and car.Name or "NIL"))

    local liveryTable = makeLiveryTable(car, liveryData, carId)
    print("[formatLiveryData] liveryTable built — car:", liveryTable.car, "| liveryCount:", liveryTable.liveryCount)

    livery = livery
        .. string.format("%-22s %s\n", "Car:", tostring(liveryTable.car or "Unknown"))
        .. string.format(
            "%-22s %s\n",
            " Livery Count:",
            tostring(liveryTable.liveryCount or "0")
        )

    for key, uniqueLivery in liveryTable.liveries do
        print("[formatLiveryData] Processing livery key:", key, "name:", tostring(uniqueLivery.name or "Unknown"))
        local unique = ""
            .. string.format("%-22s %s\n", "  Name:", tostring(uniqueLivery.name or "Unknown"))
            .. string.format(
                "%-22s %s\n",
                "  Vehicle Color:",
                tostring(uniqueLivery.vehicleColor or "Unknown")
            )
            .. string.format(
                "%-22s %s\n",
                "  Livery Color:",
                tostring(uniqueLivery.liveryColor or "Unknown")
            )
            .. string.format(
                "%-22s %s\n",
                "  Livery Transparency:",
                tostring(uniqueLivery.liveryTransparency or "Unknown")
            )
            .. string.format(
                "%-22s %s\n",
                "  Approval Status:",
                tostring(uniqueLivery.approved or "Unknown")
            )
        livery = livery .. unique
        livery = livery .. "  Texture Ids:\n"
        for side, id in uniqueLivery.textures do
            livery = livery
                .. string.format("    %-12s %s\n", tostring(side) .. ":", tostring(id or "Unknown"))
            print("[formatLiveryData]   Texture appended:", side, "->", id)
        end

        if settings.download then
            print("[formatLiveryData] download=true, computing download path...")
            local downloadLocation
            local safeCar = sanitize(liveryTable.car)
            local safeCategory = sanitize(category)
            local safeLiveryName = sanitize(uniqueLivery.name)
            print("[formatLiveryData]   safeCar:", safeCar, "| safeCategory:", safeCategory, "| safeLiveryName:", safeLiveryName)

            if liveryTable.liveryCount == 1 then
                downloadLocation = settings.baseDownloadLocation
                    .. safeServerName
                    .. "/"
                    .. safeCategory
                    .. "/liveries/"
                    .. safeCar
                print("[formatLiveryData]   Single-livery path:", downloadLocation)
            else
                downloadLocation = settings.baseDownloadLocation
                    .. safeServerName
                    .. "/"
                    .. safeCategory
                    .. "/liveries/"
                    .. safeCar
                    .. "/"
                    .. safeLiveryName
                print("[formatLiveryData]   Multi-livery path:", downloadLocation)
            end

            print("[formatLiveryData]   makefolder:", downloadLocation)
            makefolder(downloadLocation)

            local txtPath = downloadLocation .. "/" .. safeLiveryName .. ".txt"
            print("[formatLiveryData]   Writing livery text to:", txtPath)
            writefile(txtPath, unique)
            print("[formatLiveryData]   Text written successfully")

            print("[formatLiveryData]   Fetching livery images...")
            local images = getLiveryImages(uniqueLivery.textures, downloadLocation)
            print("[formatLiveryData]   Images fetched:", #images)

            print("[formatLiveryData]   Building embed...")
            local embed = makeLiveryEmbed(car, uniqueLivery, category)
            print("[formatLiveryData]   Embed built")

            if
                settings.sendToWebhook
                and string.find(
                    settings.webhookURL,
                    "discord.com/api/webhooks/"
                )
            then
                print("[formatLiveryData]   Sending to Discord webhook...")
                sendToDiscord(embed, images, settings.webhookURL)
                print("[formatLiveryData]   Discord send complete")
            else
                print("[formatLiveryData]   Webhook send skipped (sendToWebhook=false or invalid URL)")
            end
        else
            print("[formatLiveryData] download=false, skipping file operations")
        end

        if key > 0 and key ~= liveryTable.liveryCount then
            livery = livery .. "  " .. string.rep("-", 15) .. "\n"
        end
    end
    print("[formatLiveryData] Formatting complete for:", liveryTable.car)
    return livery .. "\n", liveryTable
end

local function outputLiveries(liveryTable)
    print("[outputLiveries] Called with liveryTable teams:")
    for team, val in pairs(liveryTable) do
        if type(val) == "table" then
            local c = 0
            for _ in pairs(val) do c = c + 1 end
            print("[outputLiveries]   Team:", team, "| entries:", c)
        end
    end

    local liveryTables = {}
    local liveries = [[
  _     _                _           
 | |   (_)_   _____ _ __(_) ___  ___ 
 | |   | \ \ / / _ \ '__| |/ _ \/ __|
 | |___| |\ V /  __/ |  | |  __/\__ \
 |_____|_| \_/ \___|_|  |_|\___||___/

]]
    local liveryCopy = table.clone(liveryTable)
    print("[outputLiveries] Processing", (function() local c=0 for _ in pairs(liveryCopy) do c=c+1 end return c end)(), "teams...")

    for team, val in liveryCopy do
        local count = 0
        if type(val) == "table" then
            for _, _ in val do
                count += 1
            end
        end
        print("[outputLiveries] Team:", team, "| car count:", count)

        if count > 0 then
            if settings.download then
                local teamFolder = settings.baseDownloadLocation .. safeServerName .. "/" .. sanitize(team)
                print("[outputLiveries] Creating team folder:", teamFolder)
                makefolder(teamFolder)
            end
            liveries = liveries
                .. string.rep("=", 30)
                .. "\n"
                .. tostring(team)
                .. "\n"
                .. string.rep("=", 30)
                .. "\n"
            liveryTables[team] = {}
            if type(val) == "table" then
                for car, carData in val do
                    print("[outputLiveries]   Car:", tostring(car), "| carData count:", #carData)
                    if #carData > 0 then
                        print("[outputLiveries]   Calling formatLiveryData for car:", tostring(car))
                        local liveryString, liveryTable =
                            formatLiveryData(car, carData, team)
                        liveries = liveries .. liveryString
                        table.insert(liveryTables[team], liveryTable)
                        print("[outputLiveries]   formatLiveryData complete for car:", tostring(car))
                    else
                        print("[outputLiveries]   Skipping car", tostring(car), "(empty carData)")
                    end
                end
            end
        else
            print("[outputLiveries] Skipping team", team, "(no cars)")
        end
    end

    print("[outputLiveries] All teams processed. Invoking Quit jobs...")
    replicatedStorage:WaitForChild("FE"):WaitForChild("StartJob"):InvokeServer("Quit")
    print("[outputLiveries] First Quit invoked")
    task.wait()
    replicatedStorage:WaitForChild("FE"):WaitForChild("StartJob"):InvokeServer("Quit")
    print("[outputLiveries] Second Quit invoked")

    print("[outputLiveries] Returning livery string (length:", #liveries, ") and liveryTables")
    return liveries, liveryTables
end

local function getClosestCivilianSpawner()
    print("[getClosestCivilianSpawner] Searching for closest civilian spawner...")
    local closest, dist = nil, math.huge
    local playerLoc = game.Players.LocalPlayer.Character.WorldPivot.Position
    print("[getClosestCivilianSpawner] Player position:", tostring(playerLoc))

    local spawnerParents = workspace:WaitForChild("VehicleSpawners"):GetChildren()
    print("[getClosestCivilianSpawner] VehicleSpawners children count:", #spawnerParents)

    for _, item in spawnerParents do
        if
            item.Name == "Civilian_Spawners"
            and #item:GetChildren() > 0
        then
            print("[getClosestCivilianSpawner] Found Civilian_Spawners group:", item.Name, "| children:", #item:GetChildren())
            for _, spawner in item:GetChildren() do
                if #spawner:GetChildren() > 0 then
                    local a = playerLoc - spawner.WorldPivot.Position
                    print("[getClosestCivilianSpawner]   Spawner:", spawner.Name, "| distance:", a.Magnitude)
                    if a.Magnitude < dist then
                        closest = spawner
                        dist = a.Magnitude
                        print("[getClosestCivilianSpawner]   New closest:", spawner.Name, "at dist:", dist)
                    end
                end
            end
        end
    end

    if closest then
        print("[getClosestCivilianSpawner] Result: closest spawner:", closest.Name, "| dist:", dist)
    else
        warn("[getClosestCivilianSpawner] No valid civilian spawner found!")
    end
    return closest
end

local function getCar()
    print("[getCar] Finding closest civilian spawner...")
    local closest = getClosestCivilianSpawner()
    if not closest then
        warn("[getCar] No closest spawner found!")
        return false
    end
    print("[getCar] Closest spawner:", closest.Name)

    print("[getCar] Waiting for SpawnClicker and InteractionAttachment...")
    local interaction =
        closest:WaitForChild("SpawnClicker", 2):WaitForChild(
            "InteractionAttachment",
            2
        )

    if not interaction then
        warn("[getCar] InteractionAttachment not found within timeout! Returning false.")
        return false
    end
    print("[getCar] InteractionAttachment found:", interaction:GetFullName())

    local spawnCar = { "Chevlon Captain 1992", nil, false, interaction }
    local buyCar = {
        "Chevlon Captain 1992",
        Color3.new(
            0.05098039656877518,
            0.4117647409439087,
            0.6745098233222961
        )
    }
    print("[getCar] spawnCar args:", spawnCar[1], "| nil:", tostring(spawnCar[2]), "| false:", tostring(spawnCar[3]), "| interaction:", interaction:GetFullName())
    print("[getCar] buyCar args:", buyCar[1], "| Color:", tostring(buyCar[2]))

    print("[getCar] Teleporting character to spawner position:", tostring(closest.WorldPivot.Position))
    char.HumanoidRootPart.Position = closest.WorldPivot.Position
    task.wait(0.2)

    print("[getCar] Invoking BuyCar remote...")
    replicatedStorage:WaitForChild("FE"):WaitForChild("BuyCar"):InvokeServer(
        unpack(buyCar)
    )
    print("[getCar] BuyCar invoked")
    task.wait(0.2)

    print("[getCar] Firing SpawnCar remote...")
    replicatedStorage:WaitForChild("FE"):WaitForChild("SpawnCar"):FireServer(
        unpack(spawnCar)
    )
    print("[getCar] SpawnCar fired")

    return true
end

local starter = nil
local function isPlayerInOwnCar()
    local seat = char.Humanoid.SeatPart
    if not seat then
        print("[isPlayerInOwnCar] No seat part found")
        local elapsed = os.time() - starter
        print("[isPlayerInOwnCar] Time since starter:", elapsed, "seconds")
        if elapsed > 10 then
            print("[isPlayerInOwnCar] Timeout exceeded, calling getCar() again...")
            getCar()
            starter = os.time()
            print("[isPlayerInOwnCar] starter reset to:", starter)
        end
        return false
    else
        local owner = seat.Parent:GetAttribute("Owner")
        print("[isPlayerInOwnCar] In seat:", seat.Name, "| Parent:", seat.Parent.Name, "| Owner attribute:", tostring(owner), "| LocalPlayer:", lp.Name)
        if owner == lp.Name then
            print("[isPlayerInOwnCar] Player IS in their own car!")
            return true
        end
    end
    print("[isPlayerInOwnCar] Player is in a car but it is NOT theirs")
    return false
end

local function findPlayerCar()
    print("[findPlayerCar] Searching workspace.Vehicles for car owned by:", lp.Name)
    local vehicleCount = 0
    for _, car in workspace.Vehicles:GetChildren() do
        vehicleCount = vehicleCount + 1
        if car:GetAttribute("Owner") == lp.Name then
            print("[findPlayerCar] Found player car:", car.Name, "| ClassName:", car.ClassName)
            return car
        end
    end
    warn("[findPlayerCar] No car found for player in workspace.Vehicles (checked", vehicleCount, "vehicles)")
    return nil
end

local function gotoLocation()
    print("[gotoLocation] Checking if already at location...")
    local atLocation = false

    local target = workspace:WaitForChild("JobStarters"):WaitForChild("News Station Worker").Main.Position
    local p = char.HumanoidRootPart.Position - target
    print("[gotoLocation] Distance to target:", p.Magnitude, "| target:", tostring(target))

    if p.Magnitude < 30 then
        atLocation = true
        print("[gotoLocation] Already at location!")
    end

    if atLocation then return end

    print("[gotoLocation] Not at location, beginning movement loop...")
    repeat
        local car = findPlayerCar()
        if car then
            print("[gotoLocation] Moving car to News Station Worker position...")
            car:MoveTo(
                workspace:WaitForChild("JobStarters"):WaitForChild("News Station Worker").Main.Position
            )
        else
            warn("[gotoLocation] No car found to move!")
        end

        local p = char.HumanoidRootPart.Position - workspace:WaitForChild("JobStarters"):WaitForChild("News Station Worker").Main.Position
        print("[gotoLocation] Current distance:", p.Magnitude)
        if p.Magnitude > 30 then
            print(p.Magnitude)
            print("[gotoLocation] Still too far, calling getCar()...")
            if not getCar() then
                warn("[gotoLocation] Failed to get car! Make sure to spawn a car.")
            end
        else
            print("[gotoLocation] Reached location! Distance:", p.Magnitude)
            atLocation = true
        end
    until atLocation == true
    print("[gotoLocation] At location confirmed")
end

local function getJob()
    print("[getJob] Starting job acquisition sequence...")

    local newsJoin = {
        "Start",
        workspace:WaitForChild("JobStarters"):WaitForChild("News Station Worker")
    }
    print("[getJob] newsJoin args:", newsJoin[1], "| target:", newsJoin[2]:GetFullName())

    print("[getJob] Checking wanted level...")
    local wantedLevel = game:GetService("ReplicatedStorage"):WaitForChild("FE"):WaitForChild("GetWantedLevel"):InvokeServer(game.Players.LocalPlayer)
    print("[getJob] Wanted level:", tostring(wantedLevel))
    if wantedLevel ~= 0 then
        warn("[getJob] ABORT: Player is wanted (level:", tostring(wantedLevel), "). Must be 0 to take liveries.")
        return
    end
    print("[getJob] Wanted level OK (0)")

    print("[getJob] Checking player team:", tostring(game:GetService("Players").LocalPlayer.Team))
    if game:GetService("Players").LocalPlayer.Team ~= game.Teams.Civilian then
        warn("[getJob] ABORT: Player is not on Civilian team! Current team:", tostring(game:GetService("Players").LocalPlayer.Team))
        return
    end
    print("[getJob] Team OK (Civilian)")

    print("[getJob] Calling getCar()...")
    if not getCar() then
        warn("[getJob] getCar() returned false! Make sure to spawn a car.")
    else
        print("[getJob] getCar() succeeded")
    end

    task.wait(0.2)

    print("[getJob] Waiting for player to be in their own car...")
    starter = os.time()
    print("[getJob] starter set to:", starter)
    repeat
        task.wait()
    until isPlayerInOwnCar()
    print("[getJob] Player confirmed in own car!")

    local car = findPlayerCar()
    if car then
        print("[getJob] Moving car to News Station Worker spawn point...")
        car:MoveTo(
            workspace:WaitForChild("JobStarters"):WaitForChild(
                "News Station Worker"
            ).Main.Position
        )
        print("[getJob] Car moved")
    else
        warn("[getJob] Could not find player car to move!")
    end

    task.wait(1)

    print("[getJob] Invoking StartJob remote with 'Start'...")
    local joinTeam =
        game:GetService("ReplicatedStorage"):WaitForChild("FE"):WaitForChild("StartJob"):InvokeServer(
            unpack(newsJoin)
        )
    print("[getJob] StartJob response:", tostring(joinTeam))

    if joinTeam ~= "Success" then
        warn("[getJob] StartJob did not return 'Success'! Got:", tostring(joinTeam))
    else
        print("[getJob] Job started successfully!")
    end
end

local function getLiveries()
    print("[getLiveries] Starting livery retrieval process...")
    print("[getLiveries] Calling getJob()...")
    getJob()
    print("[getLiveries] getJob() complete")

    print("[getLiveries] Waiting for VehicleSpawners > NewsStationWorker_Spawners > Stand > SpawnClicker > InteractionAttachment...")
    local interactionAttachment = workspace
        :WaitForChild("VehicleSpawners")
        :WaitForChild("NewsStationWorker_Spawners")
        :WaitForChild("Stand")
        :WaitForChild("SpawnClicker")
        :WaitForChild("InteractionAttachment")
    print("[getLiveries] InteractionAttachment found:", interactionAttachment:GetFullName())

    print("[getLiveries] Calling getVehicleSpawnData:Call('News Station Worker', attachment)...")
    local success, data =
        getVehicleSpawnData:Call(
            "News Station Worker",
            interactionAttachment
        ):Await()

    print("[getLiveries] getVehicleSpawnData response — success:", success)
    if success then
        if data and data.liveries then
            local teamCount = 0
            for _ in pairs(data.liveries) do teamCount = teamCount + 1 end
            print("[getLiveries] Livery data received! Teams in data:", teamCount)
        else
            warn("[getLiveries] success=true but data or data.liveries is nil! data:", tostring(data))
        end
        print("[getLiveries] Calling outputLiveries()...")
        return outputLiveries(data.liveries)
    else
        warn("[getLiveries] FAILED to get livery data! success=false. data:", tostring(data))
        return
    end
end

local function outputServerInfo()
    print("[outputServerInfo] Starting server info output...")
    local data = getServerData()
    print("[outputServerInfo] Server data received")

    local server = [[
  ____                             _        __       
 / ___|  ___ _ ____   _____ _ __  (_)_ __  / _| ___  
 \___ \ / _ \ '__\ \ / / _ \ '__| | | '_ \| |_ / _ \ 
  ___) |  __/ |   \ V /  __/ |    | | | | |  _| (_) |
 |____/ \___|_|    \_/ \___|_|    |_|_| |_|_|  \___/ 

]]

    server = server
        .. string.format("%-10s %s\n", "Name:", tostring(data.name or "Unknown"))
        .. string.format("%-10s %s\n", "Join code:", tostring(data.code or "Unknown"))
        .. string.format("%-10s %s\n", "Icon:", tostring(data.icon or "Unknown"))
        .. "Teams:\n"

    local teamCount = 0
    for team, info in data.teams do
        teamCount = teamCount + 1
        print("[outputServerInfo] Team", teamCount, ":", team, "| Name:", tostring(info.Name), "| Logo:", tostring(info.Logo))
        server = server
            .. string.format("%-10s %s\n", " Team:", tostring(team or "Unknown"))
            .. string.format("%-10s %s\n", "   Name:", tostring(info.Name or "Unknown"))
            .. string.format("%-10s %s\n", "   Logo:", tostring(info.Logo or "Unknown"))
    end
    print("[outputServerInfo] Total teams:", teamCount)

    server = server
        .. string.format("%-10s %s", "Rules:\n", tostring(data.rules))
        .. string.format(
            "%-10s %s",
            "Description:\n",
            tostring(data.description)
        )

    print("[outputServerInfo] Building Discord embeds...")
    local mainEmbed = {
        title = data.name,
        description = "",
        fields = {
            {
                name = "Server name",
                value = tostring(data.name),
                inline = true
            },
            {
                name = "Server join code",
                value = tostring(data.code),
                inline = true
            },
            {
                name = "Server icon",
                value = "`" .. tostring(data.icon) .. "`",
                inline = true
            }
        }
    }
    for team, info in data.teams do
        mainEmbed.description = mainEmbed.description
            .. string.format("%-10s %s\n", "**Team:**", tostring(team))
            .. string.format(
                "%-10s %s\n",
                "  **Name:**",
                "`" .. tostring(info.Name) .. "`"
            )
            .. string.format(
                "%-10s %s\n",
                "  **Logo id:**",
                "`" .. tostring(info.Logo) .. "`"
            )
    end
    print("[outputServerInfo] mainEmbed built")

    local descEmbed = {
        title = data.name,
        description = "```" .. data.description .. "```"
    }
    print("[outputServerInfo] descEmbed built")

    local rulesEmbed = {
        title = data.name,
        description = "```" .. data.rules .. "```"
    }
    print("[outputServerInfo] rulesEmbed built")

    local images = {}
    if settings.download then
        print("[outputServerInfo] download=true, creating server folder and fetching images...")
        local serverFolder = settings.baseDownloadLocation .. safeServerName
        print("[outputServerInfo] makefolder:", serverFolder)
        makefolder(serverFolder)

        print("[outputServerInfo] Fetching server icon, id:", tostring(data.icon))
        local ok, img = getImage(
            data.icon,
            settings.baseDownloadLocation .. safeServerName,
            "logo"
        )
        print("[outputServerInfo] Server icon fetch result:", ok)
        if ok then
            table.insert(images, { name = "logo.png", data = img })
            print("[outputServerInfo] logo.png added to images table")
        else
            warn("[outputServerInfo] Failed to fetch server icon!")
        end

        for team, info in data.teams do
            local safeTeam = sanitize(team)
            local safeName = sanitize(info.Name)
            local teamFolder = settings.baseDownloadLocation
                .. safeServerName
                .. "/"
                .. safeTeam
            print("[outputServerInfo] Creating team folder:", teamFolder)
            makefolder(teamFolder)
            print("[outputServerInfo] Fetching team logo for:", team, "| Logo id:", tostring(info.Logo))
            local ok, img = getImage(info.Logo, teamFolder, safeName)
            print("[outputServerInfo] Team logo fetch result:", ok, "for team:", team)
            if ok then
                table.insert(images, { name = safeName .. ".png", data = img })
                print("[outputServerInfo] Team logo added to images:", safeName .. ".png")
            else
                warn("[outputServerInfo] Failed to fetch logo for team:", team)
            end
        end
        print("[outputServerInfo] Total images collected:", #images)
    else
        print("[outputServerInfo] download=false, skipping file downloads")
    end

    if
        settings.sendToWebhook
        and string.find(settings.webhookURL, "discord.com/api/webhooks/")
    then
        print("[outputServerInfo] Sending mainEmbed to Discord...")
        sendToDiscord(mainEmbed, {}, settings.webhookURL)
        print("[outputServerInfo] Sending descEmbed to Discord...")
        sendToDiscord(descEmbed, {}, settings.webhookURL)
        print("[outputServerInfo] Sending rulesEmbed with images to Discord...")
        sendToDiscord(rulesEmbed, images, settings.webhookURL)
        print("[outputServerInfo] All embeds sent")
    else
        print("[outputServerInfo] Webhook send skipped (sendToWebhook=false or invalid URL)")
    end

    print("[outputServerInfo] Done. Returning server string and original settings")
    return server .. "\n\n", data.original
end

local function getUniforms()
    print("[getUniforms] Starting uniform extraction...")
    local uniformTable = {}
    local uniforms = [[
  _   _       _  __                          
 | | | |_ __ (_)/ _| ___  _ __ _ __ ___  ___ 
 | | | | '_ \| | |_ / _ \| '__| '_ ` _ \/ __|
 | |_| | | | | |  _| (_) | |  | | | | | \__ \
  \___/|_| |_|_|_|  \___/|_|  |_| |_| |_|___/
                                             
]]

    local teamsFound = replicatedStorage.ReplicatedState.Uniforms:GetChildren()
    print("[getUniforms] Teams found in ReplicatedState.Uniforms:", #teamsFound)

    for _, team in teamsFound do
        print("[getUniforms] Processing team:", team.Name)
        local safeTeam = sanitize(team.Name)

        if settings.download then
            local uniformsFolder = settings.baseDownloadLocation
                .. safeServerName
                .. "/"
                .. safeTeam
                .. "/uniforms"
            print("[getUniforms] Creating uniforms folder:", uniformsFolder)
            makefolder(uniformsFolder)
        end

        uniformTable[team.Name] = {}
        uniforms = uniforms
            .. string.rep("=", 30)
            .. "\n"
            .. team.Name
            .. "\n"
            .. string.rep("=", 30)
            .. "\n"

        local uniformChildren = team:GetChildren()
        print("[getUniforms] Uniforms in team", team.Name, ":", #uniformChildren)

        for _, uniform in uniformChildren do
            if uniform:FindFirstChild("CustomUniform") then
                print("[getUniforms]   Custom uniform found:", uniform.Name)
                local shirtId = extractId(tostring(uniform.Shirt.ShirtTemplate))
                local pantsId = extractId(tostring(uniform.Pants.PantsTemplate))
                print("[getUniforms]   Shirt id:", shirtId, "| Pants id:", pantsId)

                uniformTable[team.Name][uniform.Name] = {
                    shirt = shirtId,
                    pants = pantsId
                }

                uniforms = uniforms
                    .. string.format(
                        "%-10s %s\n",
                        "  Name:",
                        tostring(uniform.Name or "Unknown")
                    )
                    .. string.format("%-10s %s\n", "    Shirt:", tostring(shirtId or "Unknown"))
                    .. string.format("%-10s %s\n", "    Pants:", tostring(pantsId or "Unknown"))

                print("[getUniforms]   Spawning download/webhook task for uniform:", uniform.Name)
                task.spawn(function()
                    print("[getUniforms] [task] Processing uniform:", uniform.Name, "team:", team.Name)
                    local images = {}
                    if settings.download then
                        local safeName = sanitize(uniform.Name)
                        local uniformFolder = settings.baseDownloadLocation
                            .. safeServerName
                            .. "/"
                            .. safeTeam
                            .. "/uniforms/"
                            .. safeName
                        print("[getUniforms] [task] Creating uniform folder:", uniformFolder)
                        makefolder(uniformFolder)

                        print("[getUniforms] [task] Fetching shirt image, id:", shirtId)
                        local a, img = getImage(shirtId, uniformFolder, "Shirt")
                        print("[getUniforms] [task] Shirt fetch result:", a)
                        if a then
                            table.insert(images, { name = "shirt.png", data = img })
                            print("[getUniforms] [task] shirt.png added")
                        else
                            warn("[getUniforms] [task] Failed to fetch shirt image for:", uniform.Name)
                        end

                        print("[getUniforms] [task] Fetching pants image, id:", pantsId)
                        local a, img = getImage(pantsId, uniformFolder, "Pants")
                        print("[getUniforms] [task] Pants fetch result:", a)
                        if a then
                            table.insert(images, { name = "pants.png", data = img })
                            print("[getUniforms] [task] pants.png added")
                        else
                            warn("[getUniforms] [task] Failed to fetch pants image for:", uniform.Name)
                        end
                    else
                        print("[getUniforms] [task] download=false, skipping image files")
                    end

                    local embed = {
                        title = serverName,
                        fields = {
                            {
                                name = "Team",
                                value = tostring(team.Name),
                                inline = true
                            },
                            {
                                name = "Name",
                                value = tostring(uniform.Name),
                                inline = true
                            },
                            {
                                name = "Shirt",
                                value = "`" .. shirtId .. "`",
                                inline = true
                            },
                            {
                                name = "Pants",
                                value = "`" .. pantsId .. "`",
                                inline = true
                            }
                        }
                    }
                    print("[getUniforms] [task] Embed built for:", uniform.Name)

                    if settings.sendToWebhook then
                        print("[getUniforms] [task] Sending to Discord webhook, images:", #images)
                        sendToDiscord(embed, images, settings.webhookURL)
                        print("[getUniforms] [task] Discord send complete for:", uniform.Name)
                    else
                        print("[getUniforms] [task] sendToWebhook=false, skipping")
                    end
                end)
            else
                print("[getUniforms]   Skipping uniform (no CustomUniform child):", uniform.Name)
            end
        end
    end

    print("[getUniforms] All teams processed")
    return uniforms, uniformTable
end

local function getELS()
    print("[getELS] Invoking GetCustomELS on server...")
    local result = replicatedStorage.FE.GetCustomELS:InvokeServer()
    local count = 0
    if type(result) == "table" then
        for _ in pairs(result) do count = count + 1 end
    end
    print("[getELS] ELS data received, top-level entries:", count)
    return result
end

local function getMapTemplates()
    print("[getMapTemplates] Scanning workspace.MapLayouts...")
    local mapLayouts = {}

    local layouts = workspace.MapLayouts:GetChildren()
    print("[getMapTemplates] MapLayouts children count:", #layouts)

    for _, template in layouts do
        local layoutName = template:GetAttribute("LayoutName")
        print("[getMapTemplates] Layout:", tostring(layoutName), "| template name:", template.Name)
        mapLayouts[layoutName] = {}

        local props = template.Props:GetChildren()
        print("[getMapTemplates]   Props count:", #props)
        for _, prop in props do
            local propName = prop:GetAttribute("PropName")
            local propPosition = tostring(prop.WorldPivot)
            print("[getMapTemplates]   Prop:", tostring(propName), "| position:", propPosition)
            table.insert(mapLayouts[layoutName], {
                name = propName,
                position = propPosition
            })
        end
        print("[getMapTemplates] Layout", tostring(layoutName), "complete with", #mapLayouts[layoutName], "props")
    end

    print("[getMapTemplates] Done. Total layouts:", (function() local c=0 for _ in pairs(mapLayouts) do c=c+1 end return c end)())
    return mapLayouts
end

local function takeAssets()
    print("[takeAssets] ========== ASSET TAKER STARTED ==========")
    local outputString = ""
    local outputTable = {}

    print("[takeAssets] Creating base server folder:", settings.baseDownloadLocation .. safeServerName)
    makefolder(settings.baseDownloadLocation .. safeServerName)

    print("[takeAssets] --- Step 1: Server Info ---")
    local serverInfoOutput, serverSettings = outputServerInfo()
    print("[takeAssets] Server info output length:", #serverInfoOutput)
    outputString = outputString .. serverInfoOutput
    outputTable.settings = table.clone(serverSettings)
    print("[takeAssets] Server info done")

    print("[takeAssets] --- Step 2: Uniforms ---")
    local uniformsOutput, uniformTable = getUniforms()
    print("[takeAssets] Uniforms output length:", #uniformsOutput)
    outputString = outputString .. uniformsOutput
    outputTable.uniforms = table.clone(uniformTable)
    print("[takeAssets] Uniforms done")

    print("[takeAssets] --- Step 3: Liveries ---")
    local liveriesOutput, liveryTable = getLiveries()
    print("[takeAssets] Liveries output length:", liveriesOutput and #liveriesOutput or "NIL")
    outputString = outputString .. (liveriesOutput or "")
    outputTable.liveries = table.clone(liveryTable or {})
    print("[takeAssets] Liveries done")

    print("[takeAssets] --- Step 4: ELS ---")
    local ELSTable = getELS()
    outputTable.ELS = table.clone(ELSTable)
    print("[takeAssets] ELS done")

    print("[takeAssets] --- Step 5: Map Templates ---")
    outputTable.Map = getMapTemplates()
    print("[takeAssets] Map templates done")

    local jsonPath = settings.baseDownloadLocation
        .. safeServerName
        .. "/"
        .. safeServerName
        .. ".json"
    local txtPath = settings.baseDownloadLocation
        .. safeServerName
        .. "/"
        .. safeServerName
        .. ".txt"

    print("[takeAssets] Writing JSON output to:", jsonPath)
    local jsonEncoded = httpService:JSONEncode(outputTable)
    print("[takeAssets] JSON encoded length:", #jsonEncoded, "bytes")
    writefile(jsonPath, jsonEncoded)
    print("[takeAssets] JSON written successfully")

    print("[takeAssets] Writing TXT output to:", txtPath)
    print("[takeAssets] TXT output length:", #outputString, "bytes")
    writefile(txtPath, outputString)
    print("[takeAssets] TXT written successfully")

    print("[takeAssets] ========== (updated 1.0.0) DONE — ALL ASSETS SAVED ==========")
    print("DONE")
end

print("[INIT] All functions defined. Calling takeAssets()...")
takeAssets()
