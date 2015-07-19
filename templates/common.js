function log(message) {
    if (typeof console == 'object') {
        console.log(message);
    } else {
        GM_log(message);
    }
}
