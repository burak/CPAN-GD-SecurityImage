#!/usr/bin/env perl -w
use strict;
use warnings;
use vars qw( %API %API_IT $MAGICK_SKIP );
use Test::More;
use Cwd;
use Carp qw(croak);
use lib qw(
   ..
   ../t/lib
      t/lib
);

BEGIN {
   do 't/magick.pl' || croak "Can not include t/magick.pl: $!";

   %API = (
      magick                          => 7,
      magick_scramble                 => 7,
      magick_scramble_fixed           => 7,
      magick_info_text                => 7,
      magick_scramble_info_text       => 7,
      magick_scramble_fixed_info_text => 7,
   );

   %API_IT = (
     magick_scramble_info_text => 4,
    );

   my $total  = 0;
      $total += $API{$_} foreach keys %API;
      $total += $API_IT{$_} foreach keys %API_IT;

   plan tests => $total;

 SKIP: {
     if ( $MAGICK_SKIP ) {
       skip( $MAGICK_SKIP . ' Skipping...', $total );
     }
     require GD::SecurityImage;
     GD::SecurityImage->import( use_magick => 1 );
   }
   exit if $MAGICK_SKIP;
}

use Test::GDSI;

my $class = 'GD::SecurityImage';
my $tapi =  'Test::GDSI';
   $tapi->clear;

my $font = getcwd.'/StayPuft.ttf';

my %info_text = (
   text   => $tapi->the_info_text,
   ptsize => 12,
   color  => '#000000',
   scolor => '#FFFFFF',
);

my @info_text_positions = (
  {x => 'left',  y => 'up',   strip => 0, scolor => ''},
  {x => 'left',  y => 'down', strip => 1, scolor => '#FF0000'},
  {x => 'right', y => 'down', strip => 1, scolor => '#00FF00'},
  {x => 'right', y => 'up',   strip => 1, scolor => '#0000FF'},
);

# test styles
foreach my $api (keys %API) {
   $tapi->options(args($api), extra($api));
   my $c = 1;
   foreach my $style ($tapi->styles) {
      ok(
         $tapi->save(
            $api->$style()->out(
               force    => 'png',
               compress => 1,
            ),
            $style,
            $api,
            $c++
         ),
         "$style - $api - $c++"
      );
   }
   $tapi->clear;
}

# test info text positioning
for my $api (keys %API_IT) {
  my $c = 1;
   foreach my $info (@info_text_positions) {
     $tapi->options(args($api), (extra($api, $info)));
      ok(
         $tapi->save(
            $api->ec->out(
               force    => 'png',
               compress => 1,
            ),
            join('_', @{$info}{qw/x y/}),
            $api,
            $c++
         ),
         "text_info position - $api - $c++"
      );
   }
   $tapi->clear;
}

sub extra {
   my $name = shift;
   my $it_opts = shift || {};

   if ( $name =~ m{ _info_text \z }xms ) {
     return info_text => { %info_text, %{$it_opts} };
   }
   return +();
}

sub args {
   my $name = shift;
   my %options = (
      magick => {
         width      => 250,
         height     => 80,
         send_ctobg => 1,
         font       => $font,
         ptsize     => 50,
      },
      magick_scramble => {
         width      => 350,
         height     => 80,
         send_ctobg => 1,
         font       => $font,
         ptsize     => 30,
         scramble   => 1,
      },
      magick_scramble_fixed => {
         width      => 350,
         height     => 80,
         send_ctobg => 1,
         font       => $font,
         ptsize     => 30,
         scramble   => 1,
         angle      => 32,
      },
   );
   my $o = $options{$name};
   if ( not $o ) {
     (my $tmp = $name) =~ s{ _info_text }{}xms;
      $o = $options{$tmp};
   }
   croak "Bogus arg name $name!" if not $o;
   return %{ $o }
}
