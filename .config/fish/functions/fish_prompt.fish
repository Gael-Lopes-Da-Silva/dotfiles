function fish_prompt
    set_color normal
    echo -n " { "

    set_color $fish_color_cwd
    echo -n $PWD

    set_color normal
    echo -n " } "
end
