#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use YAML qw(DumpFile);

# Collect all data in a hashref before dumping it to YAML. There's probably a
# more direct way of doing this, but this is easy enough.
my $data = {};

# Run this script ($>perl txt2yml.pl military_rank.yml) from main directory. Expect all data files
# to end in .txt and be similarly formatted.
my @files = split("\n", `ls *.txt`);

foreach my $filename (@files) {
    my ($country, $branch) = $filename =~ qr/(\w+)_(\w+).txt/;
    die "Could not get country or branch from file $filename"
        unless $country && $branch;
        
    # Data files use "af" to indicate air force while the module expects "air_force".
    $branch = "air_force" if $branch eq "af";

    open my $infile_fh, '<', $filename or die $!;

    # Empty line inserted in data files to separate rank data from meta data.
    my $has_seen_empty_line = 0;

    # Expect each row to be formatted as follows (tab-delimited):
    # Country   Branch  DoD Grade   Abbreviation    NATO Code   Title   Image URL
    # us army O-1 2LT OF-1    Second Lieutenant   https://upload.wikimedia.org/wikipedia/commons/0/05/US-O1_insignia.svg
    while (my $row = <$infile_fh>) {
        $has_seen_empty_line = addRankData($row, $country, $branch)
            unless $has_seen_empty_line;
        addMetaData($row, $country, $branch)
            if $has_seen_empty_line;
    }
}

# Use DumpFile() instead of Dump() and redirecting STDOUT to a file because
# DumpFile() sorts hash keys while Dump() does not.
print DumpFile($ARGV[0], $data);

sub addRankData {
    my ($row, $country, $branch) = @_;

    chomp $row;
    my ($grade, $abbr, $nato, $title, $url) = split("\t", $row);
    return 1 unless $title; # We've encountered an empty line.
    return 0 if $title eq "Title"; # Skip the first line.

    my $subtitle = $grade ? "$grade | $nato" : $nato;
    my $entry = {
        image       => $url,
        title       => $title,
        altSubtitle => $abbr,
        description => $subtitle,
    };

    # Initialize the tree for the data.
    $data->{$country}->{$branch} = { data => [] }
        unless $data->{$country}->{$branch};
    push @{$data->{$country}->{$branch}->{data}}, $entry;

    return 0;
}

sub addMetaData {
    my ($row, $country, $branch) = @_;
    
    chomp $row;
    $data->{$country}->{$branch}->{meta} = {
        sourceName => 'Wikipedia',
        sourceUrl  => $row,
    };
}