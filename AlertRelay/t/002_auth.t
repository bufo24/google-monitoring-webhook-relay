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
use Test::More tests => 3; # Change to planned tests
use Plack::Test;
use HTTP::Request::Common;
use Ref::Util qw<is_coderef>;

# Get API key
my $key = $ENV{'API_KEY'} || '';

# 1:
my $app = AlertRelay->to_app;
ok( is_coderef($app), 'Got app' );

# 2: / » 403
my $test = Plack::Test->create($app);
my $res  = $test->request( GET "/?key=WRONGKEY" );
ok( $res->status_line =~ /^403/, '[GET /] error 403 test successful' );

# 3: / » 200
$res  = $test->request( GET "/?key=$key" );
ok( $res->is_success, '[GET /] successful [200]' );