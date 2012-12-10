package Nagios::Nrpe;

use Moo;
use Carp;
use YAML;
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

    my $nrpe = Nagios::Nrpe->new();

=cut


sub check
{
    # Usage: Accepts the built in check called and attempts to load it.
    # Params: $self
    #         $method - name of check sub.
    # Returns: Nothing.

    my $self = shift;
    my $method = lc ( shift ) // 'example';

    for my $key ( keys %{ $self->config->{check} } )
    {
        if ( $method eq $key )
        {
            $self->$method;
        }
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

    $self->exit_code( 0 );
    $self->exit_message( $message );
    $self->exit_stats( $stats );
    $self->exit;
};


sub exit_warning 
{
    # Usage: Sets default warning exit.
    # Params: $self
    # Returns: Sets up "warning" exit and calls exit.

    my $self = shift;
    my $message = shift // 'Unknown';
    my $stats   = shift // '';

    $self->exit_code( 1 );
    $self->exit_message( $message );
    $self->exit_stats( $stats );
    $self->exit;
};


sub exit_critical
{
    # Usage: Sets default critical exit.
    # Params: $self
    # Returns: Sets up "critical" exit and calls exit.

    my $self = shift;
    my $message = shift // 'Unknown';
    my $stats   = shift // '';

    $self->exit_code( 2 );
    $self->exit_message( $message );
    $self->exit_stats( $stats );
    $self->exit;
};


sub nagios_unknown
{
    # Usage: Sets default unknown exit.
    # Params: $self
    # Returns: Sets up "critical" exit and calls exit.

    my $self = shift;
    my $message = shift // 'Unknown';
    my $stats   = shift // '';

    $self->exit_code( 3 );
    $self->exit_message( $message );
    $self->exit_stats( $stats );
    $self->exit;
};


sub exit
{
    # Usage: Creates a valid exit state for a Nagios NRPE check. This should
    # be called on completion of a check.
    # Params: $self
    # Returns: exits program.

    my $self         = shift;
    
    chomp ( my $exit_code    = ( defined $self->exit_code ) 
            ? $self->exit_code : $self->exit_unknown );

    chomp ( my $exit_message = ( defined $self->exit_message )
            ? $self->exit_message : 'Unknown' );

    chomp ( my $exit_stats   = ( defined $self->exit_stats ) 
            ? $self->exit_stats : '' ); 


    print "$exit_message|$exit_stats\n";

    exit ( $exit_code );
};


sub load_config
{
    # Usage: Loads the config file.
    # Params: $self
    # Returns: $self->config

    my $self = shift;

    $self->config( YAML::LoadFile('config.yaml') );
};


sub load_logger
{
    # Usage: Inits the logger.
    # Params: $self
    # Returns: $self->log

    my $self    = shift;

    my $config  = ( $self->verbose ) ?
                  $self->config->{log4perl}->{verbose}
                  : ( ! $self->config->{log} ) ?
                  $self->config->{log4perl}->{disabled}
                  : $self->config->{log4perl}->{default};

    Log::Log4perl->init( \$config );

    my $logger = Log::Log4perl->get_logger();

    $self->log( $logger );
};


sub error
{
    # Usage: Standard error message handling call.
    # Params: $self
    # Returns: exits program.

    my $self = shift;
    chomp ( my $msg  = shift // 'Unknown error' );

    $self->log->error( $msg );
    $self->exit_message( $msg );
    $self->exit_code( $self->exit_critical );
    $self->exit;
};


sub info
{
    # Usage: Standard info message handling call.
    # Params: $self
    # Returns: nothing.

    my $self = shift;
    chomp ( my $msg  = shift // 'Unknown info' );
    
    $self->log->info( $msg );
};


sub debug
{
    # Usage: Standard debug message handling call.
    # Params: $self
    # Returns: nothing.

    my $self = shift;
    chomp ( my $msg  = shift // 'Unknown debug' );

    $self->log->debug( $msg );
};


sub default_verbose
{
    # Usage: Sets default verbose flag
    # Params: $self
    # Returns: $self->verbose

    my $self = shift;

    $self->verbose( 0 );
};


sub default_help
{
    # Usage: Sets default help flag
    # Params: $self
    # Returns: $self->help

    my $self = shift;

    $self->help( 0 );
};


has exit_code =>
(
    is  => 'rw',
    isa => sub {
                 die "$_[0]: not a number" if ( $_[0] !~ m/^\d+$/ );
               },
);


has exit_message =>
(
    is  => 'rw',
    isa => sub {
                 die "$_[0]: exit message is empty" if ( $_[0] !~ m/\w+/ );
               },
);


has exit_stats =>
(
    is  => 'rw',
    isa => sub {
                 die "$_[0]: stats is empty" if ( $_[0] !~ m/\w+/ );
               },
);


has config =>
(
    is      => 'rw',
    isa     => sub {
                     die "$_[0]: not a hashref" if ( ref( $_[0] ) ne 'HASH');
                   },
    default => \&load_config,
);


has log =>
(
    is      => 'rw',
    lazy    => 1,
    isa     => sub {
                     die "$_[0]: not a log4perl class" if ( !
                     $_[0]->isa('Log::Log4perl::Logger') );
                   },
    default => \&load_logger,
);


has verbose =>
(
    is      => 'rw',
    isa     => sub {
                 die "$_[0]: not a boolean" if ( $_[0] !~ m/^(0|1)$/ );
               },
    default => \&default_verbose,
);


has help =>
(
    is      => 'rw',
    isa     => sub {
                     die "$_[0]: not a boolean" if ( $_[0] !~ m/^(0|1)$/ );
               },
    default => \&default_help,
);


1;
