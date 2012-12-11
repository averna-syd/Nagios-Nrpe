package Nagios::Nrpe;

use strict;
use warnings;

use Moo;
use Carp;
use YAML;
use FindBin qw($Bin);
use autodie qw< :io >;
use Log::Log4perl;
use Log::Dispatch::Syslog;
use English qw( -no_match_vars ) ;

our $VERSION  = '0.001';

## no critic (return)
## no critic (POD)
## no critic (Quotes)


sub exit_ok
{
    # Usage: Sets default ok exit.
    # Params: $self
    # Returns: Sets up "ok" exit and calls exit.

    my $self    = shift;
    my $message = shift // 'Unknown';
    my $stats   = shift // '';

    $self->exit_code( $self->ok );
    $self->exit_message( $message );
    $self->exit_stats( $stats );
    $self->_exit;
};


sub exit_warning 
{
    # Usage: Sets default warning exit.
    # Params: $self
    # Returns: Sets up "warning" exit and calls exit.

    my $self = shift;
    my $message = shift // 'Unknown';
    my $stats   = shift // '';

    $self->exit_code( $self->warning );
    $self->exit_message( $message );
    $self->exit_stats( $stats );
    $self->_exit;
};


sub exit_critical
{
    # Usage: Sets default critical exit.
    # Params: $self
    # Returns: Sets up "critical" exit and calls exit.

    my $self = shift;
    my $message = shift // 'Unknown';
    my $stats   = shift // '';

    $self->exit_code( $self->critical );
    $self->exit_message( $message );
    $self->exit_stats( $stats );
    $self->_exit;
};


sub exit_unknown
{
    # Usage: Sets default unknown exit.
    # Params: $self
    # Returns: Sets up "unknown" exit and calls exit.

    my $self = shift;
    my $message = shift // 'Unknown';
    my $stats   = shift // '';

    $self->exit_code( $self->unknown );
    $self->exit_message( $message );
    $self->exit_stats( $stats );
    $self->_exit;
};


sub _exit
{
    # Usage: Creates a valid exit state for a NAGIOS NRPE check. This should
    # be called on completion of a check.
    # Params: $self
    # Returns: exits program.

    my $self = shift;

    chomp ( my $code    = ( defined $self->exit_code ) 
            ? $self->exit_code 
            : $self->unknown
          );

    chomp ( my $message = ( defined $self->exit_message )
            ? $self->exit_message 
            : 'Unknown'
          );

    chomp ( my $stats   = ( defined $self->exit_stats ) 
            ? $self->exit_stats 
            : ''
          ); 


    print ( ( $stats =~ m/\w+/xmsi ) ? "$message|$stats\n" : "$message\n" );

    exit ( $code );
};


sub _load_config
{
    # Usage: Loads the config file.
    # Params: $self
    # Returns: hashref

    my $self = shift;

    return YAML::LoadFile( $self->config_file );
};


sub _load_logger
{
    # Usage: Inits the logger.
    # Params: $self
    # Returns: blessed ref

    my $self    = shift;

    my $config  = ( $self->verbose && $self->log ) ?
                   $self->config->{log4perl}->{verbose}
                  : ( ! $self->log && $self->verbose ) ?
                    $self->config->{log4perl}->{stdout}
                  : ( ! $self->log ) ?
                    $self->config->{log4perl}->{disabled}
                  : $self->config->{log4perl}->{default};

    Log::Log4perl->init( \$config );

    my $logger = Log::Log4perl->get_logger();

    return $logger;
};


