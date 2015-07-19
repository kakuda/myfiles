// ==UserScript==
// @name        yjh hack01
// @namespace   http://hacks.yahoo.co.jp/
// @include     http://*
// ==/UserScript==

(function () {

    GM_xmlhttpRequest({
        method: 'GET',
        url: 'http://api.map.yahoo.co.jp/LocalSearchService/V1/LocalSearch?appid=YahooDemo&p=%E5%85%AD%E6%9C%AC%E6%9C%A8%E3%83%92%E3%83%AB%E3%82%BA',
        onload: function(res) {
            var parser = new DOMParser();
            var dom = parser.parseFromString(res.responseText, "application/xml");
            var items = dom.getElementsByTagName('Item');
            var title;
            var address;
            for (var i = 0; i < items.length; i++) {
                title = items[i].getElementsByTagName('Title')[0].textContent;
                address = items[i].getElementsByTagName('Address')[0].textContent;
                alert(title + ': ' + address);
            }
        }
    });

})();
