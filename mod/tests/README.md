# Chat and menu input regression tests

Install the Python dependency and run from the repository root:

```sh
python -m pip install lupa
python mod/tests/test_chat_and_menu_inputs.py
```

The script compiles `mod/main.lua` and executes its input, chat, and option handlers with mocked engine APIs. It checks duplicate render calls, keyboard/controller opening transitions, stale input, focus changes, standalone alerts, private post-match input, chat filtering, and chat key binding persistence.

An in-game check is still needed for native keyboard/controller delivery, the Ctrl+F4 key picker, and real private-match transitions.
