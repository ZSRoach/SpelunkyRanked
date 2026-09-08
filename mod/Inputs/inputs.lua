local KEYBOARD = {
    RETURN = 13,
    SHIFT = 16,
    CTRL = 17,
    ALT = 18,
    SUPER = 91,
    TAB = 9,
    CAPS = 20,
    BACKSPACE = 8,
    SPACE = 32,
    ESC = 27,
    ARROW_LEFT = 37,
    LEFT_ARROW = 37,
    ARROW_RIGHT = 39,
    RIGHT_ARROW = 39,
    ARROW_UP = 38,
    UP_ARROW = 38,
    ARROW_DOWN = 40,
    DOWN_ARROW = 40,
    A = 65,
    B = 66,
    C = 67,
    D = 68,
    E = 69,
    F = 70,
    G = 71,
    H = 72,
    I = 73,
    J = 74,
    K = 75,
    L = 76,
    M = 77,
    N = 78,
    O = 79,
    P = 80,
    Q = 81,
    R = 82,
    S = 83,
    T = 84,
    U = 85,
    V = 86,
    W = 87,
    X = 88,
    Y = 89,
    Z = 90,
    SEMICOLON = 186,
    QUOTE = 222,
    LEFT_BRACKET = 219,
    RIGHT_BRACKET = 221,
    OPEN_BRACKET = 219,
    CLOSE_BRACKET = 221,
    COMMA = 188,
    PERIOD = 190,
    FORWARD_SLASH = 191,
    NUM_0 = 48,
    NUM_1 = 49,
    NUM_2 = 50,
    NUM_3 = 51,
    NUM_4 = 52,
    NUM_5 = 53,
    NUM_6 = 54,
    NUM_7 = 55,
    NUM_8 = 56,
    NUM_9 = 57,
    EQUAL = 187,
    DASH = 189,
}

local GAMEPAD = {
    DPAD_UP = 1,
    DPAD_DOWN = 2,
    DPAD_LEFT = 3,
    DPAD_RIGHT = 4,
    START = 5,
    SELECT = 6,
    LEFT_THUMB = 7,
    RIGHT_THUMB = 8,
    LEFT_BUMPER = 9,
    RIGHT_BUMPER = 10,
    A = 13,
    B = 14,
    X = 15,
    Y = 16,
    UP = 1000,
    DOWN = 1001,
    LEFT = 1002,
    RIGHT = 1003,
}

local MODE = {
    NONE = 0,
    GAMEPAD = 1,
    MOUSE = 2,
    KEYBOARD = 3,
}

local inputs = {
    active_mode = MODE.NONE,
}
inputs.KEYBOARD = KEYBOARD
inputs.GAMEPAD = GAMEPAD
inputs.MODE = MODE
-- Controller snapshots must be copied because engine-owned objects can mutate in place.
local current_frame_gamepad = {buttons=0, lx=0, ly=0, rx=0, ry=0}
local previous_frame_gamepad = current_frame_gamepad
local previous_frame_mouse = nil
local current_frame_mouse = nil
local pending_gamepad_presses = {}
local pending_gamepad_releases = {}

function inputs.key_down(key)
    return get_io().keydown(key)
end

function inputs.key_press(key)
    return get_io().keypressed(key)
end

function inputs.key_release(key)
    return get_io().keyreleased(key)
end

function inputs.shift_down()
    return get_io().keyshift
end

function inputs.alt_down()
    return get_io().keyalt
end

function inputs.super_down()
    return get_io().keysuper
end

function inputs.control_down()
    return get_io().keyctrl
end

function inputs.gamepad_button_down(button, gamepad)
    gamepad = gamepad or current_frame_gamepad
    if gamepad == nil then return false end
    local buttons = gamepad.buttons or 0
    if button == GAMEPAD.UP then
        if (gamepad.ly or 0) > .5 then return true end
        button = GAMEPAD.DPAD_UP
    elseif button == GAMEPAD.DOWN then
        if (gamepad.ly or 0) < -.5 then return true end
        button = GAMEPAD.DPAD_DOWN
    elseif button == GAMEPAD.LEFT then
        if (gamepad.lx or 0) < -.5 then return true end
        button = GAMEPAD.DPAD_LEFT
    elseif button == GAMEPAD.RIGHT then
        if (gamepad.lx or 0) > .5 then return true end
        button = GAMEPAD.DPAD_RIGHT
    end
    return test_flag(buttons, button)
