# Missile
Missile Clone in Godot 3.2

This is a classic style arcade game where you defend cities from a missile attack.

## Running the game
The game needs Godot Desktop 3.2. 
TODO: Create an executable for Windows

## Controls
The plus-shaped cursor indicates the target location of a defensive missile. When you press the fire button, a missile will fly to that location and explode.
The cursor can be moved with the mouse or with the left stick on a controller.
You have three different bases. There is a separate fire button for each:

- Left base: Left mouse button, 'A' key on keyboard, or left button on controller
- Middle base: middle mouse button, 'S' key on keyboard, or bottom or top button on controller
- Right base: Right mouse button, 'D' key on keyboard, or right button on controller

Start the game by pressing the '1' key on the keyboard, or the start/options/plus button on the controller
TODO: Add a start button to the screen so the player can start by clicking the mouse
Reset the game by pressing the '9' key on the keyboard, or the select/share/minus button on the controller

## Gameplay
### Waves
Attacks come in waves. At the start of each wave, your missile bases are restocked. 
At the end of a wave you get bonus points.
Waves have a bonus multiplier that increases every other wave. The maximum multiplier is 6 X points.

### Bases
Each base has a limited number of missiles. If a base it hit, it wipes out all missiles in that base until the next round.
The middle base has much faster missiles so it it best to save those for last if possible.

### Scoring
Score is kept for each enemy type and for bonus ammo and cities.
TODO: High Score that is kept between play sessions

### End of Game
TODO: Detect end of game

### Enemies
#### Missiles
ICBM Missiles come down from the top of the screen. They leave a smoke trail behind them. You have to target the missile at the bottom of the smoke trail.

TODO: 
- Better waves: In the arcade, each wave has 3 distinct phases. Usually there is a lot of missiles at once, then a pause, then another large attack, then a smaller random attack.
In this version, the wave is mostly random the whole time but a specific number of missiles occur in each wave.

#### Bombers
Bombers and satellites cross the screen and make fairly easy 
TODO: Launch missiles from bombers

#### Smart Missiles
TODO: Add missiles that are able to dodge defensive fire if you don't hit very closely to them. These missiles are larger and don't leave smoke trails.

#### UFO
TODO: Add a UFO that works like the one from Super Missile Attack which randomly fires an unblockable laser


## TODO
- Add smart missiles
- Add UFO
- Add missile launches to bombers
- Connect bonus screen to main screen so that ammo and cities are removed from playfield as they are tallied on the bonus board
- Improve wave structure so each has 3 distinct phases. This is primarily to make sure that many missiles appear at once so that you can have more attackers than defensive ammo
- Consider adding particle effects to the missiles or explosions
- Consider adding external json file that keeps high scores and allows user to customize difficulty etc
- Add option to let the user choose between classic mode and "super missile attack" which is more difficult
- Consider mutliple graphics styles such as
  - 1st gen console
  - 8 bit computer
  - Arcade
  - Modern (Indy) graphics

## Attributions
Sound files taken from soundbible.com.
#### Bomb Exploding
License: Attribution 3.0
Recorded by: Sound Explorer
Obtained from: http://soundbible.com/1986-Bomb-Exploding.html

#### Whoosh
License: Attribution 3.0
Recorded by Mark DiAngelo 
Obtained from: http://soundbible.com/2068-Woosh.html

#### Missile Launch
License: Public Domain
Recorded by Kibblesbob 
Obtained from: http://soundbible.com/1794-Missle-Launch.html