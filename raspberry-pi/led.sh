#! /bin/bash

# 绿色的灯
#echo 0    | sudo tee   /sys/class/leds/led0/brightness
#echo none | sudo tee  /sys/class/leds/led0/trigger
# 红色的灯
#echo none | sudo tee  /sys/class/leds/led1/trigger
#echo 0    | sudo tee  /sys/class/leds/led1/brightness

greenLED="/sys/class/leds/led0/brightness"
redLED="/sys/class/leds/led1/brightness"

off(){
    echo 0 > $greenLED
    echo 0 > $redLED
}

on(){
    echo 1 > $greenLED
    echo 1 > $redLED
}

main(){
    case $1 in
    on)
        on;;
    off)
        off;;
    *)
        echo "on 开启led off关闭led";;
    esac
}

main "$@"
