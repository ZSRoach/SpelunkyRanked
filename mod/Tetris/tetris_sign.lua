local tetris_sign = {}

--[[
    Reusable Tetris sign module.

    Standalone:
      local tetris = require('tetris_sign')
      tetris.init()

    Bigger mod:
      local tetris = require('tetris_sign')
      tetris.init({ spawn_sign = false })
      tetris.open()
]]

local config = {
    spawn_sign = true,
    sign_x = 46,
    sign_y = 84,
    sign_layer = LAYER.FRONT,
}

local callbacks_registered = false
local sync_fallback_inputs = nil


-- This demo is intentionally self-contained. The original ranked mod had helper modules
-- for button prompts and input polling, but the sign demo should not crash if a dev only
-- drops this module into a clean test pack.
local ok_inputs, inputs = pcall(require, 'Inputs.inputs')
if not ok_inputs or inputs == nil then
    inputs = {
        KEYBOARD = {
            RETURN = 13, SPACE = 32, ESC = 27,
            LEFT_ARROW = 37, RIGHT_ARROW = 39, UP_ARROW = 38, DOWN_ARROW = 40,
            A = 65, D = 68, S = 83, W = 87,
        },
        GAMEPAD = {
            DPAD_UP = 1, DPAD_DOWN = 2, DPAD_LEFT = 3, DPAD_RIGHT = 4,
            A = 13, B = 14,
            UP = 1000, DOWN = 1001, LEFT = 1002, RIGHT = 1003,
        },
    }

    local previous_gamepad = nil
    local current_gamepad = nil

    local function gamepad_down_from_snapshot(button, gamepad)
        if gamepad == nil then return false end
        if button == inputs.GAMEPAD.UP then
            return (gamepad.ly or 0) > 0.5 or test_flag(gamepad.buttons or 0, inputs.GAMEPAD.DPAD_UP)
        elseif button == inputs.GAMEPAD.DOWN then
            return (gamepad.ly or 0) < -0.5 or test_flag(gamepad.buttons or 0, inputs.GAMEPAD.DPAD_DOWN)
        elseif button == inputs.GAMEPAD.LEFT then
            return (gamepad.lx or 0) < -0.5 or test_flag(gamepad.buttons or 0, inputs.GAMEPAD.DPAD_LEFT)
        elseif button == inputs.GAMEPAD.RIGHT then
            return (gamepad.lx or 0) > 0.5 or test_flag(gamepad.buttons or 0, inputs.GAMEPAD.DPAD_RIGHT)
        end
        return test_flag(gamepad.buttons or 0, button)
    end

    function inputs.key_down(key)
        return get_io().keydown(key)
    end

    function inputs.key_press(key)
        return get_io().keypressed(key)
    end

    function inputs.gamepad_button_down(button)
        return gamepad_down_from_snapshot(button, current_gamepad)
    end

    function inputs.gamepad_button_press(button)
        return gamepad_down_from_snapshot(button, current_gamepad) and not gamepad_down_from_snapshot(button, previous_gamepad)
    end

    sync_fallback_inputs = function()
        previous_gamepad = current_gamepad
        current_gamepad = get_io().gamepad
    end
end


local SPELUNKY_INPUT_FLAG = {
    WHIP = 2,
    LEFT = 9,
    RIGHT = 10,
    DOWN = 12,
}

local previous_spelunky_buttons = 0
local current_spelunky_buttons = 0

local function get_spelunky_buttons()
    if state and state.player_inputs and state.player_inputs.player_slot_1 then
        return state.player_inputs.player_slot_1.buttons_gameplay or state.player_inputs.player_slot_1.buttons or 0
    end
    return 0
end

local function spelunky_button_down(button)
    return current_spelunky_buttons ~= nil and test_flag(current_spelunky_buttons, button)
end

local function spelunky_button_press(button)
    return spelunky_button_down(button) and not test_flag(previous_spelunky_buttons or 0, button)
end

local ratio = 16 / 9
local white = Color:white()
local black = Color:black()
local gray = Color:gray()

local sign = nil
local sign_open = false
local sign_delay = false
local tetris_open = false
local blocking_inputs = false
local returning_inputs = false
local menu_button_index = 0
local sign_button_fx = nil
local sign_uid = -1

local BOARD_W = 12
local BOARD_H = 22
local CELL = 0.035 -- .032
local BOARD_LEFT = -0.23
local BOARD_TOP = 0.38
local FALL_FRAMES_START = 24
local FALL_FRAMES_FAST = 3
local FALL_FRAMES_MIN = 10
local MOVE_REPEAT_DELAY = 14
local MOVE_REPEAT_INTERVAL = 9

local tetris = {}

