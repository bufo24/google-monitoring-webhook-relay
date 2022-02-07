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

package AlertRelay;
use Dancer2;
use LWP::UserAgent;

our $VERSION = '1.0.0';

# HTTP client
sub UserAgent {
	my $ua = LWP::UserAgent->new();
	$ua->agent('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:96.0) Gecko/20100101 Firefox/96.0');
	$ua->timeout("15"); # timeout value in seconds
	return $ua;
}

# Read request body (JSON) content
sub Message {
	my $msg = 'message missing';
	my $request_body = request->body || '';
	debug( "[REQUEST] body : '$request_body'" );
	if ($request_body ) {
		my $json = decode_json( $request_body );
		# Read Google Monitoring JSON message
		if ($json->{incident}) {
			my $incident_id    = $json->{incident}->{incident_id}    || '';
			my $resource_id    = $json->{incident}->{resource_id}    || '';
			my $resource_name  = $json->{incident}->{resource_name}  || '';
			my $state          = $json->{incident}->{state}          || '???';
			my $policy_name    = $json->{incident}->{policy_name}    || '';
			my $condition_name = $json->{incident}->{condition_name} || '';
			my $url            = $json->{incident}->{url}            || '';
			my $summary        = $json->{incident}->{summary}        || '';
			# Edit values
			$state          = uc $state; 
			$policy_name    =~ s/\{/\[/g;
			$policy_name    =~ s/\}/\]/g;
			$resource_name  =~ s/\{/\[/g;
			$resource_name  =~ s/\}/\]/g;
			$condition_name =~ s/\{/\[/g;
			$condition_name =~ s/\}/\]/g;
			$summary        =~ s/\{/\[/g;
			$summary        =~ s/\}/\]/g;
			# Icon
			my $icon = '➡️';
			$icon = '🔥' if $state eq 'OPEN';
			$icon = '✅' if $state eq 'CLOSED';
			$icon = '🔕' if $state eq 'TEST';
			# Message
			$msg = "$icon [$state] $policy_name";
			$msg .= " » resource = $resource_name" if ($resource_name);
			$msg .= " » condition = $condition_name" if ($condition_name);
			$msg .= " » summary = $summary" if ($summary);
			$msg .= " » url = $url" if ($url);
		}
	} else {
		response->status(400);
		send_as JSON => { error => "JSON missing" };
	}
	return $msg;
};

# AUTHENTICATION
hook before_request => sub {
	my $key     = param('key')    || '';
	my $api_key = $ENV{'API_KEY'} || '';
	debug( "[PARAM] key : '$key'" );
	debug( "[ENV] API_KEY : '$api_key'");
	if ( $api_key && $key eq $api_key ) {
		return;
	} else {
		response->status(403);
		send_as JSON => { error => "API key" };
	}
};

prefix undef;

# Root
get '/' => sub {
	send_as JSON => { version => "$VERSION" };
};
