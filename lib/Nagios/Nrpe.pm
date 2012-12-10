package Nagios::Nrpe;

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

    $self->exit_code( $self->ok );
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

    $self->exit_code( $self->warning );
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

    $self->exit_code( $self->critical );
    $self->exit_message( $message );
    $self->exit_stats( $stats );
    $self->exit;
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
    $self->exit;
};


sub exit
{
    # Usage: Creates a valid exit state for a Nagios NRPE check. This should
    # be called on completion of a check.
    # Params: $self
    # Returns: exits program.

    my $self = shift;
    
    chomp ( my $exit_code    = ( defined $self->exit_code ) 
            ? $self->exit_code : $self->unknown );

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
    # Returns: hashref

    my $self = shift;

    return YAML::LoadFile( $self->config_file );
};


sub load_logger
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
    # Returns: exits program.

    my $self = shift;
    chomp ( my $msg  = shift // 'Unknown error' );

    $self->log->error( $msg );
    $self->exit_message( $msg );
    $self->exit_code( $self->critical );
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


has ok =>
(
    is      => 'ro',
    isa     => sub {
                 die "$_[0]: nagios ok exit code is 0" if ( $_[0] ne '0' );
               },
    default => sub { return 0 },
);


has warning =>
(
    is      => 'ro',
    isa     => sub {
                 die "$_[0]: nagios warning exit code is 1" if ( $_[0] ne '1' );
               },
    default => sub { return 1 },
);


has critical =>
(
    is      => 'ro',
    isa     => sub {
                 die "$_[0]: nagios critical exit code is 2" if ( $_[0] ne '2' );
               },
    default => sub { return 2 },
);


has unknown =>
(
    is      => 'ro',
    isa     => sub {
                 die "$_[0]: nagios unknown exit code is 3" if ( $_[0] ne '3');
               },
    default => sub { return 3 },
);


has exit_code =>
(
    is  => 'rw',
    isa => sub {
                 die "$_[0]: invalid nagios exit code" if ( $_[0] !~ m/^(0|1|2|3)$/ );
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
    is      => 'ro',
    lazy    => 1,
    isa     => sub {
                     die "$_[0]: not a hashref" if ( ref( $_[0] ) ne 'HASH');
                   },
    default => \&load_config,
);


has config_file =>
(
    is      => 'ro',
    isa     => sub {
                 die "$_[0]: not a readable file" if ( ! -T $_[0] || ! -r $_[0] );
               },
    default => sub { return "$FindBin::Bin/../config.yaml" },
);


has log =>
(
    is      => 'ro',
    lazy    => 1,
    isa     => sub {
                     die "$_[0]: not a log4perl class" if ( !
                     $_[0]->isa('Log::Log4perl::Logger') );
                   },
    default => \&load_logger,
);


has verbose =>
(
    is      => 'ro',
    isa     => sub {
                 die "$_[0]: not a boolean" if ( $_[0] !~ m/^(0|1)$/ );
               },
    default => sub { return 0 },
);


has help =>
(
    is      => 'rw',
    isa     => sub {
                     die "$_[0]: not a boolean" if ( $_[0] !~ m/^(0|1)$/ );
               },
    default => sub { return 0 },
);


1;
