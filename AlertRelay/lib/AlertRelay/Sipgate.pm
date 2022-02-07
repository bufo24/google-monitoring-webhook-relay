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

package AlertRelay::Sipgate;
use Dancer2 appname => 'AlertRelay';
use LWP::UserAgent;
use HTTP::Request::Common;

our $VERSION = '1.0.0';

post '/sipgate' => sub {
	my $id    = $ENV{'SIPGATE_ID'}    || '';
	my $token = $ENV{'SIPGATE_TOKEN'} || '';
	my $sms   = $ENV{'SIPGATE_SMS'}   || 's0';
	my $tel   = $ENV{'SIPGATE_TEL'}   || '';
	debug( "[ENV] SIPGATE_ID : '$id'" );
	debug( "[ENV] SIPGATE_TOKEN : '$token'" );
	debug( "[ENV] SIPGATE_SMS : '$sms'" );
	debug( "[ENV] SIPGATE_TEL : '$tel'" );
	unless ($id && $token && $sms && $tel) {
		response->status(501);
		send_as JSON => { error => "Sipgate token id, token, SMS extension id and/or SMS recipient" };
	}
	my $url = 'https://api.sipgate.com/v2/sessions/sms';
	# Create JSON for content body
	my %json;
	$json{smsId}     = $sms;
	$json{recipient} = $tel;
	$json{message}   = AlertRelay::Message();;
	# Convert Perl hash to JSON
	my $json_text = to_json(\%json);
	# HTTP client
	my $ua = AlertRelay::UserAgent();
	# Execute Sipgate webhook
	my $request = POST "$url";
	$request->authorization_basic($id, $token);
	$request->header( 'Content-Type' => 'application/json', 'Content-Length' => length($json_text) );
	$request->content( $json_text );
	my $response = $ua->request($request);
	debug( "[SIPGATE] status_line : '".     $response->status_line ."'");
	debug( "[SIPGATE] decoded_content : '". $response->decoded_content ."'");
	if ($response->is_success) {
		send_as JSON => { ok => "Sipgate SMS sent successfully" };
	} else {
		response->status(500);
		send_as JSON => { error => "Sipgate SMS could not be sent!" };
	}
};