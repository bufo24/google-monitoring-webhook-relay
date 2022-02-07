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

package AlertRelay::Test;
use Dancer2 appname => 'AlertRelay';
use LWP::UserAgent;
use HTTP::Request::Common;

our $VERSION = '1.0.0';

post '/test' => sub {
	my $msg = AlertRelay::Message();
	send_as JSON => { message => "$msg" };
};