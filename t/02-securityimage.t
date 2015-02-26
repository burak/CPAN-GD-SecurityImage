use strict;
use warnings;
use Test::More tests => 35;
use Cwd;
use vars qw( $MAGICK_SKIP );
use Carp qw(croak);
use lib qw(
   ..
   ../t/lib
      t/lib
);
use Test::GDSI;

BEGIN {
  do 't/magick.pl' || croak "Can not include t/magick.pl: $!";
   require GD::SecurityImage;
   import  GD::SecurityImage;
}

# used to evaluate expressions in void context
sub void(&) {
  $_[0]->();
  ();
}

my $class = 'GD::SecurityImage';
my $font  = getcwd.'/StayPuft.ttf';
my $tapi  = 'Test::GDSI';

IMPORT: {
  $class->import('bad_arg');
  is($GD::SecurityImage::BACKEND, 'GD', 'import() ignore bad arguments.');

  eval { $class->import( backend => 'bad_arg' ) };
  ok($@, 'import() die on invalid backend.');

  $class->import();
  is($GD::SecurityImage::BACKEND, 'GD', 'import() default backend.');

  $class->import( backend => 'GD' );
  is($GD::SecurityImage::BACKEND, 'GD', 'import() load valid backend.');
}

NEW: {
  my $im = $class->new('bad_args');
  is(ref($im), 'GD::SecurityImage', 'new() ignores bad arguments.');

  # font option
  $im = $class->new(font => 'Inexistent font');
  ok($im->create('ttf')->gdbox_empty, "new() won't load invalid fonts.");

  # gd_font option
  $tapi->save(
    $class->new(gd_font => 'inexistent')
          ->random
          ->create
          ->out,
    'default',
    'gd_font',
    0);

  # angle option
  eval { $class->new( angle => 361 ) };
  ok($@, 'new() die on angle parameter out of range [0].');

  eval { $class->new( angle => -361 ) };
  ok($@, 'new() die on angle parameter out of range [1].');

  my $c=0;
  for my $angle (0, 45, 90, 135, 180, 225, 270 ,315, 360) {
    $tapi->save(
      $class->new(
        scramble => 1,
        width  => 300,
        height => 100,
        font   => $font,
        angle  => $angle
       )->random(sprintf("%03dDEG", $angle))
        ->create(ttf => 'box', [63, 143, 167], [226, 223, 169])
        ->info_text(
          x     => 'left',
          y     => 'down',
          strip => 1,
          text  => $angle,
          gd    => 1,
         )
        ->out,
      $angle,
      "gd_ttf_angle",
      $c++);
  }
}

BACKENDS: {
  open my $fh, '>', \my $output or croak "Can't open output.";
  select $fh;
  $class->backends();
  select STDOUT;
  close $fh;
  ok(defined $output, 'backends() in void context.');
};

RANDOM: {
  my $rand = void { $class->new->random("string") };
  ok( !defined $rand, "random() undefined value in void context." );
};

CCONVERT: {
  my $color = $class->new->cconvert('#0a0a0a');
  ok($color, 'cconvert() convert color string using GD backend.');

  $color = $class->new->cconvert('Invalid color');
  ok($color == 1, 'cconvert() GD, returns default index on invalid args.');

  $color = $class->new->_cconvert_new();
  ok($color == 1, '_convert_new() GD, returns default index for invalid args.');
}

CREATE: {
  my $im = $class->new->create('normal', 'style_unknown');
  ok($im->isa($class), "create() won't die on unknown style.");
}

PARTICLE: {
  eval { my $im = $class->new->particle };
  ok($@, 'particle() dies if called before create');

  my $im = void  { $class->new->create->particle };
  ok( !defined $im, 'particle() returns undef in void context' );

  eval {
    local $SIG{__WARN__} = sub { croak shift };
    my $im = $class->new(width => 5, height => 10);
    $im->create->particle
  };
  ok($@, "particle() warns when using small dimensions.")
}

