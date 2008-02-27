use strict;
use Module::Build;
my $class = new Module::Build(
                              module_name => 'Template::Quick',
                              requires    => {'Test::More' => 0,'Module::Build' => 0, 'CGI::QuickApp' => '>=0.25',},
                              ($] >= 5.005 ? (AUTHOR => 'Dirk Lindner <lze@cpan.org>') : ()),
                              dist_abstract      => "a Simple Template system",
                              license            => "lgpl",
                              create_makefile_pl => 'passthrough',
)->create_build_script;
