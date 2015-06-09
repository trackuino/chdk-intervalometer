# What is this? #

The Trackuino intervalometer is a [Lua](http://www.lua.org/) script that works on Canon cameras with the [CHDK](http://chdk.wikia.com/wiki/CHDK) firmware. The idea behind an [intervalometer](http://en.wikipedia.org/wiki/Intervalometer) is that the camera can take photos and videos of the flight while the tracker reports its position, and they both work independently. That way, if either subsystem crashes or runs out of batteries, the other won't be affected. It also means less work for the main controller, less interaction between parts, and less risk of failure.

Using the Trackuino intervalometer involves installing CHDK in your Canon camera. This is a perfectly safe and non-destructive process. The CHDK firmware resides in your camera's SD card. If you want to remove CHDK, you just format your SD card and your camera is back to normal.

## Features ##

  * Can take photos AND videos alternately
  * The duration of the videos, the number of photos between videos and the time between photos are configurable
  * The camera can be pre-focused to minimize AF operation during flight
  * Optionally turn off the screen to save power

## Compatible cameras ##

This has been tested on a Canon A570IS, but it should be compatible with most Digic III point and shoots. Please report issues otherwise!

# Download #

Provided you have CHDK installed:

Use the `download zip` button and unzip it to get the "trackuino.lua" file. Then, copy it over to the CHDK\SCRIPTS directory in your camera's flash card.**

# Intervalometer Settings and Operation #

To configure the intervalometer, start the camera in recording mode (not in playback mode). The dial mode is irrelevant. Press ALT (usually the "print" button), then MENU. Go to "Scripting parameters" and load up the script "trackuino.lua". You can change any of the parameters:

| **Parameter** | **Values** | **Default value** | **Purpose** |
|:--------------|:-----------|:------------------|:------------|
|Mode|0=photos+videos, 1=photos only|0 |Mode "0" takes photos and videos alternately. Mode "1" takes only photos|
|Video length|Number of seconds|30 seconds|Duration of each video|
|Pics between videos|Number of pics|5 |This is the number of pictures taken between videos|
|Time between pics|Number of seconds|10|This is the delay between any two consecutive photos|
|Display|0=off, 1=on|0 |The default is to keep the display off as much as possible to preserve batteries during the flight. Turning the screen off is kind of tricky, and requires you to press ALT twice after launching the intervalometer. The script will tell you what to do and when, just follow the instructions on the screen. Leave the screen on if you want to check what the intervalometer is doing before a real flight|
|Prefocus|0=off, 1=on|1 |This **only works in mode 1** (photo intervalometer). If you use it in mode 0 (videos + photos), it won't have any effect. When turned on (1), the script will try to pre-focus once at the beginning, then lock the focus. If the script can't acquire a valid focus after 5 attempts, it will error out and you will have to start over. This is especially useful when the camera is pointing at a low contrast area where the autofocus usually struggles, such as the sky or a large mass of clouds. On the other hand, the temperature and pressure changes might affect the optics and the surface focus might no longer be valid at high altitudes. I haven't really tested it on a real flight (yet)|

To launch the intervalometer (or any script in CHDK), enter the ALT mode, then press the shutter. To abort a running script, press the shutter again.

# Recommended camera settings #

These are the recommended settings if you want to use the intervalometer for high altitude balloon photography:

  * CHDK menu:
    * Take RAW images: off (unless you have a huge flash card)
  * Canon menu:
    * Picture review: off (this will save power)
    * IS Mode: shoot only (this will save power, too)

# Credit #

The Trackuino intervalometer is largely based on CHDK's [Accurate intervalometer with power saving and pre-focus](http://chdk.wikia.com/wiki/LUA/Scripts:_Accurate_Intervalometer_with_power-saving_and_pre-focus) and [the Spacebits team's intervalometer](http://softwarelivre.sapo.pt/projects/spacebits/browser/trunk/chdk/spacebits100.lua?rev=104). Most of the code is actually taken from them, so If the trackuino intervalometer doesn't work for you, make sure you check these out!

# Further Hacking #

This script has been tested on an A570IS camera. If you want to hack into it to try and make it work on different cameras or add functionality, here is some information:

## Video and Scene modes ##

Videos are taken using the "VIDEO\_STD" setting (640x480 @ 30fps + mono audio @ 11025 Hz). Other options are "VIDEO\_SPEED" (for faster framerate) and "VIDEO\_COMPACT" (for lower resolution).

Photos are taken in "Kids and pets" scene mode regardless of the actual dial mode. I found this to be the most appropriate mode to counter the blur due to the payload spinning all the time. In this mode, the camera will favor a fast shutter speed at the expense of a larger aperture (which might cause some optical aberration), while keeping the ISO at a reasonably low noise level. You can try and experiment with different scene modes.

If you want to see what modes are available on your camera, run the SETMODE.LUA script (under the CHDK/SCRIPTS/TEST directory in your SD). It will leave a log file "setmode.log" at the root of the SD card with the list of available modes:

```
a570 101a CHDK 0.9.9-1200 Jun  5 2011 12:45:41 vxworks 0x314c
START                        |                 AUTO   1 32768 STL
TRY                 AUTO   1 |                 AUTO   1 32768 STL  290ms OK
TRY                    P   2 |                    P   2 32772 STL  360ms OK
TRY                   TV   3 |                   TV   3 32771 STL  410ms OK
TRY                   AV   4 |                   AV   4 32770 STL  410ms OK
TRY                    M   5 |                    M   5 32769 STL  530ms OK
TRY             PORTRAIT   6 |             PORTRAIT   6 32781 STL  430ms OK
TRY            LANDSCAPE   8 |            LANDSCAPE   8 32780 STL  420ms OK
TRY            VIDEO_STD   9 |            VIDEO_STD   9  2597 VID  630ms OK
TRY          VIDEO_SPEED  10 |          VIDEO_SPEED  10  2598 VID  470ms OK
TRY        VIDEO_COMPACT  11 |        VIDEO_COMPACT  11  2599 VID  610ms OK
TRY               STITCH  15 |               STITCH  15 33290 STL  800ms OK
TRY       SCN_UNDERWATER  17 |       SCN_UNDERWATER  17 16406 STL  730ms OK
TRY             SCN_SNOW  22 |             SCN_SNOW  22 16403 STL  470ms OK
TRY            SCN_BEACH  23 |            SCN_BEACH  23 16404 STL  470ms OK
TRY         SCN_FIREWORK  24 |         SCN_FIREWORK  24 16405 STL  690ms OK
TRY         SCN_AQUARIUM  28 |         SCN_AQUARIUM  28 16407 STL  390ms OK
TRY      SCN_NIGHT_SCENE  30 |      SCN_NIGHT_SCENE  30 16398 STL  480ms OK
TRY               INDOOR  34 |               INDOOR  34 32785 STL  440ms OK
TRY            KIDS_PETS  35 |            KIDS_PETS  35 32784 STL  460ms OK
TRY       NIGHT_SNAPSHOT  36 |       NIGHT_SNAPSHOT  36 32779 STL  440ms OK
TRY          SCN_FOLIAGE  38 |          SCN_FOLIAGE  38 16402 STL  400ms OK
TRY                 AUTO   1 |                 AUTO   1 32768 STL  400ms OK
```

## Known bugs ##

  * Interrupting the script while the camera is recording video will leave it stuck at recording until you shut it down.

## Links to CHDK docs ##

  * [List of CHDK's specific functions available to Lua scripts](http://chdk.wikia.com/wiki/Script_commands)
  * Keeping the display off can be especially tricky and camera-dependent. Here is a [thread on the issue](http://chdk.setepontos.com/index.php?topic=5306.0).
  * [Accurate intervalometer with power saving and pre-focus](http://chdk.wikia.com/wiki/LUA/Scripts:_Accurate_Intervalometer_with_power-saving_and_pre-focus)
  * [PropertyCases](http://chdk.wikia.com/wiki/PropertyCase), these are parameters that can be read or tweaked programatically.
  * [CHDK's Lua reference](http://chdk.wikia.com/wiki/Lua/Lua_Reference), with usage examples for some of the core CHDK functions (shooting manually, reading properties portably, etc.)
