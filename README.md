# Weatherbar

Weatherbar is a "widget" for
i3bar/[i3status](https://github.com/i3/i3status).

Weatherbar prints a concise display of current and forecasted
weather.  For example, the following shows three sections for
Beaverton, OR, USA, for sunset/sunrise and present conditions (Rain
Heavy, 50 degrees F, Wind 18 mph, Humidity 81); the next 9 hours (Rain
Moderate and Heavy, temps 50 and 49); and the next six days of highs
and lows.

    0724-1632 RH50.18.81 | RM50 RH49 RM49 | RH5149 RL4841 RM4741 RL4539 NC4541 RM453


## Config

Get your own free OpenWeatherMap API key by
[signing up](https://home.openweathermap.org/users/sign_up).  You
shouldn't have to worry about hitting any limits for this.

Find your city's ID by starting
[here](https://openweathermap.org/city/5713376), and make note of it.


## Run it

Put Weatherbar into your crontab to run every half-hour.

    0,30 * * * *    WEATHER_APIKEY=123... WEATHER_CITYID=456... /path/to/weatherbar.zsh

On each run, a temporary file, `/tmp/weather.txt`, is created/replaced
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
      echo "$weather | MEM:$mem | $line" || exit 1
    done
