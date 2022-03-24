#!/bin/bash
COMMAND=$1
PARAM1=$2
PARAM2=$3
ARGSNUMBER=$#
AUTHFILE=.jfrogauth
echo "hey"
# If this runs inside a container
#[ -f /.dockerenv ] && echo "I'm in a container!"

# [ -z ${username} ] || 

#GENERATE TOKEN
GenToken () {
#    read -p "Username: " username
#    read -s -p "Password: " password
#    echo ""
    curl -s -XPOST -u $username:$password https://galipapa.jfrog.io/artifactory/api/security/token -d "username=$username" -d "scope=member-of-groups:administrators" | jq -r '.access_token' > .jfrogauth
}

if [[ -f "$AUTHFILE" ]]; then
    Token=$(cat .jfrogauth)
    #Checking that authentication token is valid
    CHECKAUTH=$(curl -s -H "Authorization: Bearer $Token" https://galipapa.jfrog.io/artifactory/api/system/version  | jq -r '.errors | .[].message' 2>/dev/null )
    #If Token is invalid
    if [ "$CHECKAUTH" == "Props Authentication Token not found" ]; then
        echo Token is invalid

        #Regenerate Token
        GenToken
    fi

else
    #Generate Token
    GenToken
fi

Token=$(cat .jfrogauth)
#Usage: ./file.sh Command

if [ "$1" = "-help" ]
    then
    echo "Usage $0 COMMAND
    List of Commands are: storageInfo, repo, ping, version, createUser - Receives Two Parameters, deleteUser - Receive One Parameter
    Example: $0 createUser Test1 Password1"
    exit 0
fi

if [ $ARGSNUMBER -lt 1 ]
    then
        echo "Token is valid, please proceed
         Usage: $0 Command
         try: $0 -help for help"
        exit 2
fi


ping () {

curl -s -u $username:$password https://galipapa.jfrog.io/artifactory/api/system/ping
echo ""

}

version () {

VER=$(curl -s -H "Authorization: Bearer $Token" https://galipapa.jfrog.io/artifactory/api/system/version | grep version | cut -d '"' -f4)

echo "Artifactory Version: $VER"


}

createUser () {
if [ $ARGSNUMBER -lt 3 ]
    then
        echo "Usage:  $0 createUser UserName Password"
        exit 2
else
    CREATION=$(curl -s -XPUT -H 'Content-Type: application/json' -H "Authorization: Bearer $Token" https://galipapa.jfrog.io/artifactory/api/security/users/$PARAM1 -d '
    {
    "name": "'$PARAM1'",
    "email" : "'$PARAM1'@testorg.com",
    "password": "'$PARAM2'",
    "disableUIAccess" : false
    }')

    if [[ ${#CREATION} = 0 ]]; then
        echo User Successfully Created
    else
        echo $CREATION
        echo Creation Failed Please Fix
    fi
fi
}

deleteUser () {

if [ $ARGSNUMBER -lt 2 ]
    then
        echo "Usage:  $0 deleteUser UserName"
        exit 2
else

curl -XDELETE -s -H "Authorization: Bearer $Token" https://galipapa.jfrog.io/artifactory/api/security/users/$PARAM1
echo ""
fi
}

listRepo () {

curl -s -H "Authorization: Bearer $Token" GET https://galipapa.jfrog.io/artifactory/api/repositories

}

storageInfo () {

curl -s -H "Authorization: Bearer $Token" https://galipapa.jfrog.io/artifactory/api/storageinfo

}

if [[ "$1" = "storageInfo" || "$1" = "ping" || "$1" = "version" || "$1" = "createUser" || "$1" = "deleteUser" || "$1" = "listRepo" ]]; then
$1
else
echo "Available Commands are storageInfo, ping, version, createUser, deleteUser, listRepo"
fi
