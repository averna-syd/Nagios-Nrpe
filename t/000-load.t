use Test::More tests => 3;
use FindBin qw($Bin);

BEGIN { use_ok 'Nagios::Nrpe'; };

$stdout=qx{  perlcritic -verbose 1 --cruel $Bin/../lib/Nagios/Nrpe.pm };
$exit=$? >> 8;
is ($exit, '0', "Perl Critic (cruel) Nagios::Nrpe");

$stdout=qx{  perlcritic -verbose 1 --cruel $Bin/../bin/nagios_nrpe.pl };
$exit=$? >> 8;
is ($exit, '0', "Perl Critic (cruel) nagios_nrpe.pl");

