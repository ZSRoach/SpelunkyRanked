meta = {
    name = 'S2 Ranked',
    version = '1.0',
    description = '1v1 Spelunky For Rank',
    author = 'ZSRoach',
    unsafe = true,
}

local button_prompts = require("ButtonPrompts/button_prompts")
local inputs = require("Inputs.inputs")

--constants
ratio = 16/9
seedChangeWindow = 45
drawVoteWindow = 45
white = Color:white()
black = Color:black()
categoryList = {
    "Any%",
    "Sunken City%",
    --"CO Entry",
    "Low%",
    "Low% J/T",
    "No TP Any%",
    "No TP Sunken City%",
    "No TP Eggplant%",
    "No Gold Low%",
    "Abzu%",
    "Duat%",
    "No TP Abzu%",
    "No TP Duat%",
    --"Chain Low% Abzu",
    --"Chain Low% Duat",
}
shopCategories = {
    "Any%",
    "Sunken City",
    "No TP Any%",
    "No TP Sunken City%",
    "No TP Eggplant%",
    "Abzu%",
    "Duat%",
    "No TP Abzu%",
    "No TP Duat%",
}
nonShopCategories = {
    "Low%",
    "Low% J/T",
    "No Gold Low%",
    --"Chain Low% Abzu",
    --"Chain Low% Duat",
}
tpCategories = {
    "Any%",
    "Sunken City",
    "Duat%",
}
mattockCategories = {
    "No TP Any%",
    "No TP Sunken City%",
    "No TP Abzu%",
    "No TP Duat%",
}
bombCategories = {
    "Sunken City",
    "No TP Sunken City%",
    "No TP Eggplant%",
    "No TP Abzu%",
    "No TP Duat%",
}
packCategories = {
    "Any%",
    "No TP Any%",
    "No TP Duat%",
}
jetpackCategories = {
    "Sunken City",
    "No TP Sunken City%",
    "No TP Eggplant%",
    "No TP Abzu%",
}
telepackCategories = {
    "Abzu%",
    "Duat%",
}
path_rooms = {1, 2, 3, 4, 5, 6, 7, 8, 102, 107, 109}
replace_rooms = {ROOM_TEMPLATE.PEN_ROOM, ROOM_TEMPLATE.VAULT, ROOM_TEMPLATE.ALTAR, ROOM_TEMPLATE.IDOL, ROOM_TEMPLATE.IDOL_TOP}
altar_replace = {ROOM_TEMPLATE.PEN_ROOM, ROOM_TEMPLATE.VAULT, ROOM_TEMPLATE.IDOL, ROOM_TEMPLATE.IDOL_TOP, ROOM_TEMPLATE.SIDE}
shop_rooms = {
    ROOM_TEMPLATE.SHOP,
    ROOM_TEMPLATE.SHOP_LEFT,
    ROOM_TEMPLATE.SHOP_ENTRANCE_UP,
    ROOM_TEMPLATE.SHOP_ENTRANCE_UP_LEFT,
    ROOM_TEMPLATE.SHOP_ENTRANCE_DOWN,
    ROOM_TEMPLATE.SHOP_ENTRANCE_DOWN_LEFT,
}
small_shop_rooms = {
    ROOM_TEMPLATE.SHOP,
    ROOM_TEMPLATE.SHOP_LEFT,
}
pack_items = {
    ENT_TYPE.ITEM_PURCHASABLE_JETPACK,
    ENT_TYPE.ITEM_PURCHASABLE_HOVERPACK,
}
tp_items = {
    ENT_TYPE.ITEM_TELEPORTER,
    ENT_TYPE.ITEM_PURCHASABLE_TELEPORTER_BACKPACK,
}
notp_items = {
    ENT_TYPE.ITEM_MATTOCK,
    ENT_TYPE.ITEM_PICKUP_BOMBBOX,
    ENT_TYPE.ITEM_PRESENT,
}
specialty_items = {
    ENT_TYPE.ITEM_PICKUP_BOMBBOX,
    ENT_TYPE.ITEM_PICKUP_COMPASS,
    ENT_TYPE.ITEM_PICKUP_SPECTACLES,
    ENT_TYPE.ITEM_PICKUP_SKELETON_KEY,
    ENT_TYPE.ITEM_CAMERA,
    ENT_TYPE.ITEM_MATTOCK,
    ENT_TYPE.ITEM_TELEPORTER,
    ENT_TYPE.ITEM_METAL_SHIELD,
    ENT_TYPE.ITEM_FREEZERAY,
    ENT_TYPE.ITEM_PURCHASABLE_POWERPACK,
    ENT_TYPE.ITEM_PURCHASABLE_TELEPORTER_BACKPACK,
    ENT_TYPE.ITEM_PURCHASABLE_HOVERPACK,
    ENT_TYPE.ITEM_PURCHASABLE_JETPACK,
    ENT_TYPE.ITEM_PRESENT,
}
replaceable_items = {
    ENT_TYPE.ITEM_PICKUP_ROPEPILE,
    ENT_TYPE.ITEM_PICKUP_BOMBBAG,
    ENT_TYPE.ITEM_PICKUP_PARACHUTE,
    ENT_TYPE.ITEM_PICKUP_PASTE,
    ENT_TYPE.ITEM_PRESENT,
    ENT_TYPE.ITEM_PICKUP_SPRINGSHOES,
    ENT_TYPE.ITEM_PICKUP_PITCHERSMITT,
    ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES,
    ENT_TYPE.ITEM_PURCHASABLE_CAPE,
    ENT_TYPE.ITEM_PICKUP_SPIKESHOES,
    ENT_TYPE.ITEM_MACHETE,
    ENT_TYPE.ITEM_BOOMERANG,
    ENT_TYPE.ITEM_CROSSBOW,
    ENT_TYPE.ITEM_WEBGUN,
    ENT_TYPE.ITEM_SHOTGUN,
    ENT_TYPE.ITEM_PICKUP_BOMBBOX,
    ENT_TYPE.ITEM_PICKUP_COMPASS,
    ENT_TYPE.ITEM_PICKUP_SPECTACLES,
    ENT_TYPE.ITEM_PICKUP_SKELETON_KEY,
    ENT_TYPE.ITEM_CAMERA,
    ENT_TYPE.ITEM_MATTOCK,
    ENT_TYPE.ITEM_TELEPORTER,
    ENT_TYPE.ITEM_METAL_SHIELD,
    ENT_TYPE.ITEM_FREEZERAY,
    ENT_TYPE.ITEM_PURCHASABLE_POWERPACK,
    ENT_TYPE.ITEM_PURCHASABLE_TELEPORTER_BACKPACK,
    ENT_TYPE.ITEM_PURCHASABLE_HOVERPACK,
    ENT_TYPE.ITEM_PURCHASABLE_JETPACK,
}
levelOrder = {
    {1,1},
    {1,2},
    {1,3},
    {1,4},
    {2,1},
    {2,2},
    {2,3},
    {2,4},
    {3,1},
    {4,1},
    {4,2},
    {4,3},
    {4,4},
    {5,1},
    {6,1},
    {6,2},
    {6,3},
    {6,4},
    {7,1},
    {7,2},
    {7,3},
    {7,4},
}
lowHoldViolationItems = {
    ENT_TYPE.ITEM_WOODEN_SHIELD,
    ENT_TYPE.ITEM_METAL_SHIELD,
    ENT_TYPE.ITEM_JETPACK,
    ENT_TYPE.ITEM_HOVERPACK,
    ENT_TYPE.ITEM_CAPE,
    ENT_TYPE.ITEM_POWERPACK,
    ENT_TYPE.ITEM_TELEPORTER_BACKPACK,
    ENT_TYPE.ITEM_VLADS_CAPE,
}
lowUseViolationItems = {
    ENT_TYPE.ITEM_WEBGUN,
    ENT_TYPE.ITEM_SHOTGUN,
    ENT_TYPE.ITEM_FREEZERAY,
    ENT_TYPE.ITEM_CLONEGUN,
    ENT_TYPE.ITEM_CAMERA,
    ENT_TYPE.ITEM_TELEPORTER,
    ENT_TYPE.ITEM_MATTOCK,
    ENT_TYPE.ITEM_BOOMERANG,
    ENT_TYPE.ITEM_MACHETE,
    ENT_TYPE.ITEM_PLASMACANNON,
    ENT_TYPE.ITEM_SCEPTER,
}
tpItems = {
    ENT_TYPE.ITEM_TELEPORTER,
    ENT_TYPE.ITEM_TELEPORTER_BACKPACK,
}
chainTouchItems = {
    ENT_TYPE.ITEM_EXCALIBUR,
    ENT_TYPE.ITEM_SCEPTER,
    ENT_TYPE.ITEM_POWERUP_ANKH,
}
exemptTypes = {
    ENT_TYPE.LOGICAL_DOOR,
    ENT_TYPE.LOGICAL_DOOR_AMBIENT_SOUND,
    ENT_TYPE.LOGICAL_BLACKMARKET_DOOR,
    ENT_TYPE.LOGICAL_ARROW_TRAP_TRIGGER,
    ENT_TYPE.LOGICAL_TOTEM_TRAP_TRIGGER,
    ENT_TYPE.LOGICAL_JUNGLESPEAR_TRAP_TRIGGER,
    ENT_TYPE.LOGICAL_SPIKEBALL_TRIGGER,
    ENT_TYPE.LOGICAL_CRUSH_TRAP_TRIGGER,
    ENT_TYPE.LOGICAL_TENTACLE_TRIGGER,
    ENT_TYPE.LOGICAL_WET_EFFECT,
    ENT_TYPE.LOGICAL_ONFIRE_EFFECT,
    ENT_TYPE.LOGICAL_POISONED_EFFECT,
    ENT_TYPE.LOGICAL_CURSED_EFFECT,
    ENT_TYPE.LOGICAL_CAMERA_ANCHOR,
    ENT_TYPE.LOGICAL_BURNING_ROPE_EFFECT,
    ENT_TYPE.LOGICAL_DUSTWALL_APEP,
    ENT_TYPE.LOGICAL_CAMERA_FLASH,
    ENT_TYPE.LOGICAL_PORTAL,
    ENT_TYPE.LOGICAL_WATER_DRAIN,
    ENT_TYPE.LOGICAL_BOULDERSPAWNER,
    ENT_TYPE.LOGICAL_LAVA_DRAIN,
    ENT_TYPE.LOGICAL_SPLASH_BUBBLE_GENERATOR,
    ENT_TYPE.LOGICAL_MINIGAME,
    ENT_TYPE.LOGICAL_ANCHOVY_FLOCK,
    ENT_TYPE.LOGICAL_BIGSPEAR_TRAP_TRIGGER,
    ENT_TYPE.LOGICAL_PLATFORM_SPAWNER,
    ENT_TYPE.LOGICAL_STATICLAVA_SOUND_SOURCE,
    ENT_TYPE.LOGICAL_STREAMLAVA_SOUND_SOURCE,
    ENT_TYPE.LOGICAL_STREAMWATER_SOUND_SOURCE,
    ENT_TYPE.LOGICAL_CONVEYORBELT_SOUND_SOURCE,
    ENT_TYPE.LOGICAL_QUICKSAND_AMBIENT_SOUND_SOURCE,
    ENT_TYPE.LOGICAL_QUICKSAND_SOUND_SOURCE,
    ENT_TYPE.LOGICAL_DUSTWALL_SOUND_SOURCE,
    ENT_TYPE.LOGICAL_ICESLIDING_SOUND_SOURCE,
    ENT_TYPE.LOGICAL_PIPE_TRAVELER_SOUND_SOURCE,
    ENT_TYPE.LOGICAL_FROST_BREATH,
    ENT_TYPE.LOGICAL_EGGPLANT_THROWER,
}

