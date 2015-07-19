<?php
echo   "---------- *PHP-dump* ----------\n";

// read STDIN from pipe
$region = "";
while(!feof(STDIN)) {
    $region .= fgets(STDIN);
}
// validate region string
if (!validate($region)) {
    exit(1);
}
// dump region string
$region = "var_dump(" . trim($region, " \t\n\r\0\x0B;") . ");";
if (eval($region) === FALSE) {
    echo "Error[" . $region . "]";
}

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
