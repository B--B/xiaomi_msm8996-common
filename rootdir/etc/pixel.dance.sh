#!/system/bin/sh

# Brightness
BRG=echo #value
# Color channel sysfs
BLUE=/sys/class/leds/blue/brightness
GREEN=/sys/class/leds/green/brightness
RED=/sys/class/leds/red/brightness

EXIT() {
    # Reset channels
    echo 0 | tee $BLUE $GREEN $RED
    exit 0
}

PIXEL() {
    $BRG 255 > /sys/class/leds/red/brightness
    $BRG 0 > /sys/class/leds/red/start_idx
    $BRG "0,100,100,0" > /sys/class/leds/red/duty_pcts
    $BRG 0 > /sys/class/leds/red/pause_hi
    $BRG 0 > /sys/class/leds/red/pause_lo
    $BRG 400 > /sys/class/leds/red/ramp_step_ms
    $BRG 255 > /sys/class/leds/green/brightness
    $BRG 7 > /sys/class/leds/green/start_idx
    $BRG "0,0,100,100" > /sys/class/leds/green/duty_pcts
    $BRG 0 > /sys/class/leds/green/pause_hi
    $BRG 0 > /sys/class/leds/green/pause_lo
    $BRG 400 > /sys/class/leds/green/ramp_step_ms
    $BRG 255 > /sys/class/leds/blue/brightness 
    $BRG 14 > /sys/class/leds/blue/start_idx
    $BRG "100,0,0,0" > /sys/class/leds/blue/duty_pcts
    $BRG 0 > /sys/class/leds/blue/pause_hi
    $BRG 0 > /sys/class/leds/blue/pause_lo
    $BRG 400 > /sys/class/leds/blue/ramp_step_ms
    $BRG 1 > /sys/class/leds/rgb/rgb_blink
}

RUN() {
    case $PATTERN in
    disabled) EXIT;;
    pixel) PIXEL;;
    esac
}

LOOP() {
    # Start a loop
    while :; do
        BOOT=$(getprop sys.boot_completed | grep "1")
    if [ "$BOOT" == "1" ]; then
        PATTERN=pixel
    fi
    RUN
    done
}

# Default
PATTERN=pixel

RUN
