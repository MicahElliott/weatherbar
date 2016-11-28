#! /bin/zsh

# weatherbar — current/forecasted weather in i3status 1-line format
#
# Dependencies: zsh, jq, curl, personal openweathermap api key


wfile=/tmp/weather.txt
truncate -s0 $wfile

# Get your own API key at:
# https://home.openweathermap.org/api_keys
apikey="appid=${WEATHER_APIKEY?must set WEATHER_APIKEY}"
# To find your city, start here:
# https://openweathermap.org/city/5713376
# and search, and note the URL for the trailing ID.
cityid="id=${WEATHER_CITYID?must set WEATHER_CITYID}"
fmt="units=${WEATHER_UNITS-imperial}"  # or "metric"; standard/Kelvin is default
present="api.openweathermap.org/data/2.5/weather?$cityid&$apikey&$fmt"
threehr="api.openweathermap.org/data/2.5/forecast/city?$cityid&$apikey&$fmt"
forecast="api.openweathermap.org/data/2.5/forecast/daily?$cityid&$apikey&$fmt"

# Condition codes
# https://openweathermap.org/weather-conditions

# Print-append to weather file
pf() { print -n $* >> $wfile }

# Convert from kelvin to Fahrenheit (NIU; see WEATHER_UNITS above)
tof() { k=$1; printf '%0.0f' $(( 9/5. * (k - 273) + 32 )) }

# Convert epoch to present time
totime() { date -d @$1 +%H%M }

# https://openweathermap.org/weather-conditions
# Thunderstorm, Drizzle, Rain, Snow, Atmos, Clear/None, Clouds, Extreme, Misc
# I invented these 2-char codes that resemble above categories
declare -A condtab
condtab=(
    200 TL 201 TM 202 TH 210 TL 211 TM 212 TH 221 TH 231 TL 231 TL 232 TM
    300 DL 301 DM 302 DH 310 DL 311 DM 312 DH 313 DM 314 DH 321 DM
    500 RL 501 RM 502 RH 503 RH 504 RX 511 RF 520 RL 522 RH 531 RM
    600 SL 601 SM 602 SH 611 SS 612 SS 615 SR 616 SR 620 SR 621 SR 622 SR
    701 AM 711 AS 721 AH 731 AD 741 AF 751 AD 761 AD 762 AV 771 AQ 781 AT
    800 NC 801 CF 802 CS 803 CB 804 CO
    900 ET 901 ES 902 EU 903 EC 904 EH 905 EW 906 EA
    951 MC 952 MB 953 MB 954 MB 955 MB 956 MB 957 MG 958 MG 959 MG
    960 MS 961 MS 962 MU
)

### Current weather
#   RL46.6.93 0717-1635
#      800          Clear          283.27       50
#      8.7          1479482183     1479515798   Beaverton
parms='.weather[0].id, .weather[0].main, .main.temp,  .main.humidity,
       .wind.speed, .sys.sunrise,  .sys.sunset, .name'
vals=( $(curl -s $present |jq -r $parms) )
cond=$condtab[$vals[1]] desc=$vals[2]
temp=$(printf '%0.0f' $vals[3]) hum=$vals[4]
wspeed=$(printf '%0.0f' $vals[5])
srise=$(totime $vals[6]) sset=$(totime $vals[7])
city=$vals[8]
# print $vals
# print $cond T$temp W$wspeed H$hum $srise-$sset
pf $srise-$sset $cond$temp.$wspeed.$hum

### 3-hr (x3)
# | RL46 RM44 RH43
parms='
 .list[0].main.temp, .list[1].main.temp, .list[2].main.temp,
 .list[0].weather[0].id, .list[1].weather[0].id, .list[2].weather[0].id'
vals=( $(curl -s $threehr |jq -r $parms) )

pf ' |'
for i in {1..3}; do
    pf " $condtab[$vals[i+3]]$(printf '%0.0f' $vals[i])"
done

### Forecast
# | RH5143 NC4841 RL4840 EC4438"
parms='.list[].weather[0].id, .list[].temp.min, .list[].temp.max'
vals=( $(curl -s $forecast |jq -r $parms) )

pf ' |'
for i in {1..7}; do
    cond=$condtab[$vals[i]]
    lo=$(printf '%0.0f' $vals[i+7])
    hi=$(printf '%0.0f' $vals[i+14])
    pf " $cond$hi$lo"
done
