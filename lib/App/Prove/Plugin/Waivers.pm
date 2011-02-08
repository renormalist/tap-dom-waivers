package App::Prove::Plugin::Waivers;

use strict;
use warnings;

use YAML::Any;
use TAP::DOM;
use TAP::DOM::Waivers 'waive';

use Data::Dumper;
use Test::More;

our $VERSION = '0.01';

# sub _slurp {
#         my ($filename) = @_;

#         local $/;
#         open (my $F, "<", $filename) or die "Cannot read $filename";
#         return <$F>;
# }

sub load {
    my ($class, $p) = @_;
    my @args = @{ $p->{args} };
    my $app  = $p->{app_prove};

    diag "******************** Waivers.load() ********************";
    diag "******************** formatter: ". ($app->formatter || 'NONE');

    #diag Dumper($p);
    
    # parse the args
    my %TFW_args;
    foreach my $arg (@args) {
	my ($key, $val) = split(/:/, $arg, 2);
	if (grep {$key eq $_} qw(FOO BAR)) { # allow repeated keys: FOO -> FOOs, BAR -> BARs
	    push @{ $TFW_args{$key . 's'}}, $val;
	} else {
	    $TFW_args{$key} = $val;
	}
    }

    while (my ($key, $val) = each %TFW_args) {
	$val = join( ':', @$val ) if (ref($val) eq 'ARRAY');
	$ENV{"TAP_FORMATTER_WAIVERS_".uc($key)} = $val;
    }

    #WEITER: das hier in Session rein;
    # my $waiverfile     = $TFW_args{waiver};
    # my $tapfile        = "t/failed_IPv6.tap";
    # my $waivers        = YAML::Any::Load(_slurp($waiverfile));
    # my $tapdom         = TAP::DOM->new(tap => _slurp($tapfile));
    # my $patched_tapdom = waive($tapdom, $waivers);

    # set the formatter to use
    $app->formatter( 'TAP::DOM::Waivers::Formatter' );

    # diag ",---------------------------------------------------------.";
    # diag "PATCHED TAP-DOM:";
    # diag "";
    # diag $patched_tapdom->to_tap;
    # diag "`---------------------------------------------------------'";

    # we're done
    return $class;
}

# development on plugin:
#   perl -Ilib `which prove` -Ilib -vl -e cat -P Waivers=waiver:t/metawaiverdesc.yml t/failed_IPv6.tap
# normally activate plugin:
#                     prove  -Ilib -vl -e cat -P Waivers=waiver:t/metawaiverdesc.yml t/failed_IPv6.tap

1;
