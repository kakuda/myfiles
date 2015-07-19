#!/usr/bin/perl -w

use strict;
use warnings;
use LWP::Simple;
use XML::Simple;

my $xml = LWP::Simple::get("http://api.map.yahoo.co.jp/LocalSearchService/V1/LocalSearch?appid=YahooDemo&p=%E5%85%AD%E6%9C%AC%E6%9C%A8%E3%83%92%E3%83%AB%E3%82%BA");
my $xs = XML::Simple->new;
my $doc = $xs->XMLin($xml);
for my $item (@{$doc->{Item}}) {
    print "$item->{Title}: $item->{Address}\n";
}
