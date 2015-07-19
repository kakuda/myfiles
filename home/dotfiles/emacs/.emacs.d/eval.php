<?php
echo   "---------- *PHP-eval* ----------\n";

// read STDIN from pipe
$region = "";
while(!feof(STDIN)) {
    $line = fgets(STDIN);
    if (preg_match('@^(#!|<\?php$|\?>$)@', $line)) { continue; }
    $region .= $line;
}
// validate region string
if (!validate($region)) {
    exit(1);
}
// eval region string
eval($region);

echo "\n--------------------------------\n";


/**
 * validate region string
 *
 * @param String $region Emacs's region string
 * @return Boolean TRUE: valid / FALSE: invalid
 *
 */
function validate($region) {
    // check string length
    if (strlen($region) == 0) {
        return false;
    }
    return true;
}
