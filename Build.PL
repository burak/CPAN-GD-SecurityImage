use strict;
use Module::Build;
use File::Spec;
use IO::File;

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

my $class = Module::Build->subclass(
                class => 'MBSubclass',
                code  => raw_subclass(),
            );

my $mb = $class->new(
    module_name    => 'GD::SecurityImage',
    license        => 'perl',
    requires       => { 'GD'            => 0      },
    recommends     => { 'Image::Magick' => '6.0.4'},
    build_requires => {
       'Test::More' => '0.40',
    },
    sign           => 0,
    dist_author    => 'Burak Gursoy <burak@cpan.org>',
    create_license => 1,
    no_index       => {
        directory => [
            'tools',
            't',
        ]
    },
    meta_merge => {
        resources => {
            repository => 'http://bitbucket.org/burak/cpan-gd-securityimage/',
        },
    },
);

$mb->create_build_script;

sub raw_subclass {
    my $file = File::Spec->catfile( 'tools', 'Build.pm' );
    my $FH   = IO::File->new;
    $FH->open( $file, 'r' ) or die "Can not open($file): $!";
    my $rv = do { local $/; <$FH> };
    close $FH;
    return $rv;
}
