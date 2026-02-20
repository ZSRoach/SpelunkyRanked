# Spelunky Ranked

> **Note:** Spelunky Ranked is not affiliated with [Mossranking](https://mossranking.com), or [MCSR Ranked](https://mcsrranked.com/). Both are great services — check them out!

---

## Overview

Spelunky Ranked is a **competitive speedrunning mod and companion application** for Spelunky 2 in which players compete in matchmade 1v1s on the same seed.

- **Part 1:** The mod itself, which runs via Modlunky
- **Part 2:** The standalone Ranked App (`S2Ranked.exe`)

Both components are required to play matches. Spelunky Ranked currently **only runs on Windows** — support for other platforms is planned, with more information to come.

---

## Important Info

### Firewall Permissions (setup.bat)

S2Ranked requires explicit firewall permissions to communicate with the game. The app comes bundled with a `setup.bat` file that handles this automatically.

> ⚠️ Batch files can run commands directly on your system. You are strongly encouraged to verify the file does exactly what is described below and nothing more.

Here's what `setup.bat` does:

1. **Verifies administrator access** — required to modify the Windows Advanced Security Firewall.
2. **Accesses the Windows Firewall** via the Network Shell (`netsh advfirewall firewall`).
3. **Removes existing firewall rules relating to S2Ranked** — gets rid of any blocks which Windows has placed on the app, and removes old rules from prior installations of the app
4. **Adds a new firewall rule** — names it, sets the direction to accept incoming messages, and sets the status to allow.
5. **Identifies the target program** — `S2Ranked.exe` in the same directory.
6. **Enables the rule** for both UDP and TCP protocols.

I encourage you to confirm yourself that this file does **only what it is intended to do and nothing else.** The file also contains comments explaining each command, to make it easier to understand.

S2Ranked uses **UDP** to communicate with the game and **TCP** to communicate with the Ranked Server. This permission is required to play — without it, connections will be blocked by Windows.
My knowledge of these processes is quite fresh, so I'll look into a cleaner more trustworthy approach in the future, but for now, exercise caution and proper cyber safety.

### Unsafe Mode

The Spelunky Ranked mod requires **Modlunky's Unsafe Mode** to be enabled. No additional setup is needed before launching the game — simply enable the mod once the game is open.

Unsafe Mode is required because Modlunky blocks UDP Server functions without it, and UDP is the best method for the game to communicate with the S2Ranked app. Since the connection is purely local, no additional risk is introduced.

### Login

S2Ranked uses **Steam OpenID** to log in and register players. Steam does not send any sensitive information to the ranked server — only your publicly available Steam ID is passed. All information that Steam provides is outlined on the Steam OpenID page.

---

## How It Works

### 1. Queue for a Match

Interact with the sign in the Camp and press the queue button. You're free to walk around, or play a run while waiting for a match to be found. **S2Ranked must be open!** 
The server will attempt to pair players together based off of rank proximity and time spent in queue. The longer a player queues, the further their possible queue range is expanded. This may lead to unfair matches, but may also be better for queue times. This process also subject to change in future updates.

### 2. Category Ban Process

Both players receive the same set of **5 randomly selected categories** from the server. Players alternate striking a category from the pool until one category remains. Both players are then loaded into the match with the goal of completing that category on the given seed. Matches continue until one player finishes or a draw/forfeit request ends the match.

### 3. Play the Match

**Deaths & Resets**
Progress is saved on every level. On death, instant restart, or category rule violation, players are returned to **four levels before their furthest point of progression**.

*Example: A death on 7-4 sends you back to 6-4. If you then die on 7-1, you're sent back to 6-4 again.*

**Mid Match Actions**
Opening the pause menu during a match shows a sidebar with four options:

| Button | Action |
|--------|--------|
| 1 | Fully reset the seed and all saved progress |
| 2 | Request a seed change *(requires mutual agreement)* |
| 3 | Request a draw *(requires mutual agreement)* |
| 4 | Forfeit the match |

The player can also send **in-game messages to their opponent.** These messages can be toggled on/off on the main menu, along with a few other settings. There is currently no filter in place, so use at your discretion. Reports of misuse will result in administrative action.

**Category Violations**
Any action deemed to violate the current category's rules results in an instant restart, which takes effect on the next level transition. Players may also manually restart after a violation before the transition occurs. Not all violations are currently handled properly, but attempts to ruin the competitive integrity of a match may be met with indefinite bans from the service.

**Completed Matches**
Finished match data is saved to the server, and is visible in the S2Ranked app. Look at personal stats, community-wide achievements, active matches, and more.

---

## Categories

> *The full category list is subject to change, but currently these are implemented. Category rules can be viewed at [mossranking.com](https://mossranking.com/categories.php?no_game=3).*

| Category |
|----------|
| Any% |
| Sunken City% |
| Low% |
| Low% J/T |
| No TP Any% |
| No TP Sunken City% |
| No TP Eggplant% |
| No Gold Low% |
| Abzu% |
| Duat% |
| No TP Abzu% |
| No TP Duat% |

---

## Rank Thresholds

> *Rank thresholds are subject to change. Elo gains/losses are currently flat values — a full algorithm is planned for a future update.*

| Rank | Elo Range |
|------|-----------|
| Gold | 0 – 299 |
| Emerald | 300 – 599 |
| Sapphire | 600 – 899 |
| Ruby | 900 – 1,199 |
| Diamond | 1,200 – 1,599 |
| Cosmic | 1,600+ |

## Download and Install Process
Download and install [Modlunky](https://github.com/spelunky-fyi/modlunky2/releases). Then download `S2Ranked.zip` and `Spelunky Ranked.zip` from the releases page. Place the files from `Spelunky Ranked.zip` into the `/Spelunky 2/Mods/Packs/Spelunky Ranked/` folder. You can place the `S2Ranked.zip` files anywhere you'd like, really, but I recommend `/Spelunky 2/S2Ranked/` for ease of access. In `/S2Ranked/`, run `setup.bat` as an administrator, and then launch S2Ranked.exe. Once you login, **close the app, and relaunch.** The connection between the game and the app doesn't seem to take before the second launch of the app. Then launch Modlunky, and enable the mod from the Playlunky tab. I recommend using the Playlunky save as to not affect your existing player profile. **Also if your playlunky save is fresh, you may want to copy your normal save and use that as the playlunky save too. Just rename a copy to `savegame.sav.pl`**. I'm not actually sure what speedrun mode does, but keep it off I guess. Launch the game and `S2Ranked.exe`, and happy queueing!
