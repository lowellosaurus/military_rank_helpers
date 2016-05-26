#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use YAML qw(Bless Dump);

open my $infile_fh, '<', $ARGV[0] or die $!;

# Collect all data in a hashref before dumping it to YAML. There's probably a
# more direct way of doing this, but this is easy enough.
# NOTE: This only dumps the data, still need to add metadata by hand.
my $data = {};

# Expect each row to be formatted as follows (tab-delimited):
# Country   Branch  DoD Grade   Abbreviation    NATO Code   Title   Image URL
# us army O-1 2LT OF-1    Second Lieutenant   https://upload.wikimedia.org/wikipedia/commons/0/05/US-O1_insignia.svg
while (my $row = <$infile_fh>) {
    chomp $row;
    my ($country, $branch, $grade, $abbr, $nato, $title, $url)
        = split("\t", $row);
    last unless $title;
    next if $title eq "Title"; # Skip the first line.

    my $subtitle = $grade ? "$grade | $nato" : $nato;
    my $entry = {
        image       => $url,
        title       => $title,
        altSubtitle => $abbr,
        subtitle    => $subtitle,
    };

    # Initialize the tree for the data.
    $data->{$country}->{$branch} = { data => [] }
        unless $data->{$country}->{$branch};
    push @{$data->{$country}->{$branch}->{data}}, $entry;
}

print Dump $data;