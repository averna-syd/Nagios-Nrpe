package Nagios::Nrpe::Check::Example;

use Moo::Role;
use Carp;

=head1 NAME

Nagios::Nrpe::Check::Example

=head 1 ABSTRACT

A small framework for custom Nagios NRPE client side checks. 
The main objective of these modules is to remove the repetitive boilerplate
required when making client side NRPE checks without hopefully adding in too
many dependencies.

=head1 SYNOPSIS

Allows the creation of custom Nagios client side NRPE checks.

Example usage:

    use Nagios::Nrpe;

    my $nrpe = Nagios::Nrpe->new();

=cut


sub example
{
    my $self = shift;

    $self->info('Loaded example NRPE check.');

    # Something useful that checks something goes here.

    $self->exit_ok('OK', 'example=123;example2=123;');
};


1;