local pieces = {
    I = {
        {{0,0}, {-1,0}, {1,0}, {2,0}},
        {{0,0}, {0,-1}, {0,1}, {0,2}},
    },
    O = {
        {{0,0}, {1,0}, {0,1}, {1,1}},
    },
    T = {
        {{0,0}, {-1,0}, {1,0}, {0,1}},
        {{0,0}, {0,-1}, {0,1}, {1,0}},
        {{0,0}, {-1,0}, {1,0}, {0,-1}},
        {{0,0}, {0,-1}, {0,1}, {-1,0}},
    },
    L = {
        {{0,0}, {-1,0}, {1,0}, {1,1}},
        {{0,0}, {0,-1}, {0,1}, {1,-1}},
        {{0,0}, {-1,-1}, {-1,0}, {1,0}},
        {{0,0}, {-1,1}, {0,-1}, {0,1}},
    },
    J = {
        {{0,0}, {-1,1}, {-1,0}, {1,0}},
        {{0,0}, {0,-1}, {0,1}, {1,1}},
        {{0,0}, {-1,0}, {1,0}, {1,-1}},
        {{0,0}, {-1,-1}, {0,-1}, {0,1}},
    },
    S = {
        {{0,0}, {1,0}, {0,1}, {-1,1}},
        {{0,0}, {0,-1}, {1,0}, {1,1}},
    },
    Z = {
        {{0,0}, {-1,0}, {0,1}, {1,1}},
        {{0,0}, {1,-1}, {1,0}, {0,1}},
    },
}

local piece_bag = {'I', 'O', 'T', 'L', 'J', 'S', 'Z'}

-- local board_fill_color = Color:new(0.035, 0.04, 0.055, 0.94)
-- local board_grid_color = Color:new(0.18, 0.20, 0.24, 0.30)
-- local board_border_color = Color:new(0.78, 0.80, 0.86, 0.85)
local board_fill_color = Color:new(0.180, 0.145, 0.090, 0.08)
local board_grid_color = Color:new(0.090, 0.075, 0.047, 1)
local board_border_color = Color:new(0.1, 0.1, 0.1, 1)
local block_edge_color = Color:new(0.08, 0.08, 0.10, 0.82)
local piece_colors = {
    I = Color:aqua(),
    O = Color:yellow(),
    T = Color:fuchsia(),
    L = Color:new(1.0, 0.48, 0.08, 1.0),
    J = Color:blue(),
    S = Color:lime(),
    Z = Color:red(),
}

local piece_sprites = {
    O = {
        texture = TEXTURE.DATA_TEXTURES_MONSTERS_OLMEC_0,
        row = 0,
        col = 0,
    },
    L = {
        texture = TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_TRAPS_0,
        row = 0,
        col = 3,
        per_cell = true,
    },
    T = {
        texture = TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_TRAPS_0,
        row = 0,
        col = 6,
        per_cell = true,
    },
    J = {
        texture = TEXTURE.DATA_TEXTURES_JOURNAL_ENTRY_TRAPS_0,
        row = 0,
        col = 1,
        per_cell = true,
    },
    S = {
        texture = TEXTURE.DATA_TEXTURES_FLOORSTYLED_GOLD_0,
        row = 9,
        col = 9,
        per_cell = true,
    },
    I_TOP = {
        texture = TEXTURE.DATA_TEXTURES_FLOORMISC_0,
        row = 6,
        col = 1,
        per_cell = true,
    },
    I_MIDDLE_A = {
        texture = TEXTURE.DATA_TEXTURES_FX_SMALL2_0,
        row = 4,
        col = 6,
        per_cell = true,
    },
    I_MIDDLE_B = {
        texture = TEXTURE.DATA_TEXTURES_FX_SMALL2_0,
        row = 4,
        col = 5,
        per_cell = true,
    },
    I_BOTTOM = {
        texture = TEXTURE.DATA_TEXTURES_FLOORMISC_0,
        row = 2,
        col = 6,
        per_cell = true,
    },
    Z_LEFT = {
        texture = TEXTURE.DATA_TEXTURES_FLOORSTYLED_WOOD_0,
        row = 5,
        col = 0,
        per_cell = true,
    },
    Z_MIDDLE_TOP = {
        texture = TEXTURE.DATA_TEXTURES_FLOORSTYLED_WOOD_0,
        row = 2,
        col = 2,
        per_cell = true,
    },
    Z_MIDDLE_BOTTOM = {
        texture = TEXTURE.DATA_TEXTURES_FLOORSTYLED_WOOD_0,
        row = 4,
        col = 0,
        per_cell = true,
    },
    Z_RIGHT = {
        texture = TEXTURE.DATA_TEXTURES_FLOORSTYLED_WOOD_0,
        row = 5,
        col = 2,
        per_cell = true,
    },
}

