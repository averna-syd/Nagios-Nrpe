package Nagios::Nrpe::Check::Hostsfile;

use Carp;
use Moo::Role;


1;

__END__

=pod

=head1 NAME

Nagios::Nrpe::Check::Hostsfile

=head1 VERSION

version 0.001

=head1 SYNOPSIS

Checks the hosts file to ensure correctness. Generally only useful
if you've got a bucket load of stuff in your hosts file (why?!?).

Example usage:

    use Nagios::Nrpe;

    my $check = Nagios::Nrpe->new();
    $check->hosts_file;

=head1 NAME

Nagios::Nrpe::Check::Hostsfile - Linux hosts file syntax checker.

=head1 AUTHOR

Sarah Fuller <sarah@averna.id.au>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Sarah Fuller.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
