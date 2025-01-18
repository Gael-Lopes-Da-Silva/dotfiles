alias la = ls -a
alias ll = ls -al
alias rm = rm -rfI
alias cp = cp -pri
alias mv = mv -pi

alias zed = zeditor

alias decompress = ouch decompress
alias compress = ouch compress

alias shutdown = sudo shutdown now
alias reboot = sudo reboot
alias poweroff = sudo poweroff
alias lock = loginctl lock-session
alias suspend = systemctl suspend
alias hibernate = systemctl hibernate

def install [...package: string] {
    paru -S ...$package
}

def search [package: string] {
    paru -Ss $package --color=always | less -r
}

def update [package?: string] {
    match $package {
        null => {paru -Syu}
        _ => {paru -Syu $package}
    }
}

def remove [...package: string] {
    paru -Rns ...$package
}

def infos [package?: string] {
    match $package {
        null => {paru -Qi --color=always | less -r}
        _ => {paru -Qi $package}
    }
}

def list [package?: string] {
    match $package {
        null => {paru -Qe --color=always | less -r}
        _ => {paru -Qe $package}
    }
}

def owns [package: string] {
    paru -Qo $package
}

def files [package?: string] {
    match $package {
        null => {paru -Ql --color=always | less -r}
        _ => {paru -Ql $package}
    }
}

def clean [] {
    paru -Rns (paru -Qdtq)
}