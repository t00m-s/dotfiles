function fuck
    if test -n "$argv[1]"
        killall -9 $argv[1]
    else
        echo "Usage: fuck <application>"
        return 1
    end
end
