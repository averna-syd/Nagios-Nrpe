use Test::More tests => 7;

BEGIN { use_ok( 'Nagios::Nrpe' ); }

my $object = Nagios::Nrpe->new ();
isa_ok ($object, 'Nagios::Nrpe');

$stdout=qx{ perl -Ilib -e "use Nagios::Nrpe; Nagios::Nrpe->new( exit_code =>
Nagios::Nrpe->new->exit_ok )->exit;" };
$exit=$? >> 8;
is ($exit, '0', "Ok exit");

$stdout=qx{ perl -Ilib -e "use Nagios::Nrpe; Nagios::Nrpe->new( exit_code =>
Nagios::Nrpe->new->exit_warning )->exit;" };
$exit=$? >> 8;
is ($exit, '1', "Warning exit");

$stdout=qx{ perl -Ilib -e "use Nagios::Nrpe; Nagios::Nrpe->new( exit_code =>
Nagios::Nrpe->new->exit_critical )->exit;" };
$exit=$? >> 8;
is ($exit, '2', "Critical exit");

$stdout=qx{ perl -Ilib -e "use Nagios::Nrpe; Nagios::Nrpe->new( exit_code =>
Nagios::Nrpe->new->exit_unknown )->exit;" };
$exit=$? >> 8;
is ($exit, '3', "Unknown exit");

$stdout=qx{ perl -Ilib -e "use Nagios::Nrpe; Nagios::Nrpe->new()->exit;" };
$exit=$? >> 8;
is ($exit, '3', "Default exit");

