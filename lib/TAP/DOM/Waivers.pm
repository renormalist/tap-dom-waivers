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
                        _patch_dom_dpath( $new_dom_ref, $waiver, $_ ) foreach @paths;
                }
                elsif (my @descriptions = @{$waiver->{match_description} || []}) {
                        my @paths = map { _description_to_dpath($_) } @descriptions;
                        _patch_dom_dpath( $new_dom_ref, $waiver, $_ ) foreach @paths;
                }
        }
        return $$new_dom_ref;
}

sub _description_to_dpath {
        my ($description) = @_;

        # the '#' as delimiter is not expected in a description
        # because it has TAP semantics, however, we escape to be sure
        $description =~ s/\#/\\\#/g;

        return "//lines//description[value =~ qr#$description#]/..";
}

sub _meta_patch {
        my ($metapatch) = @_;

        my $patch;
        my $explanation;
        if ($explanation = $metapatch->{TODO}) {
                $patch = {
                          is_ok        => 1,
                          has_todo     => 1,
                          is_actual_ok => 0,
                          directive    => 'TODO',
                          explanation  => $explanation,
                         };
        } elsif ($explanation = $metapatch->{SKIP}) {
                $patch = {
                          is_ok        => 1,
                          has_skip     => 1,
                          is_actual_ok => 0,
                          directive    => 'SKIP',
                          explanation  => $explanation,
                         };
        }
        return $patch;
}

sub _patch_dom_dpath {
        my ($dom_ref, $waiver, $path) = @_;

        my $patch;
        if (exists $waiver->{metapatch}) {
                $patch = _meta_patch($waiver->{metapatch});
        } else {
                $patch = $waiver->{patch};
        }
        my $comment  = $waiver->{comment};
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
