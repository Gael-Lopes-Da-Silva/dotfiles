#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ICON_MIC ""
#define ICON_MUTE ""

#define CMD_GET_VOLUME "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null"

int
main(void)
{
    FILE *fp;
    char output[128];
    float volume = -1.0;
    int isMuted = 0;
    const char *icon = ICON_MIC;

    if ((fp = popen(CMD_GET_VOLUME, "r")) == NULL) {
        return 1;
    }

    if (fgets(output, sizeof(output), fp) && sscanf(output, "Volume: %f %*s", &volume) == 1) {
        isMuted = strstr(output, "[MUTED]") != NULL;
    }
    pclose(fp);

    if (volume < 0.0) {
        return 1;
    }

    if (volume == 0.0 || isMuted) {
        icon = ICON_MUTE;
    }

    if (isMuted) {
        printf(" %s ^c#474747^MUTED^d^ ", icon);
    } else {
        printf(" %s %.2f ", icon, volume);
    }

    return 0;
}
