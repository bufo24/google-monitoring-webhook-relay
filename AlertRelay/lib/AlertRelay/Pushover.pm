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

package AlertRelay::Pushover;
use Dancer2 appname => 'AlertRelay';
use LWP::UserAgent;
use HTTP::Request::Common;

our $VERSION = '1.0.0';

post '/pushover' => sub {
	my $user  = $ENV{'PUSHOVER_USER'}  || '';
	my $token = $ENV{'PUSHOVER_TOKEN'} || '';
	debug( "[ENV] PUSHOVER_USER : '$user'" );
	debug( "[ENV] PUSHOVER_TOKEN : '$token'" );
	unless ($user && $token) {
		response->status(501);
		send_as JSON => { error => "Pushover user and/or token" };
	}
	my $url   = 'https://api.pushover.net/1/messages.json';
	my $msg   = AlertRelay::Message();
	my $ua    = AlertRelay::UserAgent();
	# Execute Pushover webhook
	my $request = POST "$url", [ "token" => $token, "user" => $user, "message" => $msg ];
	my $response = $ua->request($request);
	debug( "[PUSHOVER] status_line : '".     $response->status_line ."'");
	debug( "[PUSHOVER] decoded_content : '". $response->decoded_content ."'");
	if ($response->is_success) {
		send_as JSON => { ok => "Pushover message sent successfully" };
	} else {
		response->status(500);
		send_as JSON => { error => "Pushover message could not be sent!" };
	}
};