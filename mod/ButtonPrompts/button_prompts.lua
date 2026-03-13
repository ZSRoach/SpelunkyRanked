
-- The prompt type determines what icon is shown along with the prompt.
local PROMPT_TYPE <const> = {
	DOOR = 0,
	INTERACT = 1,
	VIEW = 2,
	SPEECH = 3,
}

local active = false
local reset_callback = nil

local signs = {}
local callbacks = {}
local action_callbacks = {}
local shop_callbacks = {}
local button_prompts_hidden = false
local function reset_button_prompts()
	signs = {}
	button_prompts_hidden = false
    for _, callback in pairs(callbacks) do
        clear_callback(callback)
    end
    for _, callback in pairs(shop_callbacks) do
        clear_callback(callback)
    end
    for _, callback in pairs(action_callbacks) do
        clear_callback(callback)
    end
    callbacks = {}
    shop_callbacks = {}
    action_callbacks = {}
end

-- If hidden=true, hide all button prompts. If hidden=false, enable all button prompts such that
-- prompts near the player will be visible.
local function hide_button_prompts(hidden)
	button_prompts_hidden = hidden
    for _, sign in ipairs(signs) do
        if button_prompts_hidden then
            sign.flags = clr_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
        else
            sign.flags = set_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
        end
    end
end

