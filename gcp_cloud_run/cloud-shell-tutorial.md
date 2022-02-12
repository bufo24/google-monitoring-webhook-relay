# How to set up Google Cloud Run

## Welcome 👋!

In this tutorial, you are going to set up [Google Cloud Monitoring Alerting Webhook Relay](https://github.com/Cyclenerd/google-monitoring-webhook-relay) on Google Cloud Run.

**Time to complete**: Less than 10 minutes

Click the **Start** button to move to the next step.

## Config

Change to `gcp_cloud_run` directory:

```bash
cd gcp_cloud_run/
```

View default configuration:
```bash
cat default_config
```

**Overwrite default configuration with `my_config` file**

Change API key:
```bash
echo "API_KEY='$(echo $RANDOM | md5sum | head -c 20)'" >> my_config
```

Change project ID:
```bash
echo "MY_GCP_PROJECT='my-project-id'" >> my_config
```

Change region:
```bash
echo "MY_GCP_REGION='europe-north1'" >> my_config
```

Pass other configuration options as [environment variables](https://github.com/Cyclenerd/google-monitoring-webhook-relay#configuration) to Cloud Run container service:

Example for Discord webhook url parameter:
```bash
echo "DISCORD_URL='https://discord.com/api/webhooks/123456789/abcdefghijklmnopqrstuvwxyz'" >> my_config
```

## Create Artifact Registry 

Create a new Artifact Registry repository for Docker images:
```bash
bash 01_create_docker_registry.sh
```

## Copy Docker image

Copy Docker image from GitHub Container Registry to Artifact Registry:
```bash
bash 02_copy_docker_image.sh
```

💡 You can always repeat this step to copy and mirror the Docker image.

The tool `gcrane` from [go-containerregistry](https://github.com/google/go-containerregistry/blob/main/cmd/gcrane/README.md) is used to copy the image.
If you don't have it installed, the script will try to install it under `/usr/local/bin/`.

## Deploy Cloud Run service

Deploy container to Cloud Run service and test HTTP API:
```bash
bash 03_deploy_cloud_run.sh
```

💡 You can always repeat this step to update the Cloud Run container.

## Done 🎉

You can now use the HTTP API to get notified.

Test:
```bash
curl -i \
  -H "Content-Type: application/json" \
  --data @../AlertRelay/t/test.json \
  https://<Cloud Run service URL>/test?key=$API_KEY
```