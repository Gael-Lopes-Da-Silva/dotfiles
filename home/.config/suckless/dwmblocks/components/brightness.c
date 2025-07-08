#include <stdio.h>
#include <string.h>
#include <glob.h>

#define ICON_BRIGHT "󰃠"
#define ICON_DIM "󰃞"

char *brightness_status(void) {
	static char result[32];
	FILE *fp;
	char brightness_path[128] = "";
	char max_brightness_path[128] = "";
	int brightness = -1, max_brightness = -1;
	const char *icon = ICON_BRIGHT;

	glob_t glob_result;
	if (glob("/sys/class/backlight/*/brightness", 0, NULL, &glob_result) == 0 && glob_result.gl_pathc > 0) {
		strncpy(brightness_path, glob_result.gl_pathv[0], sizeof(brightness_path) - 1);
		strncpy(max_brightness_path, brightness_path, sizeof(max_brightness_path) - 1);
		char *pos = strstr(max_brightness_path, "brightness");
		if (pos) {
			strcpy(pos, "max_brightness");
		}
		globfree(&glob_result);
	} else {
		snprintf(result, sizeof(result), " %s ERR ", ICON_BRIGHT);
		return result;
	}

	if ((fp = fopen(brightness_path, "r")) != NULL) {
		if (fscanf(fp, "%d", &brightness) != 1) {
			brightness = -1;
		}
		fclose(fp);
	}

	if ((fp = fopen(max_brightness_path, "r")) != NULL) {
		if (fscanf(fp, "%d", &max_brightness) != 1) {
			max_brightness = -1;
		}
		fclose(fp);
	}

	if (brightness < 0 || max_brightness <= 0) {
		snprintf(result, sizeof(result), " %s ERR ", ICON_BRIGHT);
		return result;
	}

	int percentage = (brightness * 100) / max_brightness;

	if (percentage <= 50) {
		icon = ICON_DIM;
	}

	snprintf(result, sizeof(result), " %s %d%% ", icon, percentage);

	return result;
}
