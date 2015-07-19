#!/usr/local/bin/php
<?php

$urls = array("http://api.search.yahoo.co.jp/WebSearchService/V1/webSearch?appid=YahooDemo&query=yahoo",
              "http://api.search.yahoo.co.jp/ImageSearchService/V1/imageSearch?appid=YahooDemo&query=yahoo",
              "http://api.search.yahoo.co.jp/VideoSearchService/V1/videoSearch?appid=YahooDemo&query=yahoo",
              "http://api.map.yahoo.co.jp/LocalSearchService/V1/LocalSearch?appid=YahooDemo&p=yahoo"
              );

$cm = curl_multi_init();
$chlist = array();
foreach ($urls as $url) {
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($curl, CURLOPT_HEADER, FALSE);
    curl_multi_add_handle($cm, $curl);
    $chlist[] = $curl;
}

do {
    $n = curl_multi_exec($cm, $active);
} while ($active);

$contents = array();
for ($i = 0; $i < sizeof($chlist); $i++) {
    $contents[] = curl_multi_getcontent($chlist[$i]);
    curl_close($chlist[$i]);
}
curl_multi_close($cm);

//print_r($contents);
