package TAP::DOM::Waivers;

use strict;
use warnings;

our $VERSION = '0.01';

use Data::Dumper;
use Data::DPath 'dpathr';
use Clone "clone";
use Sub::Exporter -setup => {
                             exports => [ 'waive' ],
                             groups  => { all   => [ 'waive' ] },
                            };

sub waive {
        my ($dom, $waivers, $options) = @_;

        my $new_dom_ref;
        if ($options->{no_clone}) {
                $new_dom_ref = \$dom;
        } else {
                $new_dom_ref = \ (clone($dom));
        }
        foreach my $waiver (@$waivers) {
                # apply on matching dpath
                if (my @paths = @{$waiver->{match_dpath} || []}) {
                        foreach my $path (@paths) {
                                _patch_dom_dpath( $new_dom_ref, $waiver, $path );
                        }
                }
                # if-elsif cascade for others, test numbers, TAP lines, etc
                else {
                        # nop
                }
        }
        return $$new_dom_ref;
}

sub _patch_dom_dpath {
        my ($dom_ref, $waiver, $path) = @_;

        my $comment  = $waiver->{comment};
        my $patch    = $waiver->{patch};
        my @points   = dpathr($path)->match($$dom_ref);
        foreach my $p (@points) {
                $$p->{$_} = $patch->{$_} foreach keys %$patch;
        }
}

1;

__END__

# Dropped ideas

# Other match criteria, eg. by line:

#  my $waivers = [
#                 {
#                   match_lines => [ 7, 9, 15 ],
#                   patch       => { ... },
#                 }
#                ];

# By number:

#  my $waivers = [
#                 {
#                   match_numbers => [ 5, 7, 12 ],
#                   patch         => { ... },
#                 }
#                ];

# By descriptions:

#  my $waivers = [
#                 {
#                   match_descriptions => [ 'IPv6' ],
#                   patch              => { ... },
#                 }
#                ];
