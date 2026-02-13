meta = {
    name = 'S2 Ranked',
    version = '1.0',
    description = '1v1 Spelunky For Rank',
    author = 'ZSRoach',
}

local button_prompts = require("ButtonPrompts/button_prompts")
local inputs = require("Inputs.inputs")

-- server variables
gameAddress = "127.0.0.1"
gamePort = 21587
bridgeAddress = "127.0.0.1:21588"

serverDelay = 3 -- time in seconds to wait before doing any server actions
lastServerOp = 0 -- time of last server operation


-- match variables
matchStarted = false
matchResultReceived = false

categoryType = nil
seed = 0xAAAAAAAAAAAAAAAA
currentSaves = {}
furthestLevel = {1,1}

-- camp variables
signOpen = false
ratio = 16/9
white = Color:white()
black = Color:black()
inQueue = false
buttonIndex = 0
queueStateText = "Not in queue"



--camp functions
function spawnSign()
    local signUID = spawn_entity(ENT_TYPE.ITEM_SPEEDRUN_SIGN, 46, 84, LAYER.FRONT, 0, 0)
    sign = get_entity(signUID)
    sign.flags = clr_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
    button_prompts.spawn_button_prompt_on(button_prompts.PROMPT_TYPE.INTERACT, signUID, function()
        signOpen = true
        get_player(1).input = nil
        set_journal_enabled(false)
    end)
end

function blockInputs()
    set_journal_enabled(false)
    get_player(1).input = nil
end

function returnInputs()
    get_player(1).input = state.player_inputs.player_slot_1
    set_journal_enabled(true)
end

function renderTexture(render_ctx, texture, r, c, top, left, size)
    --helper function for loading singular textures
    local position = AABB:new(left, top*ratio, left+(size*.1),(top-(size*.1))*ratio)
    render_ctx:draw_screen_texture(texture,r,c,position,white)
end

function renderText(render_ctx, str, x, y, scale, color)
    --helper function for rendering text
    render_ctx:draw_text(str,x,y,scale,scale,color, VANILLA_TEXT_ALIGNMENT.CENTER, VANILLA_FONT_STYLE.ITALIC)
end

function renderToast(render_ctx)
    --hard code toast location
    local x = -1.05
    local y = .45
    local scale = 2
    for xoffset = 0, 2, 1 do
        local newx = x + (xoffset*scale/10)
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_DEATHMATCH2_0, 7, 7+xoffset, y,newx,scale)
    end
    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3, 6, y-.025, x+.05, scale-.5)
    renderText(render_ctx, "In queue...", x+.366,y+.1666,.0015,white)
end

function renderWindow(render_ctx)
    --hard code these for window placement
    local top = .4
    local left = -.4

    local yInc = (math.abs(top)*2)/5
    local xInc = (math.abs(left)*2)/5
    for yoffset = 0, -4, -1 do
        for xoffset = 0, 4, 1 do
            l = left + (xInc*xoffset)
            t = (top + (yInc*yoffset))*ratio
            r = left + (xInc*(xoffset+1))
            b = (top + (yInc*(yoffset-1)))*ratio
            local position = AABB:new(l,t,r,b)
            render_ctx:draw_screen_texture(TEXTURE.DATA_TEXTURES_MENU_BASIC_2,math.abs(yoffset),xoffset,position,white)
        end
    end
end

function renderWindowObjects(render_ctx)
    --hard code text location
    local textX = 0
    local textY = .05
    local textScale = .002

    --hard code icon location
    local iconTop = .20
    local iconLeft = -.05
    local iconSize = 1

    renderText(render_ctx, queueStateText, textX, textY, textScale, white)
    if inQueue then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3, 6, iconTop, iconLeft, iconSize)
    end

end