INFO_TEXT: {
  eval { my  $im = $class->new->info_text };
  ok($@, 'info_text() dies if info_text was called before create');

  my $im = $class->new->create->info_text('invalid_argument');
  ok(!defined $im, "info_text() won't continue with invalid arguments");

  $im = $class->new->create->info_text;
  ok($im->isa($class), 'info_text() with default parameters');

  # use info_text with a given angle
  $tapi->save(
    $class->new(
      angle  => 30,
      width  => 300,
      height => 100,
      font   => $font,
     )->random('MyTest')
      ->create(ttf => 'ec', [84, 207, 112], [0,0,0])
      ->info_text(
        x     => 'left',
        y     => 'down',
        text  => 'IT angle',
       )
      ->out(force => 'png'),
    'info_text',
    'gd_ttf_angle',
    30);
}

OUT: {
  my ($img, $mime, $rnd) = $class->new->random->create->out( force => 'xpm' );
  is($mime, 'png', 'out() unsupported file format defaults to PNG.');

  ($img, $mime, $rnd) = $class->new->random->create->out('invalid_argument');
  ok($img &&  $mime &&  $rnd, 'out() ignores invalid arguments');

  ($img, $mime, $rnd) = $class->new->random->create->out(
    force => 'jpeg',
    compress => 10
   );
  ok($img && $mime && $rnd, 'out() jpeg compression support');
}

R2H: {
  my @rgb = $class->new->r2h(255, 255);
  ok( !@rgb, "r2h() won't process invalid RGB input." );
}

SKIP: {
  if ( $MAGICK_SKIP ) {
    skip( $MAGICK_SKIP . ' Skipping...', 1 );
  }

 MAGICK_IMPORT: {
      $class->import( use_magick => 1 );
      is($GD::SecurityImage::BACKEND, 'Magick', 'Magick import() backend.');
    }

 MAGICK_NEW: {
    # angle option
    my $c = 0;
    for my $angle (0, 45, 90, 135, 180, 225, 270 ,315, 360) {
      $tapi->save(
        $class->new(
          scramble => 1,
          width  => 300,
          height => 100,
          font   => $font,
          angle  => $angle
         )->random(sprintf("%03dDEG", $angle))
          ->create(ttf => 'box', [63, 143, 167], [226, 223, 169])
          ->info_text(
            x     => 'left',
            y     => 'down',
            strip => 1,
            text  => "$angle Deg",
           )
          ->out(force => 'png'),
        $angle,
        "magick_ttf_angle",
        $c++);
    }

    # font option
    my $im= $class->new( font => 'Inexistent font' )->create('ttf');
    ok($im->gdbox_empty ==  0, "Magick new() don't take invalid fonts.");
  }

 MAGICK_CCONVERT: {
    eval { my $im = $class->new->cconvert(15) };
    ok($@, "Magick cconvert() can't handle index values.");

    my $color = $class->new->cconvert('Invalid color');
    ok(defined $color, 'Magick cconvert() ignores invalid color as an argument.');

    my $hex_color = '#0a0a0a';
    $color = $class->new->cconvert($hex_color);
    is($color, $hex_color, 'Magick cconvert() Convert color string.');

    $color =  $class->new->_cconvert_new();
    ok(defined $color, 'Magick _cconvert_new() may take no arguments');
  }

 MAGICK_INFO_TEXT: {
    # use info_text with a given angle
    $tapi->save(
      $class->new(
        angle  => 10,
        width  => 300,
        height => 100,
       )->random('MyTest')
        ->create
        ->info_text(
          x     => 'left',
          y     => 'down',
          text  => 'IT angle',
         )
        ->out(force => 'png'),
      'info_text',
      'magick_ttf_angle',
      10);
  }

 MAGICK_OUT: {
    my %test_out = (
      'jpeg compression support.'       => [force => 'jpeg', compress => 10],
      'gif output supported.'           => [force => 'gif'],
      'gif compression support.',       => [force => 'gif', compress => 10],
      'unknown format defaults to gif.' => [force => 'unknown'],
      'ignores invalid arguments.',     => ['invalid argument'],
     );

    for my $test_name (keys %test_out) {
      my ($img, $mime, $rnd) = $class->new->random->create->out(
        @{ $test_out{$test_name} }
       );
      ok($img && $mime && $rnd, 'Magick out() ' . $test_name);
    }
  }
}

