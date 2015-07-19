#!/usr/bin/perl -w
#
# ľ���ɸ��ͳ��¬�Ϸ��Ѵ�
# Nowral
# 99/9/10
#
# ���
$pi  = 4 * atan2(1,1); # �߼�Ψ
$rd  = $pi / 180;      # [�饸����/��]

# �Ѵ���������ɸ
# (Tokyo)
# ����   35��20��39.984328��
# ����  138��35��08.086122��
# �⤵        697.681000 [m]
$b =  35 + 20/60 + 39.984328/3600; # ���� [��]
$l = 138 + 35/60 +  8.086122/3600; # ���� [��]
$h = 697.681000; # �⤵ [m]

print "�Ѵ���\n���١� ",&deg2dms($b),"\n���١� ",&deg2dms($l),"\n�⤵�� $h\n\n";

# �ǡ��������
# �Ѵ���
# (Tokyo)
$a = 6377397.155;
$f = 1 / 299.152813;
$e2 = 2*$f - $f*$f;

# �Ѵ���
# (WGS 84)
$a_ = 6378137;        # ��ƻȾ��
$f_ = 1 / 298.257223; # ٨ʿΨ
$e2_ = 2*$f_ - $f_*$f_;  # ��1Υ��Ψ

# �¹԰�ư�� [m]
# e.g. $x_ = $x + $dx etc.
$dx = -148;
$dy = +507;
$dz = +681;

# �Ѵ�
($x, $y, $z) = &llh2xyz($b, $l, $h, $a, $e2);
($b, $l, $h) = &xyz2llh($x+$dx, $y+$dy, $z+$dz, $a_, $e2_);

# �Ѵ����줿��ɸ
print "�Ѵ���\n���١� ",&deg2dms($b),"\n���١� ",&deg2dms($l),"\n�⤵�� $h\n\n";

# ����������
# (WGS 84)
# ����   35��20��51.685555��
# ����  138��34��56.838916��
# �⤵        737.895217 [m]

#&MacPerl'Quit(2);
die "The Unhappy End";



sub llh2xyz { # �ʱ��κ�ɸ -> ľ���ɸ
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

sub xyz2llh { # ľ���ɸ -> �ʱ��κ�ɸ
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