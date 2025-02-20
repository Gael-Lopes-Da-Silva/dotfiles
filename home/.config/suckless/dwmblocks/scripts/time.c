#include <stdio.h>
#include <time.h>

#define ICON_DEFAULT "󰥔"
#define ICON_NOON_EVENING "󰩰"
#define ICON_NIGHT "󰖔"

int
main(void)
{
    time_t t;
    struct tm *tm_info;
    char time_str[9];
    int hour;
    const char *icon = ICON_DEFAULT;

    if (time(&t) == -1) {
        return 1;
    }

    tm_info = localtime(&t);
    if (!tm_info) {
        return 1;
    }

    strftime(time_str, sizeof(time_str), "%T", tm_info);
    hour = tm_info->tm_hour;

    if (hour == 12 || hour == 19) {
        icon = ICON_NOON_EVENING;
    } else if (hour >= 0 && hour <= 7) {
        icon = ICON_NIGHT;
    }

    printf(" %s %s ", icon, time_str);

    return 0;
}
