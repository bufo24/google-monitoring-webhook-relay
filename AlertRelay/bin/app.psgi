#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use AlertRelay;
use AlertRelay::Discord;
use AlertRelay::Pushover;
use AlertRelay::Sipgate;
use AlertRelay::Teams;
use AlertRelay::Test;

AlertRelay->to_app;
AlertRelay::Discord->to_app;
AlertRelay::Pushover->to_app;
AlertRelay::Sipgate->to_app;
AlertRelay::Teams->to_app;
AlertRelay::Test->to_app;
