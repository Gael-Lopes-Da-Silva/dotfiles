#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ICON_BRIGHT "󰃠"
#define ICON_DIM "󰃞"

#define CMD_GET_BRIGHTNESS "brightnessctl -m 2>/dev/null | grep backlight"

int
main(void)
{
    FILE *fp;
    char output[128];
    int brightness = -1;
    const char *icon = ICON_BRIGHT;

    if ((fp = popen(CMD_GET_BRIGHTNESS, "r")) == NULL) {
        return 1;
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
        return 1;
    }

    if (brightness <= 50) {
        icon = ICON_DIM;
    }

    printf(" %s %d%% ", icon, brightness);

    return 0;
}
