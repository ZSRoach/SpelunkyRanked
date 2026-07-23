meta = {
    name = 'S2 Ranked',
    version = '1.20',
    component_version = '1.20.0',
    description = '1v1 Spelunky For Rank',
    author = 'ZSRoach',
    unsafe = true,
}

local button_prompts = require("ButtonPrompts/button_prompts")
local inputs = require("Inputs.inputs")
local tetris = require("Tetris/tetris_sign")

--constants
ratio = 16/9
seedChangeWindow = 45
drawVoteWindow = 45
f16 = 0xFFFFFFFFFFFFFFFF
white = Color:white()
black = Color:black()
yellow = Color:yellow()
red = Color:red()
green = Color:green()
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
    "Chain Low% Abzu",
    "Chain Low% Duat",
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
    "Cosmic Ocean%",
}
nonShopCategories = {
    "Low%",
    "Low% J/T",
    "No Gold Low%",
    "Chain Low% Abzu",
    "Chain Low% Duat",
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
    ENT_TYPE.ITEM_EXCALIBUR,
}
chainLowUseViolationItems = {
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
chainLowCOUseViolationItems = {
    ENT_TYPE.ITEM_WEBGUN,
    ENT_TYPE.ITEM_SHOTGUN,
    ENT_TYPE.ITEM_FREEZERAY,
    ENT_TYPE.ITEM_CLONEGUN,
    ENT_TYPE.ITEM_CAMERA,
    ENT_TYPE.ITEM_TELEPORTER,
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
    ENT_TYPE.ITEM_POWERUP_TRUECROWN,
    ENT_TYPE.ITEM_POWERUP_EGGPLANTCROWN,
}
chainLowExemptTypes = {
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
    ENT_TYPE.ITEM_POWERUP_ANKH,
    ENT_TYPE.ITEM_POWERUP_TABLETOFDESTINY,
    ENT_TYPE.ITEM_POWERUP_UDJATEYE,
    ENT_TYPE.ITEM_POWERUP_HEDJET,
    ENT_TYPE.ITEM_POWERUP_CROWN,
    ENT_TYPE.ITEM_POWERUP_EGGPLANTCROWN,
    ENT_TYPE.ITEM_POWERUP_TRUECROWN,
}
annoyingCritters = {
    ENT_TYPE.MONS_CRITTERLOCUST,
    ENT_TYPE.MONS_CRITTERFIREFLY,
    ENT_TYPE.MONS_CRITTERDRONE,
    ENT_TYPE.MONS_CRITTERPENGUIN,
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
myself = "name"
myelo = 0
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
buttonCooldown = false

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
forfeitConfirmation = false
fullResetConfirmation = false
activeSeedChange = false
endMatchConfirmation = false
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
signDelay = false
inQueue = false
banButtonIndex = 0
callbackList = {}
scrapCallbackList = {}
resendComplete = 0

-- menu related variables
menuPage = 0
mainMenuIndex = 0
mainMenuOpen = false
queueTime = 0
activeAlerts = {} -- list of current alerts 
alerting = false -- active alert
alertIndex = 0 -- input handle var

--private room menu variables
inPrivateRoom = false
privateRoomMenuOpen = false
privateRoomPage = 0
privatePage0Index = 0
privatePageColumn = 0
privatePageRow = 0
privateConfigPage = 0
privatePendingHost = false
privateHost = false
privateConfirmLeave = false
privateConfirmStart = false
privateCodeVisible = false
privateEnterCode = ""
privatePlayers = {}
privatePlayersProgress = {}
privateRoomCode = "XXXXX"
privateRunCustom = false
privateModifiers = {
    noPercent = false,
    lowPercent = false,
    noGold = false,
    noTP = false,
    pacifist = false,
    eggplant = false,
    chain = false,
}
privateWorld2 = 0
privateWorld4 = 0
privateFinish = -1
privateFinishLevel = 5
privateCategory = "Any%"
privateRandom = false
privateHourLimit = 0
privateMinuteLimit = 0
privateWinners = 1
privateDoCheckpoints = true
privateCheckpointDistance = 3

--practive menu variables
pracSignOpen = false
pracSignPage = 0
pracCatMode = true
pracCategory = "Any%"
pracWorld = 1
pracLevel = 1
pracBombs = 4
pracRopes = 4
pracHealth = 4
pracPack = nil
pracHeld = nil
pracPackSelected = 0
pracHeldSelected = 0
pracPassives = {}
signDelay = false
pracCheckpoints = false
practiceStarted = false

pracPage0Index = 0
pracPage1Row = 0
pracPage1Column = 0
pracPage1Selected = {0,0}
pracPage2Row = 0
pracPage2Column = 0

pracPage2Items1 = {
    {1,8},
    {3,6},
    {1,9},
    {1,7},
    {4,5},
    {4,4},
}
pracPage2Items2 = {
    {2,5},
    {2,6},
    {2,9},
    {3,1},
    {3,0},
    {5,0},
}
pracPage2Items3 = {
    {0,9},
    {0,8},
    {0,7},
    {0,6},
    {0,5},
    {0,4},
}
pracPage2Items4 = {
    {0,3},
    {1,1},
    {1,2},
    {1,3},
    {1,5},
    {3,8},
    {3,9},
}
pracPackList = {
    ENT_TYPE.ITEM_JETPACK,
    ENT_TYPE.ITEM_HOVERPACK,
    ENT_TYPE.ITEM_TELEPORTER_BACKPACK,
    ENT_TYPE.ITEM_CAPE,
    ENT_TYPE.ITEM_VLADS_CAPE,
    ENT_TYPE.ITEM_POWERPACK,
}
pracHeldList = {
    ENT_TYPE.ITEM_TELEPORTER,
    ENT_TYPE.ITEM_MATTOCK,
    ENT_TYPE.ITEM_EXCALIBUR,
    ENT_TYPE.ITEM_SCEPTER,
    ENT_TYPE.ITEM_PLASMACANNON,
    ENT_TYPE.ITEM_HOUYIBOW,
}
pracPassiveList1 = {
    ENT_TYPE.ITEM_POWERUP_COMPASS,
    ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES,
    ENT_TYPE.ITEM_POWERUP_SPRING_SHOES,
    ENT_TYPE.ITEM_POWERUP_PITCHERSMITT,
    ENT_TYPE.ITEM_POWERUP_CLIMBING_GLOVES,
    ENT_TYPE.ITEM_POWERUP_SPECTACLES,
}
pracPassiveList2 = {
    ENT_TYPE.ITEM_POWERUP_PASTE,
    ENT_TYPE.ITEM_POWERUP_UDJATEYE,
    ENT_TYPE.ITEM_POWERUP_KAPALA,
    ENT_TYPE.ITEM_POWERUP_HEDJET,
    ENT_TYPE.ITEM_POWERUP_ANKH,
    ENT_TYPE.ITEM_POWERUP_SKELETON_KEY,
    ENT_TYPE.ITEM_POWERUP_TABLETOFDESTINY,
}
pracLeftPassivesSelected = {
    false,
    false,
    false,
    false,
    false,
    false,
    false,
}
pracRightPassivesSelected = {
    false,
    false,
    false,
    false,
    false,
    false,
    false,
}
leftCategoryList = {
    "Any%",
    "Sunken City%",
    "Low%",
    "Cosmic Ocean%",
    "No TP No Gold",
    "Chain Low% Abzu",
    "No TP Abzu%",
    "Abzu%",
}
rightCategoryList = {
    "No TP Any%",
    "No TP Sunken City%",
    "Low% J/T",
    "No TP Eggplant%",
    "No Gold Low%",
    "Chain Low% Duat",
    "No TP Duat%",
    "Duat%",
}
privateLeftCategoryList = {
    "Any%",
    "Sunken City%",
    "Low%",
    "Cosmic Ocean%",
    "No TP No Gold",
    "Chain Low% Abzu",
    "No TP Abzu%",
    "Abzu%",
}
privateRightCategoryList = {
    "No TP Any%",
    "No TP Sunken City%",
    "Low% J/T",
    "No TP Eggplant%",
    "No Gold Low%",
    "Chain Low% Duat",
    "No TP Duat%",
    "Duat%",
}


--sets variable values to defaults when camp loaded first time - used post match
function defaultValues()
    practiceStarted = false
    forfeitConfirmation = false
    fullResetConfirmation = false
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
    myelo = 0
    banButtonIndex = 0
    banPhase = false
    opponent = "name"
    myself = "name"
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
    endMatchConfirmation = false
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
    inQueue = false
    buttonIndex = 0
end
--resets values to default that are related to the very start of a match, right after bans
function defaultMatchValues()
    practiceStarted = false
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
    forfeitConfirmation = false
    endMatchConfirmation = false
    fullResetConfirmation = false
end

function defaultReconnectValues()
    practiceStarted = false
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
-- resets values to default positionings in the main menu
function defaultMenu()
    privateRoomMenuOpen = false
    privateRoomPage = 0
    privatePage0Index = 0
    privatePageColumn = 0
    privatePageRow = 0
    privateConfigPage = 0
    menuPage = 0
    mainMenuIndex = 0
    mainMenuOpen = false
    pracSignOpen = false
    pracSignPage = 0
    pracPage0Index = 0
    pracPage1Row = 0
    pracPage1Column = 0
    pracPage1Selected = {0,0}
    pracPage2Row = 0
    pracPage2Column = 0
end
-- resets private room configs to defaults
function defaultPrivate()
    privateConfigPage = 0
    privateConfirmLeave = false
    privateConfirmStart = false
    privateCodeVisible = false
    privateRunCustom = false
    privateModifiers = {
        noPercent = false,
        lowPercent = false,
        noGold = false,
        noTP = false,
        pacifist = false,
        eggplant = false,
        chain = false,
    }
    privateWorld2 = 0
    privateWorld4 = 0
    privateFinish = -1
    privateFinishLevel = 5
    privateCategory = "Any%"
    privateRandom = false
    privateHourLimit = 0
    privateMinuteLimit = 0
    privateWinners = 1
    privateDoCheckpoints = true
    privateCheckpointDistance = 3
end

--camp functions
function spawnSign()
    if not inPrivateRoom or not pracSignOpen then
        mainMenuOpen = false
    end
    local signUID = spawn_entity(ENT_TYPE.ITEM_SPEEDRUN_SIGN, 46, 84, LAYER.FRONT, 0, 0)
    sign = get_entity(signUID)
    sign.flags = clr_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
    if matchStarted and not changingSeed then
        if inPrivateRoom then return end
        processChat("Interact with the sign to continue the match!","Match Info")
        button_prompts.spawn_button_prompt_on(button_prompts.PROMPT_TYPE.INTERACT, signUID, function()
            force11()
        end)
    else
        button_prompts.spawn_button_prompt_on(button_prompts.PROMPT_TYPE.INTERACT, signUID, function()
            if postMatch or matchStarted then return end
            if signDelay then return end
            defaultMenu()
            mainMenuOpen = true
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

function keyTranslation(k)
    for name, value in pairs(RAW_KEY) do
        if value == k then
            return KEY[name]
        end
    end
    return nil
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
    local y = .5
    local scale = 2
    for xoffset = 0, 2, 1 do
        local newx = x + (xoffset*scale/10)
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_DEATHMATCH2_0, 7, 7+xoffset, y,newx,scale)
    end
    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3, 6, y-.025, x+.05, scale-.5)
    local minutes = queueTime//60
    local seconds = queueTime%60
    if seconds < 10 then 
        seconds = "0"..seconds
    end
    renderTextLeft(render_ctx, "In queue | "..minutes..":"..seconds, (x+.05)+((scale-.5)/10)*.9,(y-scale/20)*ratio,.0013,white)
    
end

function renderMatchInfoToast(render_ctx)
    --hard code toast location
    local x = -1.05
    local x2 = -1.1
    local y = .5
    local y2 = .32
    local scale = 2
    local scale2 = 1.5
    for xoffset = 0, 2, 1 do
        local newx = x + (xoffset*scale/10)
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_DEATHMATCH2_0, 7, 7+xoffset, y,newx,scale)
    end
    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 2, 4, y-.025, x+.05, scale-.5)
    renderTextLeft(render_ctx, "Match found | "..countdownTime(), (x+.05)+((scale-.5)/10)*.9,(y-scale/20)*ratio,.0012,white)

    for i = 0, 3, 1 do
        renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_MENU_BASIC_2,5,3+i,y2,x2+i*(scale/10),scale)
    end
    renderTextLeft(render_ctx, "["..opponentelo.."] "..opponent, (x+.05)+(scale/10)*.2,(y2-(scale/20))*ratio, .008, white)
end



