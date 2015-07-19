#!/usr/bin/perl -w

use strict;
use warnings;
use LWP::Parallel::UserAgent;
use HTTP::Request; 

my $reqs = [  
    HTTP::Request->new('GET', "http://api.search.yahoo.co.jp/WebSearchService/V1/webSearch?appid=YahooDemo&query=yahoo"),
    HTTP::Request->new('GET', "http://api.search.yahoo.co.jp/ImageSearchService/V1/imageSearch?appid=YahooDemo&query=yahoo"),
    HTTP::Request->new('GET', "http://api.search.yahoo.co.jp/VideoSearchService/V1/videoSearch?appid=YahooDemo&query=yahoo"),
    HTTP::Request->new('GET', "http://api.map.yahoo.co.jp/LocalSearchService/V1/LocalSearch?appid=YahooDemo&p=yahoo"),
];

my $pua = LWP::Parallel::UserAgent->new();
foreach my $req (@$reqs) {
    $pua->register($req);
}

my $entries = $pua->wait(2);

my @contents = ();
foreach (keys %$entries) {
    my $res = $entries->{$_}->response;
    push @contents, $res->content;
}

# print @contents;
