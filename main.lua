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
local inQueue = false

local categoryType = nil
local seed = 0xAAAAAAAAAAAAAAAA
local currentSaves = {}
local furthestLevel = {1,1}


local function spawnSign()
    local signUID = spawn_entity(ENT_TYPE.ITEM_SPEEDRUN_SIGN, 46, 84, LAYER.FRONT, 0, 0)
    sign = get_entity(signUID)
    sign.flags = clr_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
    button_prompts.spawn_button_prompt_on(button_prompts.PROMPT_TYPE.INTERACT, signUID, function()
        set_callback(renderWindow, ON.RENDER_PRE_HUD)
    end)
end

function renderWindow(ctx)
    ctx:draw_screen_texture(TEXTURE.DATA_TEXTURES_LOADING_0, 1, 1, 1, 10, 10, 1, Color:white())
end

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
                    categoryType = data.category
                    seed = data.seed
                    -- match start stuff
                    startMatch()
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
                    endMatch()
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

local function startMatch()
    state.world_next=1
    state.level_next=1
    state.theme_next=1
    state.screen_next=12
    set_adventure_seed(seed,seed)
    load_screen()
end

local function saveProgress()
    for index, save in ipairs(currentSaves) do
        if (save.level == state.level) and (save.world == state.world) then
            return
        end
    end
    saveInfo = {
        level = state.level,
        world = state.world,
        theme = state.theme,
        aggro = state.shoppie_aggro,
        tAggro = state.merchant_aggro,
        lFlags = state.level_flags,
        qFlags = state.quest_flags,
        pFlags = state.presence_flags,
        time = state.time_total,
        inventory = state.items.player_inventory[1]
    }
    table.insert(currentSaves, saveInfo)
end

local function endMatch()
    state.world_next = 1
    state.level_next = 1
    state.theme_next = 17
    state.screen_next = 11
    load_screen()
    currentSaves = {}
    furthestLevel = {1,1}
    matchStarted = false
    matchResultReceived = false
    --some sort of notification of win/loss
end

-- set_callback(startServer, ON.LOAD)
-- set_callback(timedOps, ON.GAMEFRAME)
set_callback(spawnSign, ON.CAMP)





local function loadSeed()
    if (state.screen_next==SCREEN.LEVEL) then
        set_adventure_seed(seed,seed)
    end
end


set_callback(loadSeed, ON.PRE_LOAD_SCREEN)
-- set_callback(renderWindow, ON.RENDER_PRE_HUD)
