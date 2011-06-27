--[[
@title Trackuino intervalometer
@param m Mode (0=p+v 1=p)
@default m 0
@param v Video length (secs)
@default v 30
@param p Pics between videos
@default p 5
@param t Time between pics (secs)
@default t 10
@param d Display (0=off, 1=on)
@default d 0
@param f Prefocus (0=off, 1=on)
@default f 1

Version 1.0

Read the docs at:
http://code.google.com/p/trackuino/wiki/TrackuinoIntervalometer

Credit to:

- Spacebits intervalometer: http://softwarelivre.sapo.pt/projects/spacebits/browser/trunk/chdk/spacebits100.lua?rev=104
- Accurate intervalometer: http://chdk.wikia.com/wiki/LUA/Scripts:_Accurate_Intervalometer_with_power-saving_and_pre-focus

--]]

capmode=require("capmode")
props=require("propcase")

-- convert parameters into readable variable names
param_mode = m
param_video_length = v
param_num_pics = p
param_time_between_pics = t
param_display = d
param_prefocus = f

-- globals
photos = 0

function printf(...)
  print(string.format(...))
end

function log_printf(...)
  print(string.format(...))
  log:write(os.date(s,tm),": ",string.format(...),"\n")
end

function display_off()
  if get_prop(props.DISPLAY_MODE) ~= 2 then
    printf("Press ALT twice to turn off the display")
    while get_prop(props.DISPLAY_MODE) ~= 2 do
      press("display")
    end
  end
end

function wait_button()
  -- Wait for the "set" button to be pressed
  repeat
    wait_click(200)
  until is_pressed "set"
end

function pre_focus()
  local focused = false
  local autofocus_prop
  local try = 1
  
  -- Find out the appropriate Autofocus property number
  if get_propset() == 1 then
    -- Propset 1 (DIGIC II)
    autofocus_prop = 67
  elseif get_propset() == 2 then
    -- Propset 2 (DIGIC III & IV)
    autofocus_prop = 18
  elseif get_propset() == 3 then
    -- Propset 3 (new DIGIC IV)
    autofocus_prop = 132
  else
    -- Unknown Propset
    log_printf("Unknown propset " .. get_propset())
    return false
  end
  
  -- Try to focus
  while not focused and try <= 5 do
    log_printf("Pre-focus attempt " .. try)
    press("shoot_half")
    sleep(2000)
    if get_prop(autofocus_prop) > 0 then
      focused = true
      set_aflock(1)
    end
    release("shoot_half")
    sleep(500)
    try = try + 1
  end
  return focused
end

function mode_photo()
  log_printf("photo mode")
  blink_led()
  capmode.set(capmode.name_to_mode["KIDS_PETS"])
  sleep(1000)

  -- flash off
  set_prop(props.FLASH_MODE, 2)

  -- Picture Quality (0,1,2 = Superfine, Fine, Normal)
  set_prop(props.QUALITY, 0)

  -- Focus Mode (0,1,3,4,5 = Normal, Macro, Infinity, Manual, Super Macro [SX10])
  -- set_prop(6,3)
end  

function take_photo(n)
  local i = 1
  while n == 0 or i <= n do
    photos = photos + 1
    log_printf("photo #%3d", photos)
    if i ~= 1 then
      sleep(param_time_between_pics * 1000)
    end
    shoot()
    i = i + 1
  end
end

function mode_video()
  blink_led()
  
  -- Switch to video
  capmode.set(capmode.name_to_mode["VIDEO_STD"])
  log_printf("video mode")

  -- Turn off the display if the user wants so
  set_backlight(param_display)

  sleep(500)
end


function take_video (secs)
  -- start recording
  press("shoot_half")
  press("shoot_full")

  log_printf("wait %d secs", secs)
  sleep(secs*1000)

  -- stop recording
  release("shoot_full")
  press("shoot_full")
  sleep(1000)
  release("shoot_full")

  -- wait for SD (get_movie_status returns 5 while recording, 0 or 1 when done)
  while get_movie_status() > 1 do
    log_printf("video status %d, waiting...", get_movie_status())
    sleep(1000)
  end
end

function blink_led ()
  for i = 1,5 do
    set_led (8,1)
    sleep (10)
    set_led (8,0)
    sleep (10)
  end
end

function restore()
  log_printf("Flight interrupted by user")
  -- unlock AF
  set_aflock(0)
  -- close log
  log:close()
  -- restore the original dial mode
  capmode.set(initial_mode) 
  -- restore display
  set_backlight(1)
  -- TODO: release shutter if recording a video. 
  -- The camera will get stuck recording otherwise
end  


--[[ main program ]]

blink_led()
initial_mode = capmode.get()

log=io.open("A/trackuino.log","ab")
log_printf("Flight started")


-- Which intervalometer mode?
if param_mode == 0 then

  -- Warn about prefocus not available
  if param_prefocus == 1 then
    log_printf("Warning: pre-focus not available in vid+pic mode")
    sleep(2000)
  end
  
  -- Mode: videos + pics
  while true do
    -- Switch to photo
    mode_photo()

    -- Turn off the screen (via user intervention)
    if param_display == 0 then
      display_off()
    end

    -- Take photos
    take_photo(param_num_pics)
  
    -- Take video
    mode_video()
    take_video(param_video_length)
    
  end
  
elseif param_mode == 1 then

  -- Mode: pics
  mode_photo()
  
  -- Prefocus if the user wants so
  if param_prefocus == 1 then
    printf("Press SET to prefocus")
    wait_button()
    if pre_focus() then
      log_printf("Pre-focused")
    else
      log_printf("Can't pre-focus")
      return
    end
  end
  
  -- Turn off the screen (via user intervention)
  if param_display == 0 then
    display_off()
  end

  take_photo(0)

end
  