--handles all inputs for main menu
function menuInputHandle()
    if chatting or buttonCooldown then return end
    local input = get_io()
    -- input.wantkeyboard = true
    local back = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.bomb)
    local confirm = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.jump)
    local up = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.up)
    local down = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.down)
    local left = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.left)
    local right = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.right)
    
    blockInputs()

    local function buttonStandardization()
        privateCodeVisible = false
        privatePageColumn = 0 
        privatePageRow = 0
    end

    if pracSignOpen then --menu page 2
        if pracSignPage == 0 then
            if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_UP) or inputs.gamepad_button_press(inputs.GAMEPAD.UP) then
                pracPage0Index = (pracPage0Index - 1)%4
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_DOWN) or inputs.gamepad_button_press(inputs.GAMEPAD.DOWN) then
                pracPage0Index = (pracPage0Index +1)%4
            end
            if inputs.key_press(inputs.KEYBOARD.UP_ARROW) or inputs.key_press(inputs.KEYBOARD.W) or input.keypressed(up) then
                pracPage0Index = (pracPage0Index - 1)%4
            end
            if inputs.key_press(inputs.KEYBOARD.DOWN_ARROW) or inputs.key_press(inputs.KEYBOARD.S) or input.keypressed(down) then
                pracPage0Index = (pracPage0Index + 1)%4
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                if pracPage0Index == 0 then
                    pracCatMode = not pracCatMode
                elseif pracPage0Index == 1 then
                    if pracCatMode then
                        pracSignPage = 1
                    else
                        pracSignPage = 2
                    end
                elseif pracPage0Index == 2 then
                    practiceStarted = true
                    mainMenuOpen = false
                    pracSignOpen = false
                    returnInputs()
                    practiceWarp()
                    processChat("Return to camp or finish a run to end practice.", "Info")
                elseif pracPage0Index == 3 then
                    pracSignOpen = false
                    menuPage = 0
                    pracPage0Index = 0
                end
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                pracSignOpen = false
                pracPage0Index = 0
                menuPage = 0
            end
        elseif pracSignPage == 1 then
            if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_UP) or inputs.gamepad_button_press(inputs.GAMEPAD.UP) then
                if pracPage1Column ~= 2 then
                    pracPage1Row = (pracPage1Row - 1)%7
                end
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_DOWN) or inputs.gamepad_button_press(inputs.GAMEPAD.DOWN) then
                if pracPage1Column ~= 2 then
                    pracPage1Row = (pracPage1Row + 1)%7
                end
            end
            if inputs.key_press(inputs.KEYBOARD.UP_ARROW) or inputs.key_press(inputs.KEYBOARD.W) or input.keypressed(up) then
                if pracPage1Column ~= 2 then
                    pracPage1Row = (pracPage1Row - 1)%7
                end
            end
            if inputs.key_press(inputs.KEYBOARD.DOWN_ARROW) or inputs.key_press(inputs.KEYBOARD.S) or input.keypressed(down) then
                if pracPage1Column ~= 2 then
                    pracPage1Row = (pracPage1Row + 1)%7
                end
            end
            if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                pracPage1Column = (pracPage1Column-1)%3
            end
            if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                pracPage1Column = (pracPage1Column+1)%3
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                if pracPage1Column == 2 then
                    pracCheckpoints = not pracCheckpoints
                elseif pracPage1Column == 1 then
                    pracPage1Selected = {pracPage1Column, pracPage1Row}
                    pracCategory = rightCategoryList[pracPage1Row+1]
                elseif pracPage1Column == 0 then
                    pracPage1Selected = {pracPage1Column, pracPage1Row}
                    pracCategory = leftCategoryList[pracPage1Row+1]
                end
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                pracSignPage = 0
                pracPage1Column = 0
                pracPage1Row = 0
            end
        elseif pracSignPage == 2 then
            if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_UP) or inputs.gamepad_button_press(inputs.GAMEPAD.UP) or inputs.key_press(inputs.KEYBOARD.UP_ARROW) or inputs.key_press(inputs.KEYBOARD.W) or input.keypressed(up) then
                if pracPage2Column <= 3 then
                    pracPage2Row = (pracPage2Row-1)%7
                elseif pracPage2Column == 4 or pracPage2Column == 6 or pracPage2Column == 8 then
                    if pracPage2Row == 0 then
                        pracPage2Row = 2
                    else
                        pracPage2Row = 0
                    end
                elseif pracPage2Column == 5 or pracPage2Column == 7 then
                    if pracPage2Row == 4 then
                        pracPage2Row = 6
                    else
                        pracPage2Row = 4
                    end
                end
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_DOWN) or inputs.gamepad_button_press(inputs.GAMEPAD.DOWN) or inputs.key_press(inputs.KEYBOARD.DOWN_ARROW) or inputs.key_press(inputs.KEYBOARD.S) or input.keypressed(down) then
                if pracPage2Column <= 3 then
                    pracPage2Row = (pracPage2Row+1)%7
                elseif pracPage2Column == 4 or pracPage2Column == 6 or pracPage2Column == 8 then
                    if pracPage2Row == 0 then
                        pracPage2Row = 2
                    else
                        pracPage2Row = 0
                    end
                elseif pracPage2Column == 5 or pracPage2Column == 7 then
                    if pracPage2Row == 4 then
                        pracPage2Row = 6
                    else
                        pracPage2Row = 4
                    end
                end
            end
            if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                if pracPage2Column == 6 or pracPage2Column == 8 or pracPage2Column == 7 or pracPage2Column == 5 then
                    pracPage2Column = (pracPage2Column-2)%9
                elseif pracPage2Column == 0 then
                    if pracPage2Row <=1 then
                        pracPage2Column = (pracPage2Column-1)%9
                        pracPage2Row = 0
                    elseif pracPage2Row<=3 then
                        pracPage2Column = (pracPage2Column-1)%9
                        pracPage2Row = 2
                    elseif pracPage2Row<=5 then
                        pracPage2Column = (pracPage2Column-1)%9
                        pracPage2Row = 4
                    elseif pracPage2Row<=7 then
                        pracPage2Column = (pracPage2Column-1)%9
                        pracPage2Row = 6
                    end
                else
                    pracPage2Column = (pracPage2Column-1)%9
                end
            end
            if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                if pracPage2Column == 4 or pracPage2Column == 5 or pracPage2Column == 6 or pracPage2Column == 7 then
                    pracPage2Column = (pracPage2Column+2)%9
                elseif pracPage2Column == 3 then
                    if pracPage2Row <=1 then
                        pracPage2Column = (pracPage2Column+1)%9
                        pracPage2Row = 0
                    elseif pracPage2Row<=3 then
                        pracPage2Column = (pracPage2Column+1)%9
                        pracPage2Row = 2
                    elseif pracPage2Row<=5 then
                        pracPage2Column = (pracPage2Column+2)%9
                        pracPage2Row = 4
                    elseif pracPage2Row<=7 then
                        pracPage2Column = (pracPage2Column+2)%9
                        pracPage2Row = 6
                    end
                else
                    pracPage2Column = (pracPage2Column+1)%9
                end
            end
            if inputs.key_press(inputs.KEYBOARD.RETURN) or inputs.gamepad_button_press(inputs.GAMEPAD.A) or input.keypressed(confirm) then
                if pracPage2Row == 0 then
                    if pracPage2Column == 0 then
                        pracPackSelected = 0
                        pracPack = nil
                    elseif pracPage2Column == 1 then
                        pracHeldSelected = 0
                        pracHeld = nil
                    elseif pracPage2Column == 2 then
                        pracPassives = {}
                        for i, value in ipairs(pracLeftPassivesSelected) do
                            pracLeftPassivesSelected[i] = false
                        end
                        for i, value in ipairs(pracRightPassivesSelected) do
                            pracRightPassivesSelected[i] = false
                            
                        end
                    elseif pracPage2Column == 3 then
                        if not pracRightPassivesSelected[pracPage2Row+1] then
                            table.insert(pracPassives, pracPassiveList2[pracPage2Row+1])
                            pracRightPassivesSelected[pracPage2Row+1] = true
                        end
                    elseif pracPage2Column == 4 then
                        if pracHealth <99 then
                            pracHealth = pracHealth + 1
                        end
                    elseif pracPage2Column == 6 then
                        if pracBombs < 99 then
                            pracBombs= pracBombs+1
                        end
                    elseif pracPage2Column == 8 then
                        if pracRopes < 99 then
                            pracRopes =pracRopes+ 1
                        end
                    end
                elseif pracPage2Column < 4 then
                    if pracPage2Column == 0 then
                        pracPack = pracPackList[pracPage2Row]
                        pracPackSelected = pracPage2Row
                    elseif pracPage2Column == 1 then
                        pracHeld = pracHeldList[pracPage2Row]
                        pracHeldSelected = pracPage2Row
                    elseif pracPage2Column == 2 then
                        if not pracLeftPassivesSelected[pracPage2Row+1] then
                            table.insert(pracPassives, pracPassiveList1[pracPage2Row])
                            pracLeftPassivesSelected[pracPage2Row+1] = true
                        end
                    else
                        if not pracRightPassivesSelected[pracPage2Row+1] then
                            table.insert(pracPassives, pracPassiveList2[pracPage2Row+1])
                            pracRightPassivesSelected[pracPage2Row+1] = true
                        end
                    end
                elseif pracPage2Column == 4 then
                    if pracHealth > 1 then 
                        pracHealth= pracHealth- 1
                    end
                elseif pracPage2Column == 5 then
                    if pracPage2Row == 4 then
                        if pracWorld < 9 then
                            pracWorld = pracWorld + 1
                        end
                    else
                        if pracWorld > 1 then
                            pracWorld = pracWorld -1
                        end 
                    end
                    if pracWorld == 4 or pracWorld == 7 then
                        pracLevel = 1
                    elseif pracWorld ~= 9 then
                        if pracLevel > 4 then
                            pracLevel = 4
                        end
                    end
                elseif pracPage2Column == 6 then
                    if pracBombs > 0 then
                        pracBombs = pracBombs - 1
                    end
                elseif pracPage2Column == 7 then
                    if pracPage2Row == 4 then
                        pracLevel = (pracLevel+1)
                    else
                        pracLevel = pracLevel-1
                    end
                    if pracWorld == 4 or pracWorld == 7 then
                        pracLevel = 1
                    elseif pracWorld ~= 9 then
                        if pracLevel > 4 then
                            pracLevel = 4
                        end
                    end
                    if pracLevel < 1 then
                        pracLevel = 1
                    end
                    if pracLevel > 98 then
                        pracLevel = 98
                    end
                elseif pracPage2Column == 8 then
                    if pracRopes > 0 then
                        pracRopes = pracRopes -1 
                    end
                end
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                pracSignPage = 0
                pracPage2Column = 0
                pracPage2Row = 0
            end
        end
    elseif menuPage == 1 then -- queue page = menu page 1
        if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
            if not inQueue and bridgeConnected then
                udpSend("queue_ready")
                inQueue = true
                queueTime = 0
            elseif inQueue and bridgeConnected then
                udpSend("queue_leave")
                inQueue = false
            elseif not bridgeConnected then
                inQueue = false
                processChat("Your game is not connected to the Ranked Server.", "WARN")
            end
        end
        if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
            menuPage = 0
        end
    elseif privateRoomMenuOpen then -- privateroom menu collection exists in menu page 3
        if privateRoomPage == 0 then -- host/join decision page
            if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                menuPage = 0
                privateRoomMenuOpen = false
            end
            if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                privatePage0Index = (privatePage0Index-1)%2
            end
            if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                privatePage0Index = (privatePage0Index+1)%2
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                if privatePage0Index == 0 then -- tell server to make new private room, receive room data w/ ack.
                    udpSend("create_room")
                    privatePendingHost = true
                    registerAlert(3, "temporary", "Attempting to create room...")
                else
                    privateRoomPage = 1
                    buttonStandardization()
                end
            end
        elseif privateRoomPage == 1 then -- join page (code input)
            local function buttonDecode(row, col)
                local codeInputs = {"A","B","C","D","1","2","3","4",}
                return codeInputs[(row*4)+col+1]
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                privateRoomPage = 0
                privateEnterCode = ""
                buttonStandardization()
            end
            if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                if privatePageRow ~= 2 then
                    privatePageColumn = (privatePageColumn-1)%4
                else
                    privatePageColumn = (privatePageColumn%2)+1
                end
            end
            if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                if privatePageRow ~= 2 then
                    privatePageColumn = (privatePageColumn+1)%4
                else
                    privatePageColumn = (privatePageColumn%2)+1
                end
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_UP) or inputs.gamepad_button_press(inputs.GAMEPAD.UP) or inputs.key_press(inputs.KEYBOARD.UP_ARROW) or inputs.key_press(inputs.KEYBOARD.W) or input.keypressed(up) then
                if privatePageColumn == 0 or privatePageColumn == 3 then    
                    privatePageRow = (privatePageRow-1)%2
                else
                    privatePageRow = (privatePageRow-1)%3
                end
            end
            if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_DOWN) or inputs.gamepad_button_press(inputs.GAMEPAD.DOWN) or inputs.key_press(inputs.KEYBOARD.DOWN_ARROW) or inputs.key_press(inputs.KEYBOARD.S) or input.keypressed(down) then
                if privatePageColumn == 0 or privatePageColumn == 3 then    
                    privatePageRow = (privatePageRow+1)%2
                else
                    privatePageRow = (privatePageRow+1)%3
                end
            end
            if inputs.key_press(inputs.KEYBOARD.RETURN) or inputs.gamepad_button_press(inputs.GAMEPAD.A) or input.keypressed(confirm) then
                if privatePageRow ~= 2 then
                    if #privateEnterCode < 5 then
                        privateEnterCode = privateEnterCode..buttonDecode(privatePageRow, privatePageColumn)
                    end
                else
                    if privatePageColumn == 1 then
                        privateEnterCode = ""
                    else
                        if #privateEnterCode ~= 5 then
                            local error = get_sound(VANILLA_SOUND.SHOP_SHOP_NOPE)
                            local sound = error:play(false)
                        else -- send code to server, wait for information receive, ack on receive
                            local payload = {privateEnterCode}
                            udpSend("join_room", payload)
                            privatePendingHost = false
                            registerAlert(3, "temporary", "Attempting to join...")
                        end
                    end
                end
            end


        elseif privateRoomPage == 2 then -- private lobby
            if privateHost then
                if not privateConfirmLeave and not privateConfirmStart then -- confirmation window not open
                    if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                        privatePageColumn = (privatePageColumn-1)%5
                    end
                    if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                        privatePageColumn = (privatePageColumn+1)%5
                    end
                    if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                        privateConfirmLeave = true
                    end
                    if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                        if privatePageColumn == 0 then -- leave
                            privateConfirmLeave = true
                        elseif privatePageColumn == 1 then -- config
                            privateRoomPage = 3
                            buttonStandardization()
                        elseif privatePageColumn == 2 then --tetris
                            privateRoomPage = 4
                            buttonStandardization()
                            tetris.open()
                        elseif privatePageColumn == 3 then -- show code
                            privateCodeVisible = not privateCodeVisible
                        elseif privatePageColumn == 4 then --start
                            privateConfirmStart = true
                        end
                    end
                else -- confirmation window open
                    if privateConfirmLeave then -- confirm for leaving private room as host
                        if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                            privateConfirmLeave = false
                            privatePageRow = 0
                        end
                        if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                            if privatePageRow == 0 then 
                                privatePageRow = 0
                            else -- leaving the private room as host, tell server, wait for ack
                                udpSend("leave_room")
                                privatePageRow = 0
                            end
                            privateConfirmLeave = false
                        end
                        if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                            privatePageRow = (privatePageRow-1)%2
                        end
                        if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                            privatePageRow = (privatePageRow+1)%2
                        end
                    else --confirm for starting private room
                        if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                            privateConfirmStart = false
                            privatePageRow = 0
                        end
                        if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                            if privatePageRow == 0 then 
                                privatePageRow = 0
                            else -- starting the private room, tell server, wait for ack
                                privatePageRow = 0
                                udpSend("start_room")
                            end
                            privateConfirmStart = false
                        end
                        if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                            privatePageRow = (privatePageRow-1)%2
                        end
                        if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                            privatePageRow = (privatePageRow+1)%2
                        end
                    end
                end
                
            else
                if not privateConfirmLeave then
                    if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                        privatePageColumn = (privatePageColumn-1)%3
                    end
                    if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                        privatePageColumn = (privatePageColumn+1)%3
                    end
                    if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                        privateConfirmLeave = true
                    end
                    if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                        if privatePageColumn == 0 then--leave
                            privateConfirmLeave = true
                        elseif privatePageColumn == 1 then -- tetris
                            privateRoomPage = 4
                            buttonStandardization()
                            tetris.open()
                        elseif privatePageColumn == 2 then--show code
                            privateCodeVisible = not privateCodeVisible
                        end
                    end
                else -- leave confirmation open
                    if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                        privateConfirmLeave = false
                        privatePageRow = 0
                    end
                    if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                        if privatePageRow == 0 then 

                        else -- leaving as non host, tell server, wait for ack
                            udpSend("leave_room")
                        end
                        privateConfirmLeave = false
                        privatePageRow = 0
                    end
                    if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                        privatePageRow = (privatePageRow-1)%2
                    end
                    if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                        privatePageRow = (privatePageRow+1)%2
                    end
                end
            end
        elseif privateRoomPage == 3 then -- config
            local function updateConfig(page)
                local payload = {}
                if page == 1 then
                    payload.runCustom = privateRunCustom
                elseif page == 2 then
                    payload.category = privateCategory
                    payload.random = privateRandom
                elseif page == 3 then
                    payload.modifiers = privateModifiers
                    payload.world2 = privateWorld2
                    payload.world4 = privateWorld4
                    payload.finish = privateFinish
                    payload.finishLevel = privateFinishLevel
                elseif page == 4 then
                    payload.hourLimit = privateHourLimit
                    payload.minuteLimit = privateMinuteLimit
                    payload.winners = privateWinners
                    payload.doCheckpoints = privateDoCheckpoints
                    payload.checkpointDistance = privateCheckpointDistance
                elseif page == -1 then
                    payload.runCustom = privateRunCustom
                    payload.category = privateCategory
                    payload.random = privateRandom
                    payload.modifiers = privateModifiers
                    payload.world2 = privateWorld2
                    payload.world4 = privateWorld4
                    payload.finish = privateFinish
                    payload.finishLevel = privateFinishLevel
                    payload.hourLimit = privateHourLimit
                    payload.minuteLimit = privateMinuteLimit
                    payload.winners = privateWinners
                    payload.doCheckpoints = privateDoCheckpoints
                    payload.checkpointDistance = privateCheckpointDistance
                end
                udpSend("update_room_config",payload)
            end
            if privateConfigPage == 0 then -- game/cat sidebar
                if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                    privateRoomPage = 2
                    buttonStandardization()
                    updateConfig(-1)
                end
                if inputs.key_press(inputs.KEYBOARD.UP_ARROW) or inputs.key_press(inputs.KEYBOARD.W) or input.keypressed(up) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_UP) or inputs.gamepad_button_press(inputs.GAMEPAD.UP) then
                    privatePageRow = (privatePageRow + 1)%2
                end
                if inputs.key_press(inputs.KEYBOARD.DOWN_ARROW) or inputs.key_press(inputs.KEYBOARD.S) or input.keypressed(down) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_DOWN) or inputs.gamepad_button_press(inputs.GAMEPAD.DOWN) then
                    privatePageRow = (privatePageRow - 1)%2
                end
                if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                    if privatePageRow == 0 then -- cat settings
                        privateConfigPage = 1
                        buttonStandardization()
                    else -- game settings
                        privateConfigPage = 4
                        buttonStandardization()
                    end
                end
            elseif privateConfigPage == 1 then -- cat main page
                if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                    privateConfigPage = 0
                    buttonStandardization()
                    updateConfig(1)
                end
                if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                    privatePageColumn = (privatePageColumn+ 1)%2
                end
                if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                    privatePageColumn = (privatePageColumn - 1)%2
                end
                if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                    if privatePageColumn == 0 then -- change preset/custom mode
                        privateRunCustom = not privateRunCustom
                    else -- category settings
                        if privateRunCustom then
                            privateConfigPage = 3
                        else
                            privateConfigPage = 2
                        end
                        buttonStandardization()
                    end
                    updateConfig(1)
                end
            elseif privateConfigPage == 2 then -- preset cat
                if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                    privateConfigPage = 1
                    buttonStandardization()
                    updateConfig(2)
                end
                if inputs.key_press(inputs.KEYBOARD.UP_ARROW) or inputs.key_press(inputs.KEYBOARD.W) or input.keypressed(up) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_UP) or inputs.gamepad_button_press(inputs.GAMEPAD.UP) then
                    privatePageRow = (privatePageRow - 1)%8
                end
                if inputs.key_press(inputs.KEYBOARD.DOWN_ARROW) or inputs.key_press(inputs.KEYBOARD.S) or input.keypressed(down) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_DOWN) or inputs.gamepad_button_press(inputs.GAMEPAD.DOWN) then
                    privatePageRow = (privatePageRow + 1)%8
                end
                if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                    privatePageColumn = (privatePageColumn+ 1)%3
                end
                if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                    privatePageColumn = (privatePageColumn - 1)%3
                end
                if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                    if privatePageColumn == 2 then
                        privateRandom = not privateRandom
                    end
                    if privatePageColumn == 0 then
                        privateCategory = privateLeftCategoryList[privatePageRow+1]
                        privateRandom = false
                    end
                    if privatePageColumn == 1 then
                        privateCategory = privateRightCategoryList[privatePageRow+1]
                        privateRandom = false
                    end
                    updateConfig(2)
                end
            elseif privateConfigPage == 3 then -- customize cat
                if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                    privateConfigPage = 1
                    buttonStandardization()
                    updateConfig(3)
                end
                if inputs.key_press(inputs.KEYBOARD.UP_ARROW) or inputs.key_press(inputs.KEYBOARD.W) or input.keypressed(up) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_UP) or inputs.gamepad_button_press(inputs.GAMEPAD.UP) then
                    if privatePageRow == 0 and privatePageColumn > 1 and privatePageColumn < 9 then
                        privatePageRow = 3
                        if privatePageColumn == 5 then
                            privatePageColumn = 4
                        end
                    elseif privatePageRow == 0 and privatePageColumn < 1 then
                        privatePageRow = 3
                        privatePageColumn = 2
                    elseif privatePageRow == 0 and privatePageColumn > 9 then
                        privatePageRow = 3
                        privatePageColumn = 8
                    elseif privatePageRow == 1 then
                        privatePageRow = 0 
                    elseif privatePageRow == 2 then
                        if privatePageColumn == 8 and privateFinish == 1 then
                            privatePageRow = 1
                        else
                            privatePageRow = 0
                        end
                    elseif privatePageRow == 3 then
                        privatePageRow = 2
                    end
                end
                if inputs.key_press(inputs.KEYBOARD.DOWN_ARROW) or inputs.key_press(inputs.KEYBOARD.S) or input.keypressed(down) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_DOWN) or inputs.gamepad_button_press(inputs.GAMEPAD.DOWN) then
                    if privatePageRow == 0 and privatePageColumn <=2 then
                        privatePageRow = 2
                        privatePageColumn = 2
                    elseif privatePageRow == 0 and privatePageColumn >= 8 then
                        if privateFinish == 1 then
                            privatePageRow = 1
                            if privatePageColumn == 9 then
                                privatePageColumn = 8
                            end
                        else
                            privatePageRow = 2
                            privatePageColumn = 8
                        end
                    elseif privatePageRow == 0 and privatePageColumn == 5 then
                        privatePageRow = 2
                        privatePageColumn = 4
                    elseif privatePageRow == 0  then
                        privatePageRow = 2
                    elseif privatePageRow == 1 then
                        privatePageRow = 2
                        privatePageColumn = 8
                    elseif privatePageRow == 2 then
                        privatePageRow = 3
                    elseif privatePageRow == 3 then
                        privatePageRow = 0
                    end
                end
                if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                    if privatePageRow == 0 then
                        if privatePageColumn == 2 or privatePageColumn == 6 then
                            privatePageColumn = privatePageColumn + 2
                        elseif privatePageColumn == 10 then
                            privatePageColumn = 0
                        else
                            privatePageColumn = privatePageColumn + 1
                        end
                    elseif privatePageRow == 1 then
                        if privatePageColumn == 8 then
                            privatePageColumn = 10
                        else 
                            privatePageColumn = 8
                        end
                    elseif privatePageRow == 2 then
                        privatePageColumn = privatePageColumn + 2
                        if privatePageColumn > 8 then
                            privatePageColumn = 2
                        end
                    elseif privatePageRow == 3 then
                        privatePageColumn = privatePageColumn + 2
                        if privatePageColumn > 8 then
                            privatePageColumn = 2
                        end
                    end
                end
                if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                    if privatePageRow == 0 then
                        if privatePageColumn == 4 or privatePageColumn == 8 then
                            privatePageColumn = privatePageColumn - 2
                        elseif privatePageColumn == 0 then
                            privatePageColumn = 10
                        else
                            privatePageColumn = privatePageColumn - 1
                        end
                    elseif privatePageRow == 1 then
                        if privatePageColumn == 8 then
                            privatePageColumn = 10
                        else 
                            privatePageColumn = 8
                        end
                    elseif privatePageRow == 2 then
                        privatePageColumn = privatePageColumn - 2
                        if privatePageColumn < 2 then
                            privatePageColumn = 8
                        end
                    elseif privatePageRow == 3 then
                        privatePageColumn = privatePageColumn - 2
                        if privatePageColumn < 2 then
                            privatePageColumn = 8
                        end
                    end
                end
                if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                    if privatePageRow == 0 then
                        if privatePageColumn == 0 then
                            privateWorld2 = 1
                        elseif privatePageColumn == 1 then
                            privateWorld2 = 0
                        elseif privatePageColumn == 2 then
                            privateWorld2 = 2
                        elseif privatePageColumn == 4 then
                            privateWorld4 = 1
                        elseif privatePageColumn == 5 then
                            privateWorld4 = 0 
                        elseif privatePageColumn == 6 then
                            privateWorld4 = 2
                        elseif privatePageColumn == 8 then
                            privateFinish = -1
                        elseif privatePageColumn == 9 then
                            privateFinish = 0
                        elseif privatePageColumn == 10 then
                            privateFinish = 1
                        end
                    elseif privatePageRow == 1 then
                        if privatePageColumn == 8 then
                            privateFinishLevel = 5+(privateFinishLevel - 6)%95
                        elseif privatePageColumn == 10 then
                            privateFinishLevel = 5+(privateFinishLevel-4)%95
                        end
                    elseif privatePageRow == 2 then
                        if privatePageColumn == 2 then
                            privateModifiers.noPercent = not privateModifiers.noPercent
                            if privateModifiers.noPercent then 
                                privateModifiers.lowPercent = true
                                privateModifiers.noGold = true
                                privateModifiers.noTP = true
                            end
                        elseif privatePageColumn == 4 then
                            privateModifiers.lowPercent = not privateModifiers.lowPercent
                            if privateModifiers.lowPercent then
                                privateModifiers.noTP = true
                            else
                                privateModifiers.noPercent = false
                            end
                        elseif privatePageColumn == 6 then
                            privateModifiers.noGold = not privateModifiers.noGold
                            if privateModifiers.noGold then
                            else
                                privateModifiers.noPercent = false
                            end
                        elseif privatePageColumn == 8 then
                            privateModifiers.noTP = not privateModifiers.noTP
                            if privateModifiers.noTP then 
                            else
                                privateModifiers.lowPercent = false
                                privateModifiers.noPercent = false
                            end
                        end
                    elseif privatePageRow == 3 then
                        if privatePageColumn == 2 then
                            privateModifiers.pacifist = not privateModifiers.pacifist
                        elseif privatePageColumn == 4 then
                            privateModifiers.eggplant = not privateModifiers.eggplant
                        elseif privatePageColumn == 6 then
                            privateModifiers.chain = not privateModifiers.chain
                        elseif privatePageColumn == 8 then  
                            privateModifiers.noPercent = false
                            privateModifiers.lowPercent = false
                            privateModifiers.noGold = false
                            privateModifiers.noTP = false
                            privateModifiers.eggplant = false
                            privateModifiers.pacifist = false
                            privateModifiers.chain = false
                        end
                    end
                    updateConfig(3)
                end
            elseif privateConfigPage == 4 then -- game settings
                if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                    privateConfigPage = 0
                    buttonStandardization()
                    privatePageRow = 1
                    updateConfig(4)
                end
                if inputs.key_press(inputs.KEYBOARD.UP_ARROW) or inputs.key_press(inputs.KEYBOARD.W) or input.keypressed(up) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_UP) or inputs.gamepad_button_press(inputs.GAMEPAD.UP) then
                    if privatePageColumn ~= 3 then
                        if privatePageRow == 0 then
                            privatePageRow = 2
                        else
                            privatePageRow = 0
                        end
                    end
                end
                if inputs.key_press(inputs.KEYBOARD.DOWN_ARROW) or inputs.key_press(inputs.KEYBOARD.S) or input.keypressed(down) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_DOWN) or inputs.gamepad_button_press(inputs.GAMEPAD.DOWN) then
                    if privatePageColumn ~= 3 then
                        if privatePageRow == 0 then
                            privatePageRow = 2
                        else
                            privatePageRow = 0
                        end
                    end
                end
                if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
                    if privatePageColumn == 3 then
                        privatePageRow = 0
                    end
                    privatePageColumn = (privatePageColumn + 1)%5
                    if privatePageColumn == 3 then
                        privatePageRow = 1
                    end
                end
                if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
                    if privatePageColumn == 3 then
                        privatePageRow = 0
                    end
                    privatePageColumn = (privatePageColumn - 1)%5
                    if privatePageColumn == 3 then
                        privatePageRow = 1
                    end
                end
                if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
                    if privatePageRow == 1 then
                        privateDoCheckpoints = not privateDoCheckpoints
                    elseif privatePageRow == 0 then
                        if privatePageColumn == 0 then
                            privateHourLimit = (privateHourLimit + 1)%10
                        elseif privatePageColumn == 1 then
                            privateMinuteLimit = (privateMinuteLimit+1)%60
                        elseif privatePageColumn == 2 then
                            privateWinners = 1+(privateWinners)%7
                        elseif privatePageColumn == 4 then
                            privateCheckpointDistance = (privateCheckpointDistance+1)%10
                        end
                    elseif privatePageRow == 2 then
                        if privatePageColumn == 0 then
                            privateHourLimit = (privateHourLimit - 1)%10
                        elseif privatePageColumn == 1 then
                            privateMinuteLimit = (privateMinuteLimit-1)%60
                        elseif privatePageColumn == 2 then
                            privateWinners = 1+(privateWinners-2)%7
                        elseif privatePageColumn == 4 then
                            privateCheckpointDistance = (privateCheckpointDistance-1)%10
                        end
                    end
                    updateConfig(4)
                end
            end
        elseif privateRoomPage == 4 then -- tetris
            if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
                tetris.reset_game()
                tetris.close()
                privateRoomPage = 2
                buttonStandardization()
            end
        end

    elseif menuPage == 4 then -- preMatch (bans, match found)

    else -- regular main menu on page 0
        if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
            mainMenuIndex = (mainMenuIndex-1)%3
        end
        if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
            mainMenuIndex = (mainMenuIndex+1)%3
        end
        if inputs.gamepad_button_press(inputs.GAMEPAD.A) or inputs.key_press(inputs.KEYBOARD.RETURN) or input.keypressed(confirm) then
            if mainMenuIndex == 0 then
                menuPage = 1
            elseif mainMenuIndex == 1 then
                pracSignOpen = true
                pracSignPage = 0
                pracPage0Index = 0
                menuPage = 2
            else
                privateRoomMenuOpen = true
                privateRoomPage = 0
                privatePageColumn = 0
                privatePage0Index = 0
                privatePageRow = 0
                menuPage = 3
            end
        end
        if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
            mainMenuOpen = false
            returnInputs()
            signDelay = true
            set_global_timeout(function()
                signDelay = false
            end, 10)
        end
    end
end

function closeTetrisIfActive()
    if privateRoomPage==4 then
        tetris.reset_game()
        tetris.close()
    end
end

--renders main menu background
function renderMenuBG(render_ctx)
    --background
    local position = AABB:new(-1, 1, 1, -1)
    render_ctx:draw_screen_texture(TEXTURE.DATA_TEXTURES_MENU_GENERIC_0, 0, 0, position, white) 
end
--handles central hub menu rendering
function renderMainMenu(render_ctx)
    local left = -.5
    local right = .5
    local width = math.abs(left)+right
    local buttonScale = width/.4
    local top = buttonScale/20
    local margin = (width - (buttonScale/10))

    for num = 0, 2, 1 do
        if mainMenuIndex == num then
            renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top, left+(num*(margin/2)),buttonScale)
        else
            renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top, left+(num*(margin/2)),buttonScale)
        end
        if num == 0 then
            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_ITEMS_0,1,4, top, left+(num*(margin/2))+buttonScale*.01, buttonScale/1.3)
            renderText(render_ctx, "Queue", left+(num*(margin/2))+buttonScale/20, top-(buttonScale/10)*1.7,.0018, white)
        end
        if num == 1 then
            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_LEADER_0, 9, 9, top-buttonScale*.01, left+(num*(margin/2))+buttonScale*.01, buttonScale/1.3)
            renderText(render_ctx, "Practice", left+(num*(margin/2))+buttonScale/20, top-(buttonScale/10)*1.7,.0018, white)
        end
        if num == 2 then
            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_BASIC_2, 6, 7, top-buttonScale*.02, left+(num*(margin/2))+buttonScale*.01, buttonScale/1.3)
            renderText(render_ctx, "Private", left+(num*(margin/2))+buttonScale/20, top-(buttonScale/10)*1.7,.0018, white)
            renderText(render_ctx, "Room", left+(num*(margin/2))+buttonScale/20, top-(buttonScale/10)*2.3,.0018, white)
        end
    end
    renderText(render_ctx, "Spelunky Ranked", 0, .55, .0025, yellow)
