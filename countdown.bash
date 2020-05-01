
countdown()
{
    local HMS OLDIFS SECS t
    if [[ $1 =~ ^[0-9:]+$ ]]; then
        OLDIFS="${IFS}"
        IFS=$':'
        HMS=( "$1" );
        IFS="${OLDIFS}"

        case ${#HMS[@]} in
            1) SECS=$((  HMS[0] ));;
            2) SECS=$((  HMS[1] + (HMS[0] * 60) ));;
            3) SECS=$((  HMS[2] + (HMS[1] * 60) + (HMS[0] * 3600) ));;
            4) SECS=$((  HMS[3] + (HMS[2] * 60) + (HMS[1] * 3600) + (HMS[0] * 86400)));;
            *) printf '%b\n' "Invalid time length $1" >&2; return 127;;
        esac
    elif [[ $1 =~ ^[0-9smhd]+$ ]]; then
        t="$1"
        t=${t//d/ * 86400 + }
        t=${t//h/ * 3600 + }
        t=${t//m/ * 60 + }
        t=${t//s/ + }
        # shellcheck disable=SC2154
        t="$t$secs"
        t=${t/% + /} # Strip empty addition
        # shellcheck disable=SC2004
        SECS=$(( $t ))
    else
        printf '%b\n' "Invalid time length $1" >&2
        return 127
    fi

    # shellcheck disable=SC2048,SC2086
    set -- $*
    while [ $SECS -gt 0 ]; do
        # Clear Line
        printf "\r\33[2K\r"
        [ $SECS -ge 86400 ] \
            && printf "\r%02d %02d:%02d:%02d " $((SECS/86400)) $((((SECS/3600)%3600)%24)) $(((SECS/60)%60)) $((SECS%60)) \
            || printf "\r%02d:%02d:%02d " $(((SECS/3600)%3600)) $(((SECS/60)%60)) $((SECS%60))
        # shellcheck disable=SC2004
        SECS=$(( $SECS - 1 ))
        sleep 1 || return 1; # return 'error'; SIGINTR, for example
    done
    # Again, Clear Line
    printf "\r\33[2K\r"
}
