#!/usr/bin/env perl -w
use strict;
BEGIN { do 't/skip.test' or die "Can't include skip.test!" }

eval "use Test::Pod::Coverage;1";

if ( $@ ) {
   plan skip_all => "Test::Pod::Coverage required for testing pod coverage";
}
else {
   plan tests => 1;
   # cheat a little
   pod_coverage_ok(
      'GD::SecurityImage',
      {
         trustme => [
            qw(
               add_strip
               cconvert
               gdf
               h2r
               is_hex
               r2h
               random_angle
            )
         ]
      }
   );
}
