"""Run with Python 3 and lupa: python mod/tests/test_chat_and_menu_inputs.py.

Executes the real Lua handlers with simulated engine input and rendering callbacks.
These regressions do not require a game instance or send network messages.
"""
from pathlib import Path
from lupa import LuaRuntime
root=Path(__file__).resolve().parent
s=(root.parent/'main.lua').read_text(encoding='utf-8')
lua=LuaRuntime(); lua.compile(s)
def part(a,b): return s[s.index(a):s.index(b,s.index(a))]
setup='''
ON={GUIFRAME=1,POST_PROCESS_INPUT=2}; KEY={OEM_2=191,RETURN=13,LSHIFT=160,RSHIFT=161,OL_MOD_SHIFT=256}; RAW_KEY={ESCAPE=6,RETURN=5,NUMPADENTER=110}
raw={keyboard={}}; io={wantkeyboard=false}; pressed={}; pad={}; callbacks={}; sent=0
function get_io() return io end
function io.keypressed(k) return pressed[k] or false end
function io.keydown(k) return false end
inputs={KEYBOARD={LEFT_ARROW=37,RIGHT_ARROW=39,UP_ARROW=38,DOWN_ARROW=40},GAMEPAD={A=13,B=14,LEFT=1003,RIGHT=1004,UP=1001,DOWN=1002,DPAD_UP=1,DPAD_DOWN=2,DPAD_LEFT=3,DPAD_RIGHT=4}}
function inputs.key_press(k) return pressed[k] or false end
function inputs.gamepad_button_down(k) return pad[k] or false end
function inputs.gamepad_button_press(k) local v=pad[k]; pad[k]=false; return v or false end
function get_raw_input() return raw end
function set_callback(f,e) callbacks[e]=f end
slot={input_mapping_keyboard={jump=45,bomb=44,left=2,right=3,up=0,down=1}}
state={player_inputs={player_slot_1=slot}}; player={input=slot}; players={player}
game_manager={game_props={game_has_focus=true},pause_ui={visibility=0}}
function get_player() return player end
function set_journal_enabled() end
function getCurrentAlert() return alert end
function set_global_timeout() end
function startButtonCooldown() buttonCooldown=true end
function udpSend() sent=sent+1 end
function isCommand() return false end
function doCommand() end
function processChat() end
function popAlert() alert=nil end
function makeAlertChoice() alert=nil end
function reset()
 raw.keyboard={}; pressed={}; pad={}; chatting=false; buttonCooldown=false; mainMenuOpen=true; menuPage=0; mainMenuIndex=0
 privateRoomPage=2; privateConfigPage=0; privateConfirmLeave=false; privateConfirmStart=false; pracSignPage=0; privateRoomMenuOpen=false; pracSignOpen=false; bufferPause=false; tetrisCloseInputConsumed=false; alert=nil
 game_manager.pause_ui.visibility=0; game_manager.game_props.game_has_focus=true; callbacks[1]()
end
'''
code=setup+part('-- BEGIN ranked raw keyboard navigation','--constants')+part('function blockInputs()','function renderTexture(')+part('function menuInputHandle()','function closeTetrisIfActive()')+part('function alertInput()','function renderAlert(')+part('local function closeRankedChat()','function enterMessageWindow(')
code += part('function defaultMenu()', '-- resets private room configs') + part('function spawnSign()', 'function blockInputs()')
code += """
ENT_TYPE={ITEM_SPEEDRUN_SIGN=1}; LAYER={FRONT=0}; ENT_FLAG={ENABLE_BUTTON_PROMPT=1}
function spawn_entity() return 1 end
function get_entity() return {flags=0} end
function clr_flag() return 0 end
button_prompts={PROMPT_TYPE={INTERACT=1},spawn_button_prompt_on=function(kind,uid,f) sign_open=f end}
tetris={open=function() tetris_opens=tetris_opens+1 end}
"""
lua.execute(code)
tests={
'duplicate arrow render': '''reset(); pressed[39]=true; raw.keyboard[3]={down=true}; callbacks[1](); menuInputHandle(); menuInputHandle(); assert(mainMenuIndex==1)''',
'held arrow next frame': '''pressed={}; callbacks[1](); menuInputHandle(); assert(mainMenuIndex==1)''',
'Enter confirms practice once': '''reset(); mainMenuIndex=1; raw.keyboard[5]={down=true}; callbacks[1](); menuInputHandle(); menuInputHandle(); assert(pracSignOpen and menuPage==2 and pracPage0Index==0)''',
'Jump Enter overlap': '''reset(); mainMenuIndex=1; raw.keyboard[5]={down=true}; raw.keyboard[45]={down=true}; callbacks[1](); menuInputHandle(); menuInputHandle(); assert(pracSignOpen and not practiceStarted)''',
'controller confirms once': '''reset(); mainMenuIndex=1; pad[13]=true; callbacks[1](); menuInputHandle(); menuInputHandle(); assert(pracSignOpen)''',
'chat Escape no room prompt': '''reset(); mainMenuOpen=true; privateRoomMenuOpen=true; menuPage=3; privateRoomPage=2; privateIsHost=true; privateConfirmLeave=false; privateConfirmStart=false; privatePageColumn=3; inPrivateRoom=true; chatting=true; chatMessage=''; pressed[27]=true; raw.keyboard[6]={down=true}; callbacks[1](); chatInputHandle(); inputCheck(); menuInputHandle(); assert(not chatting and not privateConfirmLeave); pressed={}; buttonCooldown=false; callbacks[1](); menuInputHandle(); assert(not privateConfirmLeave)''',
'gameplay Bomb expires': '''reset(); mainMenuOpen=false; raw.keyboard[44]={down=true}; callbacks[1](); raw.keyboard[44].down=false; callbacks[1](); mainMenuOpen=true; callbacks[1](); menuInputHandle(); assert(mainMenuOpen)''',
'focus return held key': '''reset(); game_manager.game_props.game_has_focus=false; raw.keyboard[44]={down=true}; callbacks[1](); game_manager.game_props.game_has_focus=true; callbacks[1](); menuInputHandle(); assert(mainMenuOpen)''',
'alert outside menu': '''reset(); mainMenuOpen=false; alert={alerttype='ack'}; callbacks[1](); raw.keyboard[5]={down=true}; callbacks[1](); alertInput(); assert(alert==nil)''',
'alert input cannot spill to menu': '''reset(); alert={alerttype='ack'}; callbacks[1](); raw.keyboard[5]={down=true}; callbacks[1](); alertInput(); menuInputHandle(); assert(menuPage==0)''',
'chat close Enter gameplay restores': '''reset(); mainMenuOpen=false; inPrivateRoom=true; chatting=true; chatMessage=''; pressed[13]=true; callbacks[1](); chatInputHandle(); inputCheck(); assert(not chatting and player.input==slot and not io.wantkeyboard)''',
'chat close Esc gameplay restores': '''reset(); mainMenuOpen=false; inPrivateRoom=true; chatting=true; chatMessage=''; pressed[27]=true; callbacks[1](); chatInputHandle(); inputCheck(); assert(not chatting and player.input==slot and not io.wantkeyboard)''',
'no double send': '''reset(); mainMenuOpen=false; inPrivateRoom=true; chatting=true; chatMessage='hello'; pressed[13]=true; sent=0; options={chatOpenKey=191}; callbacks[1](); chatInputHandle(); chatInputHandle(); assert(sent==1)''',
}
for name,body in tests.items():
 try: lua.execute(body); print('PASS',name)
 except Exception as e: print('FAIL',name); raise
