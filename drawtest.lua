ratio = 16/9
renderActive = false
white = Color:white()
local button_prompts = require("ButtonPrompts/button_prompts")





-- local function renderMenu(render_ctx)
--     local menu = AABB:new(-.1,-.1*ratio,.1,.1*ratio)
--     render_ctx:draw_screen_texture(TEXTURE.DATA_TEXTURES_MENU_LEADER_3,0,2,menu,white)
-- end

-- local function spawnSign()
--     local signUID = spawn_entity(ENT_TYPE.ITEM_SPEEDRUN_SIGN, 46, 84, LAYER.FRONT, 0, 0)
--     sign = get_entity(signUID)
--     sign.flags = clr_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
--     button_prompts.spawn_button_prompt_on(button_prompts.PROMPT_TYPE.INTERACT, signUID, function()
--         set_callback(renderMenu, ON.RENDER_PRE_HUD)
--     end)
-- end

-- set_callback(function(render_ctx)
--     local menu = AABB:new(-.1,.1*ratio,.1,-.1*ratio)
--     render_ctx:draw_screen_texture(TEXTURE.DATA_TEXTURES_MENU_BASIC_2,0,0,menu,white)
-- end, ON.RENDER_PRE_HUD)

queueStateText = "Not in queue"

local function renderTexture(render_ctx, texture, r, c, top, left, size)
    --helper function for loading singular textures
    local position = AABB:new(left, top*ratio, left+(size*.1),(top-(size*.1))*ratio)
    render_ctx:draw_screen_texture(texture,r,c,position,white)
end

local function renderText(render_ctx, str, x, y, scale, color)
    --helper function for rendering text
    render_ctx:draw_text(str,x,y,scale,scale,color, VANILLA_TEXT_ALIGNMENT.CENTER, VANILLA_FONT_STYLE.ITALIC)
end

local function renderWindow(render_ctx)
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

local function renderWindowInfo(render_ctx)
    --hard code text location
    local textX = 0
    local textY = .35
    local textScale = .001

    --hard code icon location
    local iconTop = .15
    local iconLeft = -.05
    local iconSize = 1

    renderText(render_ctx, queueStateText, textX, textY, textScale, white)
    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1, 8, 8, iconTop+.01, iconLeft-.01, iconSize+.2)
    renderTexture(render_ctx, TEXTURE.DATA_TEXTURES_HUD_CONTROLLER_BUTTONS_1, 5, 8, iconTop, iconLeft, iconSize)

end



local function renderHandle(render_ctx)
    renderWindow(render_ctx)
    renderWindowInfo(render_ctx)
end

set_callback(renderHandle, ON.RENDER_PRE_HUD)



set_callback(spawnSign, ON.CAMP)