register_option_bool("chatEnabled", "Show incoming chat messages (unfiltered)", true)
register_option_bool("chatExplanation", "Press Forward Slash (/) during category bans or the match to send a message.", false)
register_option_int("chatMessageLimit", "Max number of messages allowed on screen at once", 5, 1, 10)
register_option_int("chatMessageDuration", "How long messages should show for in seconds", 7, 1, 15)


-- server variables

gameAddress = "127.0.0.1"
gamePort = 21587
bridgeAddress = "127.0.0.1:21588"
bridgeConnected = false

serverDelay = .5 -- time in seconds to wait before doing any server actions
lastServerOp = 0 -- time of last server operation
postMatchDuration = 20 -- match to server config 



-- match variables
opponent = "name"
opponentelo = 0
opponentArea = 0
eloChange = 0
categories = {}
remainingCategories = {}
bansFirst = false
banTimer = 0
postMatch = false
preMatch = false
messageList = {}
chatting = false
chatMessage = ""

matchStarted = false
matchResultReceived = false
result = nil
banPhase = false
reportCount = 0

categoryType = nil
seed = 0xAAAAAAAAAAAAAAAA
currentSaves = {}
furthestLevel = {1,1}

sentSeedChange = false
activeSeedChange = false
changingSeed = false
sentDrawVote = false
activeDrawVote = false
sentForfeit = false
postMatch = false
buttonHovering = -1

shopYet = false
itemsYet = false
spawnedItems = {}
runItems = {}
hadAnkhThisRun = false
hadExcaliburThisRun = false
hadScepterThisRun = false
violate = false
--controls process of loading checkpoint
loadProg = false
loadItems = false
loadEnts = false
--warp process variables
doReset = false
warping = false
wasLevel = false
wasTransition = false
warpTo = {}
loadAt = {}
--controls warp theme
jungle = true
tidepool = true


-- camp variables
blockingPause = false
signOpen = false
inQueue = false
buttonIndex = 0
banButtonIndex = 0
queueStateText = "Not in queue"
callbackList = {}

--sets variable values to defaults when camp loaded first time - used post match
function defaultValues()
    preMatch = false
    callbackList = {}
    postMatch = false
    changingSeed = false
    eloChange = 0
    postMatch = false
    activeSeedChange = false
    activeDrawVote = false
    result = nil
    reportCount = 0
    opponentArea = 0
    violate = false
    doReset = false
    hadAnkhThisRun = false
    hadExcaliburThisRun = false
    hadScepterThisRun = false
    remainingCategories = {}
    banTimer = 0
    opponentelo = 0
    banButtonIndex = 0
    banPhase = false
    opponent = "name"
    categories = {}
    bansFirst = false
    blockingPause = false
    matchStarted = false
    matchResultReceived = false
    categoryType = nil
    seed = 0xAAAAAAAAAAAAAAAA
    currentSaves = {}
    furthestLevel = {1,1}
    sentSeedChange = false
    sentDrawVote = false
    sentForfeit = false
    buttonHovering = -1
    shopYet = false
    itemsYet = false
    spawnedItems = {}
    runItems = {}
    loadProg = false
    loadItems = false
    loadEnts = false
    warping = false
    wasLevel = false
    wasTransition = false
    warpTo = {}
    loadAt = {}
    jungle = true
    tidepool = true
    signOpen = false
    inQueue = false
    buttonIndex = 0
    queueStateText = "Not in queue"
end
--resets values to default that are related to the very start of a match, right after bans
function defaultMatchValues()
    postMatch = false
    currentSaves = {}
    furthestLevel = {1,1}
    activeSeedChange = false
    activeDrawVote = false
    reportCount = 0
    opponentArea = 0
    violate = false
    doReset = false
    hadAnkhThisRun = false
    hadExcaliburThisRun = false
    hadScepterThisRun = false
    warpTo = {}
    loadAt = {}
    jungle = true
    tidepool = true
    shopYet = false
    itemsYet = false
    spawnedItems = {}
    runItems = {}
    loadProg = false
    loadItems = false
    loadEnts = false
    warping = false
    wasLevel = false
    wasTransition = false
    sentSeedChange = false
    sentDrawVote = false
    sentForfeit = false
end

--camp functions
function spawnSign()
    signOpen = false
    local signUID = spawn_entity(ENT_TYPE.ITEM_SPEEDRUN_SIGN, 46, 84, LAYER.FRONT, 0, 0)
    sign = get_entity(signUID)
    sign.flags = clr_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
    button_prompts.spawn_button_prompt_on(button_prompts.PROMPT_TYPE.INTERACT, signUID, function()
        if postMatch or matchStarted then return end
        signOpen = true
        blockInputs()
    end)
end

function blockInputs()
    set_journal_enabled(false)
    if players[1] then
        get_player(1).input = nil
    end
    blockingPause = true
end

function blockPause()
    if not blockingPause then return end
    if game_manager.pause_ui.visibility ~=0 then game_manager.pause_ui.visibility = 0 end
end

function returnInputs()
    if players[1] then
        get_player(1).input = state.player_inputs.player_slot_1
    end
    set_journal_enabled(true)
    blockingPause = false
    game_manager.pause_ui.prompt_visible = false
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

function renderTextLeft(render_ctx, str, x, y, scale, color)
    --helper function for rendering text
    render_ctx:draw_text(str,x,y,scale,scale,color, VANILLA_TEXT_ALIGNMENT.LEFT, VANILLA_FONT_STYLE.ITALIC)
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

function renderMatchInfoToast(render_ctx)
    --hard code toast location
    local x = -1.05
    local y = .45
    local scale = 2
    for xoffset = 0, 2, 1 do
        local newx = x + (xoffset*scale/10)
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_DEATHMATCH2_0, 7, 7+xoffset, y,newx,scale)
    end
    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 2, 4, y-.025, x+.05, scale-.5)
    renderText(render_ctx, "Match found - "..countdownTime(), x+.366,y+.1666,.0012,white)
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

function renderMatchFoundInfo(render_ctx)
    --hard code text location
    local textX = 0
    local textY = .05
    local textScale = .002
    renderText(render_ctx, "Match Found", textX, textY, textScale, white)
    renderText(render_ctx, ""..countdownTime(), textX, textY-.15, textScale, white)
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
    if not bridgeConnected then
        queueStateText = "Ranked App Not Found"
    end
    -- throw in render callback to sync with input polling
    if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
        buttonIndex = (buttonIndex - 1)%3
    end
    if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
        buttonIndex = (buttonIndex + 1)%3
    end
    if inputs.gamepad_button_press(inputs.GAMEPAD.A) then
        if buttonIndex == 0 and bridgeConnected then
            queueStateText = "In Queue"
            if not inQueue then 
                placeInQueue()
            end
            inQueue = true
        elseif buttonIndex == 1 then
            if queueStateText ~= "Ranked App Not Found" then
                queueStateText = "Not In Queue"
            end
            if inQueue then
                leaveQueue()
            end
            inQueue = false
        else
            signOpen = false
            returnInputs()
        end
    end
    if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) then
        buttonIndex = (buttonIndex+1)%3
    end
    if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) then
        buttonIndex = (buttonIndex-1)%3
    end
    if inputs.key_press(inputs.KEYBOARD.RETURN) then
        if buttonIndex == 0 and bridgeConnected then
            queueStateText = "In Queue"
            if not inQueue then 
                placeInQueue()
            end
            inQueue = true
        elseif buttonIndex == 1 then
            if queueStateText ~= "Ranked App Not Found" then
                queueStateText = "Not In Queue"
            end
            if inQueue then
                leaveQueue()
            end
            inQueue = false
        else
            queueStateText = "Menu Closed"
            signOpen = false
            returnInputs()
        end
    end
end

function prepBans()
    -- close all menus, bring player to camp, stop player inputs
    signOpen = false
    if game_manager.pause_ui.visibility ~=0 then game_manager.pause_ui.visibility = 0 end
    warp(1,1, THEME.BASE_CAMP)
    blockInputs()
    banTime()
    banPhase = true
end