print(len(tests),'handler regression tests passed; Lua compiled.')

lua.execute("reset(); mainMenuOpen=false; inPrivateRoom=true; chatting=true; chatMessage=''; options={chatOpenKey=13}; pressed[13]=true; callbacks[1](); chatInputHandle(); chatInputHandle(); assert(not chatting, 'Enter binding reopened chat in same frame')")
print('PASS Enter chat binding does not reopen')
# Verify the actual message queue and renderer with the visibility toggle.
lua.execute(part('function renderChat(render_ctx)', 'function addToMessage('))
lua.execute('''
options={chatEnabled=true,chatMessageDuration=10,chatMessageLimit=5}; messageList={}; ratio=1; rendered={}; chatting=false
function renderTextLeft(ctx,text) table.insert(rendered,text) end
processChat('hello','Opponent',true); processChat('mine','You',true); processChat('Opponent entered Jungle.','Match Info')
renderChat({}); assert(#rendered==3)
options.chatEnabled=false; rendered={}; renderChat({}); assert(#rendered==1)
chatting=true; rendered={}; renderChat({}); assert(#rendered==1)
local count=#messageList; processChat('spoof','Match Info',true); assert(#messageList==count)
processChat('Opponent entered Ice Caves.','Match Info'); rendered={}; renderChat({}); assert(#rendered==2)
options.chatEnabled=true; rendered={}; renderChat({}); assert(#rendered==4)
''')
print('PASS message toggle, history, progression, sender spoof, and re-enable')
# Binding UI and saved-value round trip.
ui=LuaRuntime()
ui.execute('''KEY={OEM_2=191}; KEY_TYPE={KEYBOARD=1}; ON={SAVE=1,LOAD=2}; options={}; callbacks={}; saves=0
function register_option_callback(name,value,cb) options[name]=value; optioncb=cb end
function register_option_bool() end
function set_callback(cb,event) callbacks[event]=cb end
function key_name(k) return tostring(k) end
function save_script() saves=saves+1 end
json={encode=function(v) return tostring(v.chatOpenKey) end,decode=function(v) return {chatOpenKey=tonumber(v)} end}
ctx={win_button=function(self,label) return label==click end,key_picker=function() return selected end,save=function(self,v) saved=v end,load=function() return saved end}
'''+part('local pickingChatKey = false','register_option_int("chatMessageLimit"'))
ui.execute('''
selected=-1; click='Open chat: 191##chatOpenKey'; assert(optioncb(ctx)==191)
click=nil; selected=84; assert(optioncb(ctx)==84); assert(options.chatOpenKey==84)
callbacks[1](ctx); options.chatOpenKey=191; callbacks[2](ctx); assert(options.chatOpenKey==84)
click='Reset chat key to /'; assert(optioncb(ctx)==191 and options.chatOpenKey==191)
saved='-1'; callbacks[2](ctx); assert(options.chatOpenKey==191)
''')
print('PASS key picker, save/load, reset, and invalid saved binding')
# Exercise real sign callback and room menu with opening inputs on both callback orders.
for device in ('keyboard','controller'):
 for opening_order in ('before_poll','after_poll'):
  held = 'raw.keyboard[45]={down=true}' if device=='keyboard' else 'pad[13]=true'
  released = 'raw.keyboard[45].down=false' if device=='keyboard' else 'pad[13]=false'
  lua.execute("reset(); mainMenuOpen=false; inPrivateRoom=false; postMatch=false; matchStarted=false; banPhase=false; signDelay=false; inQueue=false; bridgeConnected=true; sent=0; callbacks[1](); spawnSign()")
  lua.execute(held)
  if opening_order=='before_poll': lua.execute('sign_open(); callbacks[1]()')
  else: lua.execute('callbacks[1](); sign_open()')
  lua.execute('menuInputHandle(); menuInputHandle(); assert(menuPage==0 and not inQueue and sent==0)')
  lua.execute('callbacks[1](); menuInputHandle(); assert(menuPage==0 and not inQueue)')
  lua.execute(released+'; callbacks[1](); menuInputHandle()')
  lua.execute(held+'; callbacks[1](); menuInputHandle(); assert(menuPage==1 and not inQueue)')
  lua.execute('callbacks[1](); menuInputHandle(); assert(not inQueue)')
  lua.execute(released+'; callbacks[1](); menuInputHandle()')
  lua.execute(held+'; callbacks[1](); menuInputHandle(); menuInputHandle(); assert(inQueue and sent==1)')
  print('PASS sign opens without auto-queue:',device,opening_order)