end 
--renders all queueing related menus
function renderQueueMenu(render_ctx)
    local buttonScale = 4
    local text
    local iconSize = 2
    local iconTop = .4
    local iconLeft = 0-iconSize/20
    
    if inQueue then 
        text = "Leave"
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3, 6, iconTop, iconLeft, iconSize)
        local minutes = queueTime//60
        local seconds = queueTime%60
        if seconds < 10 then 
            seconds = "0"..seconds
        end
        renderText(render_ctx, ""..minutes..":"..seconds, 0, .2, .003, white)
    else
        text = "Join"
    end

    renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,0, 0-buttonScale/20,buttonScale)
    renderText(render_ctx, text, 0, 0-buttonScale/17,.0022, black)
    renderText(render_ctx, "Queue", 0, 0-buttonScale/9,.0022, black)

    renderText(render_ctx, "Feel free to play runs or", -.46, .1, .001, white)
    renderText(render_ctx, "use the practice menu while", -.46, 0, .001, white)
    renderText(render_ctx, "queueing for a match.", -.46, -.1, .001, white)

    renderText(render_ctx, "Press escape or bomb to", .5, .05, .001, white)
    renderText(render_ctx, "return to the main menu.", .5, -.05, .001, white)
    

end
--renders all private room pages
function renderPrivateRoomMenu(render_ctx)
    local function sortByArea(list)
        for i = 2, #list do
            local key = list[i]
            local j = i - 1
            while j >= 1 and list[j].area < key.area do
                list[j+1] = list[j]
                j = j - 1
            end
            list[j+1] = key
        end
        return list
    end
    local function sortByTime(list)
        for i = 2, #list do
            local key = list[i]
            local j = i - 1
            while j >= 1 and list[j].finishTime > key.finishTime do
                list[j+1] = list[j]
                j = j - 1
            end
            list[j+1] = key
        end
        return list
    end
    if privateRoomPage == 0 then -- host/join page
        local left = -.4
        local right = .4
        local width = math.abs(left)+right
        local buttonScale = width/.3
        local top = buttonScale/20
        local margin = (width - (buttonScale/10))

        for num = 0, 1, 1 do
            if privatePage0Index == num then
                renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top, left+(num*(margin)),buttonScale)
            else
                renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top, left+(num*(margin)),buttonScale)
            end
            if num == 0 then
                renderText(render_ctx,"Host Room", left+(num*(margin))+buttonScale/20, (top-buttonScale/10)*ratio -.1, .0015, white)
            end
            if num == 1 then
                renderText(render_ctx,"Join Room", left+(num*(margin))+buttonScale/20, (top-buttonScale/10)*ratio -.1, .0015, white)
            end
        end
        renderText(render_ctx, "Private Room", 0, .55, .002, yellow)
    elseif privateRoomPage == 1 then -- enter code page
        renderText(render_ctx, "Enter Room Code", 0, .55, .002, yellow)
        local top = 0
        local bottom = -.65
        local left = -.4
        local right = .4
        local width = math.abs(left)+right
        local div = width/4
        local columnPositions = {}
        local codeInputs = {"A","B","C","D","1","2","3","4",}
        for i = 1, 4, 1 do
            table.insert(columnPositions, left+div*(i-1))
        end

        local height = math.abs(top)+math.abs(bottom)
        local extraSpace = .1

        local margin = height/(3+extraSpace)
        local buttonScale = height/.45
        margin = (height/3) - margin

        --render buttons for entering code
        for column = 1, 4, 1 do
            if column == 1 or column == 4 then
                for num = 0, 1, 1 do
                    if (column-1) == privatePageColumn and num == privatePageRow then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin))),columnPositions[column],buttonScale)
                    else
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top-(num*((buttonScale/10)+(margin))),columnPositions[column],buttonScale)
                    end
                    if num == 0 then
                        renderText(render_ctx,codeInputs[column],columnPositions[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin)))-buttonScale/20)*ratio,.0025,white)
                    end
                    if num == 1 then
                        renderText(render_ctx,codeInputs[column+4],columnPositions[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin)))-buttonScale/20)*ratio,.0025,white)
                    end
                end
            else
                for num = 0, 2, 1 do
                    if (column-1) == privatePageColumn and num == privatePageRow then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin))),columnPositions[column],buttonScale)
                    else
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top-(num*((buttonScale/10)+(margin))),columnPositions[column],buttonScale)
                    end
                    if num == 0 then
                        renderText(render_ctx,codeInputs[column],columnPositions[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin)))-buttonScale/20)*ratio,.0025,white)
                    end
                    if num == 1 then
                        renderText(render_ctx,codeInputs[column+4],columnPositions[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin)))-buttonScale/20)*ratio,.0025,white)
                    end
                    if num == 2 and column == 2 then
                        renderText(render_ctx,"Clear",columnPositions[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin)))-buttonScale/20)*ratio,.001,white)
                    end
                    if num == 2 and column == 3 then
                        renderText(render_ctx,"Enter",columnPositions[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin)))-buttonScale/20)*ratio,.001,white)
                    end
                end
            end
            
        end
        --render code bg
        local position = AABB:new(-.4, .21*ratio, .345, .05*ratio)
        render_ctx:draw_screen_texture(TEXTURE.DATA_TEXTURES_MENU_DISP_2, 1,0, position, white)
        --renders code
        renderText(render_ctx,privateEnterCode, 0, .12*ratio, .003, white)


    elseif privateRoomPage == 2 then -- private lobby page
        local position = AABB:new(-.4, .85, .4, .6)
        render_ctx:draw_screen_texture(TEXTURE.DATA_TEXTURES_MENU_DISP_2, 1,0, position, white)
        if privateCodeVisible then
            renderText(render_ctx,"Room Code: "..privateRoomCode, 0, .7, .0017, white)
        else
            renderText(render_ctx,"Room Code: HIDDEN", 0, .7, .0017, white)
        end


        local c1left = -.55
        local c2left = 0
        local width = .5
        local top = .3
        local bottom = -.2
        local height = math.abs(bottom)+top
        local buttonScale = width/.35
        local gap = height - 4*buttonScale/10
        local margin = gap/4
        for num = 1, #privatePlayers, 1 do -- draw player tiles
            if num > 4 then --2nd column
                for i = 0, 3, 1 do
                    renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_MENU_BASIC_2,5,3+i,top-(num-5)*((buttonScale/10)+margin),c2left+i*buttonScale/10,buttonScale)
                end
                renderTextLeft(render_ctx,"["..privatePlayers[num].elo.."] "..privatePlayers[num].name,c2left+.1,(top-(num-5)*((buttonScale/10)+margin)-buttonScale/20)*ratio,.0008, white)
                if privatePlayers[num].host then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_ITEMS_0,1,4,top-(num-5)*((buttonScale/10)+margin)-(buttonScale/10)*.22,c2left,buttonScale*.4)
                end
            else --1st column
                for i = 0, 3, 1 do
                    renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_MENU_BASIC_2,5,3+i,top-(num-1)*((buttonScale/10)+margin),c1left+i*buttonScale/10,buttonScale)
                end
                renderTextLeft(render_ctx,"["..privatePlayers[num].elo.."] "..privatePlayers[num].name,c1left+.1,(top-(num-1)*((buttonScale/10)+margin)-buttonScale/20)*ratio,.0008, white)
                if privatePlayers[num].host then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_ITEMS_0,1,4,top-(num-1)*((buttonScale/10)+margin)-(buttonScale/10)*.22,c1left,buttonScale*.4)
                end
            end
        end
        if privateHost then -- 5 buttons
            local left = -.6
            local right = .6
            local width = math.abs(left)+right
            local height = .3
            local buttonScale = height/.25
            local gap = width - 5*buttonScale/10
            local margin = gap/4
            local top = -.3
            for num = 0, 4, 1 do
                if num == privatePageColumn then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top, left+num*(buttonScale/10+margin),buttonScale)
                else
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top, left+num*(buttonScale/10+margin),buttonScale)
                end
                if num == 0 then
                    renderText(render_ctx,"Close Room", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                elseif num == 1 then
                    renderText(render_ctx,"Config", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                elseif num == 2 then
                    renderText(render_ctx,"Tetris", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                elseif num == 3 then
                    renderText(render_ctx,"Show Code", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                else
                    renderText(render_ctx,"Start Match", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                end
            end
        else -- 3 buttons
            local left = -.6
            local right = .6
            local width = math.abs(left)+right
            local height = .3
            local buttonScale = height/.25
            local gap = width - 3*buttonScale/10
            local margin = gap/2
            local top = -.3
            for num = 0, 2, 1 do
                if num == privatePageColumn then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top, left+num*(buttonScale/10+margin),buttonScale)
                else
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top, left+num*(buttonScale/10+margin),buttonScale)
                end
                if num == 0 then
                    renderText(render_ctx,"Leave Room", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                elseif num == 1 then
                    renderText(render_ctx,"Tetris", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                elseif num == 2 then
                    renderText(render_ctx,"Show Code", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                end
            end
        end
        if privateConfirmLeave then
            local contop = .1
            local conleft = -.4
            local conwidth = .8
            local consize = conwidth/.3
            for num = 0, 2, 1 do
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_BASIC_2,0,5+num, contop,conleft+num*consize/10, consize)
            end
            if privateHost then
                renderText(render_ctx, "Are you sure you want to close the room?", 0, (contop-.08)*ratio,.0008,white)
                renderText(render_ctx, "This will kick all players from the room.", 0, (contop-.12)*ratio,.0008,white)
            else
                renderText(render_ctx, "Are you sure you want to leave the room?", 0, (contop-.08)*ratio,.0008,white)
            end
            local left = -.18
            local right = .18
            local width = math.abs(left)+right
            local height = .1
            local buttonScale = .15/.2
            local gap = width - 2*buttonScale/10
            local margin = gap
            local top = -.08
            for num = 0, 1, 1 do
                if num == privatePageRow then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top, left+num*(buttonScale/10+margin),buttonScale)
                else
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top, left+num*(buttonScale/10+margin),buttonScale)
                end
                if num == 0 then
                    renderText(render_ctx,"No", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                elseif num == 1 then
                    renderText(render_ctx,"Yes", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                end
            end
        end
        if privateConfirmStart then
            local contop = .1
            local conleft = -.4
            local conwidth = .8
            local consize = conwidth/.3
            for num = 0, 2, 1 do
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_BASIC_2,0,5+num, contop,conleft+num*consize/10, consize)
            end
            renderText(render_ctx, "Are you sure you want to start the room?", 0, (contop-.08)*ratio,.0008,white)
            local left = -.18
            local right = .18
            local width = math.abs(left)+right
            local height = .1
            local buttonScale = .15/.2
            local gap = width - 2*buttonScale/10
            local margin = gap
            local top = -.08
            for num = 0, 1, 1 do
                if num == privatePageRow then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top, left+num*(buttonScale/10+margin),buttonScale)
                else
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top, left+num*(buttonScale/10+margin),buttonScale)
                end
                if num == 0 then
                    renderText(render_ctx,"No", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                elseif num == 1 then
                    renderText(render_ctx,"Yes", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                end
            end
        end
    elseif privateRoomPage == 3 then -- config page
        local top = 1.05
        local left = -.55
        for i = 0, 19, 1 do 
            if i == 0 then
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_FLOOR_VOLCANO_5,0,4,top,left,1)
            elseif i == 19 then
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_FLOOR_VOLCANO_5,2,4,top-i*(.1),left,1)
            else
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_FLOOR_VOLCANO_5,1,4,top-i*(.1),left,1)
            end
        end

        local top = .25
        local left = -.72
        local margin = .2
        local buttonScale = 1.5
        for num = 1, 2, 1 do
            if (privateConfigPage == 0 and num-1 == privatePageRow) or (num == 2 and privateConfigPage == 4) or (num == 1 and (privateConfigPage == 2 or privateConfigPage == 3 or privateConfigPage == 1)) then
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-((num-1)*((buttonScale/10)+(margin))),left,buttonScale)
            else
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top-((num-1)*((buttonScale/10)+(margin))),left,buttonScale)
            end
            if num == 1 then
                renderText(render_ctx, "Run", left+buttonScale/20,ratio*(top-((num-1)*((buttonScale/10)+(margin)))+(buttonScale/20)*.5),.0012,white)
            end
            if num == 2 then
                renderText(render_ctx,"Game",left+buttonScale/20,ratio*(top-((num-1)*((buttonScale/10)+(margin)))+(buttonScale/20)*.5),.0012,white)
            end
        end
        if privateConfigPage == 0 then
            renderText(render_ctx,"Pick a config menu, or press back to return to the lobby.",.2,0, .0012, white)
        elseif privateConfigPage == 1 then
            local left = -.25
            local right = .45
            local width = math.abs(left)+right
            local height = .4
            local buttonScale = height/.25
            local gap = width - 2*buttonScale/10
            local margin = gap/1
            local top = -.2+buttonScale/20
            for num = 0, 1, 1 do
                if num == privatePageColumn then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top, left+num*(buttonScale/10+margin),buttonScale)
                else
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top, left+num*(buttonScale/10+margin),buttonScale)
                end
                if num == 0 then
                    renderText(render_ctx,"Change Mode", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .001, white)
                elseif num == 1 then
                    renderText(render_ctx,"Config", left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .001, white)
                end
            end
            renderText(render_ctx,"Current Mode:",0.1,.5,.002, white)
            if privateRunCustom then    
                renderText(render_ctx,"Custom Requirements",0.1,.32,.002,yellow)
            else
                if privateRandom then
                    renderText(render_ctx,"Random Category",0.1,.32,.002,yellow)
                else
                    renderText(render_ctx,"Category - "..privateCategory,0.1,.32,.0012,yellow)
                end
            end
        elseif privateConfigPage == 2 then -- preset categories
            local top = .42
            local bottom = -.57
            local leftColumn = -.4
            local rightColumn = .1
            local leftButtonCount = 8
            local rightButtonCount = 8
            local height = top+math.abs(bottom)
            local extraSpace = 3

            local leftMargin = height/(leftButtonCount+extraSpace)
            local rightMargin = height/(rightButtonCount+extraSpace)

            local leftButtonScale = ((height)-(leftMargin))
            local rightButtonScale = ((height)-(rightMargin))


            for num = 0, leftButtonCount-1, 1 do
                if privatePageColumn == 0 and privatePageRow == num then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((leftButtonScale/10)+(leftMargin/extraSpace))),leftColumn,leftButtonScale)
                else
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top-(num*((leftButtonScale/10)+(leftMargin/extraSpace))),leftColumn,leftButtonScale)
                end
                if privateCategory == privateLeftCategoryList[num+1] and not privateRandom then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3, top-(num*((leftButtonScale/10)+(leftMargin/extraSpace))),leftColumn,leftButtonScale)
                end
                renderTextLeft(render_ctx, privateLeftCategoryList[num+1],leftColumn+(leftButtonScale/10)*1.2,(top-(num*((leftButtonScale/10)+(leftMargin/extraSpace))+leftButtonScale/20))*ratio,.001, white)
            end


            for num = 0, rightButtonCount-1, 1 do
                if privatePageColumn == 1 and privatePageRow == num then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((rightButtonScale/10)+(rightMargin/extraSpace))),rightColumn,rightButtonScale)
                else
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top-(num*((rightButtonScale/10)+(rightMargin/extraSpace))),rightColumn,rightButtonScale)
                end
                if privateCategory == privateRightCategoryList[num+1] and not privateRandom then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3, top-(num*((rightButtonScale/10)+(rightMargin/extraSpace))),rightColumn,rightButtonScale)
                end
                renderTextLeft(render_ctx, privateRightCategoryList[num+1],rightColumn+(rightButtonScale/10)*1.2,(top-(num*((rightButtonScale/10)+(rightMargin/extraSpace))+rightButtonScale/20))*ratio,.001, white)
            end

            if privatePageColumn == 2 then
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,0,.6,leftButtonScale)
            else
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,0,.6,leftButtonScale)
            end
            if privateRandom then 
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3, 0,.6,rightButtonScale)
            end
            renderText(render_ctx,"Random",.6+leftButtonScale/20,(leftButtonScale/10)*.9,.0012, white)

        elseif privateConfigPage == 3 then -- customize with modifiers
            local left = -.4
            local right = .7
            local width = math.abs(left)+right
            local buttonScale = width/1.35
            local margin = (buttonScale/10)/4
            local h1 = .2
            local h2 = -.1
            local h3 = -.25

            --height 1
            for num = 0, 10, 1 do
                if num ~= 3 and num ~= 7 then
                    if privatePageColumn == num and privatePageRow == 0 then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,h1,left+num*(buttonScale/10+margin),buttonScale)
                    else
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,h1,left+num*(buttonScale/10+margin),buttonScale)
                    end
                    if num == 0 then
                        renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_FLOOR_JUNGLE_0,0,0,h1-(buttonScale/10)*.15,(left+num*(buttonScale/10+margin))+(buttonScale/10)*.15,buttonScale*.7)
                        if privateWorld2 == 1 then
                            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h1,left+num*(buttonScale/10+margin),buttonScale)
                        end
                    elseif num == 1 then
                        renderText(render_ctx,"World 2", left+num*(buttonScale/10+margin)+buttonScale/20,h1*ratio+(buttonScale/10)*.9,.0012, white)
                        if privateWorld2 == 0 then
                            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h1,left+num*(buttonScale/10+margin),buttonScale)
                        end
                    elseif num == 2 then
                        renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_FLOOR_VOLCANO_0,0,0,h1-(buttonScale/10)*.15,(left+num*(buttonScale/10+margin))+(buttonScale/10)*.15,buttonScale*.7)
                        if privateWorld2 == 2 then
                            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h1,left+num*(buttonScale/10+margin),buttonScale)
                        end
                    elseif num == 4 then
                        renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_0,0,0,h1-(buttonScale/10)*.15,(left+num*(buttonScale/10+margin))+(buttonScale/10)*.15,buttonScale*.7)
                        if privateWorld4 == 1 then
                            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h1,left+num*(buttonScale/10+margin),buttonScale)
                        end
                    elseif num == 5 then
                        renderText(render_ctx,"World 4", left+num*(buttonScale/10+margin)+buttonScale/20,h1*ratio+(buttonScale/10)*.9,.0012, white)
                        if privateWorld4 == 0 then
                            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h1,left+num*(buttonScale/10+margin),buttonScale)
                        end
                    elseif num == 6 then
                        renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_FLOOR_TEMPLE_0,0,0,h1-(buttonScale/10)*.15,(left+num*(buttonScale/10+margin))+(buttonScale/10)*.15,buttonScale*.7)
                        if privateWorld4 == 2 then
                            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h1,left+num*(buttonScale/10+margin),buttonScale)
                        end
                    elseif num == 8 then
                        renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_MONS_BIG_0,4,4,h1-(buttonScale/10)*.15,(left+num*(buttonScale/10+margin))+(buttonScale/10)*.15,buttonScale*.7)
                        if privateFinish == -1 then
                            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h1,left+num*(buttonScale/10+margin),buttonScale)
                        elseif privateFinish == 1 then
                            if privatePageColumn == num and privatePageRow == 1 then
                                renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,8,h1-(buttonScale/10)*1.2,left+num*(buttonScale/10+margin),buttonScale)
                            else
                                renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,5,8,h1-(buttonScale/10)*1.2,left+num*(buttonScale/10+margin),buttonScale)
                            end
                            renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,6,h1-(buttonScale/10)*1.2,left+num*(buttonScale/10+margin),buttonScale)
                        end
                    elseif num == 9 then
                        renderText(render_ctx,"Finish Level", left+num*(buttonScale/10+margin)+buttonScale/20,h1*ratio+(buttonScale/10)*.9,.0012, white)
                        renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_MONS_BIG_0,4,1,h1-(buttonScale/10)*.15,(left+num*(buttonScale/10+margin))+(buttonScale/10)*.15,buttonScale*.7)
                        if privateFinish == 0 then
                            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h1,left+num*(buttonScale/10+margin),buttonScale)
                        elseif privateFinish == 1 then
                            renderText(render_ctx,"7-"..privateFinishLevel, (left+num*(buttonScale/10+margin))+(buttonScale/20),((h1-(buttonScale/10)*1.2)-buttonScale/20)*ratio,.001,white)
                        end
                        
                    elseif num == 10 then
                        if privateFinish == 1 then
                            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h1,left+num*(buttonScale/10+margin),buttonScale)
                            renderText(render_ctx, "7-"..privateFinishLevel, (left+num*(buttonScale/10+margin))+(buttonScale/20),(h1-buttonScale/20)*ratio,.001,yellow)
                            if privatePageColumn == num and privatePageRow == 1 then
                                renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,8,h1-(buttonScale/10)*1.2,left+num*(buttonScale/10+margin),buttonScale)
                            else
                                renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,5,8,h1-(buttonScale/10)*1.2,left+num*(buttonScale/10+margin),buttonScale)
                            end
                            renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,5,h1-(buttonScale/10)*1.2,left+num*(buttonScale/10+margin),buttonScale)
                        else
                            renderText(render_ctx, "7-"..privateFinishLevel, (left+num*(buttonScale/10+margin))+(buttonScale/20),(h1-buttonScale/20)*ratio,.001,white)
                        end
                        

                    end
                end
            end
            -- piece 2
            for num = 0, 10, 1 do
                if num ~= 0 and num ~= 1 and num ~= 3 and num ~= 5 and num ~= 7 and num ~= 9 and num ~= 10 then
                    if privatePageColumn == num and privatePageRow == 2 then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,h2,left+num*(buttonScale/10+margin),buttonScale)
                    else
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,h2,left+num*(buttonScale/10+margin),buttonScale)
                    end
                    if privatePageColumn == num and privatePageRow == 3 then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,h3,left+num*(buttonScale/10+margin),buttonScale)
                    else
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,h3,left+num*(buttonScale/10+margin),buttonScale)
                    end
                end
                if num == 2 then
                    renderText(render_ctx,"No%", left+num*(buttonScale/10+margin)+buttonScale/20,h2*ratio+(buttonScale/10)*.5,.0008,white)
                    renderText(render_ctx,"Pacifist", left+num*(buttonScale/10+margin)+buttonScale/20,h3*ratio+(buttonScale/10)*.5,.0008,white)
                    if privateModifiers.noPercent then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h2,left+num*(buttonScale/10+margin),buttonScale)
                    end
                    if privateModifiers.pacifist then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h3,left+num*(buttonScale/10+margin),buttonScale)
                    end
                elseif num == 4 then
                    renderText(render_ctx,"Low%", left+num*(buttonScale/10+margin)+buttonScale/20,h2*ratio+(buttonScale/10)*.5,.0008,white)
                    renderText(render_ctx,"Eggplant", left+num*(buttonScale/10+margin)+buttonScale/20,h3*ratio+(buttonScale/10)*.5,.0008,white)
                    if privateModifiers.lowPercent then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h2,left+num*(buttonScale/10+margin),buttonScale)
                    end
                    if privateModifiers.eggplant then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h3,left+num*(buttonScale/10+margin),buttonScale)
                    end
                elseif num == 5 then 
                    renderText(render_ctx, "Modifiers", left+num*(buttonScale/10+margin)+buttonScale/20,h2*ratio+(buttonScale/10)*1.8,.0012,white)
                elseif num == 6 then
                    renderText(render_ctx,"No Gold", left+num*(buttonScale/10+margin)+buttonScale/20,h2*ratio+(buttonScale/10)*.5,.0008,white)
                    renderText(render_ctx,"Chain", left+num*(buttonScale/10+margin)+buttonScale/20,h3*ratio+(buttonScale/10)*.5,.0008,white)
                    if privateModifiers.noGold then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h2,left+num*(buttonScale/10+margin),buttonScale)
                    end
                    if privateModifiers.chain then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h3,left+num*(buttonScale/10+margin),buttonScale)
                    end
                elseif num == 8 then
                    renderText(render_ctx,"No TP", left+num*(buttonScale/10+margin)+buttonScale/20,h2*ratio+(buttonScale/10)*.5,.0008,white)
                    renderText(render_ctx,"Clear", left+num*(buttonScale/10+margin)+buttonScale/20,h3*ratio+(buttonScale/10)*.5,.0008,white)
                    if privateModifiers.noTP then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3,h2,left+num*(buttonScale/10+margin),buttonScale)
                    end
                end
                
            end
            
        elseif privateConfigPage == 4 then  -- game settings
            local left = -.35
            local right = .7
            local width = math.abs(left)+right
            local buttonScale = width/.85
            local margin = (buttonScale/4)/4
            local h = 0
            for num = 0, 4, 1 do
                if num == 3 then
                    if privatePageColumn == num and privatePageRow == 1 then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,h,left+num*(buttonScale/10+margin),buttonScale)
                    else
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,h,left+num*(buttonScale/10+margin),buttonScale)
                    end
                    if privateDoCheckpoints then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0,3,3,h,left+num*(buttonScale/10+margin),buttonScale)
                    end
                    renderText(render_ctx,"Do Checkpoints", left+num*(buttonScale/10+margin)+buttonScale/20,h*ratio+(buttonScale/10)*.6,.0008,white)
                else
                    if privatePageColumn == num and privatePageRow == 0 then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,h+buttonScale/10,left+num*(buttonScale/10+margin),buttonScale)
                    else
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,h+buttonScale/10,left+num*(buttonScale/10+margin),buttonScale)
                    end
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,5,h+buttonScale/10,left+num*(buttonScale/10+margin),buttonScale)
                    if privatePageColumn == num and privatePageRow == 2 then
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,h-buttonScale/10,left+num*(buttonScale/10+margin),buttonScale)
                    else
                        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,h-buttonScale/10,left+num*(buttonScale/10+margin),buttonScale)
                    end
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,6,h-buttonScale/10,left+num*(buttonScale/10+margin),buttonScale)
                    if num == 0 then
                        renderText(render_ctx,""..privateHourLimit, left+num*(buttonScale/10+margin)+buttonScale/20,(h-buttonScale/20)*ratio,.002,white)
                        renderText(render_ctx,"Hrs.", left+num*(buttonScale/10+margin)+buttonScale/20,(h-(buttonScale/10)*2.2)*ratio,.0008,white)
                        local avg = ((left+buttonScale/20)+(left+1*(buttonScale/10+margin)+buttonScale/20))/2 
                        renderText(render_ctx,"Match Time Limit",avg, h*ratio+(buttonScale/10)*2.3,.001, white)
                    end
                    if num == 1 then
                        local min
                        if privateMinuteLimit < 10 then
                            min = "0"..privateMinuteLimit
                        else
                            min = ""..privateMinuteLimit
                        end
                        renderText(render_ctx,min, left+num*(buttonScale/10+margin)+buttonScale/20,(h-buttonScale/20)*ratio,.002,white)
                        renderText(render_ctx,"Mins.", left+num*(buttonScale/10+margin)+buttonScale/20,(h-(buttonScale/10)*2.2)*ratio,.0008,white)
                    end
                    if num == 2 then
                        renderText(render_ctx, ""..privateWinners, left+num*(buttonScale/10+margin)+buttonScale/20,(h-buttonScale/20)*ratio,.002,white)
                        renderText(render_ctx,"# winners to",left+num*(buttonScale/10+margin)+buttonScale/20, (h+(buttonScale/10)*1.7)*ratio, .001, white)
                        renderText(render_ctx,"end game",left+num*(buttonScale/10+margin)+buttonScale/20, (h+(buttonScale/10)*1.3)*ratio, .001, white)
                    end
                    if num == 4 then
                        renderText(render_ctx, ""..privateCheckpointDistance, left+num*(buttonScale/10+margin)+buttonScale/20,(h-buttonScale/20)*ratio,.002,white)
                        renderText(render_ctx,"# levels back",left+num*(buttonScale/10+margin)+buttonScale/20, (h+(buttonScale/10)*1.7)*ratio, .001, white)
                        renderText(render_ctx,"(checkpoint placement)",left+num*(buttonScale/10+margin)+buttonScale/20, (h+(buttonScale/10)*1.3)*ratio, .001, white)
                    end
                end
            end
        end
        

    elseif privateRoomPage == 4 then -- tetris page
        --handled by tetris module
    elseif privateRoomPage == 5 then -- room starting, category/run breakdown
        local left = -.4
        local left2 = -.2
        local jump = .4
        renderText(render_ctx, "Category: ",0,.4,.002, white)
        renderText(render_ctx, ""..categoryType, 0, .2, .002, yellow)
        renderText(render_ctx, "Starting in "..countdownTime(), 0, 0, .0015, white)
        local desc = {"World 2", "World 4", "Ending"}
        local ending
        if privateFinish == -1 then 
            ending = "6-4"
        elseif privateFinish == 0 then
            ending = "7-4"
        else
            ending = "7-"..privateFinishLevel 
        end
        local w2
        local w4
        if privateWorld2 == 0 then
            w2 = "Either"
        elseif privateWorld2 == 1 then
            w2 = "Jungle"
        else
            w2 = "Volcana"
        end
        if privateWorld4 == 0 then
            w4 = "Either"
        elseif privateWorld4 == 1 then
            w4 = "Tidepool"
        else
            w4 = "Temple"
        end
        local specs = {w2, w4, ending}
        local desc2 = {"# of Completions", "Time Limit","Checkpoints"}
        local timeLimit
        if privateHourLimit == 0 then
            if privateMinuteLimit == 0 then
                timeLimit = "None"
            else
                timeLimit = privateMinuteLimit.." Minutes"
            end
        else    
            timeLimit = privateHourLimit..":"..privateMinuteLimit
        end
        local cp
        if privateDoCheckpoints then
            cp = "Back "..privateCheckpointDistance.." Levels"
        else
            cp = "No Checkpoints"
        end
        local specs2 = {privateWinners, timeLimit, cp}
        if privateRunCustom then
            for num = 0, 2, 1 do 
                renderText(render_ctx, desc[num+1], left+num*jump, -.2, .001, white)
                renderText(render_ctx, ""..specs[num+1], left+num*jump, -.3, .001, yellow)
            end
        else
            renderText(render_ctx,"Regular Ranked Ruleset Applies", 0, -.25, .002, white)
        end
        for num = 0, 2, 1 do 
            renderText(render_ctx, desc2[num+1], left+num*jump, -.45, .001, white)
            renderText(render_ctx, ""..specs2[num+1], left+num*jump, -.55, .001, yellow)
        end


    elseif privateRoomPage == 6 then -- room in progress, finished/forfeit active progress screen
        if privatePlayersProgress then
            local full,racing, forfeited, finished = {}, {}, {}, {}
            for _, player in ipairs(privatePlayersProgress) do
                if player.forfeited then
                    table.insert(forfeited, player)
                elseif player.finishTime then
                    table.insert(finished, player)
                else
                    table.insert(racing, player)
                end
            end
            

            racing = sortByArea(racing)
            forfeited = sortByArea(forfeited)
            finished = sortByTime(finished)
            for _, p in ipairs(finished) do
                table.insert(full, p)
            end
            for _, p in ipairs(racing) do
                table.insert(full, p)
            end
            for _, p in ipairs(forfeited) do
                table.insert(full, p)
            end

            local top = .4
            local width = .45
            local scale = width/.3
            local left = (-width/2)-scale/20
            local gap = (scale/10)*.6
            local size = .0008
            for i, p in ipairs(full) do -- draw player tiles
                for j = 0, 3, 1 do
                    renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_MENU_BASIC_2,5,3+j,(top+scale/20)-i*(gap),left+j*scale/10,scale)
                end
                if p.forfeited then
                    renderText(render_ctx,"FORFEIT @ ("..p.area.."-"..p.level..") - "..p.player_name,0,(top-i*(gap))*ratio,size, red)
                elseif p.finishTime then
                    local hrs = math.floor(p.finishTime // 3600)
                    local minutes = math.floor((p.finishTime % 3600)/60)
                    local seconds = p.finishTime % 60
                    local time
                    if hrs == 0 then
                        time = minutes..":"..seconds
                    else
                        time = hrs..":"..minutes..":"..seconds
                    end
                    renderText(render_ctx,time.." - "..p.player_name,0,ratio*(top-i*(gap)),size, green)
                else
                    renderText(render_ctx,"("..p.area.."-"..p.level..") - "..p.player_name,0,(top-i*(gap))*ratio,size, yellow)
                end
                
            end

            renderText(render_ctx, "Match In Progress!", -.5,.1,.0015, white)
            renderText(render_ctx, "Please be patient!", -.5, -.1, .001, white)
            renderText(render_ctx, "Match In Progress!", .5,.1,.0015, white)
            renderText(render_ctx, "Please be patient!", .5, -.1, .001, white)
            renderText(render_ctx, "Standings", 0, .4*ratio, .0018, white)


        else -- no progress recorded (should be impossible to see)
            renderText(render_ctx,"If you're seeing this, that's an issue!", 0, 0, .0008, white)
        end
    elseif privateRoomPage == 7 then -- room finished, results screen
        local full, dnf, forfeited, finished = {}, {}, {}, {}
        for _, p in ipairs(privatePlayersProgress) do
            if p.result == "finished" then
                table.insert(finished, { player_id = p.steam_id, player_name = p.name, finishTime = p.completion_time, placement = p.placement })
            elseif p.result == "forfeited" then
                table.insert(forfeited, { player_id = p.steam_id, player_name = p.name, forfeited = true })
            else 
                table.insert(dnf, { player_id = p.steam_id, player_name = p.name, area = p.furthest_area, level = p.furthest_level, theme = p.furthest_theme, dnf = true })
            end
        end

        dnf = sortByArea(dnf)

        for _, p in ipairs(finished) do table.insert(full, p) end
        for _, p in ipairs(dnf) do table.insert(full, p) end
        for _, p in ipairs(forfeited) do table.insert(full, p) end
        local top = .4
        local width = .45
        local scale = width/.3
        local left = (-width/2)-scale/20
        local gap = (scale/10)*.6
        local size = .0008
        for i, p in ipairs(full) do -- draw player tiles
            for j = 0, 3, 1 do
                renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_MENU_BASIC_2,5,3+j,(top+scale/20)-i*(gap),left+j*scale/10,scale)
            end
            if p.forfeited then
                renderText(render_ctx, "FORFEIT - "..p.player_name, 0, (top-i*(gap))*ratio, size, red)
            elseif p.dnf then
                renderText(render_ctx, "DNF @ ("..p.area.."-"..p.level..") - "..p.player_name, 0, (top-i*(gap))*ratio, size, yellow)
            elseif p.finishTime then
                local hrs = math.floor(p.finishTime / 3600)
                local minutes = math.floor((p.finishTime % 3600) / 60)
                local seconds = p.finishTime % 60

                local sec_str = string.format("%.2f", seconds)
                if seconds < 10 then
                    sec_str = "0" .. sec_str
                end

                local time
                if hrs == 0 then
                    time = minutes .. ":" .. sec_str
                else
                    local min_str = (minutes < 10) and ("0" .. minutes) or tostring(minutes)
                    time = hrs .. ":" .. min_str .. ":" .. sec_str
                end
                renderText(render_ctx,p.placement..") "..time.." - "..p.player_name,0,ratio*(top-i*(gap)),size, green)
            end
        end
        renderText(render_ctx, "Returning to lobby", -.5,.1,.0015, white)
        renderText(render_ctx, "in "..countdownTime(), -.5, -.1, .001, white)
        renderText(render_ctx, "Returning to lobby", .5,.1,.0015, white)
        renderText(render_ctx, "in "..countdownTime(), .5, -.1, .001, white)
        renderText(render_ctx, "Results", 0, .4*ratio, .0018, white)
    end
