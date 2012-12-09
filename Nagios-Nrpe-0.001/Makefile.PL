
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A small framework for custom Nagios NRPE client side checks. \nThe main objective of these modules is to remove the repetitive boilerplate\nrequired when making client side NRPE checks without hopefully adding in too\nmany dependencies.",
  "AUTHOR" => "Sarah Fuller <sarah\@averna.id.au>",
  "BUILD_REQUIRES" => {
    "Test::More" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Nagios-Nrpe",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Nagios::Nrpe",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Moo" => 0,
    "Moo::Role" => 0
  },
  "VERSION" => "0.001",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



