#!/usr/local/bin/php
<?php

$urls = array("http://api.search.yahoo.co.jp/WebSearchService/V1/webSearch?appid=YahooDemo&query=yahoo",
              "http://api.search.yahoo.co.jp/ImageSearchService/V1/imageSearch?appid=YahooDemo&query=yahoo",
              "http://api.search.yahoo.co.jp/VideoSearchService/V1/videoSearch?appid=YahooDemo&query=yahoo",
              "http://api.map.yahoo.co.jp/LocalSearchService/V1/LocalSearch?appid=YahooDemo&p=yahoo"
              );

foreach ($urls as $url) {
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($curl, CURLOPT_HEADER, FALSE);
    $contents[] = curl_exec($curl);
    curl_close($curl);
}

//print_r($contents);
