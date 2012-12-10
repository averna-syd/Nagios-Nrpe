#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;
use Nagios::Nrpe;

my $nrpe = Nagios::Nrpe->new( verbose => 1 );
$nrpe->log->info('stuff');
#$check->yum;

#print Dumper ( $nrpe );
#print $check->command->{verbose} . "\n";

#$check->exit_message('Something');
#$check->exit_stats('stat=123;');
#$check->exit_code( $check->exit_warning );
#$check->exit;

