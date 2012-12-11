#!/usr/bin/env perl

use strict;
use warnings;

use Cwd;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Nagios::Nrpe;
use Getopt::Long;
use Pod::Usage;

# debug
use Data::Dumper;

my $opts = { verbose => 0, 'check-path' => getcwd };
GetOptions( $opts, 'check-name|n=s', 'check-path|p', 'verbose|v', 'help|h', 'man|m' );

exit pod2usage(1) if ( ! $opts->{'check-name'} );

my $nrpe = Nagios::Nrpe->new( check_name => $opts->{'check-name'}, 
                              check_path => $opts->{'check-path'},
                              verbose    => $opts->{verbose}, 
                            );

$nrpe->generate_check;

#my $nrpe = Nagios::Nrpe->new();
#print Dumper ( $nrpe->config );
#( $opts->{'check-list'} ) ? $nrpe->check_list
#: ( $opts->{check} )      ? $nrpe->check( $opts->{check} )
#: ( $opts->{man} )        ? print "man\n"
#: print "help\n";

__END__

=head1 NAME

B<nagios_nrpe.pl> - A small framework for creating custom Nagios NRPE client
side checks.

=head1 SYNOPSIS

 nagios_nrpe.pl -n yum_upadate_notify

=head1 OPTIONS

=over 8

=item B<-n, --check-name>
 The name of the nagios NRPE check script to be created.

=item B<-p, --check-path>
 The path where NRPE check scipt is created. Default is current working
 directory.

=item B<-v, --verbose>
 Prints the error(s) found.

=item B<-h, --help>
 Prints a brief help message.

=item B<-m, --man>
 Prints the full manual page.

=back

=head1 DESCRIPTION

Something, something darkside.

=head1 AUTHOR

    Sarah Fuller, C<< <sarah.fuller at uts.edu.au> >>

=cut
