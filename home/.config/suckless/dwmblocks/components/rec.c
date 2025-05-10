#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ICON_MIC ""
#define ICON_MUTE ""
#define CMD_GET_VOLUME "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null"

char *rec_status(void) {
	static char result[128];
	FILE *fp;
	char output[128];
	float volume = -1.0;
	int isMuted = 0;
	const char *icon = ICON_MIC;

	if ((fp = popen(CMD_GET_VOLUME, "r")) == NULL) {
		snprintf(result, sizeof(result), " %s ERR ", ICON_MIC);
		return result;
	}

	if (fgets(output, sizeof(output), fp) && sscanf(output, "Volume: %f %*s", &volume) == 1) {
		isMuted = strstr(output, "[MUTED]") != NULL;
	}
	pclose(fp);

	if (volume < 0.0) {
		snprintf(result, sizeof(result), " %s ERR ", ICON_MIC);
		return result;
	}

	if (volume == 0.0 || isMuted) {
		icon = ICON_MUTE;
	}

	if (isMuted) {
		snprintf(result, sizeof(result), " %s ^c#474747^MUTED^d^ ", icon);
	} else {
		snprintf(result, sizeof(result), " %s %d%% ", icon, (int)(volume * 100));
	}

	return result;
}
