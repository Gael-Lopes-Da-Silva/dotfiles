#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ICON_BATTERY_100 "󰁹"
#define ICON_BATTERY_90 "󰂂"
#define ICON_BATTERY_80 "󰂁"
#define ICON_BATTERY_70 "󰂀"
#define ICON_BATTERY_60 "󰁿"
#define ICON_BATTERY_50 "󰁾"
#define ICON_BATTERY_40 "󰁽"
#define ICON_BATTERY_30 "󰁼"
#define ICON_BATTERY_20 "󰁻"
#define ICON_BATTERY_10 "󰁺"
#define ICON_CHARGING "󰂄"
#define ICON_FULL "󰂃"

#define CMD_GET_BATTERY "upower -i $(upower -e 2>/dev/null | grep /battery) 2>/dev/null"

char *battery_status(void) {
    static char result[128];
    FILE *fp;
    char output[256];
    int battery = -1;
    char state[16] = "";
    const char *icon = ICON_BATTERY_100;
    const char *color = "";
    int type = 0;

    if ((fp = popen(CMD_GET_BATTERY, "r")) == NULL) {
        result[0] = '\0';
        return result;
    }

    while (fgets(output, sizeof(output), fp)) {
        if (strstr(output, "percentage")) {
            sscanf(output, " percentage: %d%%", &battery);
        } else if (strstr(output, "state")) {
            sscanf(output, " state: %15s", state);
        }
    }
    pclose(fp);

    if (battery < 0 || strlen(state) == 0) {
        result[0] = '\0';
        return result;
    }

    if (strcmp(state, "charging") != 0 && battery != 100) {
        if (battery >= 90) {
            icon = ICON_BATTERY_90;
        } else if (battery >= 80) {
            icon = ICON_BATTERY_80;
        } else if (battery >= 70) {
            icon = ICON_BATTERY_70;
        } else if (battery >= 60) {
            icon = ICON_BATTERY_60;
        } else if (battery >= 50) {
            icon = ICON_BATTERY_50;
        } else if (battery >= 40) {
            icon = ICON_BATTERY_40;
        } else if (battery >= 30) {
            icon = ICON_BATTERY_30;
        } else if (battery >= 20) {
            icon = ICON_BATTERY_20;
        } else {
            icon = ICON_BATTERY_10;
        }
    }

    if (strcmp(state, "charging") == 0) {
        icon = ICON_CHARGING;
        if (battery >= 95) {
            color = "#50BF00";
            type = 1;
        }
    } else if (strcmp(state, "discharging") == 0) {
        if (battery <= 20) {
            color = "#FF8000";
            type = 1;
        }
        if (battery <= 10) {
            color = "#FF0000";
            type = 1;
        }
    }

    if (battery == 100) {
        icon = ICON_FULL;
        color = "#005577";
        type = 2;
    }

    if (type == 0) {
        snprintf(result, sizeof(result), " %s %d%% ", icon, battery);
    } else if (type == 1) {
        snprintf(result, sizeof(result), " %s ^c%s^%d%%^d^ ", icon, color, battery);
    } else if (type == 2) {
        snprintf(result, sizeof(result), "^b%s^ %s %d%% ^d^", color, icon, battery);
    }

    return result;
}
