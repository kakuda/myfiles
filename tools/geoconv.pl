#!/usr/bin/perl -w
#
# 直交座標経由の測地系変換
# Nowral
# 99/9/10
#
# 定数
$pi  = 4 * atan2(1,1); # 円周率
$rd  = $pi / 180;      # [ラジアン/度]

# 変換したい座標
# (Tokyo)
# 緯度   35°20′39.984328″
# 経度  138°35′08.086122″
# 高さ        697.681000 [m]
$b =  35 + 20/60 + 39.984328/3600; # 緯度 [度]
$l = 138 + 35/60 +  8.086122/3600; # 経度 [度]
$h = 697.681000; # 高さ [m]

print "変換前\n緯度： ",&deg2dms($b),"\n経度： ",&deg2dms($l),"\n高さ： $h\n\n";

# データム諸元
# 変換元
# (Tokyo)
$a = 6377397.155;
$f = 1 / 299.152813;
$e2 = 2*$f - $f*$f;

# 変換先
# (WGS 84)
$a_ = 6378137;        # 赤道半径
$f_ = 1 / 298.257223; # 扁平率
$e2_ = 2*$f_ - $f_*$f_;  # 第1離心率

# 並行移動量 [m]
# e.g. $x_ = $x + $dx etc.
$dx = -148;
$dy = +507;
$dz = +681;

# 変換
($x, $y, $z) = &llh2xyz($b, $l, $h, $a, $e2);
($b, $l, $h) = &xyz2llh($x+$dx, $y+$dy, $z+$dz, $a_, $e2_);

# 変換された座標
print "変換後\n緯度： ",&deg2dms($b),"\n経度： ",&deg2dms($l),"\n高さ： $h\n\n";

# 本当の答え
# (WGS 84)
# 緯度   35°20′51.685555″
# 経度  138°34′56.838916″
# 高さ        737.895217 [m]

#&MacPerl'Quit(2);
die "The Unhappy End";



sub llh2xyz { # 楕円体座標 -> 直交座標
    my($b, $l, $h, $a, $e2) = @_;
    my($sb, $cb, $rn, $x, $y, $z);

    $b *= $rd;
    $l *= $rd;
    $sb = sin($b);
    $cb = cos($b);
    $rn = $a / sqrt(1-$e2*$sb*$sb);

    $x = ($rn+$h) * $cb * cos($l);
    $y = ($rn+$h) * $cb * sin($l);
    $z = ($rn*(1-$e2)+$h) * $sb;

    ($x, $y, $z);
}

sub xyz2llh { # 直交座標 -> 楕円体座標
    my($x, $y, $z, $a, $e2) = @_;
    my($bda, $p, $t, $st, $ct, $b, $l, $sb, $rn, $h);
    $bda = sqrt(1-$e2); # b/a

    $p = sqrt($x*$x+$y*$y);
    $t = atan2($z, $p*$bda);
    $st = sin($t);
    $ct = cos($t);
    $b = atan2($z+$e2*$a/$bda*$st*$st*$st, $p-$e2*$a*$ct*$ct*$ct);
    $l = atan2($y, $x);

    $sb = sin($b);
    $rn = $a / sqrt(1-$e2*$sb*$sb);
    $h = $p/cos($b) - $rn;

    ($b/$rd, $l/$rd, $h);
}

sub deg2dms {
    my($d) = @_;
    my($m, $s, $sf);
    $sf = int($d*360000 + 0.5);
    $s = $sf / 100 % 60;
    $m = $sf / 6000 % 60;
    $d = int($sf/360000);
    $sf %= 100;
    sprintf("%d\.%02d\.%02d\.%02d", $d, $m, $s, $sf);
}
