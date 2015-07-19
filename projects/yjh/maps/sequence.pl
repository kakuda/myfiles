#!/usr/bin/perl -w

use strict;
use warnings;
use LWP::Simple;

my @urls = (
    "http://api.search.yahoo.co.jp/WebSearchService/V1/webSearch?appid=YahooDemo&query=yahoo",
    "http://api.search.yahoo.co.jp/ImageSearchService/V1/imageSearch?appid=YahooDemo&query=yahoo",
    "http://api.search.yahoo.co.jp/VideoSearchService/V1/videoSearch?appid=YahooDemo&query=yahoo",
    "http://api.map.yahoo.co.jp/LocalSearchService/V1/LocalSearch?appid=YahooDemo&p=yahoo"
);

my @contents = ();
foreach (@urls) {
    push @contents, LWP::Simple::get($_);
}

# print @contents;
