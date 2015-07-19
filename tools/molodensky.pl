#!/home/y/bin/perl -w
#
# Standard Molodensky Datum Transformation
# Nowral
# 99/11/24
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

# �Ѵ���
# (WGS 84)
$a_ = 6378137;        # ��ƻȾ��
$f_ = 1 / 298.257223; # ٨ʿΨ

# �¹԰�ư�� [m]
# e.g. $x_ = $x + $dx etc.
$dx = -148;
$dy = +507;
$dz = +681;

# �Ѵ�
($b, $l, $h) = &molodensky($b, $l, $h, $a, $f, $a_, $f_);

# �Ѵ����줿��ɸ
print "�Ѵ���\n���١� ",&deg2dms($b),"\n���١� ",&deg2dms($l),"\n�⤵�� $h\n\n";

# ����������
# (WGS 84)
# ����   35��20��51.685555��
# ����  138��34��56.838916��
# �⤵        737.895217 [m]

#&MacPerl'Quit(2);
die "The Unhappy End";


sub molodensky {
    my($b, $l, $h, $a, $f, $a_, $f_) = @_;
    my($bda, $e2, $da, $df, $db, $dl, $dh);
    my($sb, $cb, $sl, $cl, $rn, $rm);
    $b *= $rd;
    $l *= $rd;

    $e2 = 2*$f - $f*$f; # Υ��Ψ e^2
    $bda = 1- $f;       # ��Ⱦ�� / ��ƻȾ�� b/a
    ($da, $df) = ($a_-$a, $f_-$f);
    ($sb, $cb, $sl, $cl) = (sin($b), cos($b), sin($l), cos($l));

    $rn = 1 / sqrt(1 - $e2*$sb*$sb);
    $rm = $a * (1 - $e2) * $rn * $rn * $rn;
    $rn *= $a;

    #����η׻�
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
