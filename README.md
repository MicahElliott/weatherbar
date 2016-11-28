# Weatherbar

Weatherbar is a "widget" for
i3bar/[i3status](https://github.com/i3/i3status).

**Weatherbar prints a concise display of current and forecasted
weather.** For example, the following shows three sections for
Beaverton, OR, USA, for _sunset/sunrise_ and _present conditions_
(Rain Heavy, 50 degrees F, Wind 18 mph, Humidity 81); the _next 9
hours_ (Rain Moderate and Heavy, temps 50 and 49); and the _next six
days_ of highs and lows.

    0724-1632 RH50.18.81 | RM50 RH49 RM49 | RH5149 RL4841 RM4741 RL4539 NC4541 RM453

The above tells me I probably won't be going for a run or bike ride
for the next several days.  See the source for a little more detail on
the weather conditions mnemonics.

It should be enough to **update (run) every 15 or 30 minutes**.
Although it may be slow to run (a second or two), the status bar
itself will be very quick to update every second or few since it's
only reading a temporary file — not calling anything.


## Config

Get your own free OpenWeatherMap API key by
[signing up](https://home.openweathermap.org/users/sign_up).  You
shouldn't have to worry about hitting any limits for this.  Should be
quick and easy.

Find your city's ID by starting
[here](https://openweathermap.org/city/5713376).

Set your [temperature units](http://www.openweathermap.org/forecast5)
for Fahrenheit (`imperial` (default)), Celsius (`metric`), or Kelvin
(`standard`).  E.g., `WEATHER_UNITS=metric`.


## Run it

First install a few dependencies: zsh,
[jq](https://stedolan.github.io/jq/), and curl.

Copy/clone `weatherbar.zsh` to somewhere on your path.

Put Weatherbar into your crontab to run every half-hour.

    % crontab -e
    ...
    0,30 * * * *    WEATHER_APIKEY=123... WEATHER_CITYID=456... /path/to/weatherbar.zsh

On each run, a temporary file, `/tmp/weather.txt`, is created/replaced,
holding the text of the last run.


## Add it to your i3status

Modify your `~/.i3/config` to call a custom `my-i3status` command (as
described
[here](https://i3wm.org/i3status/manpage.html#_external_scripts_programs_with_i3status).

    bar {
      ...
      status_command my-i3status
    }

Then your `my-i3status` script is something like:

    i3status --config ~/.i3status.conf | while :
    do
      read line
      weather=$(cat /tmp/weather.txt)
      echo "$weather | $line" || exit 1
    done


## Improvements

I couldn't figure out how to get color working, but that would be
awesome if someone knows how to feed this through i3status as json
with markup.  Highs in red, lows in blue, a few other colors would
make it more quickly readable.
