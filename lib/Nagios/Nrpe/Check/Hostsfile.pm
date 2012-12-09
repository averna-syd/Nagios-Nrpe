package Nagios::Nrpe::Check::Hostsfile;

use Carp;
use Moo::Role;

=head1 NAME

Nagios::Nrpe::Check::Hostsfile - Linux hosts file syntax checker.

=head1 SYNOPSIS

Checks the hosts file to ensure correctness. Generally only useful
if you've got a bucket load of stuff in your hosts file (why?!?).

Example usage:

    use Nagios::Nrpe;

    my $check = Nagios::Nrpe->new();
    $check->hosts_file;
=cut

1;
