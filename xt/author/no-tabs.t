use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.15

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Dist/Zilla/Plugin/GitHub/RequireGreenBuild.pm',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/01-compile.t'
);

notabs_ok($_) foreach @files;
done_testing;