function buttonHandle(render_ctx)
    --hard coded button locations
    local queueButtonScale = 1.5
    local queueButtonX = -.32+queueButtonScale/20
    local queueButtonY = -.10
    
    local leaveQueueButtonScale = queueButtonScale
    local leaveQueueButtonX = 0-queueButtonScale/20
    local leaveQueueButtonY = -.10
    
    local closeButtonScale = queueButtonScale
    local closeButtonX = .32-queueButtonScale/10-(queueButtonScale/20)
    local closeButtonY = -.10
  
    local textY = -.3
    local textScale = .0008

    --texture change for highlighted button
    if buttonIndex == 0 then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,queueButtonY,queueButtonX,queueButtonScale)
        renderText(render_ctx,"Queue", -.32+queueButtonScale/10, textY, textScale, black)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,queueButtonY,queueButtonX,queueButtonScale)
        renderText(render_ctx,"Queue", -.32+queueButtonScale/10, textY, textScale, white)
    end

    if buttonIndex == 1 then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,8,leaveQueueButtonY,leaveQueueButtonX,leaveQueueButtonScale)
        renderText(render_ctx,"Cancel", 0, textY, textScale, black)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,5,8,leaveQueueButtonY,leaveQueueButtonX,leaveQueueButtonScale)
        renderText(render_ctx,"Cancel", 0, textY, textScale, white)
    end

    if buttonIndex == 2 then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,8,closeButtonY,closeButtonX,closeButtonScale)
        renderText(render_ctx,"Close", .32-queueButtonScale/10, textY, textScale, black)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,5,8,closeButtonY,closeButtonX,closeButtonScale)
        renderText(render_ctx,"Close", .32-queueButtonScale/10, textY, textScale, white)
    end
end

function inputHandle()
    -- throw in render callback to sync with input polling
    if inputs.active_mode==1 then --controller
        if inputs.gamepad_button_release(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_release(inputs.GAMEPAD.LEFT) then
            buttonIndex = (buttonIndex - 1)%3
        end
        if inputs.gamepad_button_release(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_release(inputs.GAMEPAD.RIGHT) then
            buttonIndex = (buttonIndex + 1)%3
        end
        if inputs.gamepad_button_release(inputs.GAMEPAD.A) then
            if buttonIndex == 0 then
                queueStateText = "In Queue"
                inQueue = true
            elseif buttonIndex == 1 then
                queueStateText = "Not In Queue"
                inQueue = false
            else
                queueStateText = "Menu Closed"
                signOpen = false
                returnInputs()

            end
        end
    else --keyboard
        if inputs.key_release(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_release(inputs.KEYBOARD.D) then
            buttonIndex = (buttonIndex+1)%3
        end
        if inputs.key_release(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_release(inputs.KEYBOARD.A) then
            buttonIndex = (buttonIndex-1)%3
        end
        if inputs.key_release(inputs.KEYBOARD.RETURN) then
            if buttonIndex == 0 then
                queueStateText = "In Queue"
                inQueue = true
            elseif buttonIndex == 1 then
                queueStateText = "Not In Queue"
                inQueue = false
            else
                queueStateText = "Menu Closed"
                signOpen = false
                returnInputs()
            end
        end
    end
end

function renderHandle(render_ctx)
    if signOpen then
        renderWindow(render_ctx)
        renderWindowObjects(render_ctx)
        buttonHandle(render_ctx)
        inputHandle()
    end
    if (not signOpen) and inQueue then
        renderToast(render_ctx)
    end
end
-- server functions    

function startServer()
    server = UdpServer:new(gameAddress,gamePort)
    if not server:is_open() then
        console_print("UDP Server Initialization Failed: "..server:last_error_str())
        return
    end
end

function timedOps()
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

--udp functions

function placeInQueue()
    server:send(json.encode({ event = "queue_ready"}), bridgeAddress)
end

function ban(category)
    server:send(json.encode({ event = "ban", category = category}), bridgeAddress)
end

function progressUpdate(area, level)
    server:send(json.encode({ event = "progress", area = area, level = level }), bridgeAddress)
end

function deathReport()
    server:send(json.encode({ event = "death" }), bridgeAddress)
end

function restartReport()
    server:send(json.encode({ event = "instant_restart"}), bridgeAddress)
end

function completionReport()
    server:send(json.encode({ event = "completion" }), bridgeAddress)
end

--game process functions

function startMatch()
    --this doesnt work, make it do
    state.world_next=1
    state.level_next=1
    state.theme_next=1
    state.screen_next=12
    set_adventure_seed(seed,seed)
    load_screen()
end

function saveProgress()
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

function endMatch()
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





function loadSeed()
    if (state.screen_next==SCREEN.LEVEL) then
        set_adventure_seed(seed,seed)
    end
end


set_callback(loadSeed, ON.PRE_LOAD_SCREEN)
set_callback(renderHandle, ON.RENDER_PRE_HUD)