sub error
{
    # Usage: Standard error message handling call.
    # Params: $self
    #         $message - message string for output.
    # Returns: exits program.

    my $self = shift;
    chomp ( my $message = shift // 'Unknown error' );

    $self->logger->error( $message );
    $self->exit_message( $message );
    $self->exit_code( $self->critical );
    $self->_exit;
};


sub info
{
    # Usage: Standard info message handling call.
    # Params: $self
    #         $message - message string for output.
    # Returns: nothing.

    my $self = shift;
    chomp ( my $message = shift // 'Unknown info' );
    
    $self->logger->info( $message );
};


sub debug
{
    # Usage: Standard debug message handling call.
    # Params: $self
    #         $message - message string for output.
    # Returns: nothing.

    my $self = shift;
    chomp ( my $message = shift // 'Unknown debug' );

    $self->logger->debug( $message );
};


sub generate_check
{
    # Usage: Generates a new NAGIOS NRPE check.
    # Params: $self
    #         $check_name - Internal, holds check name.
    #         $template   - Internal, holds check template.
    #         $check_path - Internal, holds path to new check file.
    # Returns: nothing.

    my $self       = shift;
    my $check_name = $self->check_name . '.pl';
    my $template   = $self->config->{template};
    my $check_path = $self->check_path . '/' . $check_name;

    $template   =~ s/\[\%\s+checkname\s+\%\]/$check_name/xmsgi;

    croak "File $check_path already exists" if ( -e $check_path );

    open ( my $fh, '>',  $check_path )
    || croak "Failed to create check $check_path $ERRNO";

        print {$fh} $template;

    close ( $fh );

    return;
};


has ok =>
(
    is      => 'ro',
    isa     => sub {
                     croak "$_[0]: nagios ok exit code is 0"
                     if ( $_[0] ne '0' );
                   },
    default => sub { return $_[0]->config->{nagios}->{ok} },
);


has warning =>
(
    is      => 'ro',
    isa     => sub {
                     croak "$_[0]: nagios warning exit code is 1"
                     if ( $_[0] ne '1' );
                   },
    default => sub { return $_[0]->config->{nagios}->{warning} },
);


has critical =>
(
    is      => 'ro',
    isa     => sub {
                     croak "$_[0]: nagios critical exit code is 2"
                     if ( $_[0] ne '2' );
                   },
    default => sub { return $_[0]->config->{nagios}->{critical} },
);


has unknown =>
(
    is      => 'ro',
    isa     => sub {
                     croak "$_[0]: nagios unknown exit code is 3"
                     if ( $_[0] ne '3');
                   },
    default => sub { return $_[0]->config->{nagios}->{unknown} },
);


has exit_code =>
(
    is  => 'rw',
    isa => sub {
                 croak "$_[0]: invalid nagios exit code"
                 if ( $_[0] !~ m/ ^ (?:0|1|2|3) $ /xms );
               },
);


has exit_message =>
(
    is  => 'rw',
    isa => sub {
                 croak "$_[0]: exit message is empty"
                 if ( $_[0] !~ m/\w+/xms );
               },
);


has exit_stats =>
(
    is  => 'rw',
    isa => sub {
                 croak "$_[0]: stats is undef"
                 if ( ! defined $_[0] );
               },
);


has config =>
(
    is      => 'ro',
    lazy    => 1,
    isa     => sub {
                     croak "$_[0]: not a hashref"
                     if ( ref( $_[0] ) ne 'HASH');
                   },
    default => \&_load_config,
);


has config_file =>
(
    is      => 'ro',
    isa     => sub {
                     croak "$_[0]: not a readable file"
                     if ( ! -T $_[0] || ! -r $_[0] );
                   },
    default => sub { ( -e "$Bin/../config.yaml" ) ? "$Bin/../config.yaml"
                                                  : "$Bin/config.yaml" 
                   },
);


has logger =>
(
    is      => 'ro',
    lazy    => 1,
    isa     => sub {
                     croak "$_[0]: not a log4perl class" 
                     if ( ! $_[0]->isa('Log::Log4perl::Logger') );
                   },
    default => \&_load_logger,
);


has log =>
(
    is      => 'ro',
    isa     => sub {
                     croak "$_[0]: not a boolean"
                     if ( $_[0] !~ m/ ^ (?:0|1) $/xms );
                   },
    default => sub { return $_[0]->config->{log} },
);


has verbose =>
(
    is      => 'ro',
    isa     => sub {
                 croak "$_[0]: not a boolean" 
                 if ( $_[0] !~ m/ ^ (?:0|1) $/xms );
               },
    default => sub { return $_[0]->config->{verbose} },
);


has check_name =>
(
    is   => 'ro',
    lazy => 1,
    isa  => sub {
                 croak "$_[0]: invalid check name"
                 if ( $_[0] !~ m/ ^ \w+ $ /xms );
               },
);


has check_path =>
(
    is   => 'ro',
    lazy => 1,
    isa  => sub { croak "$_[0]: directory does not exist or can't write to"
                        . " directory" if ( ! -d $_[0] || ! -w $_[0] );
                },
);


1;


__END__

=pod

=head1 NAME

Nagios::Nrpe - Small framework for creating & using custom NAGIOS NRPE checks.

=head1 VERSION

version 0.001

=head 1 DESCRIPTION

The main objective of this module is to allow one to rapidly create and use
new custom NAGIOS NRPE checks. This is done in two ways.

Firstly, this module allows one to create new check scripts on the fly.

Secondly, the module gives the user a number of necessary and/or commonly 
found features one might use in NRPE checks. Thus removing much of the
repetitive boilerplate when creating new checks.

Hopefully this is achieved in such a way as to avoid too many 
dependencies. 

Finally, this over-engineered bit of code to solve a very small problem
was dreamt up out of boredom and a desire to have consistent ad hoc NAGIOS 
NRPE scripts. More effort to setup than value added?

=head1 SYNOPSIS

Allows the creation of custom NAGIOS NRPE checks.

Example usage:

    use Nagios::Nrpe;

    # Standard call.
    # Assuming the log flag is turned on within the yaml config
    # file, all log messages will be logged to syslog.

    my $nrpe = Nagios::Nrpe->new();


    # Verbose call.
    # Overides the log flag within the yaml config
    # file and logs messages syslog.
    # Also, causes all logging to be printed to stdout.

    my $nrpe = Nagios::Nrpe->new( verbose => 1, );


    # Log info message.
    # If verbose is on will print to stdout.

    $nrpe->info( 'Insert info message here.' );


    # Log debug message.
    # If verbose is on will print to stdout.

    $nrpe->debug( 'Insert debug message here.' );
    

    # Log error message.
    # If verbose is on will print to stdout.
    # NOTE: An error message call will cause the program to exit with a
    # critical nagios exit code.

    $nrpe->error( 'Not working, oh noes!' );


    # Exit OK
    # Pass human readable message and then nagios stats (if any).
    # This call will exit the program with the desired exit code.

    $nrpe->exit_ok( 'Looks good', 'stat1=123;stat2=321;' );


    # Exit WARNING
    # Pass human readable message and then nagios stats (if any).
    # This call will exit the program with the desired exit code.

    $nrpe->exit_warning( 'Looks interesting', 'stat1=123;stat2=321;' );


    # Exit CRITICAL
    # Pass human readable message and then nagios stats (if any).
    # This call will exit the program with the desired exit code.

    $nrpe->exit_critical( 'oh god, oh god, we're all going to die',
                         'stat1=123;stat2=321;' );


    # Exit UNKNOWN
    # Pass human readable message and then nagios stats (if any).
    # This call will exit the program with the desired exit code.

    $nrpe->exit_critical( 'I donno lol!' );

=head1 AUTHOR

Sarah Fuller <sarah@averna.id.au>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Sarah Fuller.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
