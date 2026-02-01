meta = {
    name = 'S2 Ranked',
    version = '1.0',
    description = '1v1 Spelunky For Rank',
    author = 'ZSRoach',
}

local button_prompts = require("ButtonPrompts/button_prompts")
local inputs = require("Inputs.inputs")

local gameAddress = "127.0.0.1"
local gamePort = 21587
local bridgeAddress = "127.0.0.1:21588"

local serverDelay = 3 -- time in seconds to wait before doing any server actions
local lastServerOp = 0 -- time of last server operation

local matchStarted = false
local matchResultReceived = false

local function startServer()
    server = UdpServer:new(gameAddress,gamePort)
    if not server:is_open() then
        console_print("UDP Server Initialization Failed: "..server:last_error_str())
        return
    end
end

local function timedOps()
    elapsedTime = (get_global_frame()/60) - lastServerOp
    if (elapsedTime >= serverDelay) then
        lastServerOp = (get_global_frame()/60)
        --read operations
        while server:read(function(message, source)
            local data = json.decode(message)
            local event = data.event
            if event == nil then return end

            -- Heartbeat 
            if event == "ping" then
                server:send(json.encode({ event = "pong" }), source)
            
            -- Match found
            elseif event == "paired" then
                local opponent = data.opponent_name
                local categories = data.categories
                local bansFirst = data.ban_order_first

            -- Ban Phase 
            elseif event == "ban_update" then
                local categories = data.categories
            
            -- Match start (ack required)
            elseif event == "match_start" then 
                if not matchStarted then
                    matchStarted = true
                    local category = data.category
                    local seed = data.seed
                    -- match start stuff
                end
                server:send(json.encode({ event = "ack", ack_event = "match_start" }), source)

            --Opponent progress
            elseif event == "opponent_progress" then
                local opponentArea = data.area
            
            -- Match result (ack required)
            elseif event == "match_result" then
                if not matchResultReceived then
                    matchResultReceived = true
                    local result = data.result
                end
                server:send(json.encode({ event = "ack", ack_event = "match_result"}), source)

            elseif event == "match_scrapped" then
                --something happens here to kick the player out

            end
        end) ~= -1 do end
    end
end

local function placeInQueue()
    server:send(json.encode({ event = "queue_ready"}), bridgeAddress)
end

local function ban(category)
    server:send(json.encode({ event = "ban", category = category}), bridgeAddress)
end

local function progressUpdate(area, level)
    server:send(json.encode({ event = "progress", area = area, level = level }), bridgeAddress)
end

local function deathReport()
    server:send(json.encode({ event = "death" }), bridgeAddress)
end

local function restartReport()
    server:send(json.encode({ event = "instant_restart"}), bridgeAddress)
end

local function completionReport()
    server:send(json.encode({ event = "completion" }), bridgeAddress)
end

set_callback(startServer, ON.LOAD)
set_callback(timedOps, ON.GAMEFRAME)

categoryType = nil
seed = 0xAAAAAAAAAAAAAAAA



local function loadSeed()
    if (state.screen_next==SCREEN.LEVEL) then
        set_adventure_seed(seed,seed)
    end
end


set_callback(loadSeed, ON.PRE_LOAD_SCREEN)
