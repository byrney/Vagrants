function usage(){
    echo "usage"
}

function main(){
    param(
        [alias("s")][string] $serverName ,
        [alias("v")][switch] $verbose
    )
    if(!$serverName){
        usage;
        exit 2;
    }
    if($verbose){
        echo "serverName: $serverName";
    } else {
        echo $serverName;
    }
}

#
# call main passing all args
#
echo @psBoundParameters
main $args.split(' ')

