#include <stdio.h>
#include <time.h>
#include <string.h>

#define ICON_DEFAULT "󰃭"
#define ICON_BIRTHDAY ""
#define ICON_TRAVEL ""
#define ICON_SPECIAL "󰴺"

int
main(void)
{
    time_t t;
    struct tm *tm_info;
    char date_str[11];
    char short_date[6];
    const char *icon = ICON_DEFAULT;

    if (time(&t) == -1) {
        return 1;
    }

    tm_info = localtime(&t);
    if (!tm_info) {
        return 1;
    }

    strftime(date_str, sizeof(date_str), "%d/%m/%Y", tm_info);
    strftime(short_date, sizeof(short_date), "%d/%m", tm_info);

    if (strcmp(short_date, "19/06") == 0) {
        icon = ICON_BIRTHDAY;
    } else if (strcmp(short_date, "11/09") == 0) {
        icon = ICON_TRAVEL;
    } else if (strcmp(short_date, "20/04") == 0) {
        icon = ICON_SPECIAL;
    }

    printf(" %s %s ", icon, date_str);

    return 0;
}
