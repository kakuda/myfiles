#!/usr/local/bin/php
<?php
$doc = simplexml_load_file("http://api.map.yahoo.co.jp/LocalSearchService/V1/LocalSearch?appid=YahooDemo&p=%E5%85%AD%E6%9C%AC%E6%9C%A8%E3%83%92%E3%83%AB%E3%82%BA");
foreach ($doc->Item as $item) {
    echo $item->Title . ": " . $item->DatumTky97->Lat . "," . $item->DatumTky97->Lon . "\n";
}
