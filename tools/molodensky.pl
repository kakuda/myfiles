#!/home/y/bin/perl -w
#
# Standard Molodensky Datum Transformation
# Nowral
# 99/11/24
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

# 変換先
# (WGS 84)
$a_ = 6378137;        # 赤道半径
$f_ = 1 / 298.257223; # 扁平率

# 並行移動量 [m]
# e.g. $x_ = $x + $dx etc.
$dx = -148;
$dy = +507;
$dz = +681;

# 変換
($b, $l, $h) = &molodensky($b, $l, $h, $a, $f, $a_, $f_);

# 変換された座標
print "変換後\n緯度： ",&deg2dms($b),"\n経度： ",&deg2dms($l),"\n高さ： $h\n\n";

# 本当の答え
# (WGS 84)
# 緯度   35°20′51.685555″
# 経度  138°34′56.838916″
# 高さ        737.895217 [m]

#&MacPerl'Quit(2);
die "The Unhappy End";


sub molodensky {
    my($b, $l, $h, $a, $f, $a_, $f_) = @_;
    my($bda, $e2, $da, $df, $db, $dl, $dh);
    my($sb, $cb, $sl, $cl, $rn, $rm);
    $b *= $rd;
    $l *= $rd;

    $e2 = 2*$f - $f*$f; # 離心率 e^2
    $bda = 1- $f;       # 極半径 / 赤道半径 b/a
    ($da, $df) = ($a_-$a, $f_-$f);
    ($sb, $cb, $sl, $cl) = (sin($b), cos($b), sin($l), cos($l));

    $rn = 1 / sqrt(1 - $e2*$sb*$sb);
    $rm = $a * (1 - $e2) * $rn * $rn * $rn;
    $rn *= $a;

    #ずれの計算
    $db = -$dx*$sb*$cl - $dy*$sb*$sl + $dz*$cb
        + $da*$rn*$e2*$sb*$cb/$a + $df*($rm/$bda+$rn*$bda)*$sb*$cb;
    $db /= $rm + $h;
    $dl = -$dx*$sl + $dy*$cl;
    $dl /= ($rn+$h) * $cb;
    $dh = $dx*$cb*$cl + $dy*$cb*$sl + $dz*$sb
        - $da*$a/$rn + $df*$bda*$rn*$sb*$sb;

    (($b+$db)/$rd, ($l+$dl)/$rd, $h+$dh);
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
