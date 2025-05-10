#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ICON_BRIGHT "󰃠"
#define ICON_DIM "󰃞"
#define CMD_GET_BRIGHTNESS "brightnessctl -m 2>/dev/null | grep backlight"

char *brightness_status(void) {
    static char result[32];
    FILE *fp;
    char output[128];
    int brightness = -1;
    const char *icon = ICON_BRIGHT;

    if ((fp = popen(CMD_GET_BRIGHTNESS, "r")) == NULL) {
        snprintf(result, sizeof(result), " %s ERR ", ICON_BRIGHT);
        return result;
    }

    if (fgets(output, sizeof(output), fp)) {
        char *token = strtok(output, ",");
        for (int i = 0; i < 3 && token != NULL; i++) {
            token = strtok(NULL, ",");
        }
        if (token) {
            brightness = atoi(token);
        }
    }
    pclose(fp);

    if (brightness < 0) {
        snprintf(result, sizeof(result), " %s ERR ", ICON_BRIGHT);
        return result;
    }

    if (brightness <= 50) {
        icon = ICON_DIM;
    }

    snprintf(result, sizeof(result), " %s %d%% ", icon, brightness);
    return result;
}
