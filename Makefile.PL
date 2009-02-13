use ExtUtils::MakeMaker;

my $make = $^O =~ m{MSWin}i
           ? 'nmake'
           : 'make ';

print qq~
.------------------------------------------------------------.
| You are about to install "GD::SecurityImage".              |
|                                                            |
| Although it is in the GD:: namespace, the module is also   |
| compatible with Image::Magick. If you have "Image::Magick" | 
| installed, the required tests for "Image::Magick" will be  |
| performed (if you do a `$make test`).                      |
|                                                            |
| Note that "Image::Magick" is *not* a prerequisite for      |
| "GD::SecurityImage", but "GD" is.                          |
 ------------------------------------------------------------

~;

WriteMakefile(
   NAME         => 'GD::SecurityImage',
   VERSION_FROM => 'lib/GD/SecurityImage.pm',
   PREREQ_PM    => {GD => 0},
   ($] >= 5.005 ? (
   AUTHOR       => 'Burak Gursoy <burak@cpan.org>',
   ABSTRACT     => 'Security image (captcha) generator',
   ) : ()),
   PL_FILES     => {},
);
