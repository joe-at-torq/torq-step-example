if [ -z "$COMMAND" ] #Check if required paramater is passed.
then
    echo "{\"error\":\"no command provided\"}"
    exit 9
else    
    echo "{\"command\":\"your command is $COMMAND\"}"
    exit 0
fi