end
--renders all practice menu pages
function renderPracMenu(render_ctx)
    if pracSignPage == 0 then -- main page
        local left = -.6
        local top = .5
        local bottom = -.55
        local height = top + math.abs(bottom)
        local margin = height / 6
        local topmost = top - margin
        local bottommost = bottom + margin
        local buttonScale = (topmost+math.abs(bottommost))/.5

        local text
        
        for num = 0, 3, 1 do
            if num == 0 then
                text = "Change Mode"
            elseif num == 1 then
                text = "Config"
            elseif num == 2 then
                text = "Play"
            else 
                text = "Exit"
            end
            if pracPage0Index == num then
                renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,topmost-(num*((buttonScale/10)+(margin/3))),left,buttonScale)
            else
                renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,topmost-(num*((buttonScale/10)+(margin/3))),left,buttonScale)
            end
            renderTextLeft(render_ctx, text, (left - buttonScale/10)+.33,(topmost-(num*((buttonScale/10)+(margin/3))+buttonScale/20))*ratio,.0018, white)
        end

        renderText(render_ctx, "Current Mode", .4, .3, .0025, yellow)
        if pracCatMode then
            renderText(render_ctx, "Category", .4, .1, .0018, white)
            renderText(render_ctx, "Selected Category", .4, -.3, .0025, yellow)
            renderText(render_ctx, pracCategory, .4, -.5, .0018, white)
        else
            renderText(render_ctx, "Custom", .4, .1, .0018, white)
            renderText(render_ctx, "Selected Level", .4, -.3, .0025, yellow)
            local text
            local subtext = ""
            if pracWorld == 1 then
                text = "1"
            elseif pracWorld == 2 then
                text = "2"
                subtext = "(Jungle)"
            elseif pracWorld == 3 then
                text = "2"
                subtext = "(Volcana)"
            elseif pracWorld == 4 then
                text = "3"
            elseif pracWorld == 5 then
                text = "4"
                subtext = "(Tidepool)"
            elseif pracWorld == 6 then
                text = "4"
                subtext = "(Temple)"
            elseif pracWorld == 7 then
                text = "5"
            elseif pracWorld == 8 then
                text = "6"
            elseif pracWorld == 9 then
                text = "7"
                if pracLevel > 4 then
                    subtext = "(Cosmic Ocean)"
                end
            end
            local levelText = ""..text.."-"..pracLevel
            renderText(render_ctx, levelText, .4, -.5, .0018, white)
            renderText(render_ctx, subtext, .4, -.64, .0014, white)
        end
        

    elseif pracSignPage == 1 then -- category config
        local top = .33
        local bottom = -.57
        local leftColumn = -.7
        local rightColumn = -.3
        local leftButtonCount = 8
        local rightButtonCount = 8
        local height = top+math.abs(bottom)
        local extraSpace = 3

        local leftMargin = height/(leftButtonCount+extraSpace)
        local rightMargin = height/(rightButtonCount+extraSpace)

        local leftButtonScale = ((height)-(leftMargin))
        local rightButtonScale = ((height)-(rightMargin))


        for num = 0, leftButtonCount-1, 1 do
            if pracPage1Column == 0 and pracPage1Row == num then
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((leftButtonScale/10)+(leftMargin/extraSpace))),leftColumn,leftButtonScale)
            else
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top-(num*((leftButtonScale/10)+(leftMargin/extraSpace))),leftColumn,leftButtonScale)
            end
            if pracPage1Selected[1] == 0 and pracPage1Selected[2] == num then
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3, top-(num*((leftButtonScale/10)+(leftMargin/extraSpace))),leftColumn,leftButtonScale)
            end
            renderTextLeft(render_ctx, leftCategoryList[num+1],leftColumn+(leftButtonScale/10)*1.2,(top-(num*((leftButtonScale/10)+(leftMargin/extraSpace))+leftButtonScale/20))*ratio,.001, white)
        end


        for num = 0, rightButtonCount-1, 1 do
            if pracPage1Column == 1 and pracPage1Row == num then
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((rightButtonScale/10)+(rightMargin/extraSpace))),rightColumn,rightButtonScale)
            else
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top-(num*((rightButtonScale/10)+(rightMargin/extraSpace))),rightColumn,rightButtonScale)
            end
            if pracPage1Selected[1] == 1 and pracPage1Selected[2] == num then
                renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,3, top-(num*((rightButtonScale/10)+(rightMargin/extraSpace))),rightColumn,rightButtonScale)
            end
            renderTextLeft(render_ctx, rightCategoryList[num+1],rightColumn+(rightButtonScale/10)*1.2,(top-(num*((rightButtonScale/10)+(rightMargin/extraSpace))+rightButtonScale/20))*ratio,.001, white)
        end


        if pracPage1Column == 2 then
            renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,0,.4,1) 
        else
            renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,0,.4,1)
        end
        renderText(render_ctx, "Do checkpoints", .45, .06*ratio,.0015, white)
        renderText(render_ctx, "On: Respawn on level you died.", .45, -.15*ratio, .0008, white)
        renderText(render_ctx, "Play 1 seed to completion.", .45, -.19*ratio, .0008, white)
        renderText(render_ctx, "Off: Behaves like adventure.", .45, -.29*ratio, .0008, white)
        renderText(render_ctx, "Deaths and restarts play a new seed.", .45, -.33*ratio, .0008, white)
        if pracCheckpoints then
            renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_0, 3,3, 0,.4,1)
        end
        

    else -- practice config
        local top = .23
        local bottom = -.57
        local columnPositions = {-.7,-.4,-.1,.1}
        local columnPositions2 = {.35,.43,.51,.59,.67}
        local buttonCount = 7
        local height = top+math.abs(bottom)
        local extraSpace = 3

        local margin = height/(buttonCount+extraSpace)

        local buttonScale = ((height)-(margin))

        for column = 1, 4, 1 do
            for num = 0, buttonCount-1, 1 do
                if pracPage2Column == column-1 and pracPage2Row == num then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin/extraSpace))),columnPositions[column],buttonScale)
                else
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top-(num*((buttonScale/10)+(margin/extraSpace))),columnPositions[column],buttonScale)
                end
                if (column == 1 and pracPackSelected == num) or (column == 2 and pracHeldSelected == num) or (column == 3 and pracLeftPassivesSelected[num+1]) or (column == 4 and pracRightPassivesSelected[num+1]) then
                    renderTexture(render_ctx,TEXTURE.DATA_TEXTURES_HUD_0, 3,3, top-(num*((buttonScale/10)+(margin/extraSpace))),columnPositions[column],buttonScale)
                end
                if column == 1 and num > 0 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_ITEMS_0,pracPage2Items1[num][1],pracPage2Items1[num][2],top-(num*((buttonScale/10)+(margin/extraSpace))),columnPositions[column]+(buttonScale/10)*1.2,buttonScale)
                elseif column == 2 and num > 0 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_ITEMS_0,pracPage2Items2[num][1],pracPage2Items2[num][2],top-(num*((buttonScale/10)+(margin/extraSpace))),columnPositions[column]+(buttonScale/10)*1.2,buttonScale)
                elseif column == 3 and num > 0 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_ITEMS_0,pracPage2Items3[num][1],pracPage2Items3[num][2],top-(num*((buttonScale/10)+(margin/extraSpace))),columnPositions[column]+(buttonScale/10)*1.2,buttonScale)
                elseif column == 4 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_ITEMS_0,pracPage2Items4[num+1][1],pracPage2Items4[num+1][2],top-(num*((buttonScale/10)+(margin/extraSpace))),columnPositions[column]+(buttonScale/10)*1.2,buttonScale)
                end
            end
        end

        renderText(render_ctx, "Backpack", columnPositions[1]+buttonScale/5,(top+margin/2)*ratio,.0012, white)
        renderText(render_ctx, "In-Hand", columnPositions[2]+buttonScale/5,(top+margin/2)*ratio,.0012, white)
        renderText(render_ctx, "Passives", columnPositions[4],(top+margin/2)*ratio,.0012, white)

        for column = 1, 5, 1 do
            for num = 0, buttonCount-1, 1 do
                if pracPage2Column == 4 and pracPage2Row == 0 and column == 1 and num == 0 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin/extraSpace)))+(buttonScale*.005),columnPositions2[column]-(buttonScale*.005),buttonScale*1.1)
                elseif pracPage2Column == 6 and pracPage2Row == 0 and column == 3 and num == 0 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin/extraSpace)))+(buttonScale*.005),columnPositions2[column]-(buttonScale*.005),buttonScale*1.1)
                elseif pracPage2Column == 8 and pracPage2Row == 0 and column == 5 and num == 0 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin/extraSpace)))+(buttonScale*.005),columnPositions2[column]-(buttonScale*.005),buttonScale*1.1)
                elseif pracPage2Column == 4 and pracPage2Row == 2 and column == 1 and num == 2 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin/extraSpace)))+(buttonScale*.005),columnPositions2[column]-(buttonScale*.005),buttonScale*1.1)
                elseif pracPage2Column == 6 and pracPage2Row == 2 and column == 3 and num == 2 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin/extraSpace)))+(buttonScale*.005),columnPositions2[column]-(buttonScale*.005),buttonScale*1.1)
                elseif pracPage2Column == 8 and pracPage2Row == 2 and column == 5 and num == 2 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin/extraSpace)))+(buttonScale*.005),columnPositions2[column]-(buttonScale*.005),buttonScale*1.1)
                elseif pracPage2Column == 5 and pracPage2Row == 4 and column == 2 and num == 4 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin/extraSpace)))+(buttonScale*.005),columnPositions2[column]-(buttonScale*.005),buttonScale*1.1)
                elseif pracPage2Column == 7 and pracPage2Row == 4 and column == 4 and num == 4 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin/extraSpace)))+(buttonScale*.005),columnPositions2[column]-(buttonScale*.005),buttonScale*1.1)
                elseif pracPage2Column == 5 and pracPage2Row == 6 and column == 2 and num == 6 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin/extraSpace)))+(buttonScale*.005),columnPositions2[column]-(buttonScale*.005),buttonScale*1.1)
                elseif pracPage2Column == 7 and pracPage2Row == 6 and column == 4 and num == 6 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top-(num*((buttonScale/10)+(margin/extraSpace)))+(buttonScale*.005),columnPositions2[column]-(buttonScale*.005),buttonScale*1.1)
                end

                
                if (column == 1 or column == 3 or column == 5) and num == 0 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,9,5,top-(num*((buttonScale/10)+(margin/extraSpace))),columnPositions2[column],buttonScale)
                elseif (column == 1 or column == 3 or column == 5) and num == 2 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,9,6,top-(num*((buttonScale/10)+(margin/extraSpace))),columnPositions2[column],buttonScale)
                elseif (column == 2 or column == 4) and num == 6 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,9,6,top-(num*((buttonScale/10)+(margin/extraSpace))),columnPositions2[column],buttonScale)
                elseif (column == 2 or column == 4) and num == 4 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,9,5,top-(num*((buttonScale/10)+(margin/extraSpace))),columnPositions2[column],buttonScale)                    
                elseif column == 1 and num == 1 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 3,0,top-(num*((buttonScale/10)+(margin/extraSpace)))+.03,columnPositions2[column],buttonScale)
                    renderText(render_ctx, ""..pracHealth, columnPositions2[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin/extraSpace)))-buttonScale/14)*ratio,.0012,white)                   
                elseif column == 3 and num == 1 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 1,2,top-(num*((buttonScale/10)+(margin/extraSpace)))+.03,columnPositions2[column],buttonScale)                    
                    renderText(render_ctx, ""..pracBombs, columnPositions2[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin/extraSpace)))-buttonScale/14)*ratio,.0012,white)  
                elseif column == 5 and num == 1 then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_0, 1,3,top-(num*((buttonScale/10)+(margin/extraSpace)))+.03,columnPositions2[column],buttonScale)                
                    renderText(render_ctx, ""..pracRopes, columnPositions2[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin/extraSpace)))-buttonScale/14)*ratio,.0012,white)  
                elseif column == 2 and num == 5 then
                    local text
                    local subtext = ""
                    if pracWorld == 1 then
                        text = "1"
                    elseif pracWorld == 2 then
                        text = "2"
                        subtext = "Jungle"
                    elseif pracWorld == 3 then
                        text = "2"
                        subtext = "Volcana"
                    elseif pracWorld == 4 then
                        text = "3"
                    elseif pracWorld == 5 then
                        text = "4"
                        subtext = "Tidepool"
                    elseif pracWorld == 6 then
                        text = "4"
                        subtext = "Temple"
                    elseif pracWorld == 7 then
                        text = "5"
                    elseif pracWorld == 8 then
                        text = "6"
                    elseif pracWorld == 9 then
                        text = "7"
                        if pracLevel > 4 then
                            subtext = "Cosmic Ocean"
                        end
                    end
                    renderText(render_ctx, ""..text, columnPositions2[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin/extraSpace)))-buttonScale/20)*ratio,.0015,white)
                    renderText(render_ctx, ""..subtext, columnPositions2[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin/extraSpace)))-buttonScale/9)*ratio,.0006,white)  
                elseif column == 4 and num == 5 then
                    renderText(render_ctx, ""..pracLevel, columnPositions2[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin/extraSpace)))-buttonScale/20)*ratio,.0015,white)  
                elseif column == 3 and num == 5 then
                    renderText(render_ctx, "-", columnPositions2[column]+buttonScale/20,(top-(num*((buttonScale/10)+(margin/extraSpace)))-buttonScale/20)*ratio,.0015,white)  
                end
            end
        end
        renderText(render_ctx, "Resources", columnPositions2[3]+buttonScale/20,(top+margin/2)*ratio,.0012, white)
        renderText(render_ctx, "Spawn Level", columnPositions2[3]+buttonScale/20, -.13*ratio,.0012,white)
    end
