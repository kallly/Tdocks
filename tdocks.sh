GREEN='\033[0;92m';
NC='\033[0m';

containers=$(docker container list -q);
current_container='';

declare -i N_TOTAL=$(echo $containers | wc -w);
declare -i X_MAX=2;
declare -i Y_MAX=2;
declare -i X_GOAL=1;
declare -i Y_GOAL=1;

function refreshTdocksData()
{
    containers=$(docker container list -q);
    current_container='';

    N_TOTAL=$(echo $containers | wc -w);
    X_MAX=2;
    Y_MAX=2;
    X_GOAL=1;
    Y_GOAL=1;
}

function displayTdocks()
{   
    clear;
    refreshTdocksData;
    echo 'List des containers.';

    declare -i X=1;
    declare -i Y=1;
    for container in $containers
    do
        if [ $X -eq $X_GOAL ] && [ $Y -eq $Y_GOAL ];
        then
            echo -en "${GREEN}";
            current_container=$container;
        fi
        name=$(docker inspect --format='{{.Config.Image}}' $container | sed -e 's/.*\///g' | sed -e 's/:.*//g');
        echo -en "$name\t";
        echo -en "${NC} ";

        X=$X+1;
        if [ $X -gt $X_MAX ];
        then
            echo '';
            X=1;
            Y=$Y+1;
        fi
    done
}
refreshTdocksData;
displayTdocks;

stop=false;
while [ "$stop" = false ]
do
    move='';
    key='';
    read -r -sn1 key;
    key=$(echo "$key" | hexdump -x | head -1 | sed 's/   //g' | cut -d ' ' -f2);

    case $key in
        '0a71') stop=true;displayTdocks;;
        '0a41') if [ $Y_GOAL -gt 1 ];then Y_GOAL=$Y_GOAL-1;fi;displayTdocks;;
        '0a42') if [ $((($Y_GOAL+1)*$X_GOAL)) -le $N_TOTAL ];then Y_GOAL=$Y_GOAL+1;fi;displayTdocks;;
        '0a43') if [ $X_GOAL -lt $X_MAX ] && [ $((($X_GOAL+1)*$Y_GOAL)) -le $N_TOTAL ];then X_GOAL=$X_GOAL+1;fi;displayTdocks;;
        '0a44') if [ $X_GOAL -gt 1 ];then X_GOAL=$X_GOAL-1;fi;displayTdocks;;
        '000a') docker exec -it $current_container /bin/bash;displayTdocks;;
        *);;
    esac
done

echo '';