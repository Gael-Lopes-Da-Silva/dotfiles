#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>

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

#define MAX_PATH_LEN 512
#define MAX_BATTERY_DIR_LEN 256
#define MAX_NAME_LEN 32

#define SYSFS_POWER_SUPPLY "/sys/class/power_supply/"

static int read_file(const char *path, char *buffer, size_t buffer_size) {
    FILE *fp = fopen(path, "r");
    if (!fp) return -1;
    if (fgets(buffer, buffer_size, fp) == NULL) {
        fclose(fp);
        return -1;
    }
    buffer[strcspn(buffer, "\n")] = 0;
    fclose(fp);
    return 0;
}

static char *find_battery(void) {
    DIR *dir = opendir(SYSFS_POWER_SUPPLY);
    if (!dir) return NULL;

    struct dirent *entry;
    static char battery_path[MAX_BATTERY_DIR_LEN];
    battery_path[0] = '\0';

    while ((entry = readdir(dir))) {
        if (strncmp(entry->d_name, "BAT", 3) == 0 && strlen(entry->d_name) < MAX_NAME_LEN) {
            size_t len = strlen(SYSFS_POWER_SUPPLY) + strlen(entry->d_name) + 1;
            if (len <= MAX_BATTERY_DIR_LEN) {
                battery_path[0] = '\0';
                strncat(battery_path, SYSFS_POWER_SUPPLY, MAX_BATTERY_DIR_LEN - 1);
                strncat(battery_path, entry->d_name, MAX_BATTERY_DIR_LEN - strlen(battery_path) - 1);
                break;
            }
        }
    }
    closedir(dir);
    return battery_path[0] ? battery_path : NULL;
}

char *battery_status(void) {
    static char result[128];
    char path[MAX_PATH_LEN];
    char state[16] = "";
    char capacity_str[16] = "";
    int battery = -1;
    const char *icon = ICON_BATTERY_100;
    const char *color = "";
    int type = 0;

    char *battery_dir = find_battery();
    if (!battery_dir) {
	    snprintf(result, sizeof(result), " %s ERR ", ICON_BATTERY_100);
        return result;
    }

    size_t battery_dir_len = strlen(battery_dir);
    if (battery_dir_len + strlen("/capacity") + 1 <= MAX_PATH_LEN) {
        path[0] = '\0';
        strncat(path, battery_dir, MAX_PATH_LEN - 1);
        strncat(path, "/capacity", MAX_PATH_LEN - battery_dir_len - 1);
        if (read_file(path, capacity_str, sizeof(capacity_str)) == 0) {
            battery = atoi(capacity_str);
        }
    }

    if (battery_dir_len + strlen("/status") + 1 <= MAX_PATH_LEN) {
        path[0] = '\0';
        strncat(path, battery_dir, MAX_PATH_LEN - 1);
        strncat(path, "/status", MAX_PATH_LEN - battery_dir_len - 1);
        if (read_file(path, state, sizeof(state)) != 0) {
            state[0] = '\0';
        }
    }

    if (battery < 0 || strlen(state) == 0) {
	    snprintf(result, sizeof(result), " %s ERR ", ICON_BATTERY_100);
        return result;
    }

    if (strcmp(state, "Charging") != 0 && battery != 100) {
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

    if (strcmp(state, "Charging") == 0) {
        icon = ICON_CHARGING;
        if (battery >= 95) {
            color = "#50BF00";
            type = 1;
        }
    } else if (strcmp(state, "Discharging") == 0) {
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
