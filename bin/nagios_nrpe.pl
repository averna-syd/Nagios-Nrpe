#!/usr/bin/env perl

use strict;
use warnings;

use Cwd;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Nagios::Nrpe;
use Getopt::Long;
use Pod::Usage;

our $VERSION  = '0.001';

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


__END__

=pod

=head1 NAME

B<nagios_nrpe.pl> - Create custom Nagios NRPE client checks on the fly.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

 nagios_nrpe.pl -n example_check

=head1 DESCRIPTION

Something, something darkside.

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

=head1 AUTHOR

Sarah Fuller <sarah@averna.id.au>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Sarah Fuller.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

