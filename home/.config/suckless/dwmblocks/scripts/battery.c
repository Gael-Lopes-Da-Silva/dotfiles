#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ICON_BATTERY "󰁹"
#define ICON_CHARGING "󱐋"
#define ICON_FULL ""

#define CMD_GET_BATTERY "upower -i $(upower -e 2>/dev/null | grep /battery) 2>/dev/null"

int
main(void)
{
    FILE *fp;
    char output[256];
    int battery = -1;
    char state[16] = "";
    const char *icon = ICON_BATTERY;
    const char *color = "";
    int type = 0;
    
    if ((fp = popen(CMD_GET_BATTERY, "r")) == NULL) {
        return 1;
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
        return 1;
    }
    
    if (strcmp(state, "charging") == 0) {
        icon = ICON_CHARGING;
        if (battery >= 95) {
            color = "#00FF00";
            type = 1;
        }
    } else if (strcmp(state, "discharging") == 0) {
        if (battery <= 20) {
            color = "#FF8000";
            type = 1;
        }
        if (battery <= 10) {
            color = "#FF0000";
            type = 2;
        }
    }
    
    if (battery == 100) {
        icon = ICON_FULL;
        color = "#0000FF";
        type = 2;
    }
    
    if (type == 0) {
        printf(" %s %d%% ", icon, battery);
    } else if (type == 1) {
        printf(" %s ^c%s^%d%%^d^ ", icon, color, battery);
    } else if (type == 2) {
        printf("^b%s^ %s %d%% ^d^", color, icon, battery);
    }
    
    return 0;
}