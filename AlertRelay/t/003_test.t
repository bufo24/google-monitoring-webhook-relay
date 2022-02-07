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


use strict;
use warnings;

use AlertRelay;
use AlertRelay::Test;
use Test::More tests => 3; # Change to planned tests
use Plack::Test;
use HTTP::Request::Common;
use Ref::Util qw<is_coderef>;

# Get API key
my $key = $ENV{'API_KEY'} || '';

# 1:
my $app = AlertRelay::Test->to_app;
ok( is_coderef($app), 'Got app' );

# 2: /test » 200
my $test = Plack::Test->create($app);
my $header = ['Content-Type' => 'application/json; charset=UTF-8'];
my $data = qq ~
{
    "incident": {
      "incident_id": "f2e08c333dc64cb09f75eaab355393bz",
      "resource_name": "Test with labels {project_id=project-id, host=hostname.local} can be ignored!!!",
      "state": "test",
      "policy_name": "CI/CD Test",
      "condition_name": "Test for CI/CD",
      "url": "https://github.com/Cyclenerd/google-monitoring-webhook-relay",
      "summary": "Can be ignored!"
    },
    "version": 1.1
}
~;
my $request = POST "/test?key=$key";
$request->header( 'Content-Type' => 'application/json', 'Content-Length' => length($data) );
$request->content( $data );
my $res = $test->request($request);
ok( $res->is_success, '[POST /test] successful [200]' );

# 3: /test » 400 (JSON missing)
$res  = $test->request( POST "/test?key=$key" );
ok( $res->status_line =~ /^400/, '[POST /test] error 400 test successful' );
