function fish_prompt
    set_color normal
    echo -n ' '
    echo -n '{'

    set_color $fish_color_cwd
    echo -n "" (basename $PWD) ""

    set_color normal
    echo -n '}'
    echo -n ' '
end
