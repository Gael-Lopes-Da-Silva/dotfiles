/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx       = 4;       /* border pixel of windows */
static const unsigned int snap           = 20;      /* snap pixel */
static const unsigned int systraypinning = 0;       /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft  = 0;       /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2;       /* systray spacing */
static const int systraypinningfailfirst = 1;       /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray             = 1;       /* 0 means no systray */
static const int showbar                 = 1;       /* 0 means no bar */
static const int topbar                  = 1;       /* 0 means bottom bar */
static const char *fonts[]               = { "MartianMono NFM:size=14" };
static const char col_gray1[]            = "#222222";
static const char col_gray2[]            = "#444444";
static const char col_gray3[]            = "#bbbbbb";
static const char col_gray4[]            = "#eeeeee";
static const char col_cyan[]             = "#005577";
static const char *colors[][3]           = {
    /*               fg         bg         border   */
    [SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
    [SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

static const char *const autostart[] = {
    "xsetroot", "-solid", "#474747", NULL,
    "xsetroot", "-cursor_name", "left_ptr", NULL,
    "xset", "r", "rate", "250", "40", NULL,
    "xset", "s", "off", "-dpms", NULL,

    "udiskie", "-a", "-n", "-s", NULL,
    "dsound_setup", NULL,
    "dwmblocks", NULL,
    "dunst", NULL,
    NULL /* terminate */
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

/* Lockfile */
static char lockfile[] = "/tmp/dwm.lock";

/* Session */
static char sessionfile[] = "/tmp/dwm.session";

static const Rule rules[] = {
    /* xprop(1):
     *    WM_CLASS(STRING) = instance, class
     *    WM_NAME(STRING) = title
     */
    /* class      instance    title       tags mask     isfloating   monitor */
    { "*",        NULL,       NULL,       0,            0,           -1 },
};

/* layout(s) */
static const float mfact        = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster        = 1;    /* number of clients in master area */
static const int resizehints    = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1;    /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[M]",      monocle },
    { "[]=",      tile },    /* first entry is default */
    { "[]|",      NULL },    /* no layout function means floating behavior */
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
    { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */

static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, topbar ? NULL : "-b", NULL };
static const char *termcmd[]   = { "kitty", NULL };
static const char *browsercmd[]  = { "chromium", NULL };

static const char *vol_plus[]  = { "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0.10+", NULL };
static const char *vol_minus[] = { "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0.10-", NULL };
static const char *vol_mute[]  = { "wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle", NULL };
static const char *mic_mute[]  = { "wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle", NULL };
static const char *bri_plus[]  = { "brightnessctl", "set", "+10%", NULL };
static const char *bri_minus[] = { "brightnessctl", "set", "10%-", NULL };

static const char scrsht[]     = "maim --select | xclip -selection clipboard -t image/png";
static const char scrsht_all[] = "maim -i $(xdotool getactivewindow) | xclip -selection clipboard -t image/png";

#include <X11/XF86keysym.h>

static const Key keys[] = {
/*   modifier            key                         function          argument */
    {MODKEY,             XK_p,                       spawn,            {.v = dmenucmd} },
    {MODKEY,             XK_Return,                  spawn,            {.v = termcmd} },
    {MODKEY,             XK_BackSpace,               spawn,            {.v = browsercmd} },
    {MODKEY,             XK_b,                       togglebar,        {0} },
    {MODKEY,             XK_j,                       focusstack,       {.i = +1} },
    {MODKEY,             XK_k,                       focusstack,       {.i = -1} },
    {MODKEY,             XK_i,                       incnmaster,       {.i = +1} },
    {MODKEY,             XK_d,                       incnmaster,       {.i = -1} },
    {MODKEY,             XK_h,                       setmfact,         {.f = -0.05} },
    {MODKEY,             XK_l,                       setmfact,         {.f = +0.05} },
    {MODKEY|ShiftMask,   XK_Tab,                     view,             {0} },
    {MODKEY,             XK_Tab,                     zoom,             {0} },
    {MODKEY|ShiftMask,   XK_c,                       killclient,       {0} },
    {MODKEY,             XK_t,                       setlayout,        {.v = &layouts[1]} },
    {MODKEY,             XK_f,                       setlayout,        {.v = &layouts[2]} },
    {MODKEY,             XK_m,                       setlayout,        {.v = &layouts[0]} },
    {MODKEY,             XK_space,                   setlayout,        {0} },
    {MODKEY|ShiftMask,   XK_space,                   togglefloating,   {0} },
    {MODKEY|ShiftMask,   XK_f,                       togglefullscr,    {0} },
    {MODKEY,             XK_0,                       view,             {.ui = ~0} },
    {MODKEY|ShiftMask,   XK_0,                       tag,              {.ui = ~0} },
    {MODKEY,             XK_comma,                   focusmon,         {.i = -1} },
    {MODKEY,             XK_period,                  focusmon,         {.i = +1} },
    {MODKEY|ShiftMask,   XK_comma,                   tagmon,           {.i = -1} },
    {MODKEY|ShiftMask,   XK_period,                  tagmon,           {.i = +1} },
    {MODKEY|ShiftMask,   XK_q,                       quit,             {0} },
    {MODKEY|ShiftMask,   XK_r,                       quit,             {1} },
    {MODKEY|ShiftMask,   XK_o,                       spawn,            SHCMD(scrsht) },
    {MODKEY,             XK_o,                       spawn,            SHCMD(scrsht_all) },
    {0,                  XF86XK_AudioRaiseVolume,    spawn,            {.v = vol_plus} },
    {0,                  XF86XK_AudioLowerVolume,    spawn,            {.v = vol_minus} },
    {0,                  XF86XK_AudioMute,           spawn,            {.v = vol_mute} },
    {0,                  XF86XK_AudioMicMute,        spawn,            {.v = mic_mute} },
    {0,                  XF86XK_MonBrightnessUp,     spawn,            {.v = bri_plus} },
    {0,                  XF86XK_MonBrightnessDown,   spawn,            {.v = bri_minus} },

    TAGKEYS(XK_1, 0)
    TAGKEYS(XK_2, 1)
    TAGKEYS(XK_3, 2)
    TAGKEYS(XK_4, 3)
    TAGKEYS(XK_5, 4)
    TAGKEYS(XK_6, 5)
    TAGKEYS(XK_7, 6)
    TAGKEYS(XK_8, 7)
    TAGKEYS(XK_9, 8)
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
    /* click                event mask      button          function        argument */
    { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
    { ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
    { ClkWinTitle,          0,              Button2,        zoom,           {0} },
    { ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd} },
    { ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
    { ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
    { ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
    { ClkTagBar,            0,              Button1,        view,           {0} },
    { ClkTagBar,            0,              Button3,        toggleview,     {0} },
    { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
    { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
