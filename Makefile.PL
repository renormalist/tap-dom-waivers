use inc::Module::Install;

name     'TAP-DOM-Waivers';
all_from 'lib/TAP/DOM/Waivers.pm';
author   'Steffen Schwigon <schwigon@cpan.org>';
license  'perl';

author_requires 'Module::Install::AuthorTests';

build_requires 'Test::More';

requires 'Data::DPath' => "0.42";
requires 'Sub::Exporter';
requires 'YAML::Any';
requires 'TAP::DOM';

author_tests('xt');

test_requires 'TAP::DOM';
test_requires 'Test::More' => 0.88;

repository 'git://github.com/renormalist/tap-dom-waivers.git';
bugtracker 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=TAP-DOM-Waivers';

install_script 'tap-waive';

auto_install;

WriteAll;