for device in ('keyboard','controller'):
 held = 'raw.keyboard[45]={down=true}' if device=='keyboard' else 'pad[13]=true'
 released = 'raw.keyboard[45].down=false' if device=='keyboard' else 'pad[13]=false'
 lua.execute('reset(); tetris_opens=0; '+held+'; callbacks[1](); privateRoomMenuOpen=true; menuPage=3; privateRoomPage=6; menuInputHandle(); assert(tetris_opens==0)')
 lua.execute('callbacks[1](); menuInputHandle(); assert(tetris_opens==0)')
 lua.execute(released+'; callbacks[1](); menuInputHandle(); '+held+'; callbacks[1](); menuInputHandle(); menuInputHandle(); assert(tetris_opens==1)')
 print('PASS post-run Tetris requires fresh confirmation:',device)
# An unconsumed press from the imported module cannot affect the parent anymore.
lua.execute('reset(); mainMenuOpen=false; callbacks[1](); pad={}; mainMenuOpen=true; callbacks[1](); menuInputHandle(); assert(menuPage==0)')
print('PASS inactive-to-menu transition stays neutral')
# A lingering device state must not lock every input after a private result.
for held_input in ('raw.keyboard[3]={down=true}', 'raw.keyboard[45]={down=true}', 'pad[1003]=true', 'pad[13]=true'):
 lua.execute('reset(); tetris_opens=0; mainMenuOpen=false; '+held_input+'; callbacks[1](); mainMenuOpen=true; privateRoomMenuOpen=true; menuPage=3; privateRoomPage=6; callbacks[1](); menuInputHandle(); assert(tetris_opens==0)')
 lua.execute('raw.keyboard[5]={down=true}; callbacks[1](); menuInputHandle(); menuInputHandle(); assert(tetris_opens==1, "fresh Enter blocked by lingering device input")')
 print('PASS postmatch fresh Enter with lingering input:', held_input)
# The button held during handoff is still suppressed until it releases and is pressed again.
lua.execute('reset(); tetris_opens=0; mainMenuOpen=false; raw.keyboard[5]={down=true}; callbacks[1](); mainMenuOpen=true; privateRoomMenuOpen=true; menuPage=3; privateRoomPage=6; callbacks[1](); menuInputHandle(); callbacks[1](); menuInputHandle(); assert(tetris_opens==0); raw.keyboard[5].down=false; callbacks[1](); raw.keyboard[5].down=true; callbacks[1](); menuInputHandle(); assert(tetris_opens==1)')
print('PASS held confirmation stays suppressed until its own release/repress')