end

function renderPreMatch(render_ctx)
    if preMatch then
        renderText(render_ctx,"Match Found!", 0,.6, .0035, yellow)
        renderText(render_ctx,"V.S.", 0,0,.003, red)
        renderText(render_ctx,""..countdownTime(), 0,.3, .0035, white)
        renderText(render_ctx,"["..myelo.."] "..myself, -.45,0,.0016, white)
        renderText(render_ctx,"["..opponentelo.."] "..opponent, .45,0,.0016, white)
    elseif banPhase then
        renderBanWindow(render_ctx)
        renderBanWindowObjects(render_ctx)
    end
end

function newAlert(duration, alerttype, line1, line2, choicetexta, choicetextb, choicea, choiceb)
    return {
        alerttype   = alerttype or "temporary",
        line1       = line1 or "message not found",
        line2       = line2 or "",
        choicetexta = choicetexta,
        choicetextb = choicetextb,
        choicea     = choicea,
        choiceb     = choiceb,
        duration    = (duration and duration*60) or ((alerttype == "temporary" or alerttype == nil) and 300 or -1),
        elapsed     = 0,
    }
end

function registerAlert(duration, alerttype, line1, line2, choicetexta, choicetextb, choicea, choiceb)
    local alert = newAlert(duration, alerttype, line1, line2, choicetexta, choicetextb, choicea, choiceb)
    table.insert(activeAlerts, alert)
end

function getCurrentAlert()
    return activeAlerts[1]
end

function popAlert()
    table.remove(activeAlerts, 1)
    alerting = (activeAlerts[1] ~= nil)
    alertIndex = 0
end

function makeAlertChoice(choice)
    local alert = getCurrentAlert()
    if not alert or alert.alerttype ~= "choice" then return end

    if choice == 0 and alert.choicea then
        alert.choicea()
    elseif choice == 1 and alert.choiceb then
        alert.choiceb()
    end
    popAlert()
end

function alertInput()
    local alert = getCurrentAlert()
    if not alert then return end
    local input = get_io()
    -- input.wantkeyboard = true
    local back = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.bomb)
    local confirm = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.jump)
    local up = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.up)
    local down = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.down)
    local left = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.left)
    local right = keyTranslation(state.player_inputs.player_slot_1.input_mapping_keyboard.right)
    blockInputs()
    if inputs.gamepad_button_press(inputs.GAMEPAD.B) or input.keypressed(27) or input.keypressed(back) then
        -- do nothing 
    end
    if inputs.key_press(inputs.KEYBOARD.LEFT_ARROW) or inputs.key_press(inputs.KEYBOARD.A) or input.keypressed(left) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_LEFT) or inputs.gamepad_button_press(inputs.GAMEPAD.LEFT) then
        alertIndex = (alertIndex - 1)%2
    end
    if inputs.key_press(inputs.KEYBOARD.RIGHT_ARROW) or inputs.key_press(inputs.KEYBOARD.D) or input.keypressed(right) or inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_RIGHT) or inputs.gamepad_button_press(inputs.GAMEPAD.RIGHT) then
        alertIndex = (alertIndex + 1)%2
    end
    if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_UP) or inputs.gamepad_button_press(inputs.GAMEPAD.UP) or inputs.key_press(inputs.KEYBOARD.UP_ARROW) or inputs.key_press(inputs.KEYBOARD.W) or input.keypressed(up) then
        -- do nothing
    end
    if inputs.gamepad_button_press(inputs.GAMEPAD.DPAD_DOWN) or inputs.gamepad_button_press(inputs.GAMEPAD.DOWN) or inputs.key_press(inputs.KEYBOARD.DOWN_ARROW) or inputs.key_press(inputs.KEYBOARD.S) or input.keypressed(down) then
        -- do nothing
    end
    if inputs.key_press(inputs.KEYBOARD.RETURN) or inputs.gamepad_button_press(inputs.GAMEPAD.A) or input.keypressed(confirm) then
        if alert.alerttype == "ack" then
            popAlert()
        elseif alert.alerttype == "choice" then
            makeAlertChoice(alertIndex)
        end
    end
end

