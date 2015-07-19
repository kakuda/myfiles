#!/usr/bin/perl -w

use strict;
use warnings;
use LWP::Simple;
use JavaScript::Swell;

my $xml = LWP::Simple::get("http://api.map.yahoo.co.jp/MapsService/js/V1/?appid=YahooDemo");
print JavaScript::Swell->swell($xml);
