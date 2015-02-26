#!/usr/bin/env perl -w
use strict;
use warnings;
use Test::More;
use Cwd;
use GD::SecurityImage;

plan tests => 8;

my @gt_version_tests = ('2.0', undef);
my @lt_version_tests = ('3.0', undef);

my $i = GD::SecurityImage->new;

GT0: {
  my $c = 0;

  for my $ver (@gt_version_tests) {
    my $gt = $i->_versiongt($ver);

    ok( defined $gt, "GT defined [$c]" );
    $c++;
  }
}

LT0: {
  my $c = 0;

  for my $ver (@lt_version_tests) {
    my $lt = $i->_versionlt($ver);

    ok( defined $lt, "LT defined [$c]" );
    $c++;
  }
}

GT1: {
   local $GD::VERSION = '1.19';
   ok( $i->_versiongt('1.18'), 'GT 1.18' );
   ok( $i->_versiongt('1.19'), 'ok. _versiongt() if greater or equal to 1.19' );
   ok( $i->_versionlt('3.0' ), 'but this means "smaller than"' );

   is( $i->_versiongt('2.0'), 0,
       "ok. _versiongt() if isn't greater than to 2.00" );
}