function renderAlert(render_ctx)
    if activeAlerts[1] then
        --draw alert window always
        local contop = .1
        local conleft = -.4
        local conwidth = .8
        local consize = conwidth/.3
        for num = 0, 2, 1 do
            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_MENU_BASIC_2,0,5+num, contop,conleft+num*consize/10, consize)
        end
        alerting = true
        local alert = getCurrentAlert()
        --draw alert text always
        renderText(render_ctx, alert.line1, 0, (contop-.08)*ratio,.0008,white)
        renderText(render_ctx, alert.line2, 0, (contop-.12)*ratio,.0008,white)
        if alert.alerttype == "temporary" then
            alert.elapsed = alert.elapsed + 1
            if alert.elapsed >= alert.duration then
                popAlert()
            end
        elseif alert.alerttype == "ack" then -- draw single button
            local buttonScale = .15/.2
            local left = -buttonScale/20
            local top = -.08 
            renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top,left,buttonScale)
            renderText(render_ctx,"Okay", left+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
        elseif alert.alerttype == "choice" then -- draw both buttons and choices
            local left = -.18
            local right = .18
            local width = math.abs(left)+right
            local height = .1
            local buttonScale = .15/.2
            local gap = width - 2*buttonScale/10
            local margin = gap
            local top = -.08
            for num = 0, 1, 1 do
                if num == alertIndex then
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,top, left+num*(buttonScale/10+margin),buttonScale)
                else
                    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,top, left+num*(buttonScale/10+margin),buttonScale)
                end
                if num == 0 then
                    renderText(render_ctx,alert.choicetexta, left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                elseif num == 1 then
                    renderText(render_ctx,alert.choicetextb, left+num*(buttonScale/10+margin)+buttonScale/20,ratio*(top+(buttonScale/10)*.2), .0008, white)
                end
            end
        end
    else
        if alerting then
            alerting = false 
            returnInputs()
            startButtonCooldown()
        end
        return
    end
    
end

function prepBans()
    --, bring player to camp, stop player inputs, open preMatch window
    if state.theme ~= THEME.BASE_CAMP then
        warp(1,1,THEME.BASE_CAMP)
    end
    if not mainMenuOpen then
        mainMenuOpen = true
    end
    if menuPage ~= 4 then
        menuPage = 4
    end
    if game_manager.pause_ui.visibility ~= 0 then game_manager.pause_ui.visibility = 0 end
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
            local payload = {rcat}
            udpSend("ban", payload)
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
    if mainMenuOpen then
        if not getCurrentAlert() then
            menuInputHandle()
        end
        renderMenuBG(render_ctx)
        if inQueue and menuPage ~= 1 then
            renderToast(render_ctx)
        end
        if preMatch or banPhase then
            if menuPage ~= 4 then
                menuPage = 4
            else
                renderPreMatch(render_ctx)
                if banPhase then
                    banWindowInput()
                end
            end
        end
        if pracSignOpen then -- page 2
            renderPracMenu(render_ctx)
        end

        if privateRoomMenuOpen then -- page 3
            renderPrivateRoomMenu(render_ctx)
        end

        if menuPage == 0 then
            renderMainMenu(render_ctx)
        elseif menuPage == 1 then
            renderQueueMenu(render_ctx)
        end
    elseif inQueue then
        renderToast(render_ctx)
    elseif preMatch then
        renderMatchInfoToast(render_ctx)
    end
    
    renderChat(render_ctx)
    enterMessageWindow(render_ctx)
    renderAlert(render_ctx)
    if getCurrentAlert() then
        alertInput()
    end
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
                state.loading = 0
                revealingRank = 0
                udpSend("rank_reveal_complete")
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

function prepPrivateLobby()
    if state.theme ~= THEME.BASE_CAMP then
        warp(1,1,THEME.BASE_CAMP)
    end
    if not mainMenuOpen then
        mainMenuOpen = true
    end
    if not privateRoomMenuOpen then
        privateRoomMenuOpen = true
    end
    if menuPage ~= 3 then
        menuPage = 3
    end
    if privateRoomPage ~= 2 then
        privateRoomPage = 2
    end
end

function prepPracticeMenu()
    if state.theme ~= THEME.BASE_CAMP then
        warp(1,1,THEME.BASE_CAMP)
    end
    if not mainMenuOpen then
        mainMenuOpen = true
    end
    if not pracSignOpen then
        pracSignOpen = true
    end
    if menuPage ~= 2 then
        menuPage = 2
    end
    if pracSignPage ~= 0 then
        pracSignPage = 0
    end
    practiceStarted = false
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
    local function applyConfig(data)
        privateModifiers.noPercent = data.config.modifiers.noPercent
        privateModifiers.lowPercent = data.config.modifiers.lowPercent
        privateModifiers.noGold = data.config.modifiers.noGold
        privateModifiers.noTP = data.config.modifiers.noTP
        privateModifiers.pacifist = data.config.modifiers.pacifist
        privateModifiers.eggplant = data.config.modifiers.eggplant
        privateModifiers.chain = data.config.modifiers.chain
        privateWorld2 = data.config.world2
        privateWorld4 = data.config.world4
        privateFinish = data.config.finish
        privateFinishLevel = data.config.finishLevel
        privateCategory = data.config.category
        privateRandom = data.config.random
        privateRunCustom = data.config.runCustom
        privateHourLimit = data.config.hourLimit
        privateMinuteLimit = data.config.minuteLimit
        privateWinners = data.config.winners
        privateDoCheckpoints = data.config.doCheckpoints
        privateCheckpointDistance = data.config.checkpointDistance
    end
    if server == nil or not server:is_open() then
        return 
    end
    elapsedTime = (get_global_frame()/60) - lastServerOp
    if (elapsedTime >= serverDelay) then
        lastServerOp = (get_global_frame()/60)
        if not bridgeConnected then
            udpSend("ping")
        end
        --read operations
        local af = false
        while server:read(function(message, bridgeAddress)
            local data = json.decode(message)
            local event = data.event
            if event == nil then 
                log_print("[WARN] No event received on UDP read.")
                return 
            end
            -- Heartbeat 
            if event == "ping" then
                udpSend("pong")
            elseif event == "pong" then
                bridgeConnected = true
            elseif event == "version_request" then
                udpSend("version_response")
            elseif event == "version_mismatch" then
                bridgeConnected = false
            -- Match found
            elseif event == "is_banned" then
                inQueue = false
                processChat("You are banned from ranked queues.", "Notice")
            elseif event == "paired" then
                opponent = data.opponent_name
                categories = data.categories
                remainingCategories = data.categories
                bansFirst = data.ban_order_first
                opponentelo = data.opponent_elo
                myself = data.player_name
                myelo = data.player_elo
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
                local payload = {"match_start"}
                udpSend("ack", payload)
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
                local payload = {"do_seed_change"}
                udpSend("ack", payload)

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
                local payload = {"match_result"}
                udpSend("ack", payload)

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
                local payload = {"rank_reveal"}
                udpSend("ack", payload)
            elseif event == "opponent_disconnected" then
                processChat("The opponent has disconnected. They have 30s to reconnect before they forfeit.", "Match Info")
                opponentConnected = false
            elseif event == "opponent_reconnected" then
                processChat("The opponent has reconnected. Good luck!", "Match Info")
                opponentConnected = true
            elseif event == "disconnect_detected" then
                processChat("Lost connection to the game server. Attempting reconnection...", "Match Info")
                if matchStarted then
                    processChat("Keep playing! If your connection is restored within 30 seconds, the match will continue.", "Match Info")
                end
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
                local payload = {"auto_forfeit"}
                udpSend("ack", payload)
            elseif event == "match_not_found" then
                processChat("The match you were in concluded while you were disconnected.", "Match Info")
                defaultValues()
            elseif event == "room_players_update" then
                local playerList = {}
                for i, player in ipairs(data.players) do
                    local playerData = {name = player.name, elo = player.elo}
                    if data.host_id == player.steam_id then
                        playerData.host = true
                    end
                    table.insert(playerList, playerData)
                end
                privatePlayers = playerList
            elseif event == "room_joined" or event == "room_lobby_reset" then
                closeTetrisIfActive()
                prepPrivateLobby()
                if event == "room_joined" then
                    privateHost = privatePendingHost
                end
                privateRoomCode = data.room_code
                inPrivateRoom = true
                local playerList = {}
                for i, player in ipairs(data.players) do
                    local playerData = {name = player.name, elo = player.elo}
                    if data.host_id == player.steam_id then
                        playerData.host = true
                    end
                    table.insert(playerList, playerData)
                end
                privatePlayers = playerList
                --apply config
                applyConfig(data)
            elseif event == "room_config_update" then
                --apply config
                applyConfig(data)
            elseif event == "room_alert" then
                for i, issue in ipairs(data.issues) do
                    registerAlert(-1, "ack", issue.message)
                end
                registerAlert(-1, "choice", "Would you like to start the game now?", "", "No", "Yes", nil, function()
                    udpSend("start_room")
                end)
            elseif event == "room_starting" then
                if matchStarted then
                    closeTetrisIfActive()
                    matchStarted = false
                    categoryType = data.category
                    seed = tonumber(data.seed,16)
                    applyConfig(data)
                    banTime()
                    prepPrivateLobby()
                    privateRoomPage = 5
                elseif privateRoomPage ~= 5 then
                    closeTetrisIfActive()
                    categoryType = data.category
                    seed = tonumber(data.seed,16)
                    applyConfig(data)
                    banTime() -- starts timer at 10s
                    privateRoomPage = 5
                end 
                local payload = {"room_starting"}
                udpSend("ack", payload)
                
            elseif event == "room_live" then
                if not matchStarted then
                    defaultMatchValues()
                    matchStarted = true
                    state.theme_start = THEME.DWELLING
                    state.level_start = 1
                    state.world_start = 1
                    reportCount = 0
                    hardReset()
                    privatePlayersProgress = data.players
                end
                local payload = {"room_live"}
                udpSend("ack", payload)

            elseif event == "room_progress" then
                for i, player in ipairs(privatePlayersProgress) do
                    if data.player_id == player.steam_id then
                        privatePlayersProgress[i].area = data.area
                        local playerName = data.player_name
                        if data.theme ~= privatePlayersProgress[i].theme then
                            privatePlayersProgress[i].theme = data.theme
                            if data.theme == THEME.JUNGLE then
                                processChat(playerName.." entered Jungle.", "Match Info")
                            elseif data.theme == THEME.VOLCANA then
                                processChat(playerName.." entered Volcana.", "Match Info")
                            elseif data.theme == THEME.OLMEC then
                                processChat(playerName.." entered Olmec.", "Match Info")
                            elseif data.theme == THEME.TIDE_POOL then
                                processChat(playerName.." entered Tidepool.", "Match Info")
                            elseif data.theme == THEME.TEMPLE then
                                processChat(playerName.." entered Temple.", "Match Info")
                            elseif data.theme == THEME.ICE_CAVES then
                                processChat(playerName.." entered Ice Caves.", "Match Info")
                            elseif data.theme == THEME.NEO_BABYLON then
                                processChat(playerName.." entered Neo Babylon.", "Match Info")
                            elseif data.theme == THEME.SUNKEN_CITY then
                                processChat(playerName.." entered Sunken City.", "Match Info")
                            end
                            privatePlayersProgress[i].level = data.level
                        end
                        if data.theme == THEME.COSMIC_OCEAN then
                            if (data.level % 4 == 0) and privatePlayersProgress[i].level < data.level then
                                privatePlayersProgress[i].level = data.level
                                processChat(playerName.." entered 7-"..privatePlayersProgress[i].level..".", "Match Info")
                            end
                        end
                    end
                end
            elseif event == "room_player_finished" then
                for i, player in ipairs(privatePlayersProgress) do
                    if data.steam_id == player.steam_id then
                        privatePlayersProgress[i].finishTime = data.completion_time
                    end
                end
            elseif event == "room_player_forfeited" then
                for i, player in ipairs(privatePlayersProgress) do
                    if data.steam_id == player.steam_id then
                        privatePlayersProgress[i].forfeited = true
                    end
                end
            elseif event == "room_result" then
                closeTetrisIfActive()
                privatePlayersProgress = data.participants
                matchStarted = false
                prepPrivateLobby()
                banTime()
                privateRoomPage = 7
            elseif event == "room_time_remaining" then
                local min = data.seconds//60
                local sec = data.seconds%60
                if min < 1 then
                    processChat(sec.." seconds remaining!", "Time")
                else
                    processChat(min.." minutes remaining!", "Time")
                end
            elseif event == "room_closed" then
                closeTetrisIfActive()
                prepPrivateLobby()
                defaultPrivate()
                inPrivateRoom = false
                privateRoomPage = 0--boot to main private room page
                local reason
                if data.reason == "host_left" then
                    reason = "The host closed the room."
                elseif data.reason == "inactivity_timeout" then
                    reason = "No room activity."
                end
                registerAlert(-1, "ack", "The private room was closed.", "Reason: "..reason)
            elseif event == "room_inactivity_warning" then
                registerAlert(-1, "choice", "The room will be force closed if", "there is no activity soon.","I'm here!", "Still here!", function()
                    udpSend("room_dismiss_inactivity_warning")
                end, function()
                    udpSend("room_dismiss_inactivity_warning")
                end)
            elseif event == "confirm_leave" then
                closeTetrisIfActive()
                if state.screen == SCREEN.MENU or state.screen == SCREEN.TITLE or state.screen == SCREEN.OPTIONS then -- leave via quitting to menu
                    processChat("You left the private room.", "Info")
                    inPrivateRoom = false
                elseif matchStarted then -- left during match (probably not possible under most circumstances)
                    defaultMenu()
                    defaultValues()
                    defaultPrivate()
                    processChat("You left the private room.", "Info")
                    inPrivateRoom = false
                else -- regular leave during lobby etc.
                    defaultPrivate()
                    inPrivateRoom = false
                    privateRoomPage = 0
                end
            elseif event == "confirm_completion" then
                closeTetrisIfActive()
                for i, player in ipairs(privatePlayersProgress) do
                    if data.steam_id == player.steam_id then
                        privatePlayersProgress[i].finishTime = data.completion_time
                    end
                end
                defaultMenu()
                prepPrivateLobby()
                privateRoomPage = 6
            elseif event == "confirm_forfeit" then
                closeTetrisIfActive()
                for i, player in ipairs(privatePlayersProgress) do
                    if data.steam_id == player.steam_id then
                        privatePlayersProgress[i].forfeited = true
                    end
                end
                defaultMenu()
                prepPrivateLobby()
                privateRoomPage = 6
            elseif event == "error" then
                if data.code ~= "wrong_phase" then -- silently drop wrong_phase errors
                    if data.code == "in_queue" then
                        processChat("Leave queue before attempting to join a private room!","Info")
                    elseif data.code == "already_in_room" then
                        if inPrivateRoom and not matchStarted then
                            prepPrivateLobby() -- push into private room if UI non responsive, otherwise drop
                        end
                    elseif data.code == "at_capacity" then
                        registerAlert(-1, "ack", "The server has no more space for private rooms.", "If you think this is an error, contact an admin.")
                    elseif data.code == "not_found" then
                        registerAlert(-1, "ack", "That room does not exist.")
                    elseif data.code == "not_joinable" then
                        registerAlert(-1, "ack", "You cannot join that room at this time.")
                    elseif data.code == "full" then
                        registerAlert(-1, "ack", "This room is full.")
                    elseif data.code == "banned" then
                        registerAlert(-1, "ack", "You are banned from private rooms.")
                    elseif data.code == "already_in_match" then
                        processChat("You cannot join a private room while in a match!", "Info")
                    end
                end
            end 
        end) ~= -1 do end
    end
end

--udp functions

function udpSend(msg, argList)
    argList = argList or nil
    if msg == "ping" then
        server:send(json.encode({ event = "ping"}), bridgeAddress)
    elseif msg == "pong" then
        server:send(json.encode({ event = "pong" }), bridgeAddress)
    elseif msg == "version_response" then
        server:send(json.encode({ event = "version_response", version = meta.version , component_version = meta.component_version}), bridgeAddress)
    elseif msg == "queue_ready" then
        server:send(json.encode({ event = "queue_ready"}), bridgeAddress)
    elseif msg == "ack" then
        server:send(json.encode({ event = "ack", ack_event = argList[1] }), bridgeAddress)
    elseif msg == "queue_leave" then
        if matchStarted then return end
        if not inQueue then return end
        server:send(json.encode({ event = "queue_leave"}), bridgeAddress)
        inQueue = false
    elseif msg == "ban" then
        local category = argList[1]
        server:send(json.encode({ event = "ban", category = category}), bridgeAddress)
    elseif msg == "progress" then
        local area = argList[1]
        local level = argList[2]
        local theme = argList[3]
        server:send(json.encode({ event = "progress", area = area, level = level, theme = theme }), bridgeAddress)
    elseif msg == "death" then
        server:send(json.encode({ event = "death" }), bridgeAddress)
    elseif msg == "instant_restart" then
        server:send(json.encode({ event = "instant_restart"}), bridgeAddress)
    elseif msg == "completion" then
        server:send(json.encode({ event = "completion" }), bridgeAddress)
    elseif msg == "request_seed_change" then
        set_global_timeout(function()
            sentSeedChange = false
        end, 60*seedChangeWindow)
        server:send(json.encode({ event = "request_seed_change" }), bridgeAddress)
    elseif msg == "request_draw" then
        set_global_timeout(function()
            sentDrawVote = false
        end, 60*drawVoteWindow)
        server:send(json.encode({ event = "request_draw" }), bridgeAddress)
    elseif msg == "forfeit" then
        server:send(json.encode({ event = "forfeit" }), bridgeAddress)
    elseif msg == "close_postmatch" then
        forceEndPostMatch()
        server:send(json.encode({ event = "close_postmatch" }), bridgeAddress)
    elseif msg == "send_chat" then
        returnInputs()
        local chatMsg = argList[1]
        server:send(json.encode({ event = "send_chat", message = chatMsg }), bridgeAddress)
    elseif msg == "rank_reveal_complete" then
        server:send(json.encode({ event = "rank_reveal_complete" }), bridgeAddress)
    elseif msg == "create_room" then
        server:send(json.encode({ event = "create_room" }), bridgeAddress)
    elseif msg == "join_room" then
        local code = argList[1]
        server:send(json.encode({ event = "join_room" , room_code = code }), bridgeAddress)
    elseif msg == "leave_room" then
        server:send(json.encode({ event = "leave_room" }), bridgeAddress)
    elseif msg == "update_room_config" then
        local cfg = argList
        server:send(json.encode({ event = "update_room_config" , config = cfg }), bridgeAddress)
    elseif msg == "start_room" then
        server:send(json.encode({ event = "start_room" }), bridgeAddress)
    elseif msg == "room_seed_change" then
        server:send(json.encode({ event = "room_seed_change" }), bridgeAddress)
    elseif msg == "room_force_end" then
        server:send(json.encode({ event = "room_force_end" }), bridgeAddress)
    elseif msg == "room_dismiss_inactivity_warning" then
        server:send(json.encode({ event = "room_dismiss_inactivity_warning" }), bridgeAddress)
    elseif msg == "room_forfeit" then
        server:send(json.encode({ event = "room_forfeit" }), bridgeAddress)
    end

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
    if inPrivateRoom and privateRunCustom then -- use private room config to determine theme
        if world == 1 then
            return THEME.DWELLING
        elseif world == 2 then
            if privateWorld2 == 1 then
                return THEME.JUNGLE
            else
                return THEME.VOLCANA
            end
        elseif world == 3 then
            return THEME.OLMEC
        elseif world == 4 then
            if privateWorld4 == 1 then
                if level == 4 and privateModifiers.chain then
                    return THEME.ABZU
                else
                    return THEME.TIDE_POOL
                end
            else
                if level == 4 and privateModifiers.chain then
                    return THEME.DUAT
                elseif level == 3 and privateModifiers.chain then
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
            if level == 2 and privateModifiers.eggplant then
                return THEME.EGGPLANT_WORLD
            elseif level == 4 then
                return THEME.HUNDUN
            elseif level > 4 then
                return THEME.COSMIC_OCEAN
            else
                return THEME.SUNKEN_CITY
            end
        end
    elseif practiceStarted then
        if pracCatMode then
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
                    if level == 4 and (categoryType == "Abzu%" or categoryType == "No TP Abzu%" or categoryType == "Chain Low% Abzu") then
                        return THEME.ABZU
                    else
                        return THEME.TIDE_POOL
                    end
                else
                    if level == 4 and (categoryType == "Duat%" or categoryType == "No TP Duat%" or categoryType == "Chain Low% Duat") then
                        return THEME.DUAT
                    elseif level == 3 and (categoryType == "Duat%" or categoryType == "No TP Duat%" or categoryType == "Chain Low% Duat") then
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
        else
            if world == 1 then
                return THEME.DWELLING
            elseif world == 2 then
                return THEME.JUNGLE
            elseif world == 3 then
                return THEME.VOLCANA
            elseif world == 4 then
                return THEME.OLMEC
            elseif world == 5 then
                return THEME.TIDE_POOL
            elseif world == 6 then
                return THEME.TEMPLE
            elseif world == 7 then
                return THEME.ICE_CAVES
            elseif world == 8 then
                if level == 4 then
                    return THEME.TIAMAT
                else
                    return THEME.NEO_BABYLON
                end
            elseif world == 9 then
                if level == 4 then
                    return THEME.HUNDUN
                elseif level > 4 then
                    return THEME.COSMIC_OCEAN
                else
                    return THEME.SUNKEN_CITY
                end
            end
        end
        
    else -- use category type to determine theme (regular ranked flow)
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
                if level == 4 and (categoryType == "Abzu%" or categoryType == "No TP Abzu%" or categoryType == "Chain Low% Abzu") then
                    return THEME.ABZU
                else
                    return THEME.TIDE_POOL
                end
            else
                if level == 4 and (categoryType == "Duat%" or categoryType == "No TP Duat%" or categoryType == "Chain Low% Duat") then
                    return THEME.DUAT
                elseif level == 3 and (categoryType == "Duat%" or categoryType == "No TP Duat%" or categoryType == "Chain Low% Duat") then
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
    if inPrivateRoom and privateRunCustom then
        if privateModifiers.lowPercent or privateModifiers.noPercent then
            if privateModifiers.eggplant then
                return true
            else
                return false
            end
        else
            return true
        end
    elseif practiceStarted then
        for i, cat in ipairs(shopCategories) do
            if (pracCategory == cat) then
                return true
            end
        end
        return false
    else
        for i, cat in ipairs(shopCategories) do
            if (categoryType == cat) then
                return true
            end
        end
        return false
    end
end

function getItemsForRun(category)
    local items = {}
    math.randomseed(seed)
    local packType = math.random(2)
    local haspack = false
    if inPrivateRoom and privateRunCustom then
        if privateModifiers.noGold then
            table.insert(items, ENT_TYPE.ITEM_PICKUP_SPECTACLES)
        end
        if privateModifiers.eggplant then
            if privateModifiers.lowPercent or privateModifiers.noPercent then
                table.insert(items, notp_items[3]) --present
            else
                table.insert(items, notp_items[3]) --present
                table.insert(items, pack_items[1]) --jp
                table.insert(items, notp_items[2]) -- bomb box
            end
        else
            if privateModifiers.noTP then
                table.insert(items, notp_items[1])--mattock
            else
                if privateModifiers.chain then 
                    if privateWorld4 == 1 then
                        table.insert(items,tp_items[2]) -- tpack
                        haspack = true
                    else
                        table.insert(items,tp_items[1]) --tp
                    end
                else
                    table.insert(items, tp_items[1]) -- tp
                end
            end
            if privateFinish == -1 then
                table.insert(items,pack_items[packType]) -- hp/jp
            elseif not haspack then
                table.insert(items,notp_items[2]) -- bombs for sc
                table.insert(items,pack_items[1]) -- jp for sc
                haspack = true
            else
                table.insert(items,notp_items[2]) -- bombs for sc
            end
        end
    else
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
    end
    return items
end

function loadCategoryItems(type, x , y, layer, overlay, flags)
    if (matchStarted or practiceStarted) and isShopRun() then
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
        if categoryType == "No TP Eggplant%" or (inPrivateRoom and privateModifiers.eggplant) then
            forceAltar(ctx)
        end
    end
    if practiceStarted and isShopRun() then
        forceShop(ctx)
        if pracCategory == "No TP Eggplant%" then
            forceAltar(ctx)
        end
    end
end

function setWarp(destination)
    warpTo = destination
    warpIndex = getLevelIndex(destination[1],destination[2])
end

function determineCheckpoint() -- obsolete but im lazy to make adjustments to the ranked code
    determineCheckpointAdjustable(3)
end

function determineCheckpointAdjustable(distance)
    local destination = {}
    local furthestIndex = getLevelIndex(furthestLevel[1],furthestLevel[2])
    if categoryType == "Cosmic Ocean%" and not inPrivateRoom or (categoryType == "Cosmic Ocean%" and inPrivateRoom and not privateRunCustom) or (practiceStarted and pracCatMode and pracCategory == "Cosmic Ocean%") then -- run starts in CO, 7-5 is 23
        if furthestIndex - distance < 23 then
            destination = {7,5}
        else
            destination = levelOrder[furthestIndex-distance]
        end
    elseif furthestIndex - distance < 1 then
        destination = {1,1}
    else
        destination = levelOrder[furthestIndex-distance]
    end
    setWarp(destination)
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
        if (inPrivateRoom and privateRunCustom) then
            loadProg = true
        elseif inPrivateRoom and not privateRunCustom and categoryType == "Cosmic Ocean%" and warpTo[2] > 5 then 
            loadProg = true
        elseif practiceStarted then
            if pracCategory ~= "Cosmic Ocean%" then
                loadProg = true
            end
        elseif categoryType ~= "Cosmic Ocean%" then
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

function practiceWarp()
    math.randomseed(os.time())
    seed = tonumber(generatePracticeSeed(),16)
    if pracCatMode then
        force11()
    else
        local ind = getLevelIndex(pracWorld,pracLevel)
        local world
        if pracWorld == 3 then
            world = 2
        elseif pracWorld == 4 then
            world = 3
        elseif pracWorld == 5 then
            world = 4
        elseif pracWorld == 6 then
            world = 4
        elseif pracWorld == 7 then
            world = 5
        elseif pracWorld == 8 then
            world = 6
        elseif pracWorld == 9 then
            world = 7
        end
        setSeed(ind)
        state.screen_last = state.screen
        state.screen_next = SCREEN.LEVEL
        state.theme_start = determineTheme(pracWorld,pracLevel)--handles weird worlds properly
        state.level_start = pracLevel
        state.world_start = world
        state.world_next = world
        state.level_next = pracLevel
        state.theme_next = determineTheme(pracWorld,pracLevel) --handles weird worlds properly
        state.level_count = ind-1
        state.loading = FADE.OUT
        state.quest_flags = set_flag(state.quest_flags, 1)
        state.fade_timer = 1
    end
end

function saveProgress()
    if state.screen ~= SCREEN.LEVEL then return end
    -- if categoryType == "Cosmic Ocean%" and state.world ~= 7 and not inPrivateRoom then return end
    -- if inPrivateRoom and categoryType == "Cosmic Ocean%" and not privateRunCustom and state.world ~= 7 then return end 
    local world = state.world
    local level = state.level
    if inPrivateRoom then
        determineCheckpointAdjustable(privateCheckpointDistance)
    elseif practiceStarted then
        determineCheckpointAdjustable(0)
    else
        determineCheckpoint()
    end
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
    local ind = getLevelIndex(world,level)
    currentSaves[ind] = saveInfo
    if not inPrivateRoom or (inPrivateRoom and not privateRunCustom) then
        if categoryType == "Low% J/T" then
            jungle = true
        elseif saveInfo.world == 2 then
            if state.theme == THEME.JUNGLE then
                jungle = true
            else
                jungle = false
            end
        end
        if categoryType == "Abzu%" or categoryType == "No TP Abzu%" or categoryType == "Chain Low% Abzu" then
            tidepool = true
        elseif categoryType == "Duat%" or categoryType == "No TP Duat%" or categoryType == "Chain Low% Duat" then
            tidepool = false
        elseif saveInfo.world == 4 then
            if state.theme == THEME.TIDE_POOL then
                tidepool = true
            else 
                tidepool = false
            end
        end
    end
end

function loadProgress()
    if spawnCoItems > 0 then 
        loadProg = false
        return
    end
    if not loadProg then return end
    local ind = getLevelIndex(warpTo[1],warpTo[2])
    local save = currentSaves[ind]
    local theme = determineTheme(warpTo[1],warpTo[2])
    if not save then
        loadProg = false
        return
    end
    -- if categoryType == "Cosmic Ocean%" then
    --     if warpTo[1] ~= 7 then
    --         loadProg = false
    --         return
    --     end
    --     ind = warpTo[2]-4
    --     save = currentSaves[ind]
    --     theme = THEME.COSMIC_OCEAN
    -- else
    --     ind = getLevelIndex(warpTo[1],warpTo[2])
    --     save = currentSaves[ind]
    --     theme = determineTheme(warpTo[1],warpTo[2])
    -- end

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

function loadPracItems()
    state.items.player_inventory[1].bombs = pracBombs
    state.items.player_inventory[1].ropes = pracRopes
    state.items.player_inventory[1].health = pracHealth
end

function loadPracEnts()
    local player = players[1]
    local powerups = pracPassives
    if pracPack then
        table.insert(powerups, pracPack)
    end

    --powerups
    for i, powerup in ipairs(powerups) do
        if powerup ~= 0 then
            if powerup == ENT_TYPE.ITEM_JETPACK or powerup == ENT_TYPE.ITEM_HOVERPACK or powerup == ENT_TYPE.ITEM_POWERPACK or powerup == ENT_TYPE.ITEM_TELEPORTER_BACKPACK or powerup == ENT_TYPE.ITEM_CAPE or powerup == ENT_TYPE.ITEM_VLADS_CAPE then
                pick_up(player.uid, spawn(powerup, 0, 0, LAYER.PLAYER, 0, 0))
            else
                player:give_powerup(powerup)
            end
        end
    end

    --held item
    if pracHeld ~= 0 then
        heldItem = spawn(pracHeld, 0,0, LAYER.PLAYER,0,0)
        pick_up(player.uid, heldItem)
    end
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
    local ind = getLevelIndex(warpTo[1],warpTo[2])
    local save = currentSaves[ind]
    local theme = determineTheme(warpTo[1],warpTo[2])
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
    local ind = getLevelIndex(warpTo[1],warpTo[2])
    local save = currentSaves[ind]
    local theme = determineTheme(warpTo[1],warpTo[2])
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
    if not matchStarted and not practiceStarted then return end
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
    if inPrivateRoom then
        determineCheckpointAdjustable(privateCheckpointDistance)
    elseif practiceStarted then
        determineCheckpointAdjustable(0)
        warping = true
        return
    else
        determineCheckpoint()
    end
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

function generatePracticeSeed()
    local chars = "0123456789ABCDEF"
    local hex = ""
    for i = 1, 16 do
        local randIndex = math.random(1, #chars)
        hex = hex .. chars:sub(randIndex, randIndex)
    end
    return hex
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
    if inPrivateRoom and privateRunCustom then return end
    -- run every reset before warp
    if furthestLevel[1] < 7 then 
        furthestLevel[1] = 7
    end
    if furthestLevel[2] < 5 then
        furthestLevel[2] = 5
    end
    if inPrivateRoom and not privateRunCustom then
        if getLevelIndex(furthestLevel[1],furthestLevel[2]) - privateCheckpointDistance <= 23 then
            spawnCoItems = 1
        end
    elseif practiceStarted then
        if getLevelIndex(furthestLevel[1],furthestLevel[2]) <= 23 then
            spawnCoItems = 1
        end
    else
        if furthestLevel[2] <= 8 then
            spawnCoItems = 1
        end
    end
    
end


-- handles for game functions
function preGenHandle()
    if matchStarted then
        loadInventory()
        saveProgress()
        postLevelRequirements()
    end
    if practiceStarted then
        if pracCatMode then
            if pracCategory == "Cosmic Ocean%" then
                loadInventory()
            elseif pracCheckpoints then
                loadInventory()
                saveProgress()
            end
        elseif state.level == pracLevel and state.world == pracWorld then
            loadPracItems()
        end
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
    if practiceStarted and pracCatMode and pracCheckpoints then
        loadProgress()
    end
end


function levelHandle()
    if matchStarted then
        if doReset then
            if inPrivateRoom then
                if privateDoCheckpoints then
                    doWarp()
                elseif not privateRunCustom and categoryType == "Cosmic Ocean%" then
                    doWarp()
                end
            else
                doWarp()
            end
            doReset = false
        end
        if violate then
            force11()
            violate = false
        end
        loadEntities()
        newFurthest()
        setCache()
        local payload = {state.world, state.level, state.theme}
        udpSend("progress", payload)
    end
    if practiceStarted then
        if pracCatMode then
            if (pracCategory == "Cosmic Ocean%" or pracCheckpoints) and practiceReset then
                doWarp()
                practiceReset = false
            end
            if pracCheckpoints then
                loadEntities()
                newFurthest()
                setCache()
            end
        elseif state.level == pracLevel and state.world == pracWorld then
            loadPracEnts()
        end
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
    if practiceStarted then
        if pracCatMode and pracCheckpoints then
            warpToCheckpoint()
        end
        testWin()
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
        if categoryType ~= "Cosmic Ocean%" or (categoryType == "Cosmic Ocean%" and inPrivateRoom and privateRunCustom) then
            shopYet = false
            spawnedItems = {}
            itemsYet = false
            violate = false
        else
            coCheck()
        end
        --dont report on first reset of the run (match start)
        if reportCount > 0 then
            udpSend("death")
        end
        reportCount = reportCount + 1
    end
    if practiceStarted then
        practiceReset = true
        if (pracCatMode and not pracCheckpoints) or (not pracCatMode) then
            math.randomseed(os.time())
            seed = tonumber(generatePracticeSeed(),16)
            if not pracCatMode then
                local ind = getLevelIndex(pracWorld,pracLevel)
                setSeed(ind)
            else
                forceSeed()
            end
        else
            forceSeed()
        end
        runItems = getItemsForRun(pracCategory)
        if pracCatMode then
            if pracCategory ~= "Cosmic Ocean%" then
                shopYet = false
                spawnedItems = {}
                itemsYet = false
            else
                coCheck()
            end
        end
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
    if inPrivateRoom and privateRunCustom then
        if (privateModifiers.noPercent or privateModifiers.lowPercent) and not privateModifiers.chain and privateFinish ~= 1 then--low% non chain
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
            items = get_entities_by_type(ENT_TYPE.MOUNT_TURKEY, ENT_TYPE.MOUNT_ROCKDOG, ENT_TYPE.MOUNT_AXOLOTL, ENT_TYPE.MOUNT_MECH)
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
        if privateModifiers.lowPercent or privateModifiers.noPercent or privateModifiers.noTP then-- notp
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
        if privateModifiers.noGold or privateModifiers.noPercent then--no gold
            if players[1].inventory.money > 0 then
                violated = true
                log_print("no gold violation")
            end
        end
        if privateModifiers.chain then --chain
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
        if (privateModifiers.noPercent or privateModifiers.lowPercent) and privateModifiers.chain then--chain low and chain low co
            if privateFinish ~= 1 then --does not go CO
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
                        for j, exempt in ipairs(chainLowExemptTypes) do
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
                items = get_entities_by_type(ENT_TYPE.MOUNT_TURKEY, ENT_TYPE.MOUNT_ROCKDOG, ENT_TYPE.MOUNT_AXOLOTL, ENT_TYPE.MOUNT_MECH)
                for i = 1, #items do 
                    if get_entity(items[i]).rider_uid == players[1].uid then
                        if get_entity(items[i]).tamed then
                            violated = true
                            log_print("mount violation")
                        end
                    end
                end
                --using restricted item
                items = entity_get_items_by(players[1].uid, chainLowUseViolationItems, 0)
                for i, item in ipairs(items) do
                    if test_flag(read_input(players[1].uid),2) and not test_flag(read_input(players[1].uid),12) then
                        violated = true
                        log_print("item used violation")
                    end
                end
            else -- does go CO
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
                        for j, exempt in ipairs(chainLowExemptTypes) do
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
                items = get_entities_by_type(ENT_TYPE.MOUNT_TURKEY, ENT_TYPE.MOUNT_ROCKDOG, ENT_TYPE.MOUNT_AXOLOTL, ENT_TYPE.MOUNT_MECH)
                for i = 1, #items do 
                    if get_entity(items[i]).rider_uid == players[1].uid then
                        if get_entity(items[i]).tamed then
                            violated = true
                            log_print("mount violation")
                        end
                    end
                end
                --using restricted item
                items = entity_get_items_by(players[1].uid, chainLowCOUseViolationItems, 0)
                for i, item in ipairs(items) do
                    if test_flag(read_input(players[1].uid),2) and not test_flag(read_input(players[1].uid),12) then
                        violated = true
                        log_print("item used violation")
                    end
                end
            end
        end
        if privateModifiers.noPercent then--resource requirements
            if state.items.player_inventory[1].bombs ~= 4 or state.items.player_inventory[1].ropes < 3 or state.items.players[1].health ~= 4 then
                violated = true
            end
        end
        if privateModifiers.pacifist then
            local flag = state.journal_flags
            if not test_flag(flag, 1) then
                violated = true
            end
        end
    else
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
            items = get_entities_by_type(ENT_TYPE.MOUNT_TURKEY, ENT_TYPE.MOUNT_ROCKDOG, ENT_TYPE.MOUNT_AXOLOTL, ENT_TYPE.MOUNT_MECH)
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
        if categoryType == "Low%" or categoryType == "Low% J/T" or categoryType == "No Gold Low%" or categoryType == "No TP Any%" or categoryType == "No TP Sunken City%" or categoryType == "No TP Eggplant%" or categoryType == "No TP Duat%" or categoryType == "No TP Abzu%" or categoryType == "Chain Low% Duat" or categoryType == "Chain Low% Abzu" then
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
        if (categoryType == "Abzu%" or categoryType == "Duat%" or categoryType == "No TP Abzu%" or categoryType == "No TP Duat%" or categoryType == "Chain Low% Duat" or categoryType == "Chain Low% Abzu") then
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
        --chain low
        if categoryType == "Chain Low% Duat" or categoryType == "Chain Low% Abzu" then
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
                    for j, exempt in ipairs(chainLowExemptTypes) do
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
            items = get_entities_by_type(ENT_TYPE.MOUNT_TURKEY, ENT_TYPE.MOUNT_ROCKDOG, ENT_TYPE.MOUNT_AXOLOTL, ENT_TYPE.MOUNT_MECH)
            for i = 1, #items do 
                if get_entity(items[i]).rider_uid == players[1].uid then
                    if get_entity(items[i]).tamed then
                        violated = true
                        log_print("mount violation")
                    end
                end
            end
            --using restricted item
            items = entity_get_items_by(players[1].uid, chainLowUseViolationItems, 0)
            for i, item in ipairs(items) do
                if test_flag(read_input(players[1].uid),2) and not test_flag(read_input(players[1].uid),12) then
                    violated = true
                    log_print("item used violation")
                end
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
    if inPrivateRoom and privateRunCustom then
        if privateModifiers.lowPercent or privateModifiers.noPercent then
            if petcount > 0 and not (inventory.cursed) then
                violated = true
                log_print("pet violation")
            end
        end
        if privateModifiers.chain then
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
            --duat/abzu distinct
            if privateWorld4 == 1 then
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
            elseif privateWorld4 == 2 then
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
        end
        if state.screen == SCREEN.TRANSITION then
            --going temple
            if (state.world == 3 and state.level == 1 and state.theme_next ~= THEME.TEMPLE and privateWorld4 == 2) then
                violated = true
                log_print("shouldve gone temple violation")
            end
            --going jungle
            if ((state.world == 1 and state.level == 4) and state.theme_next ~= THEME.JUNGLE and privateWorld2 == 1) then
                violated = true
                log_print("shouldve gone jungle violation")
            end
            --going tidepool
            if (state.world == 3 and state.level == 1 and state.theme_next ~= THEME.TIDE_POOL and privateWorld4 == 1) then
                violated = true
                log_print("shouldve gone tide violation")
            end
            --going volcana
            if ((state.world == 1 and state.level == 4) and state.theme_next ~= THEME.VOLCANA and privateWorld2 == 2) then
                violated = true
                log_print("shouldve gone volcana violation")
            end
        end
        if state.screen == SCREEN.TRANSITION and privateModifiers.eggplant then
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
    else
        if (categoryType == "Low%" or categoryType == "Low% J/T" or categoryType == "No Gold Low%" or categoryType == "Chain Low% Duat" or categoryType == "Chain Low% Abzu") then
            if petcount > 0 and not (inventory.cursed) then
                violated = true
                log_print("pet violation")
            end
        end
        --global chain requirements
        if (categoryType == "Abzu%" or categoryType == "Duat%" or categoryType == "No TP Abzu%" or categoryType == "No TP Duat%" or categoryType == "Chain Low% Duat" or categoryType == "Chain Low% Abzu") then
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
        if (categoryType =="Abzu%" or categoryType == "No TP Abzu%" or categoryType == "Chain Low% Abzu") then
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
        if (categoryType == "Duat%" or categoryType == "No TP Duat%" or categoryType == "Chain Low% Duat") then
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
    end
    if violated then categoryViolation() end
end

function doorManager()
    --hundun wins block tiamat
    if (categoryType == "Sunken City%" or categoryType == "No TP Sunken City%" or categoryType == "Abzu%" or categoryType == "No TP Abzu%" or categoryType == "Duat%" or categoryType == "No TP Duat%" or categoryType == "No TP Eggplant%" or categoryType == "Chain Low% Abzu" or categoryType == "Chain Low% Duat") then
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
    if inPrivateRoom and mainMenuOpen then
        mainMenuOpen = false
        returnInputs()
    elseif inPrivateRoom then
        udpSend("instant_restart")
    elseif not banPhase then
        udpSend("instant_restart") --despite being named "instant_restart" this is saved in the server as a hard Reset, as it should be
    else
        banPhase = false
        mainMenuOpen = false
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
        if inPrivateRoom then
            if privateRunCustom then
                if (privateFinish == 1 and ((state.screen == SCREEN.CONSTELLATION) or (state.screen == SCREEN.TRANSITION and state.level >= privateFinishLevel))) or (privateFinish ~=1 and state.screen == SCREEN.WIN) then
                    local flag = state.journal_flags
                    if privateModifiers.noGold then
                        winConditionsMet = test_flag(flag, 11) -- no gold
                    end
                    if privateModifiers.lowPercent then 
                        winConditionsMet = test_flag(flag,2) -- vegan
                    end
                    if privateModifiers.noPercent then
                        if notprivateModifiers.chain then
                            winConditionsMet = not test_flag(flag,14) -- damageless
                        end
                    end
                    if privateModifiers.eggplant then
                        winConditionsMet = test_flag(flag, 10)
                    end
                    winConditionsMet = winConditionsMet and not violate
                    if winConditionsMet then 
                        if resendComplete <= 0 then
                            udpSend("completion")
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
            else
                if state.screen == SCREEN.WIN then
                    local flag = state.journal_flags
                    if categoryType == "No Gold Low%" or categoryType == "No TP No Gold" then
                        winConditionsMet = test_flag(flag, 11)
                    end
                    winConditionsMet = winConditionsMet and not violate
                    if winConditionsMet then 
                        if resendComplete <= 0 then
                            udpSend("completion")
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
                        udpSend("completion")
                        resendComplete = 120
                    else 
                        resendComplete = resendComplete - 1
                    end
                end
            end
            
        else
            if state.screen == SCREEN.WIN then
                local flag = state.journal_flags
                if categoryType == "No Gold Low%" or categoryType == "No TP No Gold" then
                    winConditionsMet = test_flag(flag, 11)
                end
                winConditionsMet = winConditionsMet and not violate
                if winConditionsMet then 
                    if resendComplete <= 0 then
                        udpSend("completion")
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
                    udpSend("completion")
                    resendComplete = 120
                else 
                    resendComplete = resendComplete - 1
                end
            end
        end
    end
    if practiceStarted then
        if state.screen == SCREEN.WIN or state.screen == SCREEN.CONSTELLATION then
            prepPracticeMenu()
        end
        if pracCategory == "Cosmic Ocean%" and ((state.screen == SCREEN.TRANSITION and state.level >= 20) or (state.screen == SCREEN.LEVEL and state.level >= 21)) and pracCatMode then
            prepPracticeMenu()
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
            if inPrivateRoom and privateRoomPage == 6 and not privateHost then return end -- looking at results, no need for menu, unless host
            renderVoteMenu(render_ctx)
            if inPrivateRoom and privateRoomPage == 6 and privateHost then
                renderEndMatchButton(render_ctx)
            elseif inPrivateRoom and privateHost then
                renderHostButtons(render_ctx)
            elseif inPrivateRoom and not privateHost then
                renderNonHostButtons(render_ctx)
            else
                renderVoteButtons(render_ctx)
                voteButtonHandle()
            end
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
    if fullResetConfirmation then
        renderText(render_ctx,"Are you sure?", textX, (resetButtonY-(seedButtonScale/20))*ratio, textScale, white)
    else
        renderText(render_ctx,"Reset Seed", textX, (resetButtonY-(seedButtonScale/20))*ratio, textScale, white)
    end
    
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
    if forfeitConfirmation then
        renderText(render_ctx,"Are you sure?", textX, (forfeitButtonY-(seedButtonScale/20))*ratio, textScale, white)
    else
        renderText(render_ctx,forfeitText, textX, (forfeitButtonY-(seedButtonScale/20))*ratio, textScale, white)
    end
end

function renderNonHostButtons(render_ctx)
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
    if fullResetConfirmation then
        renderText(render_ctx,"Are you sure?", textX, (resetButtonY-(seedButtonScale/20))*ratio, textScale, white)
    else
        renderText(render_ctx,"Reset Seed", textX, (resetButtonY-(seedButtonScale/20))*ratio, textScale, white)
    end
    
    renderText(render_ctx,"This will reset your checkpoints!",textX,((resetButtonY-(seedButtonScale/20))-.04)*ratio, .0005, white)

    local seedText = "Forfeit"
    if forfeitConfirmation then
        seedText = "Are you sure?"
    end
    if buttonHovering == 1 then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,seedButtonY,seedButtonX,seedButtonScale)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,seedButtonY,seedButtonX,seedButtonScale)
    end
    renderText(render_ctx,seedText, textX, (seedButtonY-(seedButtonScale/20))*ratio, textScale, white)

    
    local mousePos = inputs.mousepos()
    local x = mousePos.x
    local y = mousePos.y
    if (x>=.51 and x<=.62) then
        if (y<=.52 and y>=.325) then buttonHovering = 0
        elseif (y<=.2625 and y>=.07) then buttonHovering = 1
        else buttonHovering = -1
        end
    else buttonHovering = -1
    end

    if (inputs.leftrelease()) then
        if (buttonHovering == 0) then
            if not fullResetConfirmation then
                fullResetConfirmation = true
            else
                hardReset()
            end
        elseif (buttonHovering == 1) then 
            if not forfeitConfirmation then
                forfeitConfirmation = true
            else
                udpSend("room_forfeit")
            end
        end
    end
