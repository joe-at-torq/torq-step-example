
if [ -z "$KUBERNETES_SERVICE_HOST" ] #Restrict this step to only execute from inside a Docker Runner environment. (Unsupported on kubernetes)
then
    if [ -z "$COMMAND" ] #Check if required paramater is passed.
    then
        echo "{\"error\":\"no command provided\"}"
        exit 9
    else    
        echo "{\"command\":\"your command is $COMMAND\"}"
        exit 0
    fi
else
    echo "  {\"error\":\"this step is only allowed to execute from a runner.\"}"
    exit 9
fi

