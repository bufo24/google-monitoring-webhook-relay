# Google Cloud Monitoring Alerting Webhook Relay

Get notified via Discord, Pushover, Sipgate SMS and Microsoft Teams message.

Available as [Docker image](https://hub.docker.com/repository/docker/cyclenerd/google-monitoring-webhook-relay) for hosting using Kubernets, AWS, Azure or [Google Cloud Platform](https://github.com/Cyclenerd/google-monitoring-webhook-relay/tree/master/gcp_cloud_run).

Based on [Dancer](https://www.perldancer.org/) Perl web framework.

[![Run on Google Cloud](https://deploy.cloud.run/button.svg)](https://github.com/Cyclenerd/google-monitoring-webhook-relay/tree/master/gcp_cloud_run)


## Services supported

* 👾 [Discord](https://github.com/Cyclenerd/google-monitoring-webhook-relay#discord--discordpl)
* 🔔 [Pushover](https://github.com/Cyclenerd/google-monitoring-webhook-relay#pushover--pushoverpl)
* ☎️ [sipgate SMS](https://github.com/Cyclenerd/google-monitoring-webhook-relay#sipgate-sms--sipgatepl)
* 👪 [Microsoft Teams](https://github.com/Cyclenerd/google-monitoring-webhook-relay#microsoft-teams--ms-teamspl)


## Configuration

The configuration is done via environment variables (`--env`).

```shell
docker run \
	--env API_KEY=foo \
	-p 127.0.0.1:8080:8080/tcp \
	cyclenerd/google-monitoring-webhook-relay:latest
```

Configuration:
* `API_KEY` : API Key to protect the relay webhook


### Discord

Discord webhook API:
<https://discord.com/developers/docs/resources/webhook#execute-webhook>

Create an webhook URL for your Discord channel:
<https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks>

The webhook URL should look similar to the following:
```text
https://discord.com/api/webhooks/<webhook-id>/<webhook-token>
```

Configuration:
* `DISCORD_URL` : Your Discord webhook url (example: `https://discord.com/api/webhooks/<webhook-id>/<webhook-token>`)

#### POST /discord

Example:
```shell
curl -i \
	-H "Content-Type: application/json" \
	--data @t/test.json \
	http://localhost:8080/discord?key=$API_KEY
```

### Pushover

Send message via Pushover API:
<https://pushover.net/api>

Configuration:
* `PUSHOVER_USER`  : The user/group key (not e-mail address) of your user (viewable when logged into our dashboard)
* `PUSHOVER_TOKEN` : Your application's API token

#### POST /pushover

Example:
```shell
curl -i \
	-H "Content-Type: application/json" \
	--data @t/test.json \
	http://localhost:8080/pushover?key=$API_KEY
```

### Sipgate SMS

Send an SMS via the sipgate REST API:
<https://www.sipgate.io/rest-api>

1. Order the free feature "SMS senden": <https://app.sipgatebasic.de/feature-store/sms-senden>
1. Get token id and token with 'sessions:sms:write' scope: <https://app.sipgate.com/personal-access-token>

Configuration:
* `SIPGATE_ID`    : Your sipgate token id (example: `token-FQ1V12`)
* `SIPGATE_TOKEN` : Your sipgate token (example: `e68ead46-a7db-46cd-8a1a-44aed1e4e372`)
* `SIPGATE_SMS`   : Your sipgate SMS extension id (default: `s0`)
* `SIPGATE_TEL`   : Phone number of the SMS recipient (example: `49157...`)

#### POST /sipgate

Example:
```shell
curl -i \
	-H "Content-Type: application/json" \
	--data @t/test.json \
	http://localhost:8080/sipgate?key=$API_KEY
```


### Microsoft Teams

Create an webhook URL for your Microsoft Teams Group:
<https://docs.microsoft.com/en-us/outlook/actionable-messages/send-via-connectors>

The webhook URL should look similar to the following:

```text
https://outlook.office365.com/webhook/ ↩
a1269812-6d10-44b1-abc5-b84f93580ba0@ ↩
9e7b80c7-d1eb-4b52-8582-76f921e416d9/ ↩
IncomingWebhook/3fdd6767bae44ac58e5995547d66a4e4/ ↩ 
f332c8d9-3397-4ac5-957b-b8e3fc465a8c
```

Configuration:
* `TEAMS_URL` : Your Teams webhook url (example: `https://outlook.office.com/webhook/<group>@<tenantID>/IncomingWebhook/<chars>/<guid>`)

#### POST /teams

Example:
```shell
curl -i \
	-H "Content-Type: application/json" \
	--data @t/test.json \
	http://localhost:8080/teams?key=$API_KEY
```


## Development

If you want to participate in the development you can find the source code in the directory `AlertRelay`.
If you just want to use the relay webhook, the Docker image is recommended.

```shell
cd AlertRelay
```


### Requirement

* Perl 5 (`perl`)
* Perl modules:
	* [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent)
	* [Dancer2](https://metacpan.org/pod/Dancer2)
	* [Starman](https://metacpan.org/pod/Starman) (*high-performance Perl PSGI web server only for production*)

Debian/Ubuntu:
```shell
sudo apt update
sudo apt install \
	libwww-perl \
	libdancer2-perl
# Production only
sudo apt install starman
```

Or install modules with cpanminus:
```shell
cpan App::cpanminus
cpanm --installdeps .
```

Start:
```shell
bash start-development-server.sh
```

First test:
```shell
curl -i http://localhost:8080/?key=$API_KEY
```

Test JSON:
```shell
curl -i \
	-H "Content-Type: application/json" \
	--data @t/test.json \
	http://localhost:8080/test?key=$API_KEY
```


### Test

Run:
```shell
bash t/test.sh
```


### Production

Start:
```shell
export API_KEY="$(echo $RANDOM | md5sum | head -c 20)"
plackup -E production -s Starman --workers=2 -l 127.0.0.1:8080 -a bin/app.psgi
```

### Build Docker image

```shell
docker build -t cyclenerd/google-monitoring-webhook-relay:latest .
```


## Contributing

Have a patch that will benefit this project?
Awesome! Follow these steps to have it accepted.

1. Please read [how to contribute](CONTRIBUTING.md).
1. Fork this Git repository and make your changes.
1. Create a Pull Request.
1. Incorporate review feedback to your changes.
1. Accepted!


## License

All files in this repository are under the [Apache License, Version 2.0](LICENSE) unless noted otherwise.