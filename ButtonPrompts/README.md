# ButtonPrompts
Add button prompts to entities

Note: Using this script will disable the TV sound.

## spawn_button_prompt_on

Use the `spawn_button_prompt_on` method to spawn a button prompt attached to a specific entity. When the entity moves, the prompt will move along with it. If the entity is destroyed, the prompt will be destroyed as well.

The method takes two parameters:
- prompt_type: Determines the icon that will be displayed with the prompt.
- on_entity_uid: UID of the entity that the prompt should be attached to.

## spawn_button_prompt

Use the `spawn_button_prompt` method to spawn a button prompt at a specific location. The spawned prompt
will have gravity, so will fall if placed in the air or if the tile it is on breaks.

The method takes four parameters:
- prompt_type: Determines the icon that will be displayed with the prompt.
- x, y, layer: The position that the prompt should be spawned at.

### PROMPT_TYPE
 
There are four prompt types:
- DOOR
- INTERACT
- VIEW
- SPEECH

## hide_button_prompts

Calling `hide_button_prompts` will enable or disable all butotn prompts. This is useful when interacting
with the prompt opens up UI that the prompt should not show during.

The method takes one parameter:
- hidden

If true, all prompts will be hidden. If false, all prompts will be re-enabled and visible if the player
is near.