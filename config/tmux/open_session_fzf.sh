 smug list |\
    sed '/^$/d' |\
    fzf --reverse --header "Open new session"  --print0 |\
    xargs -0 -I {} smug start "{}" -a 
