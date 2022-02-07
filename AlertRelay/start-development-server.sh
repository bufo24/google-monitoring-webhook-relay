#!/usr/bin/env bash

MY_DEFAULT_CONFIG="./default_config"
MY_CONFIG="./my_config"
echo "Load default config file '$MY_DEFAULT_CONFIG'"
if [ -e "$MY_DEFAULT_CONFIG" ]; then
	# ignore SC1090
	# shellcheck source=/dev/null
	source "$MY_DEFAULT_CONFIG"
else
	echo "ERROR: Default config file not found!"
	exit 9
fi
if [ -e "$MY_CONFIG" ]; then
	echo "Load config file '$MY_CONFIG'"
	# ignore SC1090
	# shellcheck source=/dev/null
	source "$MY_CONFIG"
fi

echo
echo "Environment Variables"
echo "---------------------"
echo "API_KEY         : $API_KEY"
echo "DISCORD_URL     : $DISCORD_URL"
echo "PUSHOVER_USER   : $PUSHOVER_USER"
echo "PUSHOVER_TOKEN  : $PUSHOVER_TOKEN"
echo "SIPGATE_ID      : $SIPGATE_ID"
echo "SIPGATE_TOKEN   : $SIPGATE_TOKEN"
echo "SIPGATE_SMS     : $SIPGATE_SMS"
echo "SIPGATE_TEL     : $SIPGATE_TEL"
echo "TEAMS_URL       : $TEAMS_URL"
echo

echo "Tests"
echo "----"
echo "curl -i http://localhost:8080/?key=$API_KEY"
echo
echo "curl -i -H 'Content-Type: application/json' --data @t/test.json http://localhost:8080/test?key=$API_KEY"
echo

plackup bin/app.psgi -l 127.0.0.1:8080