use strict;
use Module::Build;

print qq~
.------------------------------------------------------------.
| You are about to install "GD::SecurityImage".              |
|                                                            |
| Although it is in the GD:: namespace, the module is also   |
| compatible with Image::Magick. If you have "Image::Magick" | 
| installed, the required tests for "Image::Magick" will be  |
| performed (if you do a `perl Build test`).                 |
|                                                            |
| Note that "Image::Magick" is *not* a prerequisite for      |
| "GD::SecurityImage", but "GD" is.                          |
 ------------------------------------------------------------

~;

Module::Build->new(
   module_name => 'GD::SecurityImage',
   license     => 'perl',
   requires    => { 'GD'            => 0      },
   recommends  => { 'Image::Magick' => '6.0.4'},
   dist_author => 'Burak Gursoy <burak@cpan.org>',
)->create_build_script;