end

function renderEndMatchButton(render_ctx)
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

    local forfeitText = "End Match"
    if endMatchConfirmation then
        forfeitText = "Are you sure?"
    end
    if buttonHovering == 3 then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,8,forfeitButtonY,forfeitButtonX,forfeitButtonScale)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,5,8,forfeitButtonY,forfeitButtonX,forfeitButtonScale)
    end
    renderText(render_ctx, forfeitText, textX, (forfeitButtonY-(seedButtonScale/20))*ratio, textScale, white)


    local mousePos = inputs.mousepos()
    local x = mousePos.x
    local y = mousePos.y
    if (x>=.51 and x<=.62) then
        if (y<=-.23 and y>=-.422) then buttonHovering = 3
        else buttonHovering = -1
        end
    else buttonHovering = -1
    end

    if (inputs.leftrelease()) then
        if (buttonHovering == 3) then
            if not endMatchConfirmation then
                endMatchConfirmation = true
            else
                udpSend("room_force_end")
            end
        end
    end
end

function renderHostButtons(render_ctx)
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
    if fullResetConfirmation then
        renderText(render_ctx,"Are you sure?", textX, (resetButtonY-(seedButtonScale/20))*ratio, textScale, white)
    else
        renderText(render_ctx,"Reset Seed", textX, (resetButtonY-(seedButtonScale/20))*ratio, textScale, white)
    end
    
    renderText(render_ctx,"This will reset your checkpoints!",textX,((resetButtonY-(seedButtonScale/20))-.04)*ratio, .0005, white)

    local seedText = "Forfeit"
    if forfeitConfirmation then
        seedText = "Are you sure?"
    end
    if buttonHovering == 1 then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,8,8,seedButtonY,seedButtonX,seedButtonScale)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1,5,8,seedButtonY,seedButtonX,seedButtonScale)
    end
    renderText(render_ctx,seedText, textX, (seedButtonY-(seedButtonScale/20))*ratio, textScale, white)

    local drawText = "Change Seed"
    if sentSeedChange then
        drawText = "Are you sure?"
    end
    if buttonHovering == 2 then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,8,drawButtonY,drawButtonX,drawButtonScale)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,5,8,drawButtonY,drawButtonX,drawButtonScale)
    end
    renderText(render_ctx,drawText, textX, (drawButtonY-(seedButtonScale/20))*ratio, textScale, white)

    local forfeitText = "End Match"
    if endMatchConfirmation then
        forfeitText = "Are you sure?"
    end
    if buttonHovering == 3 then
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,8,8,forfeitButtonY,forfeitButtonX,forfeitButtonScale)
    else
        renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_0,5,8,forfeitButtonY,forfeitButtonX,forfeitButtonScale)
    end
    renderText(render_ctx, forfeitText, textX, (forfeitButtonY-(seedButtonScale/20))*ratio, textScale, white)


    local mousePos = inputs.mousepos()
    local mousePos = inputs.mousepos()
    local x = mousePos.x
    local y = mousePos.y
    if (x>=.51 and x<=.62) then
        if (y<=.52 and y>=.325) then buttonHovering = 0
        elseif (y<=.2625 and y>=.07) then buttonHovering = 1
        elseif (y<=.02 and y>=-.175) then buttonHovering = 2
        elseif (y<=-.23 and y>=-.422) then buttonHovering = 3
        else buttonHovering = -1
        end
    else buttonHovering = -1
    end

    if (inputs.leftrelease()) then
        if (buttonHovering == 0) then
            if not fullResetConfirmation then
                fullResetConfirmation = true
            else
                hardReset()
            end
        elseif (buttonHovering == 1) then 
            if not forfeitConfirmation then
                forfeitConfirmation = true
            else
                udpSend("room_forfeit")
            end
        elseif (buttonHovering == 2) then
            if not sentSeedChange then
                sentSeedChange = true
            else
                udpSend("room_seed_change")
            end
        elseif (buttonHovering == 3) then
            if not endMatchConfirmation then
                endMatchConfirmation = true
            else
                udpSend("room_force_end")
            end
        end
    end
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
    local x = mousePos.x
    local y = mousePos.y
    if (x>=.51 and x<=.62) then
        if (y<=.52 and y>=.325) then buttonHovering = 0
        elseif (y<=.2625 and y>=.07) then buttonHovering = 1
        elseif (y<=.02 and y>=-.175) then buttonHovering = 2
        elseif (y<=-.23 and y>=-.422) then buttonHovering = 3
        else buttonHovering = -1
        end
    else buttonHovering = -1
    end

    if (inputs.leftrelease()) then
        if (buttonHovering == 0) then
            if not fullResetConfirmation then
                fullResetConfirmation = true
            else
                hardReset()
            end
        elseif (buttonHovering == 1 and not sentSeedChange) then 
            sentSeedChange = true
            udpSend("request_seed_change")
        elseif (buttonHovering == 2 and not sentDrawVote) then
            sentDrawVote = true
            udpSend("request_draw")
        elseif (buttonHovering == 3) then
            if not forfeitConfirmation then
                forfeitConfirmation = true
            else
                udpSend("forfeit")
            end
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
            udpSend("close_postmatch")
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
        udpSend("close_postmatch")
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
    if not (matchStarted or banPhase or postMatch or inPrivateRoom) then
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
            if not inPrivateRoom and not mainMenuOpen then
                returnInputs()
            end
            processChat(chatMessage, "You")
            local payload = {chatMessage}
            udpSend("send_chat", payload)
            chatMessage = ""
            chatting = false
            startButtonCooldown()
        end
        if input.keypressed(27) or input.keypressed(KEY.OL_MOD_SHIFT | 27) then
            set_global_timeout(function()
                if game_manager.pause_ui.visibility ~=0 then game_manager.pause_ui.visibility = 0 end
            end, 2)
            chatting = false
            chatMessage = ""
            if not inPrivateRoom and not mainMenuOpen then
                returnInputs()
            end
            startButtonCooldown()
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
    defaultValues()
    defaultPrivate()
    defaultMenu()
    udpSend("queue_leave")
    if postMatch then
        udpSend("close_postmatch")
    end
    if inPrivateRoom then
        inPrivateRoom = false
        udpSend("leave_room")
    end
end

function incrementTimers()
    if inQueue then
        queueTime = queueTime + 1
    end
end

function startButtonCooldown()
    buttonCooldown = true
    set_global_timeout(function()
        buttonCooldown = false
    end, 10)
end

--miscellaneous
function killStupidAnnoyingCritters()
    local uids = get_entities_by_type(annoyingCritters)
    for _, uid in ipairs(uids) do
        kill_entity(uid)
    end
    if practiceStarted then 
        practiceStarted = false
        processChat("Practice session ended.", "Info")
    end
end

--softlock prevention
local SIDE = 0
local PATH_NORMAL, PATH_DROP, PATH_NOTOP, PATH_DROP_NOTOP = 1, 2, 3, 4
local ENTRANCE, ENTRANCE_DROP, EXIT, EXIT_NOTOP = 5, 6, 7, 8
local VLAD_DRILL = 120
local LAKE_EXIT, LAKE_NORMAL, LAKE_NOTOP = 129, 130, 131

local TUSKFRONTDICESHOP, TUSKFRONTDICESHOP_LEFT = 47, 48
local TUSKDICESHOP, TUSKDICESHOP_LEFT = 75, 76

local path_rooms = {
    PATH_NORMAL, 
    PATH_DROP, 
    PATH_NOTOP, 
    PATH_DROP_NOTOP,
    ENTRANCE, 
    ENTRANCE_DROP, 
    EXIT, 
    EXIT_NOTOP, 
    102, 
    107, 
    109,
    TUSKFRONTDICESHOP, 
    TUSKFRONTDICESHOP_LEFT
}

local COMPOUND_FOOTPRINT = {
    [102] = { {0,0}, {1,0}, {0,1}, {1,1} }, -- MACHINE_BIGROOM_PATH
    [103] = { {0,0}, {1,0}, {0,1}, {1,1} }, -- MACHINE_BIGROOM_SIDE
    [105] = { {0,0}, {1,0}, {0,1}, {1,1} }, -- FEELING_PRISON
    [106] = { {0,0}, {1,0}, {0,1}, {1,1} }, -- FEELING_TOMB
    [107] = { {0,0}, {1,0} },               -- MACHINE_WIDEROOM_PATH
    [108] = { {0,0}, {1,0} },               -- MACHINE_WIDEROOM_SIDE
    [109] = { {0,0}, {0,1} },               -- MACHINE_TALLROOM_PATH
    [110] = { {0,0}, {0,1} },               -- MACHINE_TALLROOM_SIDE
}
local FEELING_ROOMS = { [105] = true, [106] = true }

local SHOP_ENTRANCE_UP, SHOP_ENTRANCE_UP_LEFT = 67, 68
local SHOP_ENTRANCE_DOWN, SHOP_ENTRANCE_DOWN_LEFT = 69, 70
local SHOP_ATTIC, SHOP_ATTIC_LEFT = 71, 72
local SHOP_BASEMENT, SHOP_BASEMENT_LEFT = 73, 74
local IDOL, IDOL_TOP = 116, 117

local COFFIN_UNLOCKABLE, COFFIN_UNLOCKABLE_LEFT = 27, 28

local ENTRY_TOP  = { [PATH_NOTOP] = true, [PATH_DROP_NOTOP] = true, [EXIT_NOTOP] = true }
local EXIT_DROP  = { [PATH_DROP] = true, [PATH_DROP_NOTOP] = true, [ENTRANCE_DROP] = true }
local TRUE_EXIT  = { [EXIT] = true, [EXIT_NOTOP] = true }

local TUSK_IDS = { [TUSKFRONTDICESHOP] = true, [TUSKFRONTDICESHOP_LEFT] = true, [TUSKDICESHOP] = true, [TUSKDICESHOP_LEFT] = true }

local UDJATENTRANCE = 29
local last_udjat_room = nil

-- returns a list of {x,y} cells forming the multi-cell group containing (x,y), or nil
local function find_multicell_group(x, y, width, height)
    for origin_id, footprint in pairs(COMPOUND_FOOTPRINT) do
        for _, off in ipairs({ {0,0}, {-1,0}, {0,-1}, {-1,-1} }) do
            local ox, oy = x + off[1], y + off[2]
            if ox >= 0 and oy >= 0 and is_machine_room_origin(ox, oy) then
                if get_room_template(ox, oy, LAYER.FRONT) == origin_id then
                    for _, cell in ipairs(footprint) do
                        if ox + cell[1] == x and oy + cell[2] == y then
                            local group = {}
                            for _, c in ipairs(footprint) do
                                table.insert(group, { ox + c[1], oy + c[2] })
                            end
                            return group
                        end
                    end
                end
            end
        end
    end

    local rt = get_room_template(x, y, LAYER.FRONT)
    if rt == TUSKFRONTDICESHOP and x - 1 >= 0 then
        if get_room_template(x - 1, y, LAYER.FRONT) == TUSKDICESHOP then return { {x, y}, {x - 1, y} } end
    elseif rt == TUSKFRONTDICESHOP_LEFT and x + 1 < width then
        if get_room_template(x + 1, y, LAYER.FRONT) == TUSKDICESHOP_LEFT then return { {x, y}, {x + 1, y} } end
    elseif rt == TUSKDICESHOP and x + 1 < width then
        if get_room_template(x + 1, y, LAYER.FRONT) == TUSKFRONTDICESHOP then return { {x, y}, {x + 1, y} } end
    elseif rt == TUSKDICESHOP_LEFT and x - 1 >= 0 then
        if get_room_template(x - 1, y, LAYER.FRONT) == TUSKFRONTDICESHOP_LEFT then return { {x, y}, {x - 1, y} } end
    elseif (rt == SHOP_ENTRANCE_UP or rt == SHOP_ENTRANCE_UP_LEFT) and y - 1 >= 0 then
        local nrt = get_room_template(x, y - 1, LAYER.FRONT)
        if nrt == SHOP_ATTIC or nrt == SHOP_ATTIC_LEFT then return { {x, y}, {x, y - 1} } end
    elseif (rt == SHOP_ENTRANCE_DOWN or rt == SHOP_ENTRANCE_DOWN_LEFT) and y + 1 < height then
        local nrt = get_room_template(x, y + 1, LAYER.FRONT)
        if nrt == SHOP_BASEMENT or nrt == SHOP_BASEMENT_LEFT then return { {x, y}, {x, y + 1} } end
    elseif (rt == SHOP_ATTIC or rt == SHOP_ATTIC_LEFT) and y + 1 < height then
        local nrt = get_room_template(x, y + 1, LAYER.FRONT)
        if nrt == SHOP_ENTRANCE_UP or nrt == SHOP_ENTRANCE_UP_LEFT then return { {x, y}, {x, y + 1} } end
    elseif (rt == SHOP_BASEMENT or rt == SHOP_BASEMENT_LEFT) and y - 1 >= 0 then
        local nrt = get_room_template(x, y - 1, LAYER.FRONT)
        if nrt == SHOP_ENTRANCE_DOWN or nrt == SHOP_ENTRANCE_DOWN_LEFT then return { {x, y}, {x, y - 1} } end
    elseif rt == IDOL and y - 1 >= 0 then
        if get_room_template(x, y - 1, LAYER.FRONT) == IDOL_TOP then return { {x, y}, {x, y - 1} } end
    elseif rt == IDOL_TOP and y + 1 < height then
        if get_room_template(x, y + 1, LAYER.FRONT) == IDOL then return { {x, y}, {x, y + 1} } end
    end

    return nil

end

-- true if (x1,y1) and (x2,y2) belong to the same multi-cell group
local function same_group(x1, y1, x2, y2, width, height)
    local g = find_multicell_group(x1, y1, width, height)
    if not g then return false end
    for _, c in ipairs(g) do
        if c[1] == x2 and c[2] == y2 then return true end
    end
    return false
end

