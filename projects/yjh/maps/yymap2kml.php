<?php
class YYMap2KML {

    function process() {
        $url = "http://waiwai.map.yahoo.co.jp/rss/map/index.xml?mid=";
        if (isset($_REQUEST['rss'])) {
            $url = urldecode($_REQUEST['rss']);
        } else if(isset($_REQUEST['mid'])) {
            $url = $url . $_REQUEST['mid'];
        } else if(isset($_REQUEST['url'])) {
            $pu = parse_url(urldecode($_REQUEST['url']));
            parse_str($pu);
            $url .= $mid;
        } else {
            header("Content-Type: text/html; charset=utf-8");
            echo "specify yymap rss or mid or url.";
            return;
        }

        $rss = simplexml_load_file($url);
        $kml = $this->rss2kml($rss);
        $this->printKML($kml);
    }

    function rss2Kml($rss) {
        $kml = array();
        $kml['name'] = htmlspecialchars($rss->channel->title);
        $kml['description'] = $rss->channe->description;
        $kml['Placemark'] = $this->items2Placemarks($rss->channel->item);
        return $kml;
    }

    function buildKML($kml) {
        $pm = "";
        foreach ($kml['Placemark'] as $p) {
            $pm .= <<< KML_PLACEMARK
<Placemark>
<name>{$p['name']}</name>
<description><![CDATA[{$p['description']}]]></description>
<Point><coordinates>{$p['Point']['coordinates']}</coordinates></Point>
</Placemark>
KML_PLACEMARK;
        }
        $result = <<< KML
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://earth.google.com/kml/2.1">
<Document>
<name>{$kml['name']}</name>
<description>{$kml['description']}</description>
{$pm}
</Document>
</kml>
KML;
        return $result;
    }

    function printKML($kml) {
        header("content-disposition: attachment; filename=yymap.kml");
        header("Content-Type: application/vnd.google-earth.kml+xml; charset=utf-8");
        echo $this->buildKML($kml);
    }

    function tky2Wgs($lat, $lon) {
        $wlat = $lat - $lat * 0.00010695 + $lon * 0.000017464 + 0.0046017;
        $wlon = $lon - $lat * 0.000046038 - $lon * 0.000083043 + 0.010040;
        return array($wlat, $wlon);
    }
    
    function items2Placemarks($items) {
        if (! isset($items[0])) {
            $items = array($items);
        }
        $placemarks = array();
        foreach ($items as $item) {
            $p = array();
            $p['name'] = htmlspecialchars($item->title);
            $p['description'] = $item->description;
            $geo = $item->children("http://map.yahoo.co.jp/ygeorss");
            $tky = explode(' ', $geo->point);
            $wgs = $this->tky2wgs($tky[1], $tky[0]);
            $p['Point']['coordinates'] = "{$wgs[1]},{$wgs[0]},0";
            $placemarks[] = $p;
        }
        return $placemarks;
    }

}

$app = new YYMap2KML();
$app->process();
