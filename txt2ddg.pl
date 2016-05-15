#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use feature qw(say);

open my $infile_fh, '<', $ARGV[0] or die $!;

# Expect each row to be formatted as follows (tab-delimited):
# DoD Grade   Abbreviation    NATO Code   Title   Image URL
# O-1 2LT OF-1    Second Lieutenant   https://upload.wikimedia.org/wikipedia/commons/0/05/US-O1_insignia.svg
while (my $row = <$infile_fh>) {
    chomp $row;
    my ($grade, $abbr, $nato, $title, $url) = split("\t", $row);
    last unless $title;
    next if $title eq "Title"; # Skip the first line.
    my $subtitle = $grade ? "$grade | $nato" : $nato;
    my @lines = (
        '{',
        "    image       => '$url',",
        "    title       => '$title',",
        "    altSubtitle => '$abbr',",
        "    subtitle    => '$subtitle',",
        '},',
    );
    say join "\n", @lines;
}