use Test::More tests => 3;

BEGIN { use_ok 'Nagios::Nrpe'; };
BEGIN { use_ok 'Nagios::Nrpe::Check::Example'; }
BEGIN { use_ok 'Nagios::Nrpe::Check::Hostsfile'; };
