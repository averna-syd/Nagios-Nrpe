package Nagios::Nrpe;

use strict;
use warnings;

use Moo;
use Carp;
use YAML;
use FindBin;
use Log::Log4perl;
use Log::Dispatch::Syslog;

with(
        'Nagios::Nrpe::Check::Example',
        'Nagios::Nrpe::Check::Hostsfile',
    );

=head1 NAME

Nagios::Nrpe

=head 1 ABSTRACT

A small framework for custom Nagios NRPE client side checks. 
The main objective of these modules is to remove the repetitive boilerplate
required when making client side NRPE checks without hopefully adding in too
many dependencies.

=head1 SYNOPSIS

Allows the creation of custom Nagios client side NRPE checks.

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


    # List built-in checks.
    # These NRPE checks are available for use.

    $nrpe->check_list;


    # Built-in check.
    # Call a built-in check by name "example".
    # Built-ins should take it from here and exit 
    # the program how one would expect a nagios check 
    # to work.

    $nrpe->check( 'example' );


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

    $nrpe->exit_ok( 'Looks good', 'stat1=123;stat2=321' );


    # Exit WARNING
    # Pass human readable message and then nagios stats (if any).
    # This call will exit the program with the desired exit code.

    $nrpe->exit_warning( 'Looks interesting', 'stat1=123;stat2=321' );


    # Exit CRITICAL
    # Pass human readable message and then nagios stats (if any).
    # This call will exit the program with the desired exit code.

    $nrpe->exit_critical( 'oh god, oh god, we're all going to die',
                         'stat1=123;stat2=321' );


    # Exit UNKNOWN
    # Pass human readable message and then nagios stats (if any).
    # This call will exit the program with the desired exit code.

    $nrpe->exit_critical( 'I donno lol!' );


=cut


sub check_list
{
    # Usage: Prints out available built-in checks.
    # Params: $self
    # Returns: Nothing.

    my $self = shift;

    $self->info('Generating built-in check list.');

    map { print 'check: ' . $_ . "\n" } ( keys %{ $self->config->{check} } );

    $self->exit_ok( 'Check list complete.' );
};


sub check
{
    # Usage: Accepts the built-in check called and attempts to load it.
    # Params: $self
    #         $check - name of check sub.
    # Returns: Nothing.

    my $self  = shift;
    my $check = lc ( shift ) // 'example';

    $self->info( 'Attempting to run check: ' . $check );

    for my $key ( keys %{ $self->config->{check} } )
    {
        $self->$check if ( $check eq $key );
    }

    $self->error( 'Check not found.' );
};


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
    # Usage: Creates a valid exit state for a Nagios NRPE check. This should
    # be called on completion of a check.
    # Params: $self
    # Returns: exits program.

    my $self = shift;

    chomp ( my $code    = ( defined $self->exit_code ) 
            ? $self->exit_code : $self->unknown );

    chomp ( my $message = ( defined $self->exit_message )
            ? $self->exit_message : 'Unknown' );

    chomp ( my $stats   = ( defined $self->exit_stats ) 
            ? $self->exit_stats : '' ); 


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

    my $config  = ( $self->verbose ) ?
                    $self->config->{log4perl}->{verbose}
                  : ( ! $self->config->{log} ) ?
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

    $self->log->error( $message );
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
    
    $self->log->info( $message );
};


sub debug
{
    # Usage: Standard debug message handling call.
    # Params: $self
    #         $message - message string for output.
    # Returns: nothing.

    my $self = shift;
    chomp ( my $message = shift // 'Unknown debug' );

    $self->log->debug( $message );
};


has ok =>
(
    is      => 'ro',
    isa     => sub {
                     croak "$_[0]: nagios ok exit code is 0"
                     if ( $_[0] ne '0' );
                   },
    default => sub { return 0 },
);


has warning =>
(
    is      => 'ro',
    isa     => sub {
                     croak "$_[0]: nagios warning exit code is 1"
                     if ( $_[0] ne '1' );
                   },
    default => sub { return 1 },
);


has critical =>
(
    is      => 'ro',
    isa     => sub {
                     croak "$_[0]: nagios critical exit code is 2"
                     if ( $_[0] ne '2' );
                   },
    default => sub { return 2 },
);


has unknown =>
(
    is      => 'ro',
    isa     => sub {
                     croak "$_[0]: nagios unknown exit code is 3"
                     if ( $_[0] ne '3');
                   },
    default => sub { return 3 },
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
    default => sub { return "$FindBin::Bin/../config.yaml" },
);


has log =>
(
    is      => 'ro',
    lazy    => 1,
    isa     => sub {
                     croak "$_[0]: not a log4perl class" 
                     if ( ! $_[0]->isa('Log::Log4perl::Logger') );
                   },
    default => \&_load_logger,
);


has verbose =>
(
    is      => 'ro',
    isa     => sub {
                 croak "$_[0]: not a boolean" 
                 if ( $_[0] !~ m/ ^ (?:0|1) $/xms );
               },
    default => sub { return 0 },
);


has help =>
(
    is      => 'rw',
    isa     => sub {
                     croak "$_[0]: not a boolean"
                     if ( $_[0] !~ m/ ^ (?:0|1) $ /xms );
               },
    default => sub { return 0 },
);


1;