function renderBanWindowObjects(render_ctx)
    local left = -.5
    local right = left *-1
    local top = .4


    local width = math.abs(left) + right
    local margin = width / 8
    local leftmost = left + margin
    local rightmost = right - margin
    local buttonScale = (math.abs(leftmost) + rightmost)/.6
    local y = top - .2 - (buttonScale/20)
    for num = 0, 4, 1 do
        if banButtonIndex == num then
            renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,y,leftmost+(num*((buttonScale/10)+(margin/4))),buttonScale)
        else
            renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,y,leftmost+(num*((buttonScale/10)+(margin/4))),buttonScale)
        end
        local remains = false
        for i, cat in ipairs(remainingCategories) do
            if categories[num+1] == cat then remains = true end
        end
        if not remains then renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_0, 3,3,y, leftmost+(num*((buttonScale/10)+(margin/4))),buttonScale) end
        local pieces = split_gmatch(categories[num+1]," ")
        if #pieces == 2 then
            for i, piece in ipairs(pieces) do
                renderText(render_ctx, piece, (buttonScale/20)+(leftmost+(num*((buttonScale/10)+(margin/4)))), ((top-.17)-(i*.03))*ratio,.0006,black)
            end
        elseif #pieces >= 3 then
            local string1 = ""
            local string2 = ""
            for i, piece in ipairs(pieces) do
                if i < 3 then 
                    string1 = string1..piece.." "
                else
                    string2 = string2..piece.." "
                end
            end
            renderText(render_ctx, string1, (buttonScale/20)+(leftmost+(num*((buttonScale/10)+(margin/4)))), (top-.20)*ratio,.0006,black)
            renderText(render_ctx, string2, (buttonScale/20)+(leftmost+(num*((buttonScale/10)+(margin/4)))), (top-.23)*ratio,.0006,black)
        else
            renderText(render_ctx, pieces[1], (buttonScale/20)+(leftmost+(num*((buttonScale/10)+(margin/4)))), (top-.23)*ratio,.0006,black)
        end

                
    end

    local lines = {}
    table.insert(lines, ("["..opponentelo.."] "..opponent))
    if matchStarted then
        table.insert(lines, "Match starting...")
        table.insert(lines, ""..(countdownTime()-5))
        for line = 1, 3, 1 do
            renderText(render_ctx,lines[line],0, ratio*(0-(line*.08)),.0012,black)
        end
        return
    end
    if #categories == 0 or #remainingCategories<=1 then 
        table.insert(lines,"Waiting for server...")
    elseif bansFirst then
        table.insert(lines, "Your turn to ban")
    else
        table.insert(lines, "Opponent is banning...")
    end
    table.insert(lines,(""..countdownTime()))
    for line = 1, 3, 1 do
        renderText(render_ctx,lines[line],0, ratio*(0-(line*.08)),.0012,black)
    end

end

function renderBanWindow(render_ctx)
    --hard code these for window placement
    local top = .4
    local left = -.5

    local yInc = (math.abs(top)*2)/4
    local xInc = (math.abs(left)*2)/6
    for yoffset = 0, -3, -1 do
        for xoffset = 0, 5, 1 do
            l = left + (xInc*xoffset)
            t = (top + (yInc*yoffset))*ratio
            r = left + (xInc*(xoffset+1))
            b = (top + (yInc*(yoffset-1)))*ratio
            local position = AABB:new(l,t,r,b)
            render_ctx:draw_screen_texture(TEXTURE.DATA_TEXTURES_MENU_BASIC_2,6+math.abs(yoffset),xoffset,position,white)
        end
    end
end

