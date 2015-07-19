#!/usr/local/bin/perl -w
#
use strict;
use Win32::IE::Mechanize;

Usage() and exit unless ($ARGV[0]);
open(IN, "< $ARGV[0]") or die("");
my $ie = Win32::IE::Mechanize->new(visible => 1);
while (<IN>) {
    chomp;
    $ie->get($_);
    sleep $ARGV[1] if ($ARGV[1]);
}
close IN;

sub Usage {
    print <<USAGE;
Usage: $0 FILE [seconds]
     FILE - text file with one URL per line
     seconds - wait time per access
     Example: $0 url.txt 1
USAGE
}
__END__
