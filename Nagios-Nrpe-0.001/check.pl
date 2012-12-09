#!/usr/bin/env perl

use warnings;
use strict;
use lib './lib';
use Data::Dumper;
use Nagios::Nrpe;

my $check = Nagios::Nrpe->new( );

#$check->yum;

print Dumper ( $check );
#print $check->command->{verbose} . "\n";

#$check->exit_message('Something');
#$check->exit_stats('stat=123;');
#$check->exit_code( $check->exit_warning );
#$check->exit;

