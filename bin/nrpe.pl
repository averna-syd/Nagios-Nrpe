#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Nagios::Nrpe;
use Getopt::Long;

# debug
#use Data::Dumper;

my $opts = { verbose => 0 };
GetOptions( $opts, 'check|c=s', 'check-list|l', 'verbose|v', 'help|h', 'man|m' );
my $nrpe = Nagios::Nrpe->new( verbose => $opts->{verbose} );

( $opts->{'check-list'} ) ? $nrpe->check_list
: ( $opts->{check} )      ? $nrpe->check( $opts->{check} )
: ( $opts->{man} )        ? print "man\n"
: print "help\n";

