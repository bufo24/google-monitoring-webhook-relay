# Copyright 2022 Nils Knieling. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package AlertRelay::Discord;
use Dancer2 appname => 'AlertRelay';
use LWP::UserAgent;
use HTTP::Request::Common;

our $VERSION = '1.0.0';

post '/discord' => sub {
	my $url = $ENV{'DISCORD_URL'} || '';
	debug( "[ENV] DISCORD_URL : '$url'");
	unless ( $url && $url =~ /discord(?:app)?\.com\/api\/webhooks\/\d+\/[^\/?]+/ ) {
		response->status(501);
		send_as JSON => { error => "Discord webhook url" };
	}
	# Create JSON for content body
	my %json;
	$json{text} = AlertRelay::Message();
	# Convert Perl hash to JSON
	my $json_text = to_json(\%json);
	# HTTP client
	my $ua = AlertRelay::UserAgent();
	# Execute Slack compatible webhook
	my $request = POST "$url/slack";
	$request->header( 'Content-Type' => 'application/json', 'Content-Length' => length($json_text) );
	$request->content( $json_text );
	my $response = $ua->request($request);
	debug( "[DISCORD] status_line : '".     $response->status_line ."'");
	debug( "[DISCORD] decoded_content : '". $response->decoded_content ."'");
	if ($response->is_success) {
		send_as JSON => { ok => "Discord message sent successfully" };
	} else {
		response->status(500);
		send_as JSON => { error => "Discord message could not be sent!" };
	}
};