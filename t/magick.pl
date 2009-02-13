use strict;
use vars qw($MAGICK_SKIP);
BEGIN {
   eval "require Image::Magick;";
   if ( $@ ) {
      $MAGICK_SKIP  = "You don't have Image::Magick installed.";
      $MAGICK_SKIP .= " $@";
   }
   elsif ( $Image::Magick::VERSION lt '6.0.4') {
      $MAGICK_SKIP = "There may be a bug in your PerlMagick version's "
                   . "($Image::Magick::VERSION) QueryFontMetrics() method. "
                   . "Please upgrade to 6.0.4 or newer.";
   }
   else {
      $MAGICK_SKIP = '';
   }
}

1;
