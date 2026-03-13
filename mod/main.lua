meta = {
    name = 'S2 Ranked',
    version = '1.12',
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
f16 = 0xFFFFFFFFFFFFFFFF
white = Color:white()
black = Color:black()
categoryList = {
    "Any%",
    "Sunken City%",
    --"CO Entry",
    "Cosmic Ocean%",
    "Low%",
    "Low% J/T",
    "No TP Any%",
    "No TP Sunken City%",
    "No TP Eggplant%",
    "No Gold Low%",
    "No TP No Gold",
    "Abzu%",
    "Duat%",
    "No TP Abzu%",
    "No TP Duat%",
    --"Chain Low% Abzu",
    --"Chain Low% Duat",
}
shopCategories = {
    "Any%",
    "Sunken City%",
    "No TP Any%",
    "No TP No Gold",
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
    "Sunken City%",
    "Duat%",
}
mattockCategories = {
    "No TP Any%",
    "No TP Sunken City%",
    "No TP Abzu%",
    "No TP Duat%",
    "No TP No Gold",
}
bombCategories = {
    "Sunken City%",
    "No TP Sunken City%",
    "No TP Eggplant%",
    "No TP Abzu%",
    "No TP Duat%",
}
packCategories = {
    "Any%",
    "No TP Any%",
    "No TP Duat%",
    "No TP No Gold",
}
jetpackCategories = {
    "Sunken City%",
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
    {7,5},
    {7,6},
    {7,7},
    {7,8},
    {7,9},
    {7,10},
    {7,11},
    {7,12},
    {7,13},
    {7,14},
    {7,15},
    {7,16},
    {7,17},
    {7,18},
    {7,19},
    {7,20},
    {7,21},
    {7,22},
    {7,23},
    {7,24},
    {7,25},
    {7,26},
    {7,27},
    {7,28},
    {7,29},
    {7,30},
    {7,31},
    {7,32},
    {7,33},
    {7,34},
    {7,35},
    {7,36},
    {7,37},
    {7,38},
    {7,39},
    {7,40},
    {7,41},
    {7,42},
    {7,43},
    {7,44},
    {7,45},
    {7,46},
    {7,47},
    {7,48},
    {7,49},
    {7,50},
    {7,51},
    {7,52},
    {7,53},
    {7,54},
    {7,55},
    {7,56},
    {7,57},
    {7,58},
    {7,59},
    {7,60},
    {7,61},
    {7,62},
    {7,63},
    {7,64},
    {7,65},
    {7,66},
    {7,67},
    {7,68},
    {7,69},
    {7,70},
    {7,71},
    {7,72},
    {7,73},
    {7,74},
    {7,75},
    {7,76},
    {7,77},
    {7,78},
    {7,79},
    {7,80},
    {7,81},
    {7,82},
    {7,83},
    {7,84},
    {7,85},
    {7,86},
    {7,87},
    {7,88},
    {7,89},
    {7,90},
    {7,91},
    {7,92},
    {7,93},
    {7,94},
    {7,95},
    {7,96},
    {7,97},
    {7,98},
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
register_option_int("chatMessageDuration", "How long messages should show for in seconds", 10, 1, 15)


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
opponentTheme = 0
opponentArea = 0
opponentLevel = 0
opponentConnected = true
eloChange = 0
placementsRemaining = 0
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
revealingRank = 0
blackness = 0
winConditionsMet = true
result = nil
banPhase = false
reportCount = 0
banInputDelay = 0
blockingInputs = false
returningInputs = false

categoryType = nil
spawnCoItems = 0
seed = 0xAAAAAAAAAAAAAAAA
currentSaves = {false}
furthestLevel = {1,1}
seedCache = {
    store = {},
    udjat = {},
    bm = {},
    drill = {},
    moon = {},
    star = {},
    sun = {},
    dwellingVault = {},
    jungleVault = {},
    volcanaVault = {},
    tidepoolVault = {},
    templeVault = {},
    iceVault = {},
    neoVault = {},
    sunkenVault = {},
    coffin2 = {},
    coffin4 = {},
    coffin6 = {},
}

sentSeedChange = false
activeSeedChange = false
changingSeed = false
sentDrawVote = false
activeDrawVote = false
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
warpIndex = 1
warpStep = 0
warpTo = {}
--controls warp theme
jungle = true
tidepool = true


-- camp variables
signOpen = false
signDelay = false
inQueue = false
buttonIndex = 0
banButtonIndex = 0
queueStateText = "Not in queue"
callbackList = {}
scrapCallbackList = {}
resendComplete = 0

--sets variable values to defaults when camp loaded first time - used post match
function defaultValues()
    revealingRank = 0
    blackness = 0
    winConditionsMet = true
    spawnCoItems = 0
    signDelay = false
    resendComplete = 0
    scrapCallbackList = {}
    blockingInputs = false
    returningInputs = false
    banInputDelay = 0
    preMatch = false
    callbackList = {}
    changingSeed = false
    eloChange = 0
    placementsRemaining = 0
    postMatch = false
    activeSeedChange = false
    activeDrawVote = false
    result = nil
    reportCount = 0
    opponentArea = 0
    opponentLevel = 0
    opponentTheme = 0
    opponentConnected = true
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
    matchStarted = false
    matchResultReceived = false
    categoryType = nil
    seed = 0xAAAAAAAAAAAAAAAA
    currentSaves = {false}
    seedCache = {
        store = {},
        udjat = {},
        bm = {},
        drill = {},
        moon = {},
        star = {},
        sun = {},
        dwellingVault = {},
        jungleVault = {},
        volcanaVault = {},
        tidepoolVault = {},
        templeVault = {},
        iceVault = {},
        neoVault = {},
        sunkenVault = {},
        coffin2 = {},
        coffin4 = {},
        coffin6 = {},
    }
    furthestLevel = {1,1}
    sentSeedChange = false
    sentDrawVote = false
    buttonHovering = -1
    shopYet = false
    itemsYet = false
    spawnedItems = {}
    runItems = {}
    loadProg = false
    loadItems = false
    loadEnts = false
    warping = false
    warpIndex = 1
    warpStep = 0
    warpTo = {}
    jungle = true
    tidepool = true
    signOpen = false
    inQueue = false
    buttonIndex = 0
    queueStateText = "Not in queue"
end
--resets values to default that are related to the very start of a match, right after bans
function defaultMatchValues()
    winConditionsMet = true
    spawnCoItems = 0
    postMatch = false
    currentSaves = {false}
    seedCache = {
        store = {},
        udjat = {},
        bm = {},
        drill = {},
        moon = {},
        star = {},
        sun = {},
        dwellingVault = {},
        jungleVault = {},
        volcanaVault = {},
        tidepoolVault = {},
        templeVault = {},
        iceVault = {},
        neoVault = {},
        sunkenVault = {},
        coffin2 = {},
        coffin4 = {},
        coffin6 = {},
    }
    furthestLevel = {1,1}
    activeSeedChange = false
    activeDrawVote = false
    reportCount = 0
    opponentTheme = 0
    opponentArea = 0
    opponentLevel = 0
    opponentConnected = true
    violate = false
    doReset = false
    hadAnkhThisRun = false
    hadExcaliburThisRun = false
    hadScepterThisRun = false
    warpTo = {}
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
    warpIndex = 1
    warpStep = 0
    sentSeedChange = false
    sentDrawVote = false
end

function defaultReconnectValues()
    winConditionsMet = true
    spawnCoItems = 0
    postMatch = false
    currentSaves = {false}
    seedCache = {
        store = {},
        udjat = {},
        bm = {},
        drill = {},
        moon = {},
        star = {},
        sun = {},
        dwellingVault = {},
        jungleVault = {},
        volcanaVault = {},
        tidepoolVault = {},
        templeVault = {},
        iceVault = {},
        neoVault = {},
        sunkenVault = {},
        coffin2 = {},
        coffin4 = {},
        coffin6 = {},
    }
    furthestLevel = {1,1}
    activeSeedChange = false
    activeDrawVote = false
    opponentTheme = 0
    opponentArea = 0
    opponentLevel = 0
    opponentConnected = true
    violate = false
    doReset = false
    hadAnkhThisRun = false
    hadExcaliburThisRun = false
    hadScepterThisRun = false
    warpTo = {}
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
    warpIndex = 1
    warpStep = 0
    sentSeedChange = false
    sentDrawVote = false
end

--camp functions
function spawnSign()
    signOpen = false
    local signUID = spawn_entity(ENT_TYPE.ITEM_SPEEDRUN_SIGN, 46, 84, LAYER.FRONT, 0, 0)
    sign = get_entity(signUID)
    sign.flags = clr_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
    if matchStarted then
        processChat("Interact with the sign to continue the match!","Match Info")
        button_prompts.spawn_button_prompt_on(button_prompts.PROMPT_TYPE.INTERACT, signUID, function()
            force11()
        end)
    else
        button_prompts.spawn_button_prompt_on(button_prompts.PROMPT_TYPE.INTERACT, signUID, function()
            if postMatch or matchStarted then return end
            if signDelay then return end
            signOpen = true
            blockInputs()
        end)
    end
end

function blockInputs()
    blockingInputs = true
    returningInputs = false
end

function inputCheck()
    --keep retrying player input blocking
    if blockingInputs then
        set_journal_enabled(false)
        if not players then return end
        if not players[1] then return end
        get_player(1).input = nil
        blockingInputs = false
    -- keep retrying player input returning
    elseif returningInputs then
        set_journal_enabled(true)
        game_manager.pause_ui.prompt_visible = false
        if not players then return end
        if not players[1] then return end
        get_player(1).input = state.player_inputs.player_slot_1
        returningInputs = false
    end
end

-- function blockPause()
--     if not blockingPause then return end
--     if game_manager.pause_ui.visibility ~=0 then game_manager.pause_ui.visibility = 0 end
-- end

function returnInputs()
    returningInputs = true
    blockingInputs = false
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
            local l = left + (xInc*xoffset)
            local t = (top + (yInc*yoffset))*ratio
            local r = left + (xInc*(xoffset+1))
            local b = (top + (yInc*(yoffset-1)))*ratio
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
            signDelay = true
            set_global_timeout(function()
                signDelay = false
            end, 10)
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
            signOpen = false
            returnInputs()
            signDelay = true
            set_global_timeout(function()
                signDelay = false
            end, 10)
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
    if opponentelo == -1 then
        table.insert(lines, ("[Unranked] "..opponent))
    else
        table.insert(lines, ("["..opponentelo.."] "..opponent))
    end
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
            local l = left + (xInc*xoffset)
            local t = (top + (yInc*yoffset))*ratio
            local r = left + (xInc*(xoffset+1))
            local b = (top + (yInc*(yoffset-1)))*ratio
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
    if chatting then 
        banInputDelay = 10 
        return
    end
    if banInputDelay > 0 then
        banInputDelay = banInputDelay - 1
        return
    end
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

function setConstellation(num, rank)
    local c = savegame.constellation

    local digits = {}
    local temp = num
    repeat
        table.insert(digits, 1, temp % 10)
        temp = math.floor(temp / 10)
    until temp == 0

    local dw = 3.0
    local dh = 5.0
    local gap = 2.0
    local n = #digits
    local cy = 7.0

    local start_x
    if n % 2 == 1 then
        start_x = -((n - 1) / 2) * (dw + gap) - dw / 2
    else
        start_x = -(n / 2 - 0.5) * (dw + gap) - dw / 2
    end

    local rank_colors = {
        gold     = {1.0, 0.85, 0.0},
        emerald  = {0.3, 1.0,  0.3},
        sapphire = {0.3, 0.7,  1.0},
        ruby     = {1.0, 0.1,  0.1},
        diamond  = {1.0, 1.0,  1.0},
    }

    local color = rank_colors[rank] or {1.0, 1.0, 1.0}
    local r, g, b = color[1], color[2], color[3]

    local digit_defs = {
        [0] = {
            stars = {{0,0},{1,0},{0,0.5},{1,0.5},{0,1},{1,1}},
            lines = {{1,2},{1,3},{2,4},{3,5},{4,6},{5,6},{1,2},{1,3},{2,4},{3,5},{4,6},{5,6}}
        },
        [1] = {
            stars = {{0,1},{1,1},{0.5,1},{0.5,0},{0,0.2}},
            lines = {{1,2},{3,4},{5,4},{1,2},{3,4},{5,4}}
        },
        [2] = {
            stars = {{0,0},{1,0},{1,0.5},{0,0.5},{0,1},{1,1}},
            lines = {{1,2},{2,3},{3,4},{4,5},{5,6},{1,2},{2,3},{3,4},{4,5},{5,6}}
        },
        [3] = {
            stars = {{0,0},{1,0},{1,0.5},{0,0.5},{1,1},{0,1}},
            lines = {{1,2},{2,3},{3,4},{3,5},{5,6},{1,2},{2,3},{3,4},{3,5},{5,6}}
        },
        [4] = {
            stars = {{0,0},{0,0.5},{1,0.5},{1,0},{1,1}},
            lines = {{1,2},{2,3},{4,3},{3,5},{1,2},{2,3},{4,3},{3,5}}
        },
        [5] = {
            stars = {{0,0},{1,0},{0,0.5},{1,0.5},{0,1},{1,1}},
            lines = {{1,2},{1,3},{3,4},{4,6},{5,6},{1,2},{1,3},{3,4},{4,6},{5,6}}
        },
        [6] = {
            stars = {{0,0},{1,0},{0,0.5},{1,0.5},{0,1},{1,1}},
            lines = {{1,2},{1,3},{3,4},{3,5},{4,6},{5,6},{1,2},{1,3},{3,4},{3,5},{4,6},{5,6}}
        },
        [7] = {
            stars = {{0,0},{1,0},{0.5,1}},
            lines = {{1,2},{2,3},{1,2},{2,3}}
        },
        [8] = {
            stars = {{0,0},{1,0},{0,0.5},{1,0.5},{0,1},{1,1}},
            lines = {{1,2},{1,3},{2,4},{3,4},{3,5},{4,6},{5,6},{1,2},{1,3},{2,4},{3,4},{3,5},{4,6},{5,6}}
        },
        [9] = {
            stars = {{0,0},{1,0},{0,0.5},{1,0.5},{1,1},{0,1}},
            lines = {{1,2},{1,3},{2,4},{3,4},{4,5},{5,6},{1,2},{1,3},{2,4},{3,4},{4,5},{5,6}}
        },
    }

    -- icon definitions: {stars, lines}
    -- icon center is at (0, iy), scaled by isize
    local isize = 2.0
    local iy = cy - dh/2 - 0.75 - 4

    local icon_defs = {
        gold = {
            stars = {
                {-1.98,-0.60},{1.02,-0.60},{1.97,-0.60},
                {-2.17, 0.60},{0.82, 0.60},{2.17, 0.60},
            },
            lines = {{1,2},{2,3},{1,4},{2,5},{3,6},{4,5},{5,6}},
        },
        sapphire = {
            stars = {
                {-1.6,-1.6},{1.6,-1.6},{-1.6,1.6},{1.6,1.6},
                {-1.0,-1.0},{1.0,-1.0},{-1.0,1.0},{1.0,1.0},
            },
            lines = {
                {1,2},{1,3},{2,4},{3,4},
                {5,6},{5,7},{6,8},{7,8},
                {1,5},{2,6},{3,7},{4,8},
            },
        },
        ruby = {
            stars = {
                { 0.04,-1.85},{-1.16,-1.17},{-1.81, 0.21},{-1.23, 1.41},
                { 0.04, 1.85},{ 1.30, 1.41},{ 1.81, 0.21},{ 1.13,-1.17},
                { 0.04,-1.08},{-0.53,-0.71},{-0.90, 0.21},{-0.53, 0.86},
                { 0.04, 1.05},{ 0.67, 0.86},{ 1.02, 0.21},{ 0.54,-0.71},
            },
            lines = {
                {1,2},{2,3},{3,4},{4,5},{5,6},{6,7},{7,8},{8,1},
                {9,10},{10,11},{11,12},{12,13},{13,14},{14,15},{15,16},{16,9},
                {1,9},{2,10},{3,11},{4,12},{5,13},{6,14},{7,15},{8,16},
            },
        },
        emerald = {
            stars = {
                { 0.03,-1.61},{-1.25,-0.45},{ 1.20,-0.45},
                {-1.80, 1.18},{ 1.80, 1.18},
                { 0.03,-0.68},{-0.61,-0.15},{ 0.68,-0.15},
                {-0.99, 0.83},{ 1.09, 0.83},
                {-0.60, 1.61},{ 0.84, 1.61},
                { 0.04, 0.32},
            },
            lines = {
                {1,2},{1,3},{2,4},{3,5},{4,11},{5,12},{11,12},
                {6,7},{6,8},{7,9},{8,10},{9,10},
                {6,13},{13,9},{13,10},
                {1,6},{2,7},{3,8},{4,9},{5,10},
            },
        },
        diamond = {
            stars = {
                {-1.30,-1.49},{ 1.39,-1.49},
                {-2.08,-0.66},{ 2.08,-0.66},
                {-0.30, 1.49},{ 0.40, 1.49},
            },
            lines = {{1,2},{1,3},{2,4},{3,5},{4,6},{5,6},{3,4}},
        },
    }

    local icon = icon_defs[rank]

    -- count stars and lines
    local needed_stars = #icon.stars
    local needed_lines = #icon.lines
    for _, digit in ipairs(digits) do
        local def = digit_defs[digit]
        needed_stars = needed_stars + #def.stars
        needed_lines = needed_lines + #def.lines
    end

    c.star_count = needed_stars
    c.line_count = needed_lines
    c.scale = 1.0
    c.line_red_intensity = 0.0

    local star_idx = 1
    local line_idx = 1

    local function place_star(x, y)
        local s = c.stars[star_idx]
        s.x = x
        s.y = y
        s.size = 1.5
        s.red = r
        s.green = g
        s.blue = b
        s.alpha = 1.0
        s.halo_red = r
        s.halo_green = g
        s.halo_blue = b
        s.halo_alpha = 0.3
        s.canis_ring = false
        s.fidelis_ring = false
        star_idx = star_idx + 1
    end

    local function place_line(from, to)
        local l = c.lines[line_idx]
        l.from = from - 1
        l.to = to - 1
        line_idx = line_idx + 1
    end

    -- place icon stars
    local icon_base = star_idx
    for _, pos in ipairs(icon.stars) do
        place_star(pos[1] * isize, iy + pos[2] * isize)
    end
    for _, seg in ipairs(icon.lines) do
        place_line(icon_base + seg[1] - 1, icon_base + seg[2] - 1)
    end

    -- place digit stars
    for d, digit in ipairs(digits) do
        local ox = start_x + (n - d) * (dw + gap)
        local def = digit_defs[digit]
        local base_star = star_idx

        local corner_map = {
            {1,2},{2,4},{4,6},{5,6},{3,5},{1,3},{3,4}
        }
        local corner_used = {false,false,false,false,false,false}
        for i = 1, #def.lines do
            local seg = def.lines[i]
            if corner_map[i] then
                corner_used[corner_map[i][1]] = true
                corner_used[corner_map[i][2]] = true
            end
        end
        -- just mark all stars as used since we're using custom defs
        for i = 1, #def.stars do
            place_star(ox + (1 - def.stars[i][1]) * dw, cy - dh/2 + def.stars[i][2] * dh)
        end
        for _, seg in ipairs(def.lines) do
            place_line(base_star + seg[1] - 1, base_star + seg[2] - 1)
        end
    end
    save_progress()
end

function adjustFade()
    if revealingRank >= 2 then
        if state.loading == 0 and blackness > 0.0 and state.fade_timer <= 0 then
            state.fade_value = blackness
            blackness = blackness - .004
            if blackness < 0 then
                blackness = 0
                revealingRank = 0
            end
        end
    end
end

function revealRank()
    if revealingRank < 1 then return end
    if revealingRank == 2 then
        if state.loading == FADE.IN then
            state.fade_value = 1
            state.fade_timer = 1000
            state.loading = 0
            state.fade_timer = 0
            state.fade_value = 1
        end
        if state.loading == FADE.LOAD then
            state.fade_value = 1
        end
        if state.loading == 0 then
            state.fade_value = 1
            local c = state.camera
            c.bounds_left = 2.5
            c.bounds_right = 72.5
            c.bounds_bottom = 98.5
            c.bounds_top = 126.0
            c.calculated_focus_x = 36.000091552734
            c.calculated_focus_y = 112.09980773926
            c.adjusted_focus_x = 36.000091552734
            c.adjusted_focus_y = 112.09980773926
            c.focus_offset_x = -2.0
            c.focus_offset_y = 0.0
            c.focus_x = 36.0
            c.focus_y = 112.09999847412
            c.vertical_pan = 0.0
            c.focused_entity_uid = get_entities_by_type(ENT_TYPE.LOGICAL_CAMERA_ANCHOR)[1]
            c.inertia = 5.0
            c.peek_timer = 0
            c.peek_layer = 0
            players[1].x = 46.017
            players[1].y = 109.050
            revealingRank = 3
            blockInputs()
            set_global_timeout(function()
                returnInputs()
                state.screen_next = SCREEN.CAMP
                state.screen_last = SCREEN.CAMP
                state.fade_timer = 60
                state.fade_enabled = true
                state.loading = FADE.OUT
            end, 660)
        end
    elseif revealingRank == 1 then
        state.screen_next = SCREEN.CAMP
        state.screen_last = SCREEN.CAMP
        state.fade_timer = 120
        state.fade_delay = 80
        state.loading = FADE.OUT
        revealingRank = 2
        blackness = 1.0
    end
end

function rankRevealSound(rank)
    local gem = get_sound(VANILLA_SOUND.UI_GET_GEM)
    local gold = get_sound(VANILLA_SOUND.UI_GET_GOLD)
    local scarab = get_sound(VANILLA_SOUND.UI_GET_SCARAB)
    local constellation = get_sound(VANILLA_SOUND.CUTSCENE_CONSTELLATION_LOOP)
    local sound2 = constellation:play(true)
    for i = 0, 4 do
        local sound
        if rank == "gold" then
            sound = gold:play(true)
            if i == 4 then 
                sound = scarab:play(true)
            end
            sound:set_volume(2)
        end
        if rank == "emerald" then
            sound = gem:play(true)
            sound:set_parameter(8, .8)
            sound:set_volume(2)
        end
        if rank == "sapphire" then
            sound = gem:play(true)
            sound:set_parameter(8, 1.2)
            sound:set_volume(2)
        end
        if rank == "ruby" then
            sound = gem:play(true)
            sound:set_parameter(8, 1.6)
            sound:set_volume(2)
        end
        if rank == "diamond" then
            sound = gem:play(true)
            sound:set_parameter(8, 5.0)
            sound:set_volume(2)
        end
        set_global_timeout(function()
            sound:set_pause(false)
        end,160+i*3)
    end
    sound2:set_pause(false)
    set_global_timeout(function()
        sound2:stop()
    end, 160)
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
        local af = false
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
                local id = set_global_interval(function()
                    play_sound(VANILLA_SOUND.DEATHMATCH_DM_TIMER, -1)
                end, 60)
                -- 10 second window for match found message
                local id2 = set_global_timeout(function()
                    preMatch = false
                    prepBans()
                    clear_callback(id)
                    play_sound(VANILLA_SOUND.MENU_CHARSEL_SELECTION2, -1)
                end,599)
                table.insert(scrapCallbackList,id)
                table.insert(scrapCallbackList,id2)
            -- Ban Phase 
            elseif event == "ban_update" then
                remainingCategories = data.categories
                bansFirst = not bansFirst
                banTime()
            -- Match start (ack required)
            elseif event == "match_start" then 
                if not matchStarted then
                    defaultMatchValues()
                    matchStarted = true
                    state.theme_start = THEME.DWELLING
                    state.level_start = 1
                    state.world_start = 1
                    categoryType = data.category
                    seed = tonumber(data.seed, 16)
                    reportCount = 0
                    banTime()
                end
                server:send(json.encode({ event = "ack", ack_event = "match_start" }), bridgeAddress)

            --Opponent progress
            elseif event == "opponent_progress" then
                if data.theme ~= opponentTheme then
                    opponentTheme = data.theme
                    if opponentTheme == THEME.JUNGLE then
                        processChat(opponent.." entered Jungle.", "Match Info")
                    elseif opponentTheme == THEME.VOLCANA then
                        processChat(opponent.." entered Volcana.", "Match Info")
                    elseif opponentTheme == THEME.OLMEC then
                        processChat(opponent.." entered Olmec.", "Match Info")
                    elseif opponentTheme == THEME.TIDE_POOL then
                        processChat(opponent.." entered Tidepool.", "Match Info")
                    elseif opponentTheme == THEME.TEMPLE then
                        processChat(opponent.." entered Temple.", "Match Info")
                    elseif opponentTheme == THEME.ICE_CAVES then
                        processChat(opponent.." entered Ice Caves.", "Match Info")
                    elseif opponentTheme == THEME.NEO_BABYLON then
                        processChat(opponent.." entered Neo Babylon.", "Match Info")
                    elseif opponentTheme == THEME.SUNKEN_CITY then
                        processChat(opponent.." entered Sunken City.", "Match Info")
                    end
                end
                if data.theme == THEME.COSMIC_OCEAN then
                    if (data.level % 4 == 0) and opponentLevel < data.level then
                        opponentLevel = data.level
                        processChat(opponent.." entered 7-"..opponentLevel..".", "Match Info")
                    end
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
                    table.insert(scrapCallbackList,id)
                end
                server:send(json.encode({ event = "ack", ack_event = "do_seed_change" }), bridgeAddress)

            -- Match result (ack required)
            elseif event == "match_result" then
                if not matchResultReceived and matchStarted then
                    matchResultReceived = true
                    if not opponentConnected then
                        processChat("The opponent failed to reconnect in time, and they forfeit the match as a result.","Match Info")
                    end
                    result = data.result
                    eloChange = data.elo_change
                    placementsRemaining = data.placements_remaining
                    endMatch()
                end
                server:send(json.encode({ event = "ack", ack_event = "match_result"}), bridgeAddress)

            elseif event == "match_scrapped" then
                processChat("This match has been scrapped! No elo was lost.", "Match Info")
                for i, id in ipairs(scrapCallbackList) do
                    clear_callback(id)
                end
                defaultValues()
                if players and players[1] then
                    warp(1,1,THEME.BASE_CAMP)
                end
            elseif event == "postmatch_closed" then
                forceEndPostMatch()
            elseif event == "receive_chat" then
                --only show chat messages if user has them enabled
                if options.chatEnabled then
                    processChat(data.message, data.sender_name)
                end
            elseif event == "rank_reveal" then
                if revealingRank < 1 then
                    revealingRank = 1
                    setConstellation(data.elo, data.rank_name)
                    rankRevealSound(data.rank_name)
                end
                server:send(json.encode({ event = "ack", ack_event = "rank_reveal"}), bridgeAddress)
            elseif event == "opponent_disconnected" then
                processChat("The opponent has disconnected. They have 30s to reconnect before they forfeit.", "Match Info")
                opponentConnected = false
            elseif event == "opponent_reconnected" then
                processChat("The opponent has reconnected. Good luck!", "Match Info")
                opponentConnected = true
            elseif event == "reconnected" then
                processChat("Your connection was lost temporarily, but was restored. The match is still active.", "Match Info")
                if not matchStarted then
                    defaultReconnectValues()
                    opponent = data.opponent_name
                    opponentelo = data.opponent_elo
                    opponentTheme = data.theme
                    opponentLevel = data.level
                    matchStarted = true
                    state.theme_start = THEME.DWELLING
                    state.level_start = 1
                    state.world_start = 1
                    categoryType = data.category
                    seed = tonumber(data.seed, 16)
                    processChat("Since your game closed, your saves were lost. Navigate to 1-1 to continue.", "Match Info")
                end
            elseif event == "auto_forfeit" then
                if not af then
                    processChat("Your connection was lost during the match, and you did not reconnect in time.", "Match Info")
                    processChat("You forfeit the match, and your opponent received a win.", "Match Info")
                    if data.placements_remaining then 
                        if data.placements_remaining == 0 then
                            processChat("You finished all your placement matches, and your rank is now visible.","Match Info")
                        else
                            processChat("You have "..data.placements_remaining.." placement matches left.","Match Info")
                        end
                    else
                        processChat("You lost "..data.elo_change.." from that match.","Match Info")
                    end
                    defaultValues()
                    if players and players[1] then
                        warp(1,1,THEME.BASE_CAMP)
                    end
                    af = true
                end
                server:send(json.encode({ event = "ack", ack_event = "auto_forfeit"}), bridgeAddress)
            elseif event == "match_not_found" then
                processChat("The match you were in concluded while you were disconnected.", "Match Info")
                defaultValues()
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
    queueStateText = "Not In Queue"
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

function revealComplete()
    server:send(json.encode({ event = "rank_reveal_complete" }), bridgeAddress)
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

function getLevelIndex(world, level)
    for i, lev in ipairs(levelOrder) do
        if (world==lev[1]) and (level == lev[2]) then
            return i
        end
    end
    return -1
end

function determineTheme(world, level)
    if world == 1 then
        return THEME.DWELLING
    elseif world == 2 then
        if jungle then
            return THEME.JUNGLE
        else
            return THEME.VOLCANA
        end
    elseif world == 3 then
        return THEME.OLMEC
    elseif world == 4 then
        if tidepool then
            if level == 4 and (categoryType == "Abzu%" or categoryType == "No TP Abzu%") then
                return THEME.ABZU
            else
                return THEME.TIDE_POOL
            end
        else
            if level == 4 and (categoryType == "Duat%" or categoryType == "No TP Duat%") then
                return THEME.DUAT
            elseif level == 3 and (categoryType == "Duat%" or categoryType == "No TP Duat%") then
                return THEME.CITY_OF_GOLD
            else
                return THEME.TEMPLE
            end
        end
    elseif world == 5 then
        return THEME.ICE_CAVES
    elseif world == 6 then
        if level == 4 then
            return THEME.TIAMAT
        else
            return THEME.NEO_BABYLON
        end
    elseif world == 7 then
        if level == 4 then
            return THEME.HUNDUN
        elseif level > 4 then
            return THEME.COSMIC_OCEAN
        else
            return THEME.SUNKEN_CITY
        end
    end
end

function unlockStuff()
    savegame.characters = (1 << 20) - 1
    savegame.shortcuts = (1 << 10) - 1
    savegame.tutorial_state = (1 << 4) - 1
    savegame.completed_normal = true
    savegame.completed_hard = true
    save_progress()
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
    if category == "Cosmic Ocean%" then
        table.insert(items, ENT_TYPE.ITEM_JETPACK)
        table.insert(items, ENT_TYPE.ITEM_POWERUP_KAPALA)
        table.insert(items, ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
        if math.random(5) == 3 then
            table.insert(items, ENT_TYPE.ITEM_POWERUP_SPRING_SHOES)
        end
        if math.random(5) == 3 then
            table.insert(items, ENT_TYPE.ITEM_POWERUP_PASTE)
        end
        if math.random(5) == 3 then
            table.insert(items, ENT_TYPE.ITEM_POWERUP_SPECTACLES)
        end
        if math.random(5) == 3 then
            table.insert(items, ENT_TYPE.ITEM_POWERUP_PITCHERSMITT)
        end
        if math.random(30) == 3 then
            table.insert(items, ENT_TYPE.ITEM_POWERUP_CLIMBING_GLOVES)
        end
        if math.random(100) == 3 then
            table.insert(items, ENT_TYPE.ITEM_POWERUP_EGGPLANTCROWN)
        end
        if math.random(500) == 3 then
            table.insert(items, ENT_TYPE.ITEM_POWERUP_SPECIALCOMPASS)
        end
    end
    if category == "No TP No Gold" then
        table.insert(items, ENT_TYPE.ITEM_PICKUP_SPECTACLES)
    end
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
    if categoryType == "Cosmic Ocean%" then
        if furthestLevel[2] <= 8 then
            warpTo = {7,5} 
            warpIndex = getLevelIndex(7,5)
            return
        end
    elseif furthestLevel[1] == 1 and furthestLevel[2] <= 4 then
        warpTo = {1,1}
        warpIndex = 1
        return
    end
    local ind = getLevelIndex(furthestLevel[1], furthestLevel[2])
    table.insert(warpTo,levelOrder[ind-3][1])
    table.insert(warpTo,levelOrder[ind-3][2])
    warpIndex = ind-3
    if not warpTo then
        warpTo = {1,1}
        warpIndex = 1
        log_print("Something went wrong, and the checkpoint was set to the default 1-1")
    end 

end

function warpToCheckpoint()
    if not warping then return end
    if (warpTo == {1,1}) or (state.world == warpTo[1] and state.level >= warpTo[2]) then
        warping = false
        return
    end
    if state.loading == FADE.IN then state.fade_timer = 0 end
    if warpStep == 0 then
        if state.level ~= 1 and state.world ~= 1 then
            warp(1,1,THEME.DWELLING)
        end
        state.fade_timer = 0
        warpStep = 1

    elseif warpStep == 1 and state.screen == SCREEN.LEVEL and state.loading == 0 then
        if categoryType ~= "Cosmic Ocean%" then
            loadProg = true
        elseif warpTo[2] > 5 then
            loadProg = true
        end
        state.theme_next = determineTheme(warpTo[1], warpTo[2])
        state.world_next = warpTo[1]
        state.level_next = warpTo[2]
        state.level_count = warpIndex-1
        state.screen_last = state.screen
        state.screen_next = SCREEN.TRANSITION
        state.loading = FADE.OUT
        state.fade_timer = 0
        warpStep = 2

    elseif state.screen == SCREEN.TRANSITION and warpStep == 2 then
        setSeed(warpIndex)
        state.screen_next = SCREEN.LEVEL
        state.screen_last = state.screen
        state.loading = FADE.OUT
        state.fade_timer = 1
        warping = false
        warpStep = 0
    end
end

function force11()
    set_adventure_seed(seed,seed)
    state.screen_last = state.screen
    state.screen_next = SCREEN.LEVEL
    state.theme_start = THEME.DWELLING
    state.level_start = 1
    state.world_start = 1
    state.world_next = 1
    state.level_next = 1
    state.theme_next = 1
    state.level_count = 0
    state.loading = FADE.OUT
    state.quest_flags = set_flag(state.quest_flags, 1)
    state.fade_timer = 1
end

function saveProgress()
    if state.screen ~= SCREEN.LEVEL then return end
    if categoryType == "Cosmic Ocean%" and state.world ~= 7 then return end
    local world = state.world
    local level = state.level
    determineCheckpoint()
    -- if this level comes before the checkpoint level, do nothing
    if not (getLevelIndex(world, level) > getLevelIndex(warpTo[1],warpTo[2])) then return end
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
    local waddler = {}
    local waddlermeta = {}
    for i = 0, 10 do
        local type = waddler_entity_type_in_slot(i)
        if type ~= 0 then
            table.insert(waddler, type)
            table.insert(waddlermeta, waddler_get_entity_meta(i))
        end
    end
    local saveInfo = {
        level = state.level,
        world = state.world,
        aggro = state.shoppie_aggro_next,
        tAggro = state.merchant_aggro,
        time = state.time_total,
        timeLast = state.time_last_level,
        favor = state.kali_favor,
        altars = state.kali_altars_destroyed,
        gifts = state.kali_gifts,
        status = state.kali_status,
        tusk = state.quests.madame_tusk_state,
        horsing = state.quests.van_horsing_state,
        sparrow = state.quests.sparrow_state,
        beg = state.quests.beg_state,
        sisters = state.quests.jungle_sisters_flags,
        yang = state.quests.yang_state,
        inventory = inventory,
        companionInfo = companionInfo,
        waddler = waddler,
        waddlermeta = waddlermeta,
    }
    if categoryType ~= "Cosmic Ocean%" then
        if #currentSaves < getLevelIndex(world, level) then
            table.insert(currentSaves, saveInfo)
        else
            currentSaves[getLevelIndex(world,level)] = saveInfo
        end
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
    else
        if #currentSaves < level-4 then
            table.insert(currentSaves, saveInfo)
        else
            currentSaves[level-4] = saveInfo
        end
    end
end

function loadProgress()
    if spawnCoItems > 0 then 
        loadProg = false
        return
    end
    if not loadProg then return end
    local ind = nil
    local save = nil
    local theme = nil
    if categoryType == "Cosmic Ocean%" then
        if warpTo[1] ~= 7 then
            loadProg = false
            return
        end
        ind = warpTo[2]-4
        save = currentSaves[ind]
        theme = THEME.COSMIC_OCEAN
    else
        ind = getLevelIndex(warpTo[1],warpTo[2])
        save = currentSaves[ind]
        theme = determineTheme(warpTo[1],warpTo[2])
    end

    state.shoppie_aggro_next = save.aggro
    state.merchant_aggro = save.tAggro
    state.time_last_level = save.timeLast
    state.kali_favor = save.favor
    state.kali_altars_destroyed = save.altars
    state.kali_gifts = save.gifts
    state.kali_status = save.status
    state.quests.madame_tusk_state = save.tusk
    state.quests.van_horsing_state = save.horsing
    state.quests.sparrow_state = save.sparrow
    state.quests.beg_state = save.beg
    state.quests.jungle_sisters_flags = save.sisters
    state.quests.yang_state = save.yang
    for i, ent in ipairs(save.waddler) do
        waddler_store_entity(ent)
    end
    for i, data in ipairs(save.waddlermeta) do
        waddler_set_entity_meta(i-1, data)
    end

    -- seed cache stuff for level gen
    if #seedCache.udjat ~= 0 and ind > getLevelIndex(seedCache.udjat[1],seedCache.udjat[2]) then
        state.quest_flags = set_flag(state.quest_flags, 17)
    end
    if #seedCache.bm ~= 0 and ind > getLevelIndex(seedCache.bm[1],seedCache.bm[2]) then
        state.quest_flags = set_flag(state.quest_flags, 18)
    end
    if #seedCache.drill ~= 0 and ind > getLevelIndex(seedCache.drill[1],seedCache.drill[2]) then
        state.quest_flags = set_flag(state.quest_flags, 19)
    end
    if #seedCache.moon ~= 0 and ind > getLevelIndex(seedCache.moon[1],seedCache.moon[2]) then
        state.quest_flags = set_flag(state.quest_flags, 25)
    end
    if #seedCache.star ~= 0 and ind > getLevelIndex(seedCache.star[1],seedCache.star[2]) then
        state.quest_flags = set_flag(state.quest_flags, 26)
    end
    if #seedCache.sun ~= 0 and ind > getLevelIndex(seedCache.sun[1],seedCache.sun[2]) then
        state.quest_flags = set_flag(state.quest_flags, 27)
    end
    if #seedCache.store ~= 0 and ind > getLevelIndex(seedCache.store[1], seedCache.store[2]) then
        state.quest_flags = set_flag(state.quest_flags, 5)
        shopYet = true
        itemsYet = true
    end


    -- vault control
    if #seedCache.dwellingVault ~= 0 and warpTo[1] == 1 and ind > getLevelIndex(seedCache.dwellingVault[1],seedCache.dwellingVault[2]) then
        state.quest_flags = set_flag(state.quest_flags, 3)
    end
    if warpTo[1] == 2 then
        if #seedCache.coffin2 ~= 0 and ind > getLevelIndex(seedCache.coffin2[1], seedCache.coffin2[2]) then
            state.world2_coffin_spawned = true
        end
        if theme == THEME.JUNGLE and #seedCache.jungleVault ~= 0 and ind > getLevelIndex(seedCache.jungleVault[1],seedCache.jungleVault[2]) then
            state.quest_flags = set_flag(state.quest_flags, 3)
        elseif #seedCache.volcanaVault ~= 0 and ind > getLevelIndex(seedCache.volcanaVault[1],seedCache.volcanaVault[2]) then
            state.quest_flags = set_flag(state.quest_flags, 3)
        end
    end
    if warpTo[1] == 4 then
        if #seedCache.coffin4 ~= 0 and ind > getLevelIndex(seedCache.coffin4[1], seedCache.coffin4[2]) then
            state.world4_coffin_spawned = true
        end
        if theme == THEME.TIDE_POOL and #seedCache.tidepoolVault ~= 0 and ind > getLevelIndex(seedCache.tidepoolVault[1],seedCache.tidepoolVault[2]) then
            state.quest_flags = set_flag(state.quest_flags, 3)
        elseif #seedCache.templeVault ~= 0 and ind > getLevelIndex(seedCache.templeVault[1],seedCache.templeVault[2]) then
            state.quest_flags = set_flag(state.quest_flags, 3)
        end
    end
    if warpTo[1] == 5 and #seedCache.iceVault ~= 0 and ind > getLevelIndex(seedCache.iceVault[1],seedCache.iceVault[2]) then
        state.quest_flags = set_flag(state.quest_flags, 3)
    end
    if warpTo[1] == 6 and #seedCache.coffin6 ~= 0 and ind > getLevelIndex(seedCache.coffin6[1], seedCache.coffin6[2]) then
        state.world6_coffin_spawned = true
    end
    if warpTo[1] == 6 and #seedCache.neoVault ~= 0 and ind > getLevelIndex(seedCache.neoVault[1],seedCache.neoVault[2]) then
        state.quest_flags = set_flag(state.quest_flags, 3)
    end
    if warpTo[1] == 7 and #seedCache.sunkenVault ~= 0 and ind > getLevelIndex(seedCache.sunkenVault[1],seedCache.sunkenVault[2]) then
        state.quest_flags = set_flag(state.quest_flags, 3)
    end
    loadProg = false
    loadItems = true
end

function loadInventory()
    if spawnCoItems == 1 then
        state.items.player_inventory[1].bombs = 16
        state.items.player_inventory[1].ropes = 8
        state.items.player_inventory[1].health = 6
        loadItems = false
        loadProg = false
        spawnCoItems = 2
    end
    if not loadItems then return end
    local ind = nil
    local save = nil
    local theme = nil
    if categoryType == "Cosmic Ocean%" then
        ind = warpTo[2]-3
        save = currentSaves[ind]
        theme = THEME.COSMIC_OCEAN
    else
        ind = getLevelIndex(warpTo[1],warpTo[2])
        save = currentSaves[ind]
        theme = determineTheme(warpTo[1],warpTo[2])
    end
    loadItems = false
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
    if spawnCoItems == 2 then
        local player = players[1]
        for i, powerup in ipairs(runItems) do
            if powerup ~= 0 then
                if powerup == ENT_TYPE.ITEM_JETPACK or powerup == ENT_TYPE.ITEM_VLADS_CAPE then
                    pick_up(player.uid, spawn(powerup, 0, 0, LAYER.PLAYER, 0, 0))
                else
                    player:give_powerup(powerup)
                end
            end
        end
        loadEnts = false
        loadProg = false
        spawnCoItems = 0
    end
    if not loadEnts then return end
    loadEnts = false
    local ind = nil
    local save = nil
    local theme = nil
    if categoryType == "Cosmic Ocean%" then
        ind = warpTo[2]-3
        save = currentSaves[ind]
        theme = THEME.COSMIC_OCEAN
    else
        ind = getLevelIndex(warpTo[1],warpTo[2])
        save = currentSaves[ind]
        theme = determineTheme(warpTo[1],warpTo[2])
    end
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
    warping = true
end

function forceSeed()
    set_adventure_seed(seed,seed)
end

function setSeed(levelNum)
    set_adventure_seed(seed, seed*levelNum & f16)
end 

function setCache() 
    local world = state.world 
    local level = state.level
    local theme = state.theme
    local quest = state.quest_flags
    local questinfo = state.quests
    if test_flag(quest,5) and #seedCache.store == 0 then
        seedCache.store = {world, level}
    end
    if test_flag(quest,17) and #seedCache.udjat == 0 then
        seedCache.udjat = {world, level}
    end
    if test_flag(quest,18) and #seedCache.bm == 0 then
        seedCache.bm = {world, level}
    end
    if test_flag(quest,19) and #seedCache.drill == 0 then
        seedCache.drill = {world, level}
    end
    if test_flag(quest,25) and #seedCache.moon == 0 then
        seedCache.moon = {world, level}
    end
    if test_flag(quest,26) and #seedCache.star == 0 then
        seedCache.star = {world, level}
    end
    if test_flag(quest,27) and #seedCache.sun == 0 then
        seedCache.sun = {world, level}
    end
    if world == 1 then
        if test_flag(quest,3) and #seedCache.dwellingVault == 0 then
            seedCache.dwellingVault = {world, level}
        end
    end
    if world == 2 then
        if state.world2_coffin_spawned and #seedCache.coffin2 == 0 then
            seedCache.coffin2 = {world,level}
        end
        if theme == THEME.VOLCANA then
            if test_flag(quest,3) and #seedCache.volcanaVault == 0 then
                seedCache.volcanaVault = {world, level}
            end
        else
            if test_flag(quest,3) and #seedCache.jungleVault == 0 then
                seedCache.jungleVault = {world, level}
            end
        end
    end
    if world == 4 then
        if state.world4_coffin_spawned and #seedCache.coffin4 == 0 then
            seedCache.coffin4 = {world,level}
        end
        if theme == THEME.TIDE_POOL then
            if test_flag(quest,3) and #seedCache.tidepoolVault == 0 then
                seedCache.tidepoolVault = {world, level}
            end
        else
            if test_flag(quest,3) and #seedCache.templeVault == 0 then
                seedCache.templeVault = {world, level}
            end
        end
    end
    if world == 5 then
        if test_flag(quest,3) and #seedCache.iceVault == 0 then
            seedCache.iceVault = {world, level}
        end
    end
    if world == 6 then
        if state.world6_coffin_spawned and #seedCache.coffin6 == 0 then
            seedCache.coffin6 = {world,level}
        end
        if test_flag(quest,3) and #seedCache.neoVault == 0 then
            seedCache.neoVault = {world, level}
        end
    end
    if world == 7 then
        if test_flag(quest,3) and #seedCache.sunkenVault == 0 then
            seedCache.sunkenVault = {world, level}
        end
    end
end

function coCheck()
    if categoryType ~= "Cosmic Ocean%" then return end
    -- run every reset before warp
    if furthestLevel[1] < 7 then 
        furthestLevel[1] = 7
    end
    if furthestLevel[2] < 5 then
        furthestLevel[2] = 5
    end
    if furthestLevel[2] <= 8 then
        spawnCoItems = 1
    end
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
        setCache()
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
    inputCheck()
    revealRank()
end

function categoryViolation()
    violate = true
  -- print("you violated the category rules")
end

function resetHandle()
    if matchStarted then
        doReset = true
        forceSeed()
        runItems = getItemsForRun(categoryType)
        if categoryType ~= "Cosmic Ocean%" then
            shopYet = false
            spawnedItems = {}
            itemsYet = false
            violate = false
        else
            coCheck()
        end
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
                if not inList then
                    violated = true
                    log_print("logical violation")
                end
                
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
    if categoryType == "No Gold Low%" or categoryType == "No TP No Gold" then
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
    if state.screen ~= SCREEN.TRANSITION then return end
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
        if (state.world == 5 and not hasTablet) then 
            violated = true
            log_print("no tablet violation")
        end
        --level based
        if state.screen == SCREEN.TRANSITION then
            -- ankh check
            if (state.world == 3 and state.level == 1 and not hadAnkhThisRun) then
                violated = true
                log_print("no ankh violation")
            end
            --correct ushabti check
            if (state.world == 6 and state.level == 2 and (inventory.held_item ~= ENT_TYPE.ITEM_USHABTI or inventory.held_item_metadata~=state:get_correct_ushabti())) then
                violated = true
                log_print("no/wrong ushabti violation")
            end
        end
    end
    --specific chain requirements
    if (categoryType =="Abzu%" or categoryType == "No TP Abzu%") then
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
                log_print("shouldve gone temple violation")
            end
            --going jungle
            if ((state.world == 1 and state.level == 4) and state.theme_next ~= THEME.JUNGLE) then
                violated = true
                log_print("shouldve gone jungle violation")
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
            if state.world == 7 and state.level == 2 then
                local hasCrown = false
                for i, ent in ipairs(inventory.acquired_powerups) do
                    if ent == ENT_TYPE.ITEM_POWERUP_EGGPLANTCROWN then
                        hasCrown = true
                    end
                end
                if not hasCrown then
                    violated = true
                    log_print("no eggplant crown violation")
                end
            end
        end
    end
    if violated then categoryViolation() end
end

function doorManager()
    --hundun wins block tiamat
    if (categoryType == "Sunken City%" or categoryType == "No TP Sunken City%" or categoryType == "Abzu%" or categoryType == "No TP Abzu%" or categoryType == "Duat%" or categoryType == "No TP Duat%" or categoryType == "No TP Eggplant%") then
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
    currentSaves = {false}
    furthestLevel = {1,1}
    force11()
end

function testWin()
    if matchStarted then
        if state.screen == SCREEN.WIN then
            local flag = state.journal_flags
            if categoryType == "No Gold Low%" or categoryType == "No TP No Gold" then
                winConditionsMet = test_flag(flag, 11)
            end
            winConditionsMet = winConditionsMet and not violate
            if winConditionsMet then 
                if resendComplete <= 0 then
                    completionReport()
                    resendComplete = 120
                else 
                    resendComplete = resendComplete - 1
                end
            else
                if state.loading ~= FADE.OUT and state.loading ~= FADE.LOAD then
                    force11()
                    violate = false
                end
            end
        end
        if categoryType == "Cosmic Ocean%" and ((state.screen == SCREEN.TRANSITION and state.level >= 20) or (state.screen == SCREEN.LEVEL and state.level >= 21)) then
            if resendComplete <= 0 then
                completionReport()
                resendComplete = 120
            else 
                resendComplete = resendComplete - 1
            end
        end
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
            local l = left + (xInc*xoffset)
            local t = (top + (yInc*yoffset))*ratio
            local r = left + (xInc*(xoffset+1))
            local b = (top + (yInc*(yoffset-1)))*ratio
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
        elseif (buttonHovering == 3) then
            sendForfeit()
        end
    end
end

function endMatch()
    warp(1,1,THEME.BASE_CAMP)
    currentSaves = {false}
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
        if placementsRemaining then
            if placementsRemaining == 0 then
                table.insert(lines, "Rank reveal incoming!")
            else
                table.insert(lines, tostring(placementsRemaining).." placement matches left!")
            end
        else
            table.insert(lines, "Lost "..math.abs(eloChange).." elo")
        end
    elseif result == "win" then
        table.insert(lines, "Victory")
        table.insert(lines, "You won the match!")
        if placementsRemaining then
            if placementsRemaining == 0 then
                table.insert(lines, "Rank reveal incoming!")
            else
                table.insert(lines, tostring(placementsRemaining).." placement matches left!")
            end
        else
            table.insert(lines, "Gained "..math.abs(eloChange).." elo!")
        end
    elseif result == "draw" then
        table.insert(lines, "Draw")
        if placementsRemaining then
            if placementsRemaining == 0 then
                table.insert(lines, "Rank reveal incoming!")
            else
                table.insert(lines, tostring(placementsRemaining).." placement matches left!")
            end
        else
            table.insert(lines, "No elo change")
        end
        
    else 
        table.insert(lines, "error")
        table.insert(lines, "error")
    end
    for i, line in ipairs(lines) do
        renderText(render_ctx, line, 0, ratio*(.13-((i*.08)-((i-1)*.025))),(.0020)-(i*.0004),white)
    end
end

--chat popups, some form of message queue
function renderChat(render_ctx)
    local heightIndex = 0
    if not chatting then
        for i = 1, #messageList do
            if messageList[i][2] >= 0 then
                renderTextLeft(render_ctx, messageList[i][3]..": "..messageList[i][1],-.98,(-.3+(heightIndex*.03))*ratio,.0006, white)
                heightIndex = heightIndex + 1
            end
        end
    else
        for i = 1, #messageList do
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

function addToMessage(char, shift)
    if #chatMessage >= 50 then
        return
    elseif shift then
        if char == "1" then
            char = "!"
            chatMessage = chatMessage..char
        elseif char == "/" then
            char = "?"
            chatMessage = chatMessage..char
        elseif char == "2" then
            char = "@"
            chatMessage = chatMessage..char
        elseif char == "3" then
            char = "#"
            chatMessage = chatMessage..char
        elseif char == "4" then
            char = "$"
            chatMessage = chatMessage..char
        elseif char == "5" then
            char = "%"
            chatMessage = chatMessage..char
        elseif char == "6" then
            char = "^"
            chatMessage = chatMessage..char
        elseif char == "7" then
            char = "&"
            chatMessage = chatMessage..char
        elseif char == "8" then
            char = "*"
            chatMessage = chatMessage..char
        elseif char == "9" then
            char = "("
            chatMessage = chatMessage..char
        elseif char == "0" then
            char = ")"
            chatMessage = chatMessage..char
        elseif char == "," then
            char = "<"
            chatMessage = chatMessage..char
        elseif char == "." then
            char = ">"
            chatMessage = chatMessage..char
        elseif char == "'" then
            char = "\""
            chatMessage = chatMessage..char
        elseif char == ";" then
            char = ":"
            chatMessage = chatMessage..char
        elseif char == "[" then
            char = "{"
            chatMessage = chatMessage..char
        elseif char == "]" then
            char = "}"
            chatMessage = chatMessage..char
        elseif char == "`" then
            char = "~"
            chatMessage = chatMessage..char
        elseif char == "=" then
            char = "+"
            chatMessage = chatMessage..char
        elseif char == "-" then
            char = "_"
            chatMessage = chatMessage..char
        else
            chatMessage = chatMessage..string.upper(char)
        end
    else
        chatMessage = chatMessage..char
    end
end

function isCommand()
    if chatMessage == "/end" or chatMessage == "/cat" or chatMessage == "/category" or chatMessage == "/prog" or chatMessage == "/progress" then
        return true
    end
end

function doCommand(command)
    if command == "/end" and postMatch then
        forceEndPostMatch()
        closePostMatch()
    end
    if (command == "/cat" or command == "/category") and matchStarted then
        processChat("Current category is "..categoryType, "Match Info")
    end
    if (command == "/progress" or command == "/prog") and matchStarted then
        if opponentTheme == THEME.JUNGLE then
            processChat(opponent.." is in Jungle.", "Match Info")
        elseif opponentTheme == THEME.VOLCANA then
            processChat(opponent.." is in Volcana.", "Match Info")
        elseif opponentTheme == THEME.OLMEC then
            processChat(opponent.." is in Olmec.", "Match Info")
        elseif opponentTheme == THEME.TIDE_POOL then
            processChat(opponent.." is in Tidepool.", "Match Info")
        elseif opponentTheme == THEME.TEMPLE then
            processChat(opponent.." is in Temple.", "Match Info")
        elseif opponentTheme == THEME.ICE_CAVES then
            processChat(opponent.." is in Ice Caves.", "Match Info")
        elseif opponentTheme == THEME.NEO_BABYLON then
            processChat(opponent.." is in Neo Babylon.", "Match Info")
        elseif opponentTheme == THEME.SUNKEN_CITY then
            processChat(opponent.." is in Sunken City.", "Match Info")
        elseif opponentTheme == THEME.COSMIC_OCEAN then
            processChat(opponent.." is in 7-"..opponentLevel..".", "Match Info")
        end
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
    local input = get_io()
    --chat window already open
    if chatting then
        input.wantkeyboard = true
        blockInputs()
        local shift = false
        if input.keydown(KEY.LSHIFT) or input.keydown(KEY.RSHIFT) then
            shift = true
        end
        if input.keypressed(KEY.RETURN) then
            if isCommand() then
                doCommand(chatMessage)
                returnInputs()
                chatting = false
                chatMessage = ""
                return
            end
            if chatMessage == "" then
                chatting = false
                chatMessage = ""
                returnInputs()
                return
            end
            returnInputs()
            processChat(chatMessage, "You")
            sendChat()
            chatMessage = ""
            chatting = false
        end
        if input.keypressed(27) or input.keypressed(KEY.OL_MOD_SHIFT | 27) then
            set_global_timeout(function()
                if game_manager.pause_ui.visibility ~=0 then game_manager.pause_ui.visibility = 0 end
            end, 2)
            chatting = false
            chatMessage = ""
            returnInputs()
            return
        end
        if input.keypressed(KEY.BACKSPACE) then
            chatMessage = string.sub(chatMessage, 1, -2)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.A) or input.keypressed(KEY.A) then
            addToMessage("a",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.B) or input.keypressed(KEY.B) then
            addToMessage("b",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.C) or input.keypressed(KEY.C) then
            addToMessage("c",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.D) or input.keypressed(KEY.D) then
            addToMessage("d",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.E) or input.keypressed(KEY.E) then
            addToMessage("e",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.F) or input.keypressed(KEY.F) then
            addToMessage("f",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.G) or input.keypressed(KEY.G) then
            addToMessage("g",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.H) or input.keypressed(KEY.H) then
            addToMessage("h",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.I) or input.keypressed(KEY.I) then
            addToMessage("i",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.J) or input.keypressed(KEY.J) then
            addToMessage("j",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.K) or input.keypressed(KEY.K) then
            addToMessage("k",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.L) or input.keypressed(KEY.L) then
            addToMessage("l",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.M) or input.keypressed(KEY.M) then
            addToMessage("m",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.N) or input.keypressed(KEY.N) then
            addToMessage("n",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.O) or input.keypressed(KEY.O) then
            addToMessage("o",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.P) or input.keypressed(KEY.P) then
            addToMessage("p",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.Q) or input.keypressed(KEY.Q) then
            addToMessage("q",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.R) or input.keypressed(KEY.R) then
            addToMessage("r",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.S) or input.keypressed(KEY.S) then
            addToMessage("s",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.T) or input.keypressed(KEY.T) then
            addToMessage("t",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.U) or input.keypressed(KEY.U) then
            addToMessage("u",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.V) or input.keypressed(KEY.V) then
            addToMessage("v",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.W) or input.keypressed(KEY.W) then
            addToMessage("w",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.X) or input.keypressed(KEY.X) then
            addToMessage("x",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.Y) or input.keypressed(KEY.Y) then
            addToMessage("y",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.Z) or input.keypressed(KEY.Z) then
            addToMessage("z",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | 48) or input.keypressed(48) then
            addToMessage("0",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | 49) or input.keypressed(49) then
            addToMessage("1",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | 50) or input.keypressed(50) then
            addToMessage("2",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | 51) or input.keypressed(51) then
            addToMessage("3",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | 52) or input.keypressed(52) then
            addToMessage("4",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | 53) or input.keypressed(53) then
            addToMessage("5",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | 54) or input.keypressed(54) then
            addToMessage("6",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | 55) or input.keypressed(55) then
            addToMessage("7",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | 56) or input.keypressed(56) then
            addToMessage("8",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | 57) or input.keypressed(57) then
            addToMessage("9",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.COMMA) or input.keypressed(KEY.COMMA) then
            addToMessage(",",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.PERIOD) or input.keypressed(KEY.PERIOD) then
            addToMessage(".",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.OEM_2) or input.keypressed(KEY.OEM_2) then
            addToMessage("/",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.OEM_7) or input.keypressed(KEY.OEM_7) then
            addToMessage("'",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.OEM_1) or input.keypressed(KEY.OEM_1) then
            addToMessage(";",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.MINUS) or input.keypressed(KEY.MINUS) then
            addToMessage("-",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.PLUS) or input.keypressed(KEY.PLUS) then
            addToMessage("=",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.OEM_4) or input.keypressed(KEY.OEM_4) then
            addToMessage("[",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.OEM_6) or input.keypressed(KEY.OEM_6) then
            addToMessage("]",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | KEY.OEM_3) or input.keypressed(KEY.OEM_3) then
            addToMessage("`",shift)
        end
        if input.keypressed(KEY.OL_MOD_SHIFT | 32) or input.keypressed(32) then
            addToMessage(" ",shift)
        end
    else
        if input.keypressed(KEY.OEM_2) then
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
set_global_interval(adjustFade,1)

--server callbacks
set_callback(timedOps, ON.GUIFRAME)
set_callback(startServer, ON.LOAD)
set_callback(unlockStuff, ON.LOAD)
set_callback(defaultValues, ON.SCRIPT_ENABLE)
set_callback(startServer, ON.SCRIPT_ENABLE)
set_callback(unlockStuff, ON.SCRIPT_ENABLE)
set_callback(stopServer, ON.SCRIPT_DISABLE)

set_callback(closeConnection, ON.MENU)
set_callback(unlockStuff, ON.MENU)
set_callback(closeConnection, ON.OPTIONS)
set_callback(closeConnection, ON.TITLE)
set_callback(closeConnection, ON.CHARACTER_SELECT)