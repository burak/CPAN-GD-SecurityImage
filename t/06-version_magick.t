#!/usr/bin/env perl -w
use strict;
use warnings;
use vars qw( $MAGICK_SKIP );
use Test::More;
use Cwd;
use Carp qw( croak );
use lib  qw( .. );
use constant TOTAL_TESTS => 13;

BEGIN {
   do 't/magick.pl' || croak "Can not include t/magick.pl: $!";

   plan tests => TOTAL_TESTS;

   SKIP: {
      if ( $MAGICK_SKIP ) {
         skip( $MAGICK_SKIP . ' Skipping...', TOTAL_TESTS );
      }
      require GD::SecurityImage;
      GD::SecurityImage->import( use_magick => 1 );
   }
}

exit if $MAGICK_SKIP;

my @gt_version_tests = ('6.0'  , '.0.0','6.1.2.3.4', undef);
my @lt_version_tests = ('6.4.3', '.4.3','6.1.2.3.4', undef);

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
   local $Image::Magick::VERSION = '6.0.3';
   ok( $i->_versiongt( '6.0'   ), 'GT 6.0'   );
   ok( $i->_versiongt( '6.0.3' ), 'GT 6.0.3' );
   ok( $i->_versionlt( '6.2'   ), 'LT 6.2'   );
   ok( $i->_versionlt( '6.2.6' ), 'LT 6.2.6' );
   ok( $i->_versiongt( '7.0.3' ) == 0, 'GT 7.0.3' );
}
