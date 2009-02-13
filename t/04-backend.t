#!/usr/bin/env perl -w
use strict;
use vars qw( $MAGICK_SKIP );
use Test;
use Cwd;

BEGIN {
   do 't/magick.pl' || die "Can not include t/magick.pl: $!";

   my %total = (
      magick => 2,
      gd     => 2,
      other  => 1,
   );

   my $total  = 0;
      $total += $total{$_} foreach keys %total;
   my $class = 'GD::SecurityImage';

   plan tests => $total;

   require GD::SecurityImage;

   eval { $class->new };
   ok($@); # if there is an error == OK [since we didn't import() so far]

   # test if we've loaded the right library
   gd();
   $MAGICK_SKIP ? skip_magick() : magick();
   exit;

   sub gd {
      $class->import( use_magick => 0        ); ok( $class->new->raw->isa('GD::Image'    ) );
      $class->import( backend    => 'GD'     ); ok( $class->new->raw->isa('GD::Image'    ) );
   }
   sub magick {
      $class->import( use_magick => 1        ); ok( $class->new->raw->isa('Image::Magick') );
      $class->import( backend    => 'Magick' ); ok( $class->new->raw->isa('Image::Magick') );
   }
   sub skip_magick {
      skip( $MAGICK_SKIP . " Skipping...", sub{1}) for 1..$total{magick};
   }
}