end

local function clear_direction_aliases(pending, button)
    if button == GAMEPAD.UP or button == GAMEPAD.DPAD_UP then pending[GAMEPAD.UP], pending[GAMEPAD.DPAD_UP] = false, false end
    if button == GAMEPAD.DOWN or button == GAMEPAD.DPAD_DOWN then pending[GAMEPAD.DOWN], pending[GAMEPAD.DPAD_DOWN] = false, false end
    if button == GAMEPAD.LEFT or button == GAMEPAD.DPAD_LEFT then pending[GAMEPAD.LEFT], pending[GAMEPAD.DPAD_LEFT] = false, false end
    if button == GAMEPAD.RIGHT or button == GAMEPAD.DPAD_RIGHT then pending[GAMEPAD.RIGHT], pending[GAMEPAD.DPAD_RIGHT] = false, false end
end

function inputs.gamepad_button_press(button)
    if pending_gamepad_presses[button] then
        pending_gamepad_presses[button] = false
        clear_direction_aliases(pending_gamepad_presses, button)
        return true
    end
    return false
end

function inputs.gamepad_button_release(button)
    if pending_gamepad_releases[button] then
        pending_gamepad_releases[button] = false
        clear_direction_aliases(pending_gamepad_releases, button)
        return true
    end
    return false
end

function inputs.gamepad_left_stick(gamepad)
    gamepad = gamepad or current_frame_gamepad
    if gamepad == nil then return 0, 0 end
    return gamepad.lx or 0, gamepad.ly or 0
end

function inputs.gamepad_right_stick(gamepad)
    gamepad = gamepad or current_frame_gamepad
    if gamepad == nil then return 0, 0 end
    return gamepad.rx or 0, gamepad.ry or 0
end

local function assigned_gamepad()
    local io = get_io()
    local props = game_manager and game_manager.game_props
    local index = props and props.input_index and props.input_index[1]
    if index and index >= 8 and index < 12 and get_raw_input then
        local raw = get_raw_input()
        local controller = raw and raw.controller[index]
        local snapshot = {buttons=0, lx=0, ly=0, rx=0, ry=0}
        if controller then
            local mapping = {[0]=1, [1]=2, [2]=3, [3]=4, [4]=13, [5]=14,
                [6]=15, [7]=16, [8]=9, [9]=10, [12]=7, [13]=8, [14]=6, [15]=5}
            for raw_button, flag in pairs(mapping) do
                local value = controller.buttons and controller.buttons[raw_button]
                if value and value.down then snapshot.buttons = set_flag(snapshot.buttons, flag) end
            end
        end
        return snapshot
    end
    local pad
    if index and index >= 4 and index < 8 and io.gamepads then
        pad = io.gamepads(index - 3)
    else
        pad = io.gamepad
    end
    return {buttons=pad and pad.buttons or 0, lx=pad and pad.lx or 0,
        ly=pad and pad.ly or 0, rx=pad and pad.rx or 0, ry=pad and pad.ry or 0}
end

function inputs.mousewheel()
    return get_io().mousewheel
end

function inputs.mouseclicked()
    local clicks = {}--= {false, false, false, false, false}
    for i, v in pairs(current_frame_mouse) do
        clicks[i] = v and not previous_frame_mouse[i]
    end
    return clicks
end

function inputs.leftclick()
    return current_frame_mouse[1] and not previous_frame_mouse[1]
end
function inputs.rightclick()
    return current_frame_mouse[2] and not previous_frame_mouse[2]
end

function inputs.leftrelease()
    return previous_frame_mouse[1] and not current_frame_mouse[1]
end
function inputs.rightrelease()
    return previous_frame_mouse[2] and not current_frame_mouse[2]
end

function inputs.mousedown()
    return get_io().mousedown
end

function inputs.leftdown()
    return get_io().mousedown[1]
end

function inputs.rightdown()
    return get_io().mousedown[2]
end

function inputs.displaysize()
    return get_io().displaysize
end

 function inputs.mousepos()
    local mousep = {x = get_io().mousepos.x, y = get_io().mousepos.y}
    local display = inputs.displaysize()
    mousep.x = mousep.x / display.x
    mousep.y = mousep.y / display.y
    mousep.x, mousep.y = mousep.x * 2 - 1, 1 - mousep.y * 2
    return mousep
end

local mode_change_callbacks = {}
local mode_change_callb = 1
function inputs.add_mode_change_callback(callback)
    mode_change_callb = mode_change_callb + 1
    mode_change_callbacks[mode_change_callb] = callback
    return mode_change_callb
end

function inputs.clear_mode_change_callback(callback_id)
    mode_change_callbacks[callback_id] = nil
end

local last_mouse_pos = nil
set_callback(function()
    previous_frame_gamepad = current_frame_gamepad
    previous_frame_mouse = current_frame_mouse
    current_frame_gamepad = assigned_gamepad()
    for _, button in pairs(GAMEPAD) do
        if type(button) == 'number' then
            local was_down = inputs.gamepad_button_down(button, previous_frame_gamepad)
            local is_down = inputs.gamepad_button_down(button, current_frame_gamepad)
            if is_down and not was_down then pending_gamepad_presses[button] = true end
            if was_down and not is_down then pending_gamepad_releases[button] = true end
        end
    end

    current_frame_mouse = {}
    for i, v in ipairs(get_io().mousedown) do
        current_frame_mouse[i] = v
    end

    local mouse_pos = get_io().mousepos
    local previous_active_mode = inputs.active_mode
    if last_mouse_pos and (mouse_pos.x ~= last_mouse_pos.x or mouse_pos.y ~= last_mouse_pos.y) then
        inputs.active_mode = MODE.MOUSE
    elseif inputs.key_press(KEYBOARD.UP_ARROW) or inputs.key_press(KEYBOARD.DOWN_ARROW) or inputs.key_press(KEYBOARD.RIGHT_ARROW) or inputs.key_press(KEYBOARD.LEFT_ARROW) then
        inputs.active_mode = MODE.KEYBOARD
    elseif (inputs.gamepad_button_down(GAMEPAD.UP, current_frame_gamepad) and not inputs.gamepad_button_down(GAMEPAD.UP, previous_frame_gamepad))
        or (inputs.gamepad_button_down(GAMEPAD.DOWN, current_frame_gamepad) and not inputs.gamepad_button_down(GAMEPAD.DOWN, previous_frame_gamepad))
        or (inputs.gamepad_button_down(GAMEPAD.LEFT, current_frame_gamepad) and not inputs.gamepad_button_down(GAMEPAD.LEFT, previous_frame_gamepad))
        or (inputs.gamepad_button_down(GAMEPAD.RIGHT, current_frame_gamepad) and not inputs.gamepad_button_down(GAMEPAD.RIGHT, previous_frame_gamepad)) then
        inputs.active_mode = MODE.GAMEPAD
    end
    if inputs.active_mode ~= previous_active_mode then
        for _, callback in pairs(mode_change_callbacks) do
            callback(inputs.active_mode, previous_active_mode)
        end
    end
    last_mouse_pos = {x=mouse_pos.x, y=mouse_pos.y}
end, ON.GUIFRAME)

return inputs
-- return {
--     KEYBOARD = KEYBOARD,
--     GAMEPAD = GAMEPAD,
--     key_down = key_down,
--     key_press = key_press,
--     key_release = key_release,
--     gamepad_button_down = gamepad_button_down,
--     gamepad_button_press = gamepad_button_press,
--     gamepad_button_release = gamepad_button_release,
--     mousewheel = mousewheel,
--     mousepos = mousepos,
--     displaysize = displaysize,
--     add_mode_change_callback = add_mode_change_callback,
--     clear_mode_change_callback = clear_mode_change_callback,
-- }