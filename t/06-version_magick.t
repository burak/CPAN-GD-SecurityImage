#!/usr/bin/env perl -w
use strict;
use vars qw( $MAGICK_SKIP );
use Test;
use Cwd;

BEGIN {
   do 't/magick.pl' || die "Can not include t/magick.pl: $!";

   my $TOTAL = 6;
   plan tests => $TOTAL;

   if ( $MAGICK_SKIP ) {
      skip( $MAGICK_SKIP . " Skipping...", sub{1}) for 1..$TOTAL;
      exit;
   }
   else {
      require GD::SecurityImage;
      GD::SecurityImage->import( use_magick => 1 );
   }
}

my $i = GD::SecurityImage->new;

my $gt = $i->_versiongt(6.0);
my $lt = $i->_versionlt('6.4.3');
ok( defined $gt );
ok( defined $lt );

GT: {
   local $Image::Magick::VERSION = '6.0.3';
   ok( $i->_versiongt(  6.0    ) );
   ok( $i->_versiongt( '6.0.3' ) );
   ok( $i->_versionlt(  6.2    ) );
   ok( $i->_versionlt( '6.2.6' ) );
}
