#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;
use Nagios::Nrpe;

my $nrpe = Nagios::Nrpe->new( verbose => 1 );
#$nrpe->info('stuff');
#$nrpe->check('example');

print Dumper ( $nrpe );
#print $check->command->{verbose} . "\n";

#$nrpe->exit_message('Something');
#$nrpe->exit_stats('stat=123;');
#$nrpe->exit_code( $nrpe->exit_ok );
$nrpe->error('OPPS!');