-- true if this cell counts as "on path" right now.
local function is_path_room(x, y, width, height)
    local rt = get_room_template(x, y, LAYER.FRONT)
    if not FEELING_ROOMS[rt] then
        return has(path_rooms, rt)
    end

    local group = find_multicell_group(x, y, width, height)
    if not group then return false end

    local in_group = {}
    for _, cell in ipairs(group) do
        in_group[cell[1] .. "," .. cell[2]] = true
    end

    for _, cell in ipairs(group) do
        local cx, cy = cell[1], cell[2]
        for _, d in ipairs({ {1,0}, {-1,0}, {0,1}, {0,-1} }) do
            local nx, ny = cx + d[1], cy + d[2]
            if not in_group[nx .. "," .. ny] and nx >= 0 and nx < width and ny >= 0 and ny < height then
                local nrt = get_room_template(nx, ny, LAYER.FRONT)
                if not FEELING_ROOMS[nrt] and has(path_rooms, nrt) then
                    return true
                end
            end
        end
    end

    return false
end

-- plain, no-dissolve write. Only safe to call on cells already known to be
-- single-cell (post-dissolve, or never compound to begin with).
local function replace_room(ctx, x, y, new_id, width, height)
    local group = find_multicell_group(x, y, width, height)
    if group then
        for _, cell in ipairs(group) do
            local cx, cy = cell[1], cell[2]
            if not (cx == x and cy == y) then
                local old_id = get_room_template(cx, cy, LAYER.FRONT)
                if old_id ~= SIDE then
                    ctx:set_room_template(cx, cy, LAYER.FRONT, SIDE)
                    log_print("  room (" .. cx .. "," .. cy .. "): " .. get_room_template_name(old_id) .. " -> " .. get_room_template_name(SIDE) .. " (companion dissolve)")
                end
            end
        end
    end

    local old_id = get_room_template(x, y, LAYER.FRONT)
    local ok = ctx:set_room_template(x, y, LAYER.FRONT, new_id)
    log_print("room (" .. x .. "," .. y .. "): " .. get_room_template_name(old_id) .. " -> " .. get_room_template_name(new_id) .. " (ok=" .. tostring(ok) .. ")")
    return ok
end

-- final sweep: any coffin_unlockable room not horizontally path-adjacent
-- gets converted to a plain side room. Run AFTER all reroute edits, since
-- those edits are exactly what can change whether one ends up adjacent.
local function check_coffin_unlockables(ctx, width, height)
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local rt = get_room_template(x, y, LAYER.FRONT)
            if rt == COFFIN_UNLOCKABLE or rt == COFFIN_UNLOCKABLE_LEFT then
                local adjacent = false
                if x > 0 and is_path_room(x - 1, y, width, height) then adjacent = true end
                if x < width - 1 and is_path_room(x + 1, y, width, height) then adjacent = true end

                if not adjacent then
                    log_print("COFFIN_UNLOCKABLE at (" .. x .. "," .. y .. ") not path-adjacent, replacing with SIDE")
                    replace_room(ctx, x, y, SIDE, width, height)
                end
            end
        end
    end
end

-- dissolves every multi-cell room touching columns [lo, hi] in a row,
-- exactly once per group, BEFORE any other write happens in that operation
local function dissolve_row_range(ctx, row, lo, hi, width, height)
    local dissolved = {}
    for c = lo, hi do
        local key = c .. "," .. row
        if not dissolved[key] then
            local group = find_multicell_group(c, row, width, height)
            if group then
                log_print("dissolving multi-cell room touching (" .. c .. "," .. row .. ")")
                for _, cell in ipairs(group) do
                    local cx, cy = cell[1], cell[2]
                    local old_id = get_room_template(cx, cy, LAYER.FRONT)
                    ctx:set_room_template(cx, cy, LAYER.FRONT, SIDE)
                    log_print("  room (" .. cx .. "," .. cy .. "): " .. get_room_template_name(old_id) .. " -> " .. get_room_template_name(SIDE))
                    dissolved[cx .. "," .. cy] = true
                end
            end
        end
    end
end

-- does the cell at (x,y) potentially connect downward out of its bottom?
local function exits_downward(x, y, width, height)
    local rt = get_room_template(x, y, LAYER.FRONT)
    if EXIT_DROP[rt] then return true end
    -- tusk fronts and compound rooms can exit any allowed side, incl. bottom
    if TUSK_IDS[rt] then return true end
    if find_multicell_group(x, y, width, height) then return true end
    return false
end

-- finds the column where `row` is entered from above.
-- Priority: explicit NOTOP-type template > tuskfront > any path machine room.
-- Used to infer the exit of the row ABOVE it when that row's exit cell has
-- been destroyed (e.g. was part of a dissolved compound room).
local function find_entry_of_row(row, width, height, lake_row)
    if lake_row and row == lake_row then
        for c = 0, width - 1 do
            if get_room_template(c, lake_row, LAYER.FRONT) == LAKE_NOTOP then
                return c
            end
        end
        return nil
    end
    if row < 0 or row >= height then return nil end

    local tuskfront_col, machine_col = nil, nil
    for c = 0, width - 1 do
        local rt = get_room_template(c, row, LAYER.FRONT)
        if ENTRY_TOP[rt] then return c end
        if (rt == TUSKFRONTDICESHOP or rt == TUSKFRONTDICESHOP_LEFT) and not tuskfront_col then
            tuskfront_col = c
        elseif not machine_col
               and find_multicell_group(c, row, width, height)
               and is_path_room(c, row, width, height) then
            machine_col = c
        end
    end
    return tuskfront_col or machine_col
end

local function find_row_span(row, width, height)
    local lo, hi = nil, nil
    local entry_col, exit_col, entry_true, exit_true = nil, nil, false, false

    for c = 0, width - 1 do
        if is_path_room(c, row, width, height) then
            local rt = get_room_template(c, row, LAYER.FRONT)
            if not lo or c < lo then lo = c end
            if not hi or c > hi then hi = c end

            -- ENTRY detection
            if row == 0 and state.level_gen.spawn_room_x == c and state.level_gen.spawn_room_y == 0 then
                entry_col, entry_true = c, true
            elseif row > 0 then
                if ENTRY_TOP[rt] then
                    entry_col = c
                elseif (TUSK_IDS[rt] or find_multicell_group(c, row, width, height))
                       and is_path_room(c, row - 1, width, height)
                       and not same_group(c, row, c, row - 1, width, height)
                       and exits_downward(c, row - 1, width, height) then
                    entry_col = c
                end
            end

            -- EXIT detection
            if row == height - 1 then
                if TRUE_EXIT[rt] then exit_col, exit_true = c, true end
            elseif EXIT_DROP[rt] then
                exit_col = c
            elseif (TUSK_IDS[rt] or find_multicell_group(c, row, width, height))
                   and row < height - 1
                   and is_path_room(c, row + 1, width, height)
                   and not same_group(c, row, c, row + 1, width, height)
                   and ENTRY_TOP[get_room_template(c, row + 1, LAYER.FRONT)] then
                exit_col = c
            end
        end
    end

    return lo, hi, entry_col, exit_col, entry_true, exit_true
end

local function compose_template(has_entry, has_exit, true_entrance, true_exit)
    if true_entrance then return has_exit and ENTRANCE_DROP or ENTRANCE end
    if true_exit then return has_entry and EXIT_NOTOP or EXIT end
    if has_entry and has_exit then return PATH_DROP_NOTOP end
    if has_entry then return PATH_NOTOP end
    if has_exit then return PATH_DROP end
    return PATH_NORMAL
end

local function reconcile_row_span(ctx, row, old_lo, old_hi, new_lo, new_hi, entry_col, exit_col, entry_true, exit_true, width, height)
    local touched_lo = math.min(old_lo, new_lo)
    local touched_hi = math.max(old_hi, new_hi)

    -- PASS 1: dissolve every compound room touching the affected range FIRST,
    -- before any plain writes happen
    dissolve_row_range(ctx, row, touched_lo, touched_hi, width, height)

    -- PASS 2: clear anything left in the old span that's outside the new span
    for c = old_lo, old_hi do
        if c < new_lo or c > new_hi then
            if get_room_template(c, row, LAYER.FRONT) ~= SIDE then
                replace_room(ctx, c, row, SIDE, width, height)
            end
        end
    end

    -- PASS 3: write the new span
    for c = new_lo, new_hi do
        local t = compose_template(c == entry_col, c == exit_col,
                                    c == entry_col and entry_true, c == exit_col and exit_true)
        replace_room(ctx, c, row, t, width, height)
    end
end

-- reconciles `row` given a forced entry, using this row's own exit if
-- findable, or inferring it from the row below. If reconciling this row
-- dissolves a compound room extending into row+1 (destroying ITS entry),
-- recurse into row+1 to repair it too — and keep going until a true exit
-- is reached or no further row exists.
local function cascade_reconnect(ctx, row, entry_col, entry_true, width, height, lake_row, on_lake_swap)
    if row < 0 or row >= height then return end
    if lake_row and row == lake_row then return end

    local lo, hi, _, exit_col, _, exit_true = find_row_span(row, width, height)

    if not exit_col then
        local inferred = find_entry_of_row(row + 1, width, height, lake_row)
        if inferred then
            exit_col = inferred
            exit_true = false
            log_print("inferred row " .. row .. " exit=" .. exit_col .. " from row " .. (row + 1) .. "'s entry")
        end
    end

    if not exit_col then
        -- the entry cell may already be a self-sufficient terminus: tusk and
        -- compound rooms can connect downward on their own, without needing
        -- a separately-detectable exit column. If so, this row is already
        -- correctly connected and needs no further changes.
        local entry_rt = get_room_template(entry_col, row, LAYER.FRONT)
        if TUSK_IDS[entry_rt] or find_multicell_group(entry_col, row, width, height) then
            log_print("row " .. row .. " entry at col " .. entry_col .. " is a self-sufficient tusk/compound terminus, leaving as-is")
            return
        end

        log_print("Could not find exit point for row " .. row .. " -- placing minimum NOTOP connector at col " .. entry_col)
        replace_room(ctx, entry_col, row, PATH_NOTOP, width, height)
        return
    end

    local new_lo = math.min(entry_col, exit_col)
    local new_hi = math.max(entry_col, exit_col)
    local old_lo = lo or new_lo
    local old_hi = hi or new_hi

    log_print("-- reconnecting row " .. row .. ": entry=" .. entry_col .. " exit=" .. exit_col .. " --")
    reconcile_row_span(ctx, row, old_lo, old_hi, new_lo, new_hi, entry_col, exit_col, entry_true, exit_true, width, height)

    if exit_true then return end

    if lake_row and row + 1 == lake_row then
        if on_lake_swap then on_lake_swap(exit_col) end
        return
    end

    cascade_reconnect(ctx, row + 1, exit_col, false, width, height, lake_row, on_lake_swap)
end

local function handle_lake_row_swap(ctx, target_lake_col, width)
    local lake_row = 3
    if get_room_template(target_lake_col, lake_row, LAYER.FRONT) == LAKE_NOTOP then return end

    log_print("-- moving LAKE_NOTOP to col " .. target_lake_col .. " on row " .. lake_row .. " --")

    if get_room_template(target_lake_col, lake_row, LAYER.FRONT) == LAKE_EXIT then
        local relocated = false
        for c = 0, width - 1 do
            if c ~= target_lake_col and get_room_template(c, lake_row, LAYER.FRONT) ~= LAKE_NOTOP then
                replace_room(ctx, c, lake_row, LAKE_EXIT, width, height)
                relocated = true
                break
            end
        end
        if not relocated then
            log_print("WARNING: could not find a column to relocate LAKE_EXIT to")
        end
    end

    for c = 0, width - 1 do
        if get_room_template(c, lake_row, LAYER.FRONT) == LAKE_NOTOP then
            replace_room(ctx, c, lake_row, LAKE_NORMAL, width, height)
            break
        end
    end

    replace_room(ctx, target_lake_col, lake_row, LAKE_NOTOP, width, height)
end

local function reroute_for_edge_room(ctx, target_col, target_row, width, height)
    local adjacent_col = (target_col == 0) and 1 or (width - 2)

    if is_path_room(adjacent_col, target_row, width, height) then
        log_print("Already adjacent, nothing to do")
        return
    end

    local lo, hi, entry_col, _, entry_true = find_row_span(target_row, width, height)

    if entry_col then
        local new_lo = math.min(entry_col, adjacent_col)
        local new_hi = math.max(entry_col, adjacent_col)
        log_print("-- rerouting row " .. target_row .. ": entry=" .. entry_col .. " new exit=" .. adjacent_col .. " --")
        reconcile_row_span(ctx, target_row, lo, hi, new_lo, new_hi, entry_col, adjacent_col, entry_true, false, width, height)

        if target_row == 2 then
            handle_lake_row_swap(ctx, adjacent_col, width)
        else
            cascade_reconnect(ctx, target_row + 1, adjacent_col, false, width, height, 3,
                function(col) handle_lake_row_swap(ctx, col, width) end)
        end
        return
    end

    -- no true entry found: this row's only path presence is a compound
    -- room's body. Leave it untouched and lay a lateral spur to the target.
    local anchor_col = nil
    for c = 0, width - 1 do
        if is_path_room(c, target_row, width, height) and find_multicell_group(c, target_row, width, height) then
            anchor_col = c
            break
        end
    end

    if not anchor_col then
        log_print("Could not find any anchor (entry or compound room) for row " .. target_row)
        return
    end

    log_print("-- branching off compound room at col " .. anchor_col .. " in row " .. target_row .. " toward col " .. adjacent_col .. " --")
    local step = (adjacent_col > anchor_col) and 1 or -1
    local c = anchor_col + step
    while true do
        if c == adjacent_col then
            replace_room(ctx, c, target_row, PATH_DROP, width, height)
            break
        else
            replace_room(ctx, c, target_row, PATH_NORMAL, width, height)
        end
        c = c + step
    end

    if target_row == 2 then
        handle_lake_row_swap(ctx, adjacent_col, width)
    else
        cascade_reconnect(ctx, target_row + 1, adjacent_col, false, width, height, 3,
            function(col) handle_lake_row_swap(ctx, col, width) end)
    end
end

local function reroute_for_udjat(ctx, udjat_col, udjat_row, width, height)
    local candidates = {}
    if udjat_col > 0 then table.insert(candidates, udjat_col - 1) end
    if udjat_col < width - 1 then table.insert(candidates, udjat_col + 1) end

    for _, c in ipairs(candidates) do
        if is_path_room(c, udjat_row, width, height) then
            log_print("UDJATENTRANCE already adjacent at col " .. c .. ", nothing to do")
            return
        end
    end

    local is_last_row = (udjat_row == height - 1)
    local lo, hi, entry_col, orig_exit_col, entry_true, orig_exit_true = find_row_span(udjat_row, width, height)

    local adjacent_col
    if entry_col then
        if #candidates == 1 then
            adjacent_col = candidates[1]
        else
            adjacent_col = (entry_col <= udjat_col) and (udjat_col - 1) or (udjat_col + 1)
        end

        local exit_true = is_last_row
        local new_lo = math.min(entry_col, adjacent_col)
        local new_hi = math.max(entry_col, adjacent_col)
        log_print("-- rerouting row " .. udjat_row .. " for udjat: entry=" .. entry_col .. " new exit=" .. adjacent_col .. " (true_exit=" .. tostring(exit_true) .. ") --")
        reconcile_row_span(ctx, udjat_row, lo, hi, new_lo, new_hi, entry_col, adjacent_col, entry_true, exit_true, width, height)
    else
        local anchor_col = nil
        for c = 0, width - 1 do
            if is_path_room(c, udjat_row, width, height) and find_multicell_group(c, udjat_row, width, height) then
                anchor_col = c
                break
            end
        end

        if not anchor_col then
            log_print("Could not find any anchor (entry or compound room) for row " .. udjat_row .. " (udjat reroute)")
            return
        end

        adjacent_col = (anchor_col < udjat_col) and (udjat_col - 1) or (udjat_col + 1)

        log_print("-- branching off compound room at col " .. anchor_col .. " in row " .. udjat_row .. " toward col " .. adjacent_col .. " (udjat reroute) --")
        local step = (adjacent_col > anchor_col) and 1 or -1
        local c = anchor_col + step
        while true do
            if c == adjacent_col then
                replace_room(ctx, c, udjat_row, is_last_row and EXIT or PATH_DROP, width, height)
            else
                replace_room(ctx, c, udjat_row, PATH_NORMAL, width, height)
            end
            if c == adjacent_col then break end
            c = c + step
        end
    end

    if is_last_row then return end
    cascade_reconnect(ctx, udjat_row + 1, adjacent_col, false, width, height, nil, nil)
end

--tidepool path adjustment
set_callback(function(ctx)
    if not (state.world == 4 and state.level == 3 and state.theme == THEME.TIDE_POOL) then return end
    if categoryType ~= "Chain Low% Abzu" or not (inPrivateRoom and privateRunCustom and privateModifiers.chain) or not (pracCategory == "Chain Low% Abzu" and practiceStarted) then return end
    local width, height = state.width, state.height

    local target_col, target_row = nil, nil
    for ry = 0, 2 do
        if get_room_template(0, ry, LAYER.FRONT) == 36 then target_col, target_row = 0, ry; break
        elseif get_room_template(width - 1, ry, LAYER.FRONT) == 36 then target_col, target_row = width - 1, ry; break end
    end

    if target_col then
        log_print("room 36 found at (" .. target_col .. "," .. target_row .. ")")
        reroute_for_edge_room(ctx, target_col, target_row, width, height)
    else
        log_print("room 36 not found on either edge in rows 0-2")
    end

    check_coffin_unlockables(ctx, width, height)
end, ON.POST_ROOM_GENERATION)

--drill path adjustment
set_callback(function(ctx)
    if not (state.world == 2 and state.theme == THEME.VOLCANA) then return end
    if categoryType ~= "Chain Low% Abzu" or categoryType ~= "Chain Low% Duat" or not (inPrivateRoom and privateRunCustom and privateModifiers.chain) or not ((pracCategory == "Chain Low% Abzu" or pracCategory == "Chain Low% Duat") and practiceStarted) then return end
    if not test_flag(state.presence_flags, 3) then return end

    -- find VLAD_DRILL on the top row
    local drill_x, drill_y = nil, nil
    for rx = 0, state.width - 1 do
        local rt = get_room_template(rx, 0, LAYER.FRONT)
        if rt == 120 then
            drill_x, drill_y = rx, 0
            break
        end
    end
    if not drill_x then
        log_print("No VLAD_DRILL found on top row")
        return
    end

    -- check horizontal adjacency to a path room
    local adjacent_to_path = false
    if drill_x > 0 and has(path_rooms, get_room_template(drill_x - 1, drill_y, LAYER.FRONT)) then
        adjacent_to_path = true
    end
    if drill_x < state.width - 1 and has(path_rooms, get_room_template(drill_x + 1, drill_y, LAYER.FRONT)) then
        adjacent_to_path = true
    end
    if adjacent_to_path then
        log_print("VLAD_DRILL already adjacent to a path room, nothing to do")
        return
    end

    -- not adjacent: move the entrance next to the drill, on whichever side has more room
    local old_x, old_y = state.level_gen.spawn_room_x, state.level_gen.spawn_room_y

    local left_space = drill_x                          -- columns available to the left (0..drill_x-1)
    local right_space = (state.width - 1) - drill_x      -- columns available to the right

    local new_x
    if left_space >= right_space then
        new_x = drill_x - 1
    else
        new_x = drill_x + 1
    end

    if new_x < 0 or new_x > state.width - 1 then
        log_print("No valid neighboring column to place the entrance next to the drill")
        return
    end

    local ok1 = ctx:set_room_template(new_x, 0, LAYER.FRONT, 5)      -- new entrance
    local ok2 = ctx:set_room_template(old_x, old_y, LAYER.FRONT, 2) -- backfill old entrance spot

    if not (ok1 and ok2) then
        log_print("set_room_template failed, check indices")
        return
    end

    state.level_gen.spawn_room_x = new_x
    state.level_gen.spawn_room_y = 0

    local px, py = get_room_pos(new_x, 0)
    state.level_gen.spawn_x = px + (CONST.ROOM_WIDTH / 2)
    state.level_gen.spawn_y = py - (CONST.ROOM_HEIGHT / 2)

end, ON.POST_ROOM_GENERATION)

--udjat entrance adjustment
set_callback(function(ctx)
    last_udjat_room = nil -- reset every run, so a non-matching level can't reuse stale data
    if not (state.world == 1 and test_flag(state.presence_flags, 1)) then return end
    if categoryType ~= "Chain Low% Abzu" or categoryType ~= "Chain Low% Duat" or not (inPrivateRoom and privateRunCustom and privateModifiers.chain) or not ((pracCategory == "Chain Low% Abzu" or pracCategory == "Chain Low% Duat") and practiceStarted) then return end
    local width, height = state.width, state.height

    local udjat_col, udjat_row = nil, nil
    for ry = 1, height - 1 do
        for rx = 0, width - 1 do
            if get_room_template(rx, ry, LAYER.FRONT) == UDJATENTRANCE then
                udjat_col, udjat_row = rx, ry
                break
            end
        end
        if udjat_col then break end
    end

    if not udjat_col then
        log_print("UDJATENTRANCE not found in rows 1-" .. (height - 1))
        return
    end

    log_print("UDJATENTRANCE found at (" .. udjat_col .. "," .. udjat_row .. ")")
    last_udjat_room = { udjat_col, udjat_row }
    reroute_for_udjat(ctx, udjat_col, udjat_row, width, height)
end, ON.POST_ROOM_GENERATION)

--move keyif off path
set_callback(function()
    if not last_udjat_room then return end
    if categoryType ~= "Chain Low% Abzu" or categoryType ~= "Chain Low% Duat" or not (inPrivateRoom and privateRunCustom and privateModifiers.chain) or not ((pracCategory == "Chain Low% Abzu" or pracCategory == "Chain Low% Duat") and practiceStarted) then return end
    local width, height = state.width, state.height

    local uids = get_entities_by_type(ENT_TYPE.ITEM_LOCKEDCHEST_KEY)
    for _, uid in ipairs(uids) do
        local x, y, layer = get_position(uid)
        local rx, ry = get_room_index(x, y)

        if not is_path_room(rx, ry, width, height) then
            local px, py = get_room_pos(last_udjat_room[1], last_udjat_room[2])
            -- 2nd row from top (index 1), 5th column from left (index 4),
            -- centered on the tile. Room dims are 10x8 and 1 tile = 1 world
            -- unit, so tile offsets apply directly. y decreases downward
            -- into the room, matching the centering convention used earlier
            -- for spawn_y.
            local target_x = px + 4.5
            local target_y = py - 1.5

            log_print("ITEM_LOCKEDCHEST_KEY (uid " .. uid .. ") not in a path room at (" .. rx .. "," .. ry .. "), moving to udjat room (" .. last_udjat_room[1] .. "," .. last_udjat_room[2] .. ")")
            move_entity(uid, target_x, target_y, 0, 0, layer)
        else
            log_print("ITEM_LOCKEDCHEST_KEY (uid " .. uid .. ") already in a path room at (" .. rx .. "," .. ry .. "), leaving as-is")
        end
    end
end, ON.POST_LEVEL_GENERATION)



--camp callbacks
set_callback(renderHandle, ON.RENDER_PRE_HUD)
set_callback(spawnSign, ON.CAMP)
set_callback(killStupidAnnoyingCritters,ON.CAMP)
tetris.init({ spawn_sign = false }) --must order after render callback


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
set_global_interval(incrementTimers,60)

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