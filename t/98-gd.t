#!/usr/bin/env perl -w
use strict;
use warnings;
use vars qw( %API %API_IT );
use Test::More;
use Cwd;
use Carp qw(croak);
use lib qw(
   ..
   ../t/lib
      t/lib
);

BEGIN {
   %API = (
      gd_normal                       => 7,
      gd_ttf                          => 7,
      gd_normal_scramble              => 7,
      gd_ttf_scramble                 => 7,
      gd_ttf_scramble_fixed           => 7,
      gd_normal_info_text             => 7,
      gd_ttf_info_text                => 7,
      gd_normal_scramble_info_text    => 7,
      gd_ttf_scramble_info_text       => 7,
      gd_ttf_scramble_fixed_info_text => 7,
   );

   %API_IT = (
      gd_ttf_scramble_info_text       => 4,
      gd_ttf_scramble_fixed_info_text => 4,
   );

   my $total  = 0;
      $total += $API{$_} foreach keys %API;
      $total += $API_IT{$_} foreach keys %API_IT;

   plan tests => $total;
   require GD::SecurityImage;
   import  GD::SecurityImage;
}

use Test::GDSI;

my $tapi = 'Test::GDSI';
   $tapi->clear;

my $font = getcwd.'/StayPuft.ttf';

my %info_text = (
   text   => $tapi->the_info_text,
   ptsize => 8,
   color  => '#000000',
   scolor => '#FFFFFF',
);

my @info_text_positions = (
  {x => 'left',  y => 'down', strip => 0, scolor => ''},
  {x => 'left',  y => 'up',   strip => 1, scolor => '#FF0000'},
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
            $api->box->out(
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

   if ( $name =~ m{ _info_text \z}xms ) {
      my %extra = ( info_text => { %info_text, %{$it_opts} });
      if ( $name =~ m{ normal }xms ) {
         $extra{info_text}->{gd} = 1;
      }
      if ($name =~ m{ fixed }xms ) {
         # yes, we can use GD' s internal font and ttf together...
         $extra{info_text}->{gd} = 1;
      }
      return %extra;
   }
   return +();
}

sub args {
   my $name = shift;
   my %options = (
   gd_normal => {
      width      => 120,
      height     => 30,
      send_ctobg => 1,
      gd_font    => 'Giant',
   },
   gd_ttf => {
      width      => 210,
      height     => 60,
      send_ctobg => 1,
      font       => $font,
      ptsize     => 25,
   },
   gd_normal_scramble =>  {
      width      => 120,
      height     => 30,
      send_ctobg => 1,
      gd_font    => 'Giant',
      scramble   => 1,
   },
   gd_ttf_scramble =>  {
      width      => 300,
      height     => 90,
      send_ctobg => 1,
      font       => $font,
      ptsize     => 20,
      scramble   => 1,
   },
   gd_ttf_scramble_fixed =>  {
      width      => 350,
      height     => 90,
      send_ctobg => 1,
      font       => $font,
      ptsize     => 25,
      scramble   => 1,
      angle      => 30,
   },
   );
   my $o = $options{$name};
   if ( not $o ) {
     (my $tmp = $name) =~ s{ _info_text }{}xms;
      $o = $options{$tmp};
   }
   croak "Bogus arg name $name!" if not $o;
   return %{$o}
}