local function configure_prompt(sign, prompt_type, callback, condition)
    sign.flags = set_flag(sign.flags, ENT_FLAG.INVISIBLE)
    if button_prompts_hidden then
        sign.flags = clr_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
    end
    local button_fx
    for _, item in pairs(sign:get_items()) do
        local item_ent = get_entity(item)
        if item_ent.type.id == ENT_TYPE.FX_BUTTON then
            button_fx = item_ent
        end
    end

    if condition then
        set_post_statemachine(sign.uid, function()
            if condition() and not button_prompts_hidden then
                sign.flags = set_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
            else
                sign.flags = clr_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
            end
        end)
    end

    local prompt = get_entity(entity_get_items_by(button_fx.uid, ENT_TYPE.FX_BUTTON_DIALOG, 0)[1])
    prompt.animation_frame = 137 + 16 * prompt_type
    signs[#signs+1] = sign

    action_callbacks[sign.uid] = set_callback(function(text)
        if text == get_string(hash_to_stringid(0x12645577)) or text == get_string(hash_to_stringid(0xbab72d60)) then
            if button_fx.player_trigger then
                if callback then
                    callback()
                end

                return ""
            end
        end
        return nil
    end, ON.TOAST)
end

-- Spawn a button prompt at the coordinates.
-- prompt_type: Sets the icon that will be used along with the prompt.
-- x, y, layer: Position of the prompt.
-- callback: function called when the prompt button is pressed.
local function spawn_button_prompt(prompt_type, x, y, layer, callback, condition)
    -- Spawn a sign to "host" the prompt. We will hide the sign and silence its sound.
    local sign_uid = spawn_entity(ENT_TYPE.ITEM_CONSTRUCTION_SIGN, x, y, layer, 0, 0)
    local sign = get_entity(sign_uid)
    configure_prompt(sign, prompt_type, callback, condition)
    return sign_uid
end

-- Spawn a button prompt attached to an entity.
-- prompt_type: Sets the icon that will be used along with the prompt.
-- on_entity_uid: Entity that the prompt will attach to.
-- callback: function called when the prompt button is pressed.
local function spawn_button_prompt_on(prompt_type, on_entity_uid, callback, condition)
    local x, y, layer = get_position(on_entity_uid)
    local on_entity = get_entity(on_entity_uid)
    -- Spawn a sign to "host" the prompt. We will hide the sign and silence its sound.
    local sign_uid = spawn_entity(ENT_TYPE.ITEM_CONSTRUCTION_SIGN, x, y, layer, 0, 0)
    local sign = get_entity(sign_uid)
    configure_prompt(sign, prompt_type, callback, condition)

    callbacks[sign_uid] = set_callback(function()
        local x, y, layer = get_position(on_entity_uid)
        local on_entity_now = get_entity(on_entity_uid)
        local sign_now = get_entity(sign_uid)
        if on_entity_now ~= on_entity or sign_now ~= sign then
            clear_callback(callbacks[sign_uid])
            callbacks[sign_uid] = nil
            if action_callbacks[sign_uid] then
                clear_callback(action_callbacks[sign_uid])
                action_callbacks[sign_uid] = nil
            end
            sign:destroy()
            return
        end
        -- Do not try moving the sign into a floor tile, since that will destroy it.
        local tiles = get_entities_at(0, MASK.FLOOR | MASK.ACTIVEFLOOR, x, y, layer, .5)
        if #tiles == 0 then
            sign.x, sign.y, sign.layer = x, y, layer
        end
    end, ON.GAMEFRAME)
    return sign_uid
end

local function spawn_shop_prompt_on(prompt_type, on_entity_uid, item_name, value_text, show_price_icon, callback)
    item_name = item_name or ""
    value_text = value_text or ""
    local sign_uid = spawn_button_prompt_on(prompt_type, on_entity_uid, callback)
    local sign = get_entity(sign_uid)

    local button_fx
    for _, item in pairs(sign:get_items()) do
        local item_ent = get_entity(item)
        if item_ent.type.id == ENT_TYPE.FX_BUTTON then
            button_fx = item_ent
        end
    end

    button_fx.y = 2.3
    button_fx.x = -1

    local function update_item_name(new_item_name)
        item_name = new_item_name
    end

    local function update_value_text(new_value_text)
        value_text = new_value_text
    end

    shop_callbacks[sign_uid] = set_callback(function(ctx, draw_depth)
        if draw_depth ~= 1 then return end
        if button_prompts_hidden then return end
        local black = Color:black()
        local white = Color:white()
        local gray = Color:gray()
        black.a = button_fx.color.a
        white.a = button_fx.color.a
        gray.a = button_fx.color.a

        local x, y = get_position(on_entity_uid)
        y = y - 1.3

        ctx:draw_world_texture(TEXTURE.DATA_TEXTURES_MENU_BASIC_3, 5, 0, x - 1.5, y + 3.5, x + 1.5, y + 2, white)

        local screenx1, screeny1 = screen_position(x, y + 3.1)
        local screenx2, screeny2 = screen_position(x, y + 2.62)
        local text = item_name
        local text2 = value_text
        ctx:draw_text(text, screenx1, screeny1, .00064, .00064, black, VANILLA_TEXT_ALIGNMENT.CENTER, VANILLA_FONT_STYLE.ITALIC)
        ctx:draw_text(text2, screenx2, screeny2, .0005, .0005, white, VANILLA_TEXT_ALIGNMENT.CENTER, VANILLA_FONT_STYLE.ITALIC)

    end, ON.RENDER_PRE_DRAW_DEPTH)
    return {
        sign_uid = sign_uid,
        sign = sign,
        update_item_name = update_item_name,
        update_value_text = update_value_text,
    }
end

local function activate()
    if active then return end
    active = true

    reset_callback = set_callback(function()
        reset_button_prompts()
    end, ON.PRE_LOAD_LEVEL_FILES)
end

local function deactivate()
    if not active then return end
    active = false
    reset_button_prompts()
    if reset_callback then
        clear_callback(reset_callback)
        reset_callback = nil
    end
end

set_callback(function(ctx)
    -- Initialize in the active state.
    activate()
end, ON.LOAD)

return {
    PROMPT_TYPE = PROMPT_TYPE,
    spawn_button_prompt = spawn_button_prompt,
    spawn_button_prompt_on = spawn_button_prompt_on,
    spawn_shop_prompt_on = spawn_shop_prompt_on,
    hide_button_prompts = hide_button_prompts,
    activate = activate,
    deactivate = deactivate,
}
