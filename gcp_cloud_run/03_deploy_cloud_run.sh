#!/usr/bin/env bash

# Deploy and run Google Cloud Run container
# https://cloud.google.com/sdk/gcloud/reference/run/deploy

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

# Create service account
if gcloud iam service-accounts create "$MY_GCP_SA_NAME" \
--display-name="$MY_GCP_SA_DISPLAY_NAME" \
--description="$MY_GCP_SA_DESCRIPTION" \
--project="$MY_GCP_PROJECT"; then
	echo "Please wait... (15sec)"
	sleep 15
fi

# Get service account ID
gcloud iam service-accounts list \
	--filter="email ~ ^$MY_GCP_SA_NAME\@" \
	--project="$MY_GCP_PROJECT"
MY_GCP_SA_ID=$(gcloud iam service-accounts list --filter="email ~ ^$MY_GCP_SA_NAME\@" --format="value(email)" --project="$MY_GCP_PROJECT")
if [[ "$MY_GCP_SA_ID" == *'@'* ]]; then
	echo "Service account identifier: $MY_GCP_SA_ID"
else
	echo "ERROR: Service account identifier could not be detected"
	exit 5
fi

# Do not change
MY_GCP_RUN_IMAGE="$MY_GCP_REGION-docker.pkg.dev/$MY_GCP_PROJECT/$MY_GCP_REPOSITORY_NAME/google-monitoring-webhook-relay:latest"

# API key and environment variables (configuration)
MY_CGP_RUN_ENV_VARS="API_KEY=$API_KEY"
MY_CGP_RUN_ENV_VARS+=",DISCORD_URL=$DISCORD_URL"
MY_CGP_RUN_ENV_VARS+=",PUSHOVER_USER=$PUSHOVER_USER,PUSHOVER_TOKEN=$PUSHOVER_TOKEN"
MY_CGP_RUN_ENV_VARS+=",SIPGATE_ID=$SIPGATE_ID,SIPGATE_TOKEN=$SIPGATE_TOKEN,SIPGATE_SMS=$SIPGATE_SMS,SIPGATE_TEL=$SIPGATE_TEL"
MY_CGP_RUN_ENV_VARS+=",TEAMS_URL=$TEAMS_URL"

echo
echo "Deploy container to Cloud Run service"
echo "-------------------------------------"
echo "Name                 : $MY_GCP_RUN_SERVICE_NAME"
echo "Image                : $MY_GCP_RUN_IMAGE"
echo "CPU                  : $MY_GCP_RUN_CPU"
echo "Memory               : $MY_GCP_RUN_MEMORY"
echo "Concurrency          : $MY_GCP_RUN_CONCURRENCY"
echo "Service Account ID   : $MY_GCP_SA_ID"
echo "Instances (min/max)  : $MY_GCP_RUN_MIN_INSTANCES / $MY_GCP_RUN_MAX_INSTANCES"
echo "Region               : $MY_GCP_REGION"
echo "Project              : $MY_GCP_PROJECT"
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
gcloud run deploy "$MY_GCP_RUN_SERVICE_NAME" \
--region="$MY_GCP_REGION"                    \
--image="$MY_GCP_RUN_IMAGE"                  \
--platform=managed                           \
--cpu="$MY_GCP_RUN_CPU"                      \
--memory="$MY_GCP_RUN_MEMORY"                \
--concurrency="$MY_GCP_RUN_CONCURRENCY"      \
--allow-unauthenticated                      \
--service-account="$MY_GCP_SA_ID"            \
--min-instances="$MY_GCP_RUN_MIN_INSTANCES"  \
--max-instances="$MY_GCP_RUN_MAX_INSTANCES"  \
--set-env-vars="$MY_CGP_RUN_ENV_VARS"        \
--project="$MY_GCP_PROJECT"
echo

echo
echo "List service"
echo "------------"
gcloud run services list \
--filter="metadata.name:$MY_GCP_RUN_SERVICE_NAME" \
--limit=1 \
--project="$MY_GCP_PROJECT"
MY_GCP_RUN_URL=$(gcloud run services list \
--filter="metadata.name:$MY_GCP_RUN_SERVICE_NAME" \
--format="value(status.url)" \
--limit=1 \
--project="$MY_GCP_PROJECT")
echo

#
# Test Cloud Run service
#

echo
echo "Check version"
echo "---------------------------"
curl -i "$MY_GCP_RUN_URL/?key=$API_KEY"
echo

echo
echo "Send test message"
echo "-----------------"
curl -i \
	-H "Content-Type: application/json" \
	--data @../AlertRelay/t/test.json \
	"$MY_GCP_RUN_URL/test?key=$API_KEY"
echo

echo
echo "ALL DONE"
echo "--------"
echo "Your Cloud Run service URL: $MY_GCP_RUN_URL"
echo "Dashboard: https://console.cloud.google.com/run?project=$MY_GCP_PROJECT"
echo