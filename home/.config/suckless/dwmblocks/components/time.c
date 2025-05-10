#include <stdio.h>
#include <time.h>

#define ICON_DEFAULT "󰥔"
#define ICON_NOON_EVENING "󰩰"
#define ICON_NIGHT "󰖔"

char *time_status(void) {
    static char result[32];
    time_t t;
    struct tm *tm_info;
    char time_str[6];
    int hour;
    const char *icon = ICON_DEFAULT;

    if (time(&t) == -1) {
        snprintf(result, sizeof(result), " %s ERR ", ICON_DEFAULT);
        return result;
    }

    tm_info = localtime(&t);
    if (!tm_info) {
        snprintf(result, sizeof(result), " %s ERR ", ICON_DEFAULT);
        return result;
    }

    strftime(time_str, sizeof(time_str), "%H:%M", tm_info);
    hour = tm_info->tm_hour;

    if (hour == 12 || hour == 19) {
        icon = ICON_NOON_EVENING;
    } else if (hour >= 0 && hour <= 7) {
        icon = ICON_NIGHT;
    }

    snprintf(result, sizeof(result), " %s %s ", icon, time_str);
    return result;
}
