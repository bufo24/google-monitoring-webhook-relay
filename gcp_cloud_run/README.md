# Google Cloud Run

Deploy the [Docker image](https://hub.docker.com/repository/docker/cyclenerd/google-monitoring-webhook-relay) as highly scalable containerized applications on a fully managed serverless platform.

You can use the service to get notified about Google Cloud Platform Monitoring alerts.
Add the HTTP API URL as a webhook endpoint for this task.

## Setup

You need a Bash shell and the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install).
You can also use your [Cloud Shell](https://cloud.google.com/shell/docs/using-cloud-shell).

Clone:
```shell
git clone "https://github.com/Cyclenerd/google-monitoring-webhook-relay.git"
cd google-monitoring-webhook-relay/gcp_cloud_run/
```

### Config

Overwrite default configuration with `my_config` file:

```shell
# Get default configuration
cat default_config

# Change API key
echo "API_KEY='$(echo $RANDOM | md5sum | head -c 20)'" >> my_config

# Change project ID
echo "MY_GCP_PROJECT='my-project-id'" >> my_config

# Change region
echo "MY_GCP_REGION='europe-north1'" >> my_config
```

Pass other configuration options as [environment variables](https://github.com/Cyclenerd/google-monitoring-webhook-relay#configuration) to Cloud Run container service:

```shell
# Example for Discord webhook url parameter
echo "DISCORD_URL='https://discord.com/api/webhooks/123456789/abcdefghijklmnopqrstuvwxyz'" >> my_config
```

### Create Artifact Registry 

**Create a new Artifact Registry repository for Docker images:**
```shell
bash 01_create_docker_registry.sh
```

### Copy Docker image

**Copy Docker image from GitHub Container Registry to Artifact Registry:**
```shell
bash 02_copy_docker_image.sh
```

💡 You can always repeat this step to copy and mirror the Docker image.

The tool `gcrane` from [go-containerregistry](https://github.com/google/go-containerregistry/blob/main/cmd/gcrane/README.md) is used to copy the image.
If you don't have it installed, the script will try to install it under `/usr/local/bin/`.

### Deploy Cloud Run service

**Deploy container to Cloud Run service and test HTTP API:**
```shell
bash 03_deploy_cloud_run.sh
```

💡 You can always repeat this step to update the Cloud Run container.

### Done

You can now use the HTTP API to get notified.

### Test

```shell
curl -i \
	-H "Content-Type: application/json" \
	--data @../AlertRelay/t/test.json \
	https://<Cloud Run service URL>/test?key=$API_KEY
```