function banWindowInput()
    if not bansFirst then
        banButtonIndex = -1
        return
    end
    local validButtons = {}
    for num, cat in ipairs(categories) do
        local remains = false
        for i, rcat in ipairs(remainingCategories) do
            if categories[num] == rcat then remains = true end
        end
        if remains then table.insert(validButtons,num-1) end
    end
    if banButtonIndex == -1 then
        banButtonIndex = validButtons[1]
    end
    if chatting then return end
    --controller path
    local index = -1
    for ind, butind in ipairs(validButtons) do
        if butind == banButtonIndex then
            index = ind - 1
            break
        end
    end
    if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
        banButtonIndex = validButtons[((index-1)%(#validButtons))+1]
    end
    if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
        banButtonIndex = validButtons[((index+1)%(#validButtons))+1]
    end
    if inputs.gamepad_button_press(inputs.GAMEPAD.A) then
        banCategory(banButtonIndex)
    end
    if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) then
        banButtonIndex = validButtons[((index+1)%(#validButtons))+1]
    end
    if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) then
        banButtonIndex = validButtons[((index-1)%(#validButtons))+1]
    end
    if inputs.key_press(inputs.KEYBOARD.RETURN) then
        banCategory(banButtonIndex)
    end
end

function banCategory(index)
    local cat = categories[index+1]
    for i, rcat in ipairs(remainingCategories) do
        if rcat == cat then 
            ban(rcat)
            return
        end
    end

end

function banTime()
    banTimer = get_global_frame()
end

function countdownTime()
    return 10 - ((get_global_frame()-banTimer)//60)
end

function renderHandle(render_ctx)
    if signOpen then
        if preMatch then
            renderWindow(render_ctx)
            renderMatchFoundInfo(render_ctx)
        else
            renderWindow(render_ctx)
            renderWindowObjects(render_ctx)
            buttonHandle(render_ctx)
            inputHandle()
        end
    end
    if (not signOpen) and inQueue then
        renderToast(render_ctx)
    elseif not signOpen and preMatch then
        renderMatchInfoToast(render_ctx)
    end
    if banPhase then
        if state.loading == FADE.IN then
            state.fade_timer = 0
        end
        blockInputs()
        renderBanWindow(render_ctx)
        renderBanWindowObjects(render_ctx)
        banWindowInput()
    end
    renderChat(render_ctx)
    enterMessageWindow(render_ctx)
end

-- server functions

function startServer()
    server = UdpServer:new(gameAddress,gamePort)
    if not server:is_open() then
        print("UDP Server Initialization Failed: "..server:last_error_str())
        print("Try reloading the script. If error persists, relaunch!")
    end
end

function stopServer()
    if server then
        server:close()
        server = nil
    end
end



function timedOps()
    if server == nil or not server:is_open() then
        print("Game connection not available. Relaunch!")
        return 
    end
    elapsedTime = (get_global_frame()/60) - lastServerOp
    if (elapsedTime >= serverDelay) then
        lastServerOp = (get_global_frame()/60)
        if not bridgeConnected then
            -- print("not connected yet")
            ping()
        end
        --read operations
        while server:read(function(message, bridgeAddress)
            -- print("server has message")
            local data = json.decode(message)
            local event = data.event
            if event == nil then 
                log_print("no event received")
                return 
            end
            -- Heartbeat 
            if event == "ping" then
                server:send(json.encode({ event = "pong" }), bridgeAddress)
            elseif event == "pong" then
                if bridgeConnected == false then
                    queueStateText = "Not in queue"
                end
                bridgeConnected = true
            elseif event == "version_request" then
                server:send(json.encode({ event = "version_response", version = meta.version }), bridgeAddress)
            elseif event == "version_mismatch" then
                bridgeConnected = false
                print("You have an outdated mod version. Please update!")
            -- Match found
            elseif event == "is_banned" then
                inQueue = false
                queueStateText = "You are banned"
            elseif event == "paired" then
                opponent = data.opponent_name
                categories = data.categories
                remainingCategories = data.categories
                bansFirst = data.ban_order_first
                opponentelo = data.opponent_elo
                inQueue = false
                preMatch = true
                banTime()
                -- 10 second window for match found message
                set_global_timeout(function()
                    preMatch = false
                    prepBans()
                end,600)
            -- Ban Phase 
            elseif event == "ban_update" then
                remainingCategories = data.categories
                bansFirst = not bansFirst
                banTime()
            -- Match start (ack required)
            elseif event == "match_start" then 
                if not matchStarted then
                    matchStarted = true
                    categoryType = data.category
                    seed = tonumber(data.seed, 16)
                    reportCount = 0
                    banTime()
                end
                server:send(json.encode({ event = "ack", ack_event = "match_start" }), bridgeAddress)

            --Opponent progress
            elseif event == "opponent_progress" then
                opponentArea = data.theme
                if opponentArea == THEME.JUNGLE then
                    processChat(opponent.." entered Jungle.", "Match Info")
                elseif opponentArea == THEME.VOLCANA then
                    processChat(opponent.." entered Volcana.", "Match Info")
                elseif opponentArea == THEME.OLMEC then
                    processChat(opponent.." entered Olmec.", "Match Info")
                elseif opponentArea == THEME.TIDE_POOL then
                    processChat(opponent.." entered Tidepool.", "Match Info")
                elseif opponentArea == THEME.TEMPLE then
                    processChat(opponent.." entered Temple.", "Match Info")
                elseif opponentArea == THEME.ICE_CAVES then
                    processChat(opponent.." entered Ice Caves.", "Match Info")
                elseif opponentArea == THEME.NEO_BABYLON then
                    processChat(opponent.." entered Neo Babylon.", "Match Info")
                end
            
            elseif event == "receive_seed_change_request" then
                activeSeedChange = true
                processChat(opponent.." has requested a seed change.", "Match Info")
                set_global_timeout(function()
                    activeSeedChange = false
                end, 60*seedChangeWindow)

            elseif event == "receive_draw_request" then
                activeDrawVote = true
                processChat(opponent.." has requested a draw.", "Match Info")
                set_global_timeout(function()
                    activeDrawVote = false
                end, 60*drawVoteWindow)

            -- (ack required)
            elseif event == "do_seed_change" then
                if not changingSeed then
                    changingSeed = true
                    seed = tonumber(data.seed, 16)
                    warp(1,1,THEME.BASE_CAMP)
                    defaultMatchValues()
                    banTime()
                    local id = set_callback(renderSeedChange, ON.RENDER_PRE_HUD)
                    set_global_timeout(function()
                        clear_callback(id)
                    end, 360)
                end
                server:send(json.encode({ event = "ack", ack_event = "do_seed_change" }), bridgeAddress)

            -- Match result (ack required)
            elseif event == "match_result" then
                if not matchResultReceived and matchStarted then
                    matchResultReceived = true
                    result = data.result
                    eloChange = data.elo_change
                    endMatch()
                end
                server:send(json.encode({ event = "ack", ack_event = "match_result"}), bridgeAddress)

            elseif event == "match_scrapped" then
                print("This match has been scrapped! No Elo was lost.")
                defaultValues()
                warp(1,1,THEME.BASE_CAMP)
            elseif event == "postmatch_closed" then
                forceEndPostMatch()
            elseif event == "receive_chat" then
                --only show chat messages if user has them enabled
                if options.chatEnabled then
                    processChat(data.message, data.sender_name)
                end
            end 
        end) ~= -1 do end
    end
end

--udp functions

function ping()
    server:send(json.encode({ event = "ping"}), bridgeAddress)
end

function placeInQueue()
    server:send(json.encode({ event = "queue_ready"}), bridgeAddress)
end

function leaveQueue()
    if matchStarted then return end
    if not inQueue then return end
    server:send(json.encode({ event = "queue_leave"}), bridgeAddress)
    inQueue = false
    queueStateText = "Not in queue"
end

function ban(category)
    server:send(json.encode({ event = "ban", category = category}), bridgeAddress)
end

function progressUpdate(area, level, theme)
    server:send(json.encode({ event = "progress", area = area, level = level, theme = theme }), bridgeAddress)
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

function requestSeedChange()
    set_global_timeout(function()
        sentSeedChange = false
    end, 60*seedChangeWindow)
    server:send(json.encode({ event = "request_seed_change" }), bridgeAddress)
end

function requestDraw()
    set_global_timeout(function()
        sentDrawVote = false
    end, 60*drawVoteWindow)
    server:send(json.encode({ event = "request_draw" }), bridgeAddress)
end

function sendForfeit()
    server:send(json.encode({ event = "forfeit" }), bridgeAddress)
end

function closePostMatch()
    forceEndPostMatch()
    server:send(json.encode({ event = "close_postmatch" }), bridgeAddress)
end

function sendChat()
    returnInputs()
    server:send(json.encode({ event = "send_chat", message = chatMessage }), bridgeAddress)
end

--general helper functions
function split_gmatch(inputstr, sep)
    sep = sep or "%s" -- default to whitespace if no separator provided
    local t = {}
    -- Pattern matches one or more characters that are NOT the separator
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function has(arr, item)
    for _, v in pairs(arr) do
        if v == item then
            return true
        end
    end
    return false
end

--game process functions
function isShopRun()
    for i, cat in ipairs(shopCategories) do
        if (categoryType == cat) then
            return true
        end
    end
    return false
end

function getItemsForRun(category)
    local items = {}
    math.randomseed(seed)
    local packType = math.random(2)
    --need teleporter
    for i, cat in ipairs(tpCategories) do
        if category == cat then table.insert(items, tp_items[1]) end
    end
    --need mattock
    for i, cat in ipairs(mattockCategories) do
        if category == cat then table.insert(items, notp_items[1]) end
    end
    --need bomb
    for i, cat in ipairs(bombCategories) do
        if category == cat then table.insert(items, notp_items[2]) end
    end
    --hp/jp 
    for i, cat in ipairs(packCategories) do
        if category == cat then table.insert(items, pack_items[packType]) end
    end
    --jetpack
    for i, cat in ipairs(jetpackCategories) do
        if category == cat then table.insert(items, pack_items[1]) end
    end
    --telepack
    for i, cat in ipairs(telepackCategories) do
        if category == cat then table.insert(items, tp_items[2]) end
    end
    --hyperspecific
    if category == "No TP Eggplant%" then table.insert(items, notp_items[3]) end
    return items
end

function loadCategoryItems(type, x , y, layer, overlay, flags)
    if matchStarted and isShopRun() then
        if #spawnedItems>=4 then
            itemsYet = true
            end
        if itemsYet then return end
        local rx, ry = get_room_index(x,y)
        local rt = get_room_template(rx,ry,layer)
        if has(shop_rooms, rt) and layer == LAYER.FRONT then
            local ix = (math.floor(x) - 5) % 10 -- item x
            local iy = (math.floor(y+.5) - 3) % 8 -- item y
            if ix < 1 or ix > 4 or iy ~= 1 then
                return 
                end -- not a real shop item, ignore
            local item = table.remove(runItems,1)
            if (item and item ~= -1) and (not already_spawned(item)) then
                local uid = spawn_critical(item, x, y, layer, 0, 0)
                table.insert(spawnedItems, item)
                return uid
            else -- no more items to spawn, but this is already spawned
                local leftover = removeSpawned()
                local t = leftover[math.random(#leftover)]
                table.insert(spawnedItems, t)
                return spawn_critical(t, x, y, layer, 0, 0)
            end
        end
    end
end

function removeSpawned()
    local leftover = {}
    for i, item in ipairs(specialty_items) do
        local spawned = false
        for j, sitem in ipairs(spawnedItems) do
            if item == sitem then
                spawned = true
                break
            end
        end
        if not spawned then table.insert(leftover, item) end
    end
    return leftover
end

function already_spawned(type)
    if type == notp_items[2] then return false end
    local spawned = 0
    for i, item in ipairs(spawnedItems) do
        if item == type then
            return true
        end
    end
    return false
end

-- code modified from dregu's shopmod, thanks!
function forceShop(ctx)
    if (not shopYet and (state.level_count == 1 or state.level_count == 2)) then
        local shop_found = false
        for ry = 0, state.height - 1 do
            for rx = 0, state.width - 1 do
                local rt = get_room_template(rx, ry, LAYER.FRONT)
                if has(shop_rooms, rt) then
                    shop_found = true
                    shopYet = true
                    ctx:set_shop_type(rx,ry,LAYER.FRONT, SHOP_TYPE.SPECIALTY_SHOP)
                end
            end
        end
        if not shop_found then
            local spots = {}
            for ry = 0, state.height - 1 do
                for rx = 0, state.width - 1 do
                    local rt = get_room_template(rx, ry, LAYER.FRONT)
                    if has(replace_rooms, rt) then
                        local path_left = false
                        local path_right = false
                        if (rx > 0 and has(path_rooms, get_room_template(rx - 1, ry, LAYER.FRONT))) then
                            path_left = true
                        end
                        if (rx < state.width - 1 and has(path_rooms, get_room_template(rx + 1, ry, LAYER.FRONT))) then
                            path_right = true
                        end
                        if path_left and path_right then
                        elseif path_left then
                            table.insert(spots, { rx = rx, ry = ry, rt = rt, shop = ROOM_TEMPLATE.SHOP_LEFT })
                        elseif path_right then
                            table.insert(spots, { rx = rx, ry = ry, rt = rt, shop = ROOM_TEMPLATE.SHOP })
                        end
                    end
                end
            end
            if #spots > 0 then
                local spot = spots[1] -- always pick highest spot, cant do random since both players need same shop position
                ctx:set_room_template(spot.rx, spot.ry, LAYER.FRONT, spot.shop)
                ctx:set_shop_type(spot.rx,spot.ry,LAYER.FRONT, SHOP_TYPE.SPECIALTY_SHOP)
                if spot.rt == ROOM_TEMPLATE.VAULT then
                    state.quest_flags = clr_flag(state.quest_flags, 3)                           -- vault spawned in world
                    ctx:set_room_template(spot.rx, spot.ry, LAYER.BACK, 9)                       -- no backlayer
                elseif spot.rt == ROOM_TEMPLATE.PEN_ROOM then
                    state.quests.yang_state = 0                                                  -- yang has not spawned yet
                    ctx:set_room_template(spot.rx, spot.ry, LAYER.BACK, 9)                       -- no backlayer
                elseif spot.rt == ROOM_TEMPLATE.IDOL then
                    ctx:set_room_template(spot.rx, spot.ry - 1, LAYER.FRONT, ROOM_TEMPLATE.SIDE) -- clear the top part
                elseif spot.rt == ROOM_TEMPLATE.IDOL_TOP then
                    ctx:set_room_template(spot.rx, spot.ry + 1, LAYER.FRONT, ROOM_TEMPLATE.SIDE) -- clear the bottom part
                end
                state.level_flags = set_flag(state.level_flags, 17) -- shop spawned in level
                state.quest_flags = set_flag(state.quest_flags, 5)  -- shop spawned in run
                shopYet = true
            end
        end
    end
end

function forceAltar(ctx)
    if (shopYet and (not itemsYet)) then
        local altarFound = false
        for ry = 0, state.height - 1 do
            for rx = 0, state.width - 1 do
                local rt = get_room_template(rx,ry,LAYER.FRONT)
                if ROOM_TEMPLATE.ALTAR == rt then
                    altarFound = true
                end
            end
        end
        if not altarFound then
            local spots = {}
            for ry = 0, state.height - 1 do
                for rx = 0, state.width - 1 do
                    local rt = get_room_template(rx, ry, LAYER.FRONT)
                    if has(altar_replace, rt) then
                        table.insert(spots, { rx = rx, ry = ry, rt = rt, altar = ROOM_TEMPLATE.ALTAR })
                    end
                end
            end
            if #spots > 0 then
                local spot = spots[#spots]
                ctx:set_room_template(spot.rx, spot.ry, LAYER.FRONT, spot.altar)
                if spot.rt == ROOM_TEMPLATE.VAULT then
                    state.quest_flags = clr_flag(state.quest_flags, 3)                           -- vault spawned in world
                    ctx:set_room_template(spot.rx, spot.ry, LAYER.BACK, 9)                       -- no backlayer
                elseif spot.rt == ROOM_TEMPLATE.PEN_ROOM then
                    state.quests.yang_state = 0                                                  -- yang has not spawned yet
                    ctx:set_room_template(spot.rx, spot.ry, LAYER.BACK, 9)                       -- no backlayer
                elseif spot.rt == ROOM_TEMPLATE.IDOL then
                    ctx:set_room_template(spot.rx, spot.ry - 1, LAYER.FRONT, ROOM_TEMPLATE.SIDE) -- clear the top part
                elseif spot.rt == ROOM_TEMPLATE.IDOL_TOP then
                    ctx:set_room_template(spot.rx, spot.ry + 1, LAYER.FRONT, ROOM_TEMPLATE.SIDE) -- clear the bottom part
                end
            end
        end
    end
end

function categoryHelper(ctx)
    if matchStarted and isShopRun() then
        forceShop(ctx)
        if categoryType == "No TP Eggplant%" then
            forceAltar(ctx)
        end
    end
end


function determineCheckpoint()
    warpTo = {}
    loadAt = {}
    if furthestLevel[1] < 2 then 
        warpTo = {1,1}
        loadAt = {1,1}
        return
    elseif furthestLevel[1] == 2 and furthestLevel[2] == 1 then
        warpTo = {1,1}
        loadAt = {1,1}
        return
    end --nowhere to warp to, warp goes back 4 levels
    for i, lev in ipairs(levelOrder) do
        if (furthestLevel[1]==lev[1]) and (furthestLevel[2] == lev[2]) then
            table.insert(warpTo,levelOrder[i-4][1])
            table.insert(warpTo,levelOrder[i-4][2])
            table.insert(loadAt,levelOrder[i-5][1])
            table.insert(loadAt,levelOrder[i-5][2])
            return
        end
    end
    warpTo = {1,1}
    loadAt = {1,1}
end

function warpToCheckpoint()
    if not warping then return end
  -- print("warping to "..warpTo[1].."-"..warpTo[2])
  -- print("state "..state.world.."-"..state.level)
    if (state.world > warpTo[1]) or (state.world == warpTo[1] and state.level >= warpTo[2]) then
      -- print ("arrived")
        warping = false
        return
    end
    if state.loading == FADE.IN then
        state.fade_timer = 0
    end
    if state.screen == SCREEN.TRANSITION and not wasTransition then
        if state.world == loadAt[1] and state.level == loadAt[2] then
            loadProg = true
            loadProgress()
            forceNextNoSkip()
            wasTransition = true
            wasLevel = false
            return
        end
        forceNext()
        wasTransition = true
        wasLevel = false
    elseif state.screen == SCREEN.LEVEL and not wasLevel then
        forceTrans()
        wasLevel = true
        wasTransition = false
    end
end

function force11()
  -- print ("forcing 1-1")
    forceSeed()
    state.screen_last = state.screen
    state.screen_next = SCREEN.LEVEL
    state.world_start = 1
    state.theme_start = 1
    state.level_start = 1
    state.world_next = 1
    state.level_next = 1
    state.theme_next = 1
    state.level_count = 0
    state.quest_flags = set_flag(state.quest_flags, 1)
    state.loading = FADE.OUT
end

function forceTrans()
    forceSeed()
    -- print("force transition")
    --handle new world and theme
    local condition = false
    if (state.level == 4) then
        condition = true
        if state.theme == THEME.DWELLING then
            if jungle then
                state.theme_next = THEME.JUNGLE
            else
                state.theme_next = THEME.VOLCANA
            end
            state.world_next = 2
            state.level_next = 1
        elseif state.theme == THEME.JUNGLE or state.theme == THEME.VOLCANA then
            state.theme_next = THEME.OLMEC
            state.world_next = 3
            state.level_next = 1
        elseif state.theme == THEME.TIDE_POOL or state.theme == THEME.TEMPLE or state.theme == THEME.DUAT or state.theme == THEME.ABZU then
            state.theme_next = THEME.ICE_CAVES
            state.world_next = 5
            state.level_next = 1
        end
    end
    if (state.level==1 and (state.theme == THEME.OLMEC or state.theme == THEME.ICE_CAVES)) then
        condition = true
        if state.theme == THEME.OLMEC then
            if tidepool then
                state.theme_next = THEME.TIDE_POOL
            else
                state.theme_next = THEME.TEMPLE
            end
            state.world_next = 4
            state.level_next = 1
        else 
            state.theme_next = THEME.NEO_BABYLON
            state.world_next = 6
            state.level_next = 1
        end
    end
    if (categoryType == "No TP Duat%" or categoryType == "Duat%") then
        condition = true
        if (state.level == 2 and state.theme == THEME.TEMPLE) then
            state.theme_next = THEME.CITY_OF_GOLD
            state.level_next = state.level + 1
        elseif (state.level == 3 and state.theme == THEME.CITY_OF_GOLD) then
            state.theme_next = THEME.DUAT
            state.level_next = state.level + 1
        else
            state.level_next = state.level + 1
            state.theme_next = state.theme
        end
    end
    if (categoryType == "No TP Abzu%" or categoryType == "Abzu%") then
        condition = true
        if (state.level == 3 and state.theme == THEME.TIDE_POOL) then
            state.theme_next = THEME.ABZU
            state.level_next = state.level + 1
        else
            state.level_next = state.level + 1
            state.theme_next = state.theme
        end
    end
    if (state.level == 3 and state.theme == THEME.NEO_BABYLON) then
        condition = true 
        state.theme_next = THEME.TIAMAT
        state.level_next = state.level + 1
    end
    if not condition then
        -- print("default")
        state.level_next = state.level + 1
        state.theme_next = state.theme
    end
    -- print("trans info pre "..state.level_count.." : "..state.world.."-"..state.level)
    state.level_count = state.level_count + 1
    state.screen_last = state.screen
    state.screen_next = SCREEN.TRANSITION
    state.loading = FADE.OUT
    state.fade_timer = 0
  -- print("trans info post "..state.level_count.." : "..state.world.."-"..state.level)
end

function forceNext()
  -- print ("force next")
    forceSeed()
  -- print("next info pre "..state.level_count.." : "..state.world.."-"..state.level)
    state.screen_next = SCREEN.LEVEL
    state.screen_last = state.screen
    state.loading = FADE.OUT
    state.fade_timer = 0
  -- print("next info post "..state.level_count.." : "..state.world.."-"..state.level)
end

function forceNextNoSkip()
  -- print("force next no skip")
    forceSeed()
    state.screen_next = SCREEN.LEVEL
    state.screen_last = state.screen
    state.loading = FADE.OUT
end

function saveProgress()
    for index, save in ipairs(currentSaves) do
        if (index == (state.level_count+1)) then
            return
        end
    end
    local powerups = {}
    local companions = {}
    local companion_held_items = {}
    local companion_held_item_metadatas = {}
    local companion_trust = {}
    local companion_health = {}
    local companion_poison_tick_timers = {}
    local is_companion_cursed = {}
    for i, powerup in ipairs(state.items.player_inventory[1].acquired_powerups) do
        table.insert(powerups, powerup)
    end
    for i, companion in ipairs(state.items.player_inventory[1].companions) do
        table.insert(companions, companion)
    end
    for i, companion in ipairs(state.items.player_inventory[1].companion_held_items) do
        table.insert(companion_held_items,companion)
    end
    for i, companion in ipairs(state.items.player_inventory[1].companion_held_item_metadatas) do
        table.insert(companion_held_item_metadatas,companion)
    end
    for i, companion in ipairs(state.items.player_inventory[1].companion_trust) do
        table.insert(companion_trust,companion)
    end
    for i, companion in ipairs(state.items.player_inventory[1].companion_health) do
        table.insert(companion_health,companion)
    end
    for i, companion in ipairs(state.items.player_inventory[1].companion_poison_tick_timers) do
        table.insert(companion_poison_tick_timers,companion)
    end
    for i, companion in ipairs(state.items.player_inventory[1].is_companion_cursed) do
        table.insert(is_companion_cursed, companion)
    end
    local inventory = {
        money = state.items.player_inventory[1].money,
        bombs = state.items.player_inventory[1].bombs,
        ropes = state.items.player_inventory[1].ropes,
        poison = state.items.player_inventory[1].poison_tick_timer,
        cursed = state.items.player_inventory[1].cursed,
        elixir = state.items.player_inventory[1].elixir_buff,
        health = state.items.player_inventory[1].health,
        kapala = state.items.player_inventory[1].kapala_blood_amount,
        held = state.items.player_inventory[1].held_item,
        heldData = state.items.player_inventory[1].held_item_metadata,
        mount = state.items.player_inventory[1].mount_type,
        mountData = state.items.player_inventory[1].mount_metadata,
        kills = state.items.player_inventory[1].kills_total,
        moneyCollected = state.items.player_inventory[1].collected_money_total,
        powerups = powerups,
    }
    local companionInfo = {   
        count = state.items.player_inventory[1].companion_count,
        companion = companions,
        items = companion_held_items,
        itemData = companion_held_item_metadatas,
        trust = companion_trust,
        health = companion_health,
        poison = companion_poison_tick_timers,
        cursed = is_companion_cursed,
    }
    local saveInfo = {
        level = state.level,
        world = state.world,
        aggro = state.shoppie_aggro,
        tAggro = state.merchant_aggro,
        time = state.time_total,
        timeLast = state.time_last_level,
        favor = state.kali_favor,
        altars = state.kali_altars_destroyed,
        gifts = state.kali_gifts,
        status = state.kali_status,
        quests = state.quests,
        inventory = inventory,
        companionInfo = companionInfo,
    }
    if categoryType == "Low% J/T" then
        jungle = true
    elseif saveInfo.world == 2 then
        if state.theme == THEME.JUNGLE then
            jungle = true
        else
            jungle = false
        end
    end
    if categoryType == "Abzu%" or categoryType == "No TP Abzu%" then
        tidepool = true
    elseif categoryType == "Duat%" or categoryType == "No TP Duat%" then
        tidepool = false
    elseif saveInfo.world == 4 then
        if state.theme == THEME.TIDE_POOL then
            tidepool = true
        else 
            tidepool = false
        end
    end
    table.insert(currentSaves, saveInfo)
end

function loadProgress()
    if not loadProg then return end
    local save = currentSaves[state.level_count+2]
    if (save.aggro + 1) ~= 1 then
        state.shoppie_aggro_next = save.aggro + 1
    end
    
    state.merchant_aggro = save.tAggro
    state.time_last_level = save.timeLast
    state.kali_favor = save.favor
    state.kali_altars_destroyed = save.altars
    state.kali_gifts = save.gifts
    state.kali_status = save.status
    state.quests = save.quests

    loadProg = false
    loadItems = true
end

function loadInventory()
    if not loadItems then return end
    loadItems = false
    local save = currentSaves[state.level_count+1]
    local inventory = save.inventory
    local companionInfo = save.companionInfo
    state.items.player_inventory[1].money = inventory.money
    state.items.player_inventory[1].bombs = inventory.bombs
    state.items.player_inventory[1].ropes = inventory.ropes
    state.items.player_inventory[1].poison_tick_timer = inventory.poison
    state.items.player_inventory[1].cursed = inventory.cursed
    state.items.player_inventory[1].elixir_buff = inventory.elixir
    state.items.player_inventory[1].health = inventory.health
    state.items.player_inventory[1].kills_total = inventory.kills
    state.items.player_inventory[1].kapala_blood_amount = inventory.kapala
    state.items.player_inventory[1].companion_count = companionInfo.count
    state.items.player_inventory[1].collected_money_total = inventory.moneyCollected

    --companions
    for i = 1, companionInfo.count do
        state.items.player_inventory[1].companions[i] = companionInfo.companion[i]
        state.items.player_inventory[1].companion_held_items[i] = companionInfo.items[i]
        state.items.player_inventory[1].companion_held_item_metadatas[i] = companionInfo.itemData[i]
        state.items.player_inventory[1].companion_trust[i] = companionInfo.trust[i]
        state.items.player_inventory[1].companion_health[i] = companionInfo.health[i]
        state.items.player_inventory[1].companion_poison_tick_timers[i] = companionInfo.poison[i]
        state.items.player_inventory[1].is_companion_cursed[i] = companionInfo.cursed[i]
    end
    loadEnts = true
    
end

function loadEntities()
    if not loadEnts then return end
    loadEnts = false
    local save = currentSaves[state.level_count+1]
    local inventory = save.inventory
    local player = players[1]

    --powerups
    for i, powerup in ipairs(inventory.powerups) do
        if powerup ~= 0 then
            if powerup == ENT_TYPE.ITEM_JETPACK or powerup == ENT_TYPE.ITEM_HOVERPACK or powerup == ENT_TYPE.ITEM_POWERPACK or powerup == ENT_TYPE.ITEM_TELEPORTER_BACKPACK or powerup == ENT_TYPE.ITEM_CAPE or powerup == ENT_TYPE.ITEM_VLADS_CAPE then
                pick_up(player.uid, spawn(powerup, 0, 0, LAYER.PLAYER, 0, 0))
            else
                player:give_powerup(powerup)
            end
        end
    end

    --held item
    if inventory.held ~= 0 then
        heldItem = spawn(inventory.held, 0,0, LAYER.PLAYER,0,0)
        get_entity(heldItem):apply_metadata(inventory.heldData)
        pick_up(player.uid, heldItem)
    end
    

    --mount
    if inventory.mount ~= 0 then
        mount = spawn(inventory.mount, 0,0, LAYER.PLAYER,0,0)
        get_entity(mount):apply_metadata(inventory.mountData)
        carry(mount,player.uid)
    end
    
end

function newFurthest()
    if not matchStarted then return end
    if state.world > furthestLevel[1] then
        furthestLevel[1] = state.world
        furthestLevel[2] = state.level
    elseif state.world == furthestLevel[1] then
        if state.level >= furthestLevel[2] then
            furthestLevel[2] = state.level
        end
    end
end

function doWarp()
    determineCheckpoint()
    if warpTo[1] < 3 then
        hadAnkhThisRun = false
    end
    if (warpTo[1] < 4) or (warpTo[1] == 4 and warpTo[2]<2) then
        hadExcaliburThisRun = false
    end
    if (warpTo[1] < 4) then
        hadScepterThisRun = false
    end
    wasLevel = false
    wasTransition = true
    warping = true
end

function forceSeed()
    if not matchStarted then return end
    set_adventure_seed(seed,seed)
end


-- handles for game functions
function preGenHandle()
    if matchStarted then
        loadInventory()
        saveProgress()
        postLevelRequirements()
    end
end

function transitionHandle()
    if matchStarted then
        loadProgress()
        if violate then
            force11()
            violate = false
        end
    end
end

function levelHandle()
    if matchStarted then
        if doReset then
            doWarp()
            doReset = false
        end
        if violate then
            force11()
            violate = false
        end
        loadEntities()
        newFurthest()
        forceSeed()
        progressUpdate(state.world,state.level,state.theme)
    end
end

function gameframeHandle()
    if matchStarted then
        inLevelRequirements()
        doorManager()
    end
end

function guiframeHandle()
    if not matchStarted then
        blockPause()
    end
    if matchStarted then
        if banPhase then
            blockInputs()
            if (countdownTime()-5)<=0 then
                returnInputs()
                hardReset()
            end
        end
        if changingSeed then
            blockInputs()
            if (countdownTime()-4)<0 then
                returnInputs()
                hardReset()
            end
        end
        testWin()
        warpToCheckpoint()
    end
    chatInputHandle()
end

function categoryViolation()
    violate = true
  -- print("you violated the category rules")
end

function resetHandle()
    if matchStarted then
        doReset = true
        forceSeed()
        shopYet = false
        spawnedItems = {}
        itemsYet = false
        violate = false
        runItems = getItemsForRun(categoryType)
        --dont report on first reset of the run (match start)
        if reportCount > 0 then
            deathReport()
        end
        reportCount = reportCount + 1
    end
end

function inLevelRequirements() --checks for category violations and requirements that happen mid-level
    if not matchStarted then return end
    if warping then return end
    if state.screen ~= SCREEN.LEVEL then return end
    if not players then return end
    if not players[1] then return end
    if state.items.players[1].health == 0 then return end
    local violated = false
    --violations
    --low%
    if categoryType == "Low%" or categoryType == "Low% J/T" or categoryType == "No Gold Low%" then
        --shield, backitems
        local items = entity_get_items_by(players[1].uid,lowHoldViolationItems,0)
        if #items > 0 then
            violated = true
            log_print("low hold violation")
        end
        --other powerups
        items = entity_get_items_by(players[1].uid, 0, MASK.LOGICAL)
        if #items > 0 then
            for i, item in ipairs(items) do
                local inList = false
                for j, exempt in ipairs(exemptTypes) do
                    if get_entity_type(item) == exempt then
                        inList = true
                    end
                end
                if not inList then violated = true end
                log_print("logical violation")
            end
        end
        --resource increases - adjust later to check previous frame for smaller value than current frame
        if state.items.player_inventory[1].bombs > 4 or state.items.player_inventory[1].ropes > 4 or state.items.players[1].health> 4 then
            violated = true
        end
        --mounts
        items = get_entities_by_type(ENT_TYPE.MOUNT_TURKEY, ENT_TYPE.MOUNT_ROCKDOG, ENT_TYPE.MOUNT_AXOLOTL, ENT_TYPE.MOUNT_MECH, ENT_TYPE.MOUNT_QILIN)
        for i = 1, #items do 
            if get_entity(items[i]).rider_uid == players[1].uid then
                if get_entity(items[i]).tamed then
                    violated = true
                    log_print("mount violation")
                end
            end
        end
        --using restricted item
        items = entity_get_items_by(players[1].uid, lowUseViolationItems, 0)
        for i, item in ipairs(items) do
            if test_flag(read_input(players[1].uid),2) and not test_flag(read_input(players[1].uid),12) then
                violated = true
                log_print("item used violation")
            end
        end
    end
    --teleport violation
    if categoryType == "Low%" or categoryType == "Low% J/T" or categoryType == "No Gold Low%" or categoryType == "No TP Any%" or categoryType == "No TP Sunken City%" or categoryType == "No TP Eggplant%" or categoryType == "No TP Duat%" or categoryType == "No TP Abzu%" then
        local items = entity_get_items_by(players[1].uid, tpItems, 0)
        for i, item in ipairs(items) do
            if get_entity_type(item) == ENT_TYPE.ITEM_TELEPORTER then
                if test_flag(read_input(players[1].uid),2) and not test_flag(read_input(players[1].uid),12) then
                    violated = true
                    log_print("teleport violation")
                end
            end
            --unsure how to implement telepack check at present (need to verify player is not grounded)
            -- if get_entity_type(item) == ENT_TYPE.ITEM_TELEPORTER_BACKPACK then
            --     if test_flag(read_input(players[1].uid),1) and 
        end
    end
    -- no gold
    if categoryType == "No Gold Low%" then
        if players[1].inventory.money > 0 then
            violated = true
            log_print("no gold violation")
        end
    end
    --chain mid-level requirements
    if (categoryType == "Abzu%" or categoryType == "Duat%" or categoryType == "No TP Abzu%" or categoryType == "No TP Duat%") then
        local items = entity_get_items_by(players[1].uid, chainTouchItems, 0)
        for i, item in ipairs(items) do
            if get_entity_type(item) == chainTouchItems[1] then
                hadExcaliburThisRun = true
            elseif get_entity_type(item) == chainTouchItems[2] then
                hadScepterThisRun = true
            elseif get_entity_type(item) == chainTouchItems[3] then
                hadAnkhThisRun = true
            end
        end
    end
    if violated then categoryViolation() end
end

function postLevelRequirements() --checks for category violations and requirements that happen post-level
    if not matchStarted then return end
    if warping then return end
    local violated = false
    --pet violations in low
    local inventory = state.items.player_inventory[1]
    local petcount = state.saved_dogs + state.saved_cats + state.saved_hamsters
    if (categoryType == "Low%" or categoryType == "Low% J/T" or categoryType == "No Gold Low%") then
        if petcount > 0 and not (inventory.cursed) then
            violated = true
            log_print("pet violation")
        end
    end
    --global chain requirements
    if (categoryType == "Abzu%" or categoryType == "Duat%" or categoryType == "No TP Abzu%" or categoryType == "No TP Duat%") then
        --crown/tablet
        local hasCrown = false
        local hasTablet = false
        for i, ent in ipairs(inventory.acquired_powerups) do
            if ent == ENT_TYPE.ITEM_POWERUP_CROWN or ent == ENT_TYPE.ITEM_POWERUP_HEDJET then
                hasCrown = true
            end
            if ent == ENT_TYPE.ITEM_POWERUP_TABLETOFDESTINY then
                hasTablet = true
            end
        end
        if (test_flag(state.presence_flags,2) or test_flag(state.presence_flags,3)) and not (hasCrown) then
            violated = true
            log_print("no crown violation")
        end
        if (state.world>=5 and not hasTablet) then 
            violated = true
            log_print("no tablet violation")
        end
        --level based
        if state.screen == SCREEN.TRANSITION then
            -- ankh check
            if (state.world == 3 and state.level == 1 and not hadAnkhThisRun) then
                violated = true
                log_print("no crown violation")
            end
            --correct ushabti check
            if (state.world == 6 and state.level == 2 and (inventory.held_item ~= ENT_TYPE.ITEM_USHABTI or inventory.held_item_metadata~=state:get_correct_ushabti())) then
                violated = true
                log_print("no/wrong ushabti violation")
            end
        end
    end
    --specific chain requirements
    if (categoryType=="Abzu%" or categoryType == "No TP Abzu%") then
        --level based
        if state.screen == SCREEN.TRANSITION then
            if (state.world == 3 and state.level == 1 and state.theme_next ~= THEME.TIDE_POOL) then
                violated = true
                log_print("no tidepool violation")
            end
            --had excal
            if (state.world == 4 and state.level == 2 and not hadExcaliburThisRun) then
                violated = true
                log_print("no excalibur violation")
            end
            --going to abzu
            if (state.world==4 and state.level == 3 and state.theme_next ~= THEME.ABZU) then
                violated = true
                log_print("no abzu violation")
            end
        end
    end
    if (categoryType == "Duat%" or categoryType == "No TP Duat%") then
        --level based
        if state.screen == SCREEN.TRANSITION then
            if (state.world == 3 and state.level == 1 and state.theme_next ~= THEME.TEMPLE) then
                violated = true
                log_print("no duat violation")
            end
            --had scepter
            if ((state.world == 4 and state.level == 1) and not hadScepterThisRun) then
                violated = true
                log_print("no scepter violation")
            end
            if (state.world == 4 and state.level == 2 and state.theme_next ~= THEME.CITY_OF_GOLD) then
                violated = true
                log_print("no city of gold violation")
            end
            --going to duat
            if (state.world==4 and state.level == 3 and state.theme_next ~= THEME.DUAT) then
                violated = true
                log_print("no duat violation")
            end
        end
    end
    --j/t area requirements
    if (categoryType == "Low% J/T") then
        if state.screen == SCREEN.TRANSITION then
            --going temple
            if (state.world == 3 and state.level == 1 and state.theme_next ~= THEME.TEMPLE) then
                violated = true
                print("shouldve gone temple violation")
            end
            --going jungle
            if ((state.world == 1 and state.level == 4) and state.theme_next ~= THEME.JUNGLE) then
                violated = true
                print("shouldve gone jungle violation")
            end
        end
    end
    --eggplant child found
    if (categoryType == "No TP Eggplant%") then
        if state.screen == SCREEN.TRANSITION then
            if state.world >= 5 and state.world < 7 then
                local ents = inventory.companions
                local child = false
                for i, ent in ipairs(ents) do
                    if ent == ENT_TYPE.CHAR_EGGPLANT_CHILD then
                        child = true
                    end
                end
                if not child then
                    violated = true
                    log_print("no child violation")
                end
            end
        end
    end
    if violated then categoryViolation() end
end

function doorManager()
    --hundun wins block tiamat
    if (categoryType == "Sunken City%" or categoryType == "No TP Sunken City%" or categoryType == "Abzu%" or categoryType == "No TP Abzu" or categoryType == "Duat%" or categoryType == "No TP Duat%" or categoryType == "No TP Eggplant%") then
        if state.theme == THEME.TIAMAT then
            local ents = get_entities_by_type(ENT_TYPE.FLOOR_DOOR_EXIT)
            for i, ent in ipairs(ents) do
                get_entity(ent):unlock(false)
            end
        end
    end
    --eggplant blocks 7-1 main exit
    if categoryType == "No TP Eggplant%" then
        if state.world == 7 and state.level == 1 then
            local ents = get_entities_by_type(ENT_TYPE.FLOOR_DOOR_EXIT)
            for i, ent in ipairs(ents) do
                get_entity(ent):unlock(false)
            end
        end
    end
    --no need for cog/abzu/duat because they are handled by theme requirements
end

function hardReset()
    --first reset of run (starting match)
    if not banPhase then
        restartReport()
    else
        banPhase = false
        returnInputs()
    end
    changingSeed = false
    hadAnkhThisRun = false
    hadExcaliburThisRun = false
    hadScepterThisRun = false
    currentSaves = {}
    furthestLevel = {1,1}
    force11()
end

function testWin()
    if matchStarted and state.screen == SCREEN.WIN then
        completionReport()
    end
end

function renderSeedChange(render_ctx)
    local left = -.4
    local top = math.abs(left)/3

    local xInc = (math.abs(left)*2)/3

    xInc = xInc * 1
    for xoffset = 0, 2, 1 do
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_BASIC_2,0,5+xoffset,top,left+(xInc*xoffset),xInc*10)
    end
    local lines = {}
    table.insert(lines, "Seed Change Accepted")
    table.insert(lines, "Starting in "..(countdownTime()-4))
    for i, line in ipairs(lines) do
        renderText(render_ctx, line, 0, ratio*(.11-(i*.08)),(.002)-(i*.0005),white)
    end
end


--game render functions

function renderPauseHandle(render_ctx)
    if (matchStarted) then
        if not(game_manager.pause_ui.visibility == 0 or game_manager.pause_ui.visibility == nil or game_manager.pause_ui.visibility == 3) and not changingSeed then
            renderVoteMenu(render_ctx)
            renderVoteButtons(render_ctx)
            voteButtonHandle()
            renderMouse(render_ctx)
        end
    end
end

function renderVoteMenu(render_ctx)
    local top = .38
    local left = .45

    local yInc = (math.abs(top)*2)/3
    local xInc = (math.abs(left)*2)/3

    yInc = yInc * 1
    xInc = xInc * .6
    for yoffset = 0, -2, -1 do
        for xoffset = 0, 2, 1 do
            l = left + (xInc*xoffset)
            t = (top + (yInc*yoffset))*ratio
            r = left + (xInc*(xoffset+1))
            b = (top + (yInc*(yoffset-1)))*ratio
            local position = AABB:new(l,t,r,b)
            render_ctx:draw_screen_texture(TEXTURE.DATA_TEXTURES_MENU_BASIC_2,1+math.abs(yoffset),5+xoffset,position,white)
        end
    end
    renderText(render_ctx,"(use your mouse!)", .72,-.3*ratio,.0006,white)
end

function renderVoteButtons(render_ctx)
    --hard coded button locations
    local seedButtonScale = 1.2

    local resetButtonScale = seedButtonScale
    local resetButtonX = .51
    local resetButtonY = .29

    local seedButtonX = .51
    local seedButtonY = resetButtonY-(seedButtonScale/10)-.02
    
    local drawButtonScale = seedButtonScale
    local drawButtonX = .51
    local drawButtonY = seedButtonY-(seedButtonScale/10)-.02
    
    local forfeitButtonScale = seedButtonScale
    local forfeitButtonX = .51
    local forfeitButtonY = drawButtonY-(seedButtonScale/10)-.02

    

    local textX = .45*ratio
    local textScale = .0008


    if buttonHovering == 0 then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,resetButtonY,resetButtonX,resetButtonScale)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,resetButtonY,resetButtonX,resetButtonScale)
    end
    renderText(render_ctx,"Reset Seed", textX, (resetButtonY-(seedButtonScale/20))*ratio, textScale, white)
    renderText(render_ctx,"This will reset your checkpoints!",textX,((resetButtonY-(seedButtonScale/20))-.04)*ratio, .0005, white)

    local seedText = "Request Seed Change"
    if activeSeedChange and not sentSeedChange then
        seedText = "Accept Seed Change"
    elseif activeSeedChange and sentSeedChange then
        seedText = "Seed Change Sent"
    end
    if buttonHovering == 1 and not sentSeedChange then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,seedButtonY,seedButtonX,seedButtonScale)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,seedButtonY,seedButtonX,seedButtonScale)
    end
    renderText(render_ctx,seedText, textX, (seedButtonY-(seedButtonScale/20))*ratio, textScale, white)

    local drawText = "Request A Draw"
    if activeDrawVote and not sentDrawVote then
        drawText = "Accept Draw"
    elseif activeDrawVote and sentDrawVote then
        drawText = "Draw Request Sent"
    end
    if buttonHovering == 2 and not sentDrawVote then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,8,drawButtonY,drawButtonX,drawButtonScale)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,5,8,drawButtonY,drawButtonX,drawButtonScale)
    end
    renderText(render_ctx,drawText, textX, (drawButtonY-(seedButtonScale/20))*ratio, textScale, white)

    local forfeitText = "Forfeit"
    if sentForfeit then 
        forfeitText = "Forfeiting..."
    end
    if buttonHovering == 3 then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,8,forfeitButtonY,forfeitButtonX,forfeitButtonScale)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,5,8,forfeitButtonY,forfeitButtonX,forfeitButtonScale)
    end
    renderText(render_ctx,forfeitText, textX, (forfeitButtonY-(seedButtonScale/20))*ratio, textScale, white)
end

function renderMouse(render_ctx)
    local mousePos = inputs.mousepos()
    local scale = .5
    local x = mousePos.x-(scale/25)
    local y = mousePos.y+(scale/10)
    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 1, 6, y/ratio, x, scale)
end

function voteButtonHandle()
    local mousePos = inputs.mousepos()
    if (mousePos.x>=.51 and mousePos.x<=.62) then
        if (mousePos.y<=.29*ratio and mousePos.y>=.17*ratio) then buttonHovering = 0
        elseif (mousePos.y<=.15*ratio and mousePos.y>=.03*ratio) then buttonHovering = 1
        elseif (mousePos.y<=.01*ratio and mousePos.y>=-.13*ratio) then buttonHovering = 2
        elseif (mousePos.y<=-.15*ratio and mousePos.y>=-.27*ratio) then buttonHovering = 3
        else buttonHovering = -1
        end
    else buttonHovering = -1
    end

    if (inputs.leftrelease()) then
        if (buttonHovering == 0) then
            hardReset()
        elseif (buttonHovering==1 and not sentSeedChange) then 
            sentSeedChange = true
            requestSeedChange()
        elseif (buttonHovering == 2 and not sentDrawVote) then
            sentDrawVote = true
            requestDraw()
        elseif (buttonHovering == 3 and not sentForfeit) then
            sentForfeit = true
            sendForfeit()
        end
    end
end

function endMatch()
    warp(1,1,THEME.BASE_CAMP)
    currentSaves = {}
    furthestLevel = {1,1}
    matchStarted = false
    matchResultReceived = false
    postMatch = true
    startPostMatch()
    local id = set_callback(renderResults, ON.RENDER_PRE_HUD)
    set_global_timeout(function()
        clear_callback(id)
    end, 300)
    table.insert(callbackList, id)
end

function startPostMatch()
    banTime() --get proper time value
    --set callbacks to clear after 20 seconds
    local id = set_callback(postMatchTime, ON.RENDER_PRE_HUD)
    table.insert(callbackList, id)
    local id2 = set_global_timeout(function()
        clear_callback(id)
        forceEndPostMatch()
    end, postMatchDuration*60)
    table.insert(callbackList, id2)
    if not options.chatEnabled then
        print("No chat enabled, closing connection after results")
        id = set_global_timeout(function()
            closePostMatch()
        end, 300)
        table.insert(callbackList,id)
    end
end

function forceEndPostMatch()
    for i, id in ipairs(callbackList) do
        clear_callback(id)
    end
    postMatch = false
    defaultValues()
end

function postMatchTime(render_ctx)
    --hard code toast location
    local x = -1.05
    local y = .45
    local scale = 2
    for xoffset = 0, 2, 1 do
        local newx = x + (xoffset*scale/10)
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_DEATHMATCH2_0, 7, 7+xoffset, y,newx,scale)
    end
    renderText(render_ctx, "Connection closes in "..(countdownTime()+10), x+.3,y+.21,.001,white)
    renderText(render_ctx, "Send \"/end\" to close early", x+.3,y+.12,.0008,white)
end

function renderResults(render_ctx)
    local left = -.4
    local top = math.abs(left)/3

    local xInc = (math.abs(left)*2)/3

    xInc = xInc * 1
    for xoffset = 0, 2, 1 do
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_BASIC_2,0,5+xoffset,top,left+(xInc*xoffset),xInc*10)
    end
    local lines = {}
    if result == "loss" then
        table.insert(lines, "Defeat")
        table.insert(lines, opponent.." won the match!")
        table.insert(lines, "Lost "..math.abs(eloChange).." elo")
    elseif result == "win" then
        table.insert(lines, "Victory")
        table.insert(lines, "You won the match!")
        table.insert(lines, "Gained "..eloChange.." elo!")
    elseif result == "draw" then
        table.insert(lines, "Draw")
        table.insert(lines, "No elo change")
    else 
        table.insert(lines, "error")
        table.insert(lines, "error")
    end
    for i, line in ipairs(lines) do
        renderText(render_ctx, line, 0, ratio*(.12-(i*.08)),(.003)-(i*.001),white)
    end
end

--chat popups, some form of message queue
function renderChat(render_ctx)
    local heightIndex = 0
    for i = 1, #messageList do
        if messageList[i][2] >= 0 then
            renderTextLeft(render_ctx, messageList[i][3]..": "..messageList[i][1],-.98,(-.3+(heightIndex*.03))*ratio,.0006, white)
            heightIndex = heightIndex + 1
        end
    end
end

function expireChats()
    for i = 1, #messageList do
        if messageList[i][2] >= 0 then
            messageList[i][2] = messageList[i][2] - 1
        end
    end
end

function processChat(message, sender)
    local list = {}
    local duration = options.chatMessageDuration*60
    local mes = {message, duration, sender}
    table.insert(list, mes)
    for i = 1, #messageList do
        if i == options.chatMessageLimit then
            break
        else
            table.insert(list, messageList[i])
        end
    end
    messageList = list
end

function addToMessage(char)
    if #chatMessage >= 50 then
        return
    elseif inputs.shift_down() then
        if char == "1" then
            char = "!"
            chatMessage = chatMessage..char
        elseif char == "/" then
            char = "?"
            chatMessage = chatMessage..char
        else
            chatMessage = chatMessage..string.upper(char)
        end
    else
        chatMessage = chatMessage..char
    end
end

function isCommand()
    if chatMessage == "/end" then
        return true
    end
end

function doCommand(command)
    returnInputs()
    if command == "/end" and postMatch then
        forceEndPostMatch()
        closePostMatch()
    end
end

function chatInputHandle()
    if not (matchStarted or banPhase or postMatch) then
        if chatting then
            returnInputs()
            chatting = false
            chatMessage = ""
        end
        return
    end
    --chat window already open
    if chatting then 
        blockInputs()
        if inputs.key_press(inputs.KEYBOARD.RETURN) then
            if isCommand() then
                doCommand(chatMessage)
                chatting = false
                chatMessage = ""
                return
            end
            processChat(chatMessage, "You")
            sendChat()
            chatMessage = ""
            chatting = false
        end
        if inputs.key_press(inputs.KEYBOARD.ESC) then
            chatting = false
            chatMessage = ""
        end
        if inputs.key_press(inputs.KEYBOARD.BACKSPACE) then
            chatMessage = string.sub(chatMessage, 1, -2)
        end
        if inputs.key_press(inputs.KEYBOARD.SPACE) then
            addToMessage(" ")
        end
        if inputs.key_press(inputs.KEYBOARD.A) then
            addToMessage("a")
        end
        if inputs.key_press(inputs.KEYBOARD.B) then
            addToMessage("b")
        end
        if inputs.key_press(inputs.KEYBOARD.C) then
            addToMessage("c")
        end
        if inputs.key_press(inputs.KEYBOARD.D) then
            addToMessage("d")
        end
        if inputs.key_press(inputs.KEYBOARD.E) then
            addToMessage("e")
        end
        if inputs.key_press(inputs.KEYBOARD.F) then
            addToMessage("f")
        end
        if inputs.key_press(inputs.KEYBOARD.G) then
            addToMessage("g")
        end
        if inputs.key_press(inputs.KEYBOARD.H) then
            addToMessage("h")
        end
        if inputs.key_press(inputs.KEYBOARD.I) then
            addToMessage("i")
        end
        if inputs.key_press(inputs.KEYBOARD.J) then
            addToMessage("j")
        end
        if inputs.key_press(inputs.KEYBOARD.K) then
            addToMessage("k")
        end
        if inputs.key_press(inputs.KEYBOARD.L) then
            addToMessage("l")
        end
        if inputs.key_press(inputs.KEYBOARD.M) then
            addToMessage("m")
        end
        if inputs.key_press(inputs.KEYBOARD.N) then
            addToMessage("n")
        end
        if inputs.key_press(inputs.KEYBOARD.O) then
            addToMessage("o")
        end
        if inputs.key_press(inputs.KEYBOARD.P) then
            addToMessage("p")
        end
        if inputs.key_press(inputs.KEYBOARD.Q) then
            addToMessage("q")
        end
        if inputs.key_press(inputs.KEYBOARD.R) then
            addToMessage("r")
        end
        if inputs.key_press(inputs.KEYBOARD.S) then
            addToMessage("s")
        end
        if inputs.key_press(inputs.KEYBOARD.T) then
            addToMessage("t")
        end
        if inputs.key_press(inputs.KEYBOARD.U) then
            addToMessage("u")
        end
        if inputs.key_press(inputs.KEYBOARD.V) then
            addToMessage("v")
        end
        if inputs.key_press(inputs.KEYBOARD.W) then
            addToMessage("w")
        end
        if inputs.key_press(inputs.KEYBOARD.X) then
            addToMessage("x")
        end
        if inputs.key_press(inputs.KEYBOARD.Y) then
            addToMessage("y")
        end
        if inputs.key_press(inputs.KEYBOARD.Z) then
            addToMessage("z")
        end
        if inputs.key_press(inputs.KEYBOARD.NUM_0) then
            addToMessage("0")
        end
        if inputs.key_press(inputs.KEYBOARD.NUM_1) then
            addToMessage("1")
        end
        if inputs.key_press(inputs.KEYBOARD.NUM_2) then
            addToMessage("2")
        end
        if inputs.key_press(inputs.KEYBOARD.NUM_3) then
            addToMessage("3")
        end
        if inputs.key_press(inputs.KEYBOARD.NUM_4) then
            addToMessage("4")
        end
        if inputs.key_press(inputs.KEYBOARD.NUM_5) then
            addToMessage("5")
        end
        if inputs.key_press(inputs.KEYBOARD.NUM_6) then
            addToMessage("6")
        end
        if inputs.key_press(inputs.KEYBOARD.NUM_7) then
            addToMessage("7")
        end
        if inputs.key_press(inputs.KEYBOARD.NUM_8) then
            addToMessage("8")
        end
        if inputs.key_press(inputs.KEYBOARD.NUM_9) then
            addToMessage("9")
        end
        if inputs.key_press(inputs.KEYBOARD.COMMA) then
            addToMessage(",")
        end
        if inputs.key_press(inputs.KEYBOARD.PERIOD) then
            addToMessage(".")
        end
        if inputs.key_press(inputs.KEYBOARD.FORWARD_SLASH) then
            addToMessage("/")
        end
        if inputs.key_press(inputs.KEYBOARD.QUOTE) then
            addToMessage('"')
        end
    else
        if inputs.key_press(inputs.KEYBOARD.FORWARD_SLASH) then
            chatting = true
            chatMessage = ""
        end
    end
end

function enterMessageWindow(render_ctx)
    if chatting then
        for i = 0, 3, 1 do
            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_BASIC_2, 5, 3+i, -.28,-.5+(.25*i),2.5)
        end
        if chatMessage == ""  then
            renderText(render_ctx, "[type your message]", 0,-.4*ratio,.0008, white)
        else
            renderText(render_ctx, chatMessage, 0,-.4*ratio,.0008, white)
        end
    end
end

function closeConnection()
    leaveQueue()
    if postMatch then
        closePostMatch()
    end
end



--camp callbacks
set_callback(renderHandle, ON.RENDER_PRE_HUD)
set_callback(spawnSign, ON.CAMP)


--in game callbacks
set_callback(forceSeed, ON.PRE_LOAD_SCREEN)
set_callback(gameframeHandle, ON.GAMEFRAME)
set_callback(renderPauseHandle, ON.RENDER_POST_PAUSE_MENU)
set_callback(categoryHelper, ON.POST_ROOM_GENERATION)
set_callback(preGenHandle, ON.PRE_LEVEL_GENERATION)
set_callback(transitionHandle, ON.TRANSITION)
set_callback(levelHandle, ON.LEVEL)
set_callback(guiframeHandle, ON.GUIFRAME)
set_callback(resetHandle, ON.RESET)
set_pre_entity_spawn(loadCategoryItems, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, MASK.ITEM, replaceable_items)
set_global_interval(expireChats,1)

--server callbacks
set_callback(timedOps, ON.GUIFRAME)
set_callback(startServer, ON.LOAD)
set_callback(defaultValues, ON.SCRIPT_ENABLE)
set_callback(startServer, ON.SCRIPT_ENABLE)
set_callback(stopServer, ON.SCRIPT_DISABLE)

set_callback(closeConnection, ON.MENU)
set_callback(closeConnection, ON.OPTIONS)
set_callback(closeConnection, ON.TITLE)
set_callback(closeConnection, ON.CHARACTER_SELECT)


