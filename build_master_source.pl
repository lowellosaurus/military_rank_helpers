#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use feature qw(say);

# Run the following command from the main directory to generater master.txt
# for f in `ls *.txt`; do perl build_master_source.pl $f; done >> master.txt
my $filename = $ARGV[0];

my ($country, $branch) = split("_", $filename);
die "Could not get country or branch from file $filename"
    unless $country && $branch;

open my $infile_fh, '<', $filename or die $!;

# Expect each row to be formatted as follows (tab-delimited):
# DoD Grade   Abbreviation    NATO Code   Title   Image URL
# O-1 2LT OF-1    Second Lieutenant   https://upload.wikimedia.org/wikipedia/commons/0/05/US-O1_insignia.svg
while (my $row = <$infile_fh>) {
    chomp $row;
    next if $row =~ qr/^DoD Grade/; # Skip the first line.
    say "$country\t$branch\t$row";
}