local texture_source_cache = {}

local function source_quad_for_sprite(sprite, qx, qy, qw, qh)
    local key = tostring(sprite.texture) .. ':' .. sprite.row .. ':' .. sprite.col .. ':' .. qx .. ':' .. qy .. ':' .. qw .. ':' .. qh
    if texture_source_cache[key] ~= nil then
        return texture_source_cache[key]
    end

    local def = get_texture_definition(sprite.texture)
    if def == nil then
        return nil
    end

    local tile_width = def.tile_width or def.sub_image_width or def.width
    local tile_height = def.tile_height or def.sub_image_height or def.height
    local tile_left = ((def.sub_image_offset_x or 0) + (sprite.col * tile_width)) / def.width
    local tile_top = ((def.sub_image_offset_y or 0) + (sprite.row * tile_height)) / def.height
    local tile_w = tile_width / def.width
    local tile_h = tile_height / def.height
    local source = Quad:new(AABB:new(
        tile_left + (tile_w * qx),
        tile_top + (tile_h * qy),
        tile_left + (tile_w * (qx + qw)),
        tile_top + (tile_h * (qy + qh))
    ))

    texture_source_cache[key] = source
    return source
end

local function render_text(ctx, str, x, y, scale, color, align)
    ctx:draw_text(str, x, y, scale, scale, color, align or VANILLA_TEXT_ALIGNMENT.CENTER, VANILLA_FONT_STYLE.ITALIC)
end

local function render_texture(ctx, texture, row, col, top, left, size, color)
    local box = AABB:new(left, top * ratio, left + (size * 0.1), (top - (size * 0.1)) * ratio)
    ctx:draw_screen_texture(texture, row, col, box, color or white)
end

local function render_panel(ctx, top, left, rows, cols, size)
    for y = 0, rows - 1 do
        for x = 0, cols - 1 do
            local row = y
            local col = x
            if row > 4 then row = 4 end
            if col > 4 then col = 4 end
            render_texture(ctx, TEXTURE.DATA_TEXTURES_MENU_BASIC_2, row, col, top - (y * size * 0.1), left + (x * size * 0.1), size, white)
        end
    end
end

local function block_inputs()
    blocking_inputs = true
    returning_inputs = false
end

local function return_inputs()
    returning_inputs = true
    blocking_inputs = false
end

local function input_blocker_tick()
    if blocking_inputs then
        set_journal_enabled(false)
        if players and players[1] then
            get_player(1).input = nil
            blocking_inputs = false
        end
    elseif returning_inputs then
        set_journal_enabled(true)
        if game_manager and game_manager.pause_ui then
            game_manager.pause_ui.prompt_visible = false
        end
        if players and players[1] then
            get_player(1).input = state.player_inputs.player_slot_1
            returning_inputs = false
        end
    end
end

local function board_cell_empty(x, y)
    if x < 1 or x > BOARD_W then return false end
    if y > BOARD_H then return false end
    if y < 1 then return true end
    return tetris.board[y][x] == nil
end

local function current_blocks(piece, px, py, rot)
    local out = {}
    local shape = pieces[piece][rot]
    for _, p in ipairs(shape) do
        out[#out + 1] = {x = px + p[1], y = py + p[2]}
    end
    return out
end

local function current_o_segments(px, py)
    return {
        {x = px, y = py, segment = 'O', quad_x = 0.0, quad_y = 0.0},
        {x = px + 1, y = py, segment = 'O', quad_x = 0.5, quad_y = 0.0},
        {x = px, y = py + 1, segment = 'O', quad_x = 0.0, quad_y = 0.5},
        {x = px + 1, y = py + 1, segment = 'O', quad_x = 0.5, quad_y = 0.5},
    }
end

local function current_i_segments(px, py, rot, anim_step)
    local blocks = current_blocks('I', px, py, rot)
    table.sort(blocks, function(a, b)
        if rot == 1 then
            return a.x < b.x
        end
        if a.y == b.y then
            return a.x < b.x
        end
        return a.y < b.y
    end)

    local middle_a = 'I_MIDDLE_A'
    local middle_b = 'I_MIDDLE_B'
    if (anim_step or 0) % 2 == 1 then
        middle_a, middle_b = middle_b, middle_a
    end

    local segments = {'I_TOP', middle_a, middle_b, 'I_BOTTOM'}
    local angle = rot == 1 and math.pi / 2 or 0
    for i, block in ipairs(blocks) do
        block.segment = segments[i] or 'I_MIDDLE_A'
        block.angle = angle
    end
    return blocks
end

local function current_z_segments(px, py, rot)
    local blocks = current_blocks('Z', px, py, rot)
    local by_pos = {}
    for _, block in ipairs(blocks) do
        by_pos[block.x .. ':' .. block.y] = block
    end

    local ordered = nil
    local angle = 0
    if rot == 1 then
        ordered = {
            by_pos[(px - 1) .. ':' .. py],
            by_pos[px .. ':' .. py],
            by_pos[px .. ':' .. (py + 1)],
            by_pos[(px + 1) .. ':' .. (py + 1)],
        }
    else
        angle = math.pi / 2
        ordered = {
            by_pos[px .. ':' .. (py + 1)],
            by_pos[px .. ':' .. py],
            by_pos[(px + 1) .. ':' .. py],
            by_pos[(px + 1) .. ':' .. (py - 1)],
        }
    end

    local segments = {'Z_LEFT', 'Z_MIDDLE_TOP', 'Z_MIDDLE_BOTTOM', 'Z_RIGHT'}
    local out = {}
    for i, block in ipairs(ordered) do
        if block then
            block.segment = segments[i]
            block.angle = angle
            out[#out + 1] = block
        end
    end
    return out
end

local function can_place(piece, px, py, rot)
    for _, b in ipairs(current_blocks(piece, px, py, rot)) do
        if not board_cell_empty(b.x, b.y) then
            return false
        end
    end
    return true
end

local function choose_piece()
    return piece_bag[math.random(#piece_bag)]
end

local function spawn_piece()
    tetris.piece = tetris.next_piece or choose_piece()
    tetris.next_piece = choose_piece()
    tetris.rot = 1
    tetris.x = 6
    tetris.y = 1
    tetris.i_anim = 0
    tetris.move_hold_dir = 0
    tetris.move_hold_frames = 0
    if not can_place(tetris.piece, tetris.x, tetris.y, tetris.rot) then
        tetris.game_over = true
    end
end

local function reset_tetris()
    tetris = {
        board = {},
        score = 0,
        lines = 0,
        fall_timer = 0,
        base_fall_frames = FALL_FRAMES_START,
        fall_frames = FALL_FRAMES_START,
        game_over = false,
        paused = false,
        next_piece = nil,
        i_anim = 0,
        locked_i_anim = 0,
        move_hold_dir = 0,
        move_hold_frames = 0,
            }
    for y = 1, BOARD_H do
        tetris.board[y] = {}
    end
    spawn_piece()
end

local function lock_piece()
    local locksound = get_sound(VANILLA_SOUND.MENU_MM_SET)
    local sound2 = locksound:play(false)
    local blocks = current_blocks(tetris.piece, tetris.x, tetris.y, tetris.rot)
    if tetris.piece == 'O' then
        blocks = current_o_segments(tetris.x, tetris.y)
    elseif tetris.piece == 'I' then
        blocks = current_i_segments(tetris.x, tetris.y, tetris.rot, tetris.i_anim)
    elseif tetris.piece == 'Z' then
        blocks = current_z_segments(tetris.x, tetris.y, tetris.rot)
    end

    for _, b in ipairs(blocks) do
        if b.y >= 1 and b.y <= BOARD_H and b.x >= 1 and b.x <= BOARD_W then
            if b.segment then
                local role = nil
                if b.segment == 'I_MIDDLE_A' then
                    role = 'middle_a'
                elseif b.segment == 'I_MIDDLE_B' then
                    role = 'middle_b'
                end
                tetris.board[b.y][b.x] = {
                    sprite = b.segment,
                    angle = b.angle or 0,
                    i_role = role,
                    quad_x = b.quad_x,
                    quad_y = b.quad_y,
                    quad_w = b.quad_w,
                    quad_h = b.quad_h,
                }
            else
                tetris.board[b.y][b.x] = tetris.piece
            end
        end
    end

    local cleared = 0
    local new_board = {}
    local write_y = BOARD_H
    for y = BOARD_H, 1, -1 do
        local full = true
        for x = 1, BOARD_W do
            if tetris.board[y][x] == nil then
                full = false
                break
            end
        end
        if full then
            cleared = cleared + 1
        else
            new_board[write_y] = tetris.board[y]
            write_y = write_y - 1
        end
    end

    for y = write_y, 1, -1 do
        new_board[y] = {}
    end

    tetris.board = new_board

    if cleared > 0 then
        local old_level = math.floor(tetris.lines / 8)
        tetris.lines = tetris.lines + cleared
        tetris.score = tetris.score + ({100, 300, 500, 800})[cleared]
        local new_level = math.floor(tetris.lines / 8)
        if new_level > old_level then
            tetris.base_fall_frames = math.max(FALL_FRAMES_MIN, tetris.base_fall_frames - (2 * (new_level - old_level)))
        end
        local gem = get_sound(VANILLA_SOUND.UI_GET_GEM)
        local sound = gem:play(true)
        if cleared == 1 then
            sound:set_parameter(8, .8)
            sound:set_volume(2)
        elseif cleared == 2 then
            sound:set_parameter(8, 1.2)
            sound:set_volume(2)
        elseif cleared == 3 then
            sound:set_parameter(8, 1.6)
            sound:set_volume(2)
        elseif cleared == 4 then
            sound:set_parameter(8, 5.0)
            sound:set_volume(2)
        end
        sound:set_pause(false)
    end
    

    spawn_piece()
end

local function move_piece(dx, dy)
    if can_place(tetris.piece, tetris.x + dx, tetris.y + dy, tetris.rot) then
        tetris.x = tetris.x + dx
        tetris.y = tetris.y + dy
        if tetris.piece == 'I' and dy > 0 then
            tetris.i_anim = (tetris.i_anim or 0) + 1
        end
        return true
    end
    return false
end

local function horizontal_input_tick()
    local left_held = spelunky_button_down(SPELUNKY_INPUT_FLAG.LEFT)
    local right_held = spelunky_button_down(SPELUNKY_INPUT_FLAG.RIGHT)
    local dir = 0

    if left_held and not right_held then
        dir = -1
    elseif right_held and not left_held then
        dir = 1
    end

    if dir == 0 then
        tetris.move_hold_dir = 0
        tetris.move_hold_frames = 0
        return
    end

    if dir ~= tetris.move_hold_dir then
        tetris.move_hold_dir = dir
        tetris.move_hold_frames = 1
        move_piece(dir, 0)
        return
    end

    tetris.move_hold_frames = (tetris.move_hold_frames or 0) + 1
    if tetris.move_hold_frames > MOVE_REPEAT_DELAY
        and ((tetris.move_hold_frames - MOVE_REPEAT_DELAY) % MOVE_REPEAT_INTERVAL == 0) then
        move_piece(dir, 0)
    end
end

local function rotate_piece()
    local rotatesound = get_sound(VANILLA_SOUND.MENU_MM_SELECTION)
    local sound2 = rotatesound:play(false)
    local next_rot = tetris.rot - 1
    if next_rot < 1 then
        next_rot = #pieces[tetris.piece]
    end
    if can_place(tetris.piece, tetris.x, tetris.y, next_rot) then
        tetris.rot = next_rot
        return
    end
    -- Tiny wall-kick for pieces near the side.
    if can_place(tetris.piece, tetris.x - 1, tetris.y, next_rot) then
        tetris.x = tetris.x - 1
        tetris.rot = next_rot
        return
    end
    if can_place(tetris.piece, tetris.x + 1, tetris.y, next_rot) then
        tetris.x = tetris.x + 1
        tetris.rot = next_rot
    end
end

local function hard_drop()
    while move_piece(0, 1) do end
    lock_piece()
end

local function clear_sign_entities()
    if sign_button_fx ~= nil then
        pcall(function()
            sign_button_fx:destroy()
        end)
    end

    if sign ~= nil then
        pcall(function()
            sign:destroy()
        end)
    elseif sign_uid ~= -1 then
        local existing_sign = get_entity(sign_uid)
        if existing_sign ~= nil then
            pcall(function()
                existing_sign:destroy()
            end)
        end
    end

    sign = nil
    sign_button_fx = nil
    sign_uid = -1
end

local function close_tetris()
    tetris_open = false
    sign_open = false
    previous_spelunky_buttons = 0
    current_spelunky_buttons = 0
    return_inputs()
    sign_delay = true
    set_global_timeout(function()
        sign_delay = false
    end, 10)
end

local function open_tetris()
    sign_open = false
    tetris_open = true
    sign_delay = false
    clear_sign_entities()
    previous_spelunky_buttons = get_spelunky_buttons()
    current_spelunky_buttons = previous_spelunky_buttons
    reset_tetris()
    block_inputs()
end

local function tetris_input_tick()
    current_spelunky_buttons = get_spelunky_buttons()
    if tetris.game_over then
        -- Dev/test handling after game over. Gameplay itself is still only left, right, rotate.
        if spelunky_button_press(SPELUNKY_INPUT_FLAG.WHIP) then
            reset_tetris()
        elseif inputs.key_press(inputs.KEYBOARD.ESC) or inputs.gamepad_button_press(inputs.GAMEPAD.B) then
            close_tetris()
        end
        previous_spelunky_buttons = current_spelunky_buttons
        return
    end

    horizontal_input_tick()

    if spelunky_button_press(SPELUNKY_INPUT_FLAG.WHIP) then
        rotate_piece()
    end

    if spelunky_button_down(SPELUNKY_INPUT_FLAG.DOWN) then
        tetris.fall_frames = FALL_FRAMES_FAST
    else
        tetris.fall_frames = tetris.base_fall_frames or FALL_FRAMES_START
    end

    -- Dev/test escape only. Not part of gameplay buttons.
    if inputs.key_press(inputs.KEYBOARD.ESC) or inputs.gamepad_button_press(inputs.GAMEPAD.B) then
        close_tetris()
    end

    previous_spelunky_buttons = current_spelunky_buttons
end

local function tetris_game_tick()
    if not tetris_open or tetris.game_over then return end
    tetris.locked_i_anim = (tetris.locked_i_anim or 0) + 1
    tetris.fall_timer = tetris.fall_timer + 1
    if tetris.fall_timer >= tetris.fall_frames then
        tetris.fall_timer = 0
        if not move_piece(0, 1) then
            lock_piece()
        end
    end
end

local function draw_board(ctx)
    local left = BOARD_LEFT
    local right = BOARD_LEFT + BOARD_W * CELL
    local top = BOARD_TOP
    local bottom = BOARD_TOP - BOARD_H * CELL
    local bg = AABB:new(left, top * ratio, right, bottom * ratio)

    ctx:draw_screen_rect_filled(bg, board_fill_color)

    local line = 0.00045
    for x = 0, BOARD_W do
        local gx = BOARD_LEFT + x * CELL
        local rect = AABB:new(gx - line, top * ratio, gx + line, bottom * ratio)
        ctx:draw_screen_rect_filled(rect, board_grid_color)
    end

    for y = 0, BOARD_H do
        local gy = BOARD_TOP - y * CELL
        local rect = AABB:new(left, (gy + line) * ratio, right, (gy - line) * ratio)
        ctx:draw_screen_rect_filled(rect, board_grid_color)
    end
end

local function draw_cell(ctx, x, y, piece, active)
    if piece == nil then
        return
    end

    local angle = 0
    local quad_x = nil
    local quad_y = nil
    local quad_w = nil
    local quad_h = nil
    if type(piece) == 'table' then
        angle = piece.angle or 0
        quad_x = piece.quad_x
        quad_y = piece.quad_y
        quad_w = piece.quad_w
        quad_h = piece.quad_h
        if piece.i_role ~= nil then
            local swapped = math.floor((tetris.locked_i_anim or 0) / 12) % 2 == 1
            if piece.i_role == 'middle_a' then
                piece = swapped and 'I_MIDDLE_B' or 'I_MIDDLE_A'
            elseif piece.i_role == 'middle_b' then
                piece = swapped and 'I_MIDDLE_A' or 'I_MIDDLE_B'
            else
                piece = piece.sprite or piece.piece
            end
        else
            piece = piece.sprite or piece.piece
        end
        if piece == nil then
            return
        end
    end

    local left = BOARD_LEFT + ((x - 1) * CELL)
    local top = BOARD_TOP - ((y - 1) * CELL)
    local sprite = piece_sprites[piece]
    local pad = sprite ~= nil and 0 or (active and 0.0018 or 0.0024)
    local box = AABB:new(left + pad, (top - pad) * ratio, left + CELL - pad, (top - CELL + pad) * ratio)

    if sprite ~= nil and sprite.per_cell then
        ctx:draw_screen_texture(sprite.texture, sprite.row, sprite.col, box, white, angle, 0, 0)
        return
    end

    if sprite ~= nil and quad_x ~= nil and quad_y ~= nil then
        local source = source_quad_for_sprite(sprite, quad_x, quad_y, quad_w or 0.5, quad_h or 0.5)
        if source ~= nil then
            ctx:draw_screen_texture(sprite.texture, source, Quad:new(box), white)
            return
        end
    end

    local color = piece_colors[piece] or (active and white or gray)

    ctx:draw_screen_rect_filled(box, color)
    ctx:draw_screen_rect(box, 1.0, block_edge_color)
end

local function draw_piece_sprite(ctx, piece, x, y, w, h)
    local sprite = piece_sprites[piece]
    if sprite == nil then
        return false
    end

    local left = BOARD_LEFT + ((x - 1) * CELL)
    local top = BOARD_TOP - ((y - 1) * CELL)
    local pad = 0
    local box = AABB:new(left + pad, (top - pad) * ratio, left + (w * CELL) - pad, (top - (h * CELL) + pad) * ratio)
    ctx:draw_screen_texture(sprite.texture, sprite.row, sprite.col, box, white)
    return true
end

local function draw_board_pieces(ctx)
    local drawn_o = {}

    for y = 1, BOARD_H do
        for x = 1, BOARD_W do
            local piece = tetris.board[y][x]
            if piece == 'O' and not drawn_o[y .. ':' .. x] then
                if x < BOARD_W
                    and y < BOARD_H
                    and tetris.board[y][x + 1] == 'O'
                    and tetris.board[y + 1][x] == 'O'
                    and tetris.board[y + 1][x + 1] == 'O'
                    and draw_piece_sprite(ctx, 'O', x, y, 2, 2) then
                    drawn_o[y .. ':' .. x] = true
                    drawn_o[y .. ':' .. (x + 1)] = true
                    drawn_o[(y + 1) .. ':' .. x] = true
                    drawn_o[(y + 1) .. ':' .. (x + 1)] = true
                else
                    draw_cell(ctx, x, y, piece, false)
                end
            elseif piece ~= nil and not drawn_o[y .. ':' .. x] then
                draw_cell(ctx, x, y, piece, false)
            end
        end
    end
end

local function draw_tetris(ctx)
    

    draw_board(ctx)

    draw_board_pieces(ctx)

    if not tetris.game_over then
        if tetris.piece == 'O' then
            draw_piece_sprite(ctx, 'O', tetris.x, tetris.y, 2, 2)
        elseif tetris.piece == 'I' then
            for _, b in ipairs(current_i_segments(tetris.x, tetris.y, tetris.rot, tetris.i_anim)) do
                if b.y >= 1 then
                    draw_cell(ctx, b.x, b.y, {sprite = b.segment, angle = b.angle or 0}, true)
                end
            end
        elseif tetris.piece == 'Z' then
            for _, b in ipairs(current_z_segments(tetris.x, tetris.y, tetris.rot)) do
                if b.y >= 1 then
                    draw_cell(ctx, b.x, b.y, {sprite = b.segment, angle = b.angle or 0}, true)
                end
            end
        else
            for _, b in ipairs(current_blocks(tetris.piece, tetris.x, tetris.y, tetris.rot)) do
                if b.y >= 1 then
                    draw_cell(ctx, b.x, b.y, tetris.piece, true)
                end
            end
        end
    end

    render_text(ctx, 'Score: ' .. tostring(tetris.score), 0.26, 0.34 * ratio, 0.0015, white, VANILLA_TEXT_ALIGNMENT.LEFT)
    render_text(ctx, 'Lines: ' .. tostring(tetris.lines), 0.26, 0.26 * ratio, 0.0015, white, VANILLA_TEXT_ALIGNMENT.LEFT)

    render_text(ctx, 'Controls:', 0.5, 0.06 * ratio, 0.0012, white, VANILLA_TEXT_ALIGNMENT.CENTER)
    render_text(ctx, 'Left/Right to Move', 0.5, -.04 * ratio, 0.0009, gray, VANILLA_TEXT_ALIGNMENT.CENTER)
    render_text(ctx, 'Whip to Rotate', 0.5, -.12 * ratio, 0.0009, gray, VANILLA_TEXT_ALIGNMENT.CENTER)
    render_text(ctx, 'Hold Down to Drop Faster', 0.5, -0.20 * ratio, 0.0009, gray, VANILLA_TEXT_ALIGNMENT.CENTER)

    render_text(ctx, "Tetris module courtesy of", -.5, 0, 0.001, white, VANILLA_TEXT_ALIGNMENT.CENTER)
    render_text(ctx, "PainGravy", -.5, -0.08*ratio, 0.0014, yellow, VANILLA_TEXT_ALIGNMENT.CENTER)

    if tetris.game_over then
        render_text(ctx, 'GAME OVER', 0, 0.05 * ratio, 0.0015, white)
        render_text(ctx, 'Whip to restart', 0, -0.02 * ratio, 0.00075, white)
        render_text(ctx, 'Back to quit', 0, -.08 * ratio, 0.00075, white)
    end
end


local function player_near_sign()
    if sign == nil or players == nil or players[1] == nil then
        return false
    end

    local px, py = nil, nil
    local p = players[1]
    if p.uid ~= nil then
        px, py = get_position(p.uid)
    elseif p.x ~= nil then
        px, py = p.x, p.y
    end

    if px == nil or py == nil then
        return false
    end

    return math.abs(px - sign.x) < 2.0 and math.abs(py - sign.y) < 2.0
end

local function open_sign_menu()
    if sign_delay or sign_open or tetris_open then return end
    sign_open = true
    block_inputs()
end

local function draw_world_prompt(ctx)
    if sign == nil or sign_open or tetris_open or not player_near_sign() then return end
    local sx, sy = screen_position(sign.x, sign.y + 1.15)
    render_text(ctx, 'Press Enter / A to open', sx, sy, 0.00055, white)
end

local function draw_sign_menu(ctx)
    render_panel(ctx, 0.31, -0.27, 3, 6, 0.90)
    render_text(ctx, 'Tetris Sign', 0, 0.32 * ratio, 0.00105, white)

    local button_top = 0.10
    local button_left = -0.17
    local button_right = 0.17
    local button_bottom = -0.02
    local button_box = AABB:new(button_left, button_top * ratio, button_right, button_bottom * ratio)
    ctx:draw_screen_rect_filled(button_box, Color:new(0.88, 0.82, 0.62, 0.96))
    ctx:draw_screen_rect(button_box, 1.2, black)
    render_text(ctx, 'Open Tetris', 0, 0.025 * ratio, 0.00078, black)

    render_text(ctx, 'Enter: select     Esc: close', 0, -0.17 * ratio, 0.00052, gray)

    if inputs.key_press(inputs.KEYBOARD.RETURN) or inputs.key_press(inputs.KEYBOARD.SPACE) or inputs.gamepad_button_press(inputs.GAMEPAD.A) then
        open_tetris()
    elseif inputs.key_press(inputs.KEYBOARD.ESC) or inputs.gamepad_button_press(inputs.GAMEPAD.B) then
        sign_open = false
        return_inputs()
        sign_delay = true
        set_global_timeout(function()
            sign_delay = false
        end, 10)
    end
end

local function spawn_sign()
    sign_open = false
    tetris_open = false
    sign_delay = false
    sign_button_fx = nil

    sign_uid = spawn_entity(ENT_TYPE.ITEM_SPEEDRUN_SIGN, config.sign_x, config.sign_y, config.sign_layer, 0, 0)
    sign = get_entity(sign_uid)
    if sign then
        -- Keep the actual camp sign visible and usable. No ranked queue/private-room code.
        sign.flags = set_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)

        -- If the vanilla sign creates a button FX, remember it so ON.TOAST can tell when
        -- this sign was the thing the player interacted with.
        for _, item_uid in pairs(sign:get_items()) do
            local item = get_entity(item_uid)
            if item and item.type.id == ENT_TYPE.FX_BUTTON then
                sign_button_fx = item
                break
            end
        end
    end
end

local function render_handle(ctx)
    draw_world_prompt(ctx)
    if sign_open then
        draw_sign_menu(ctx)
    elseif tetris_open then
        draw_tetris(ctx)
        tetris_input_tick()
    end
end

local function gameframe_handle()
    input_blocker_tick()
    tetris_game_tick()

    -- Fallback interaction path: useful in clean test packs or if the vanilla sign
    -- toast changes. This keeps the demo easy to test.
    if not sign_open and not tetris_open and player_near_sign() then
        if inputs.key_press(inputs.KEYBOARD.RETURN) or inputs.key_press(inputs.KEYBOARD.SPACE) or inputs.gamepad_button_press(inputs.GAMEPAD.A) then
            open_sign_menu()
        end
    end
end

local function reset_handle()
    sign = nil
    sign_button_fx = nil
    sign_uid = -1
    sign_open = false
    tetris_open = false
    blocking_inputs = false
    returning_inputs = false
    sign_delay = false
end


function tetris_sign.open()
    open_tetris()
end

function tetris_sign.close()
    close_tetris()
end

function tetris_sign.reset_game()
    reset_tetris()
end

function tetris_sign.spawn_sign()
    spawn_sign()
end

function tetris_sign.destroy_sign()
    clear_sign_entities()
end

function tetris_sign.render(ctx)
    render_handle(ctx)
end

function tetris_sign.gameframe()
    gameframe_handle()
end

function tetris_sign.reset()
    reset_handle()
end

function tetris_sign.init(options)
    options = options or {}
    for key, value in pairs(options) do
        config[key] = value
    end

    if callbacks_registered then
        return tetris_sign
    end

    if sync_fallback_inputs ~= nil then
        set_callback(sync_fallback_inputs, ON.GUIFRAME)
    end

    set_callback(function(text)
        -- Vanilla sign interaction path. When the sign is actually triggered by the
        -- player, Spelunky emits a toast; this intercepts it and opens our tiny menu.
        if sign_button_fx ~= nil and sign_button_fx.player_trigger then
            open_sign_menu()
            return ""
        end
        return nil
    end, ON.TOAST)

    if config.spawn_sign then
        set_callback(spawn_sign, ON.CAMP)
    end
    set_callback(render_handle, ON.RENDER_PRE_HUD)
    set_callback(gameframe_handle, ON.GAMEFRAME)
    set_callback(reset_handle, ON.RESET)
    callbacks_registered = true

    return tetris_sign
end

return tetris_sign
