function dsh
    if test -n "$argv[1]"
        docker exec -it $argv[1] /bin/bash
    else
        echo "Usage: dsh <container-id>"
        return 1
    end
end
