#!/usr/bin/perl

# =================================================================
# ̾��: wwwsrch.cgi Ver3.13
# ��ǽ: �ۡ���ڡ��������Ƥ򸡺�����CGI������ץȡ�
# ���̡��ե꡼���եȡʻ��ѡ�������鷺�����ѡ���¤��ή�ѡ������۲ġ�
# ���: ���㡹
# ����: http://tohoho.wakusei.ne.jp/
# =================================================================

# =================================================================
# ������ѥ�᡼��
# =================================================================

# �� Perl�Υѥ�̾
# 1���ܤ� #!/usr/local/bin/perl �ιԤ򡢻��Ѥ��Ƥ���ץ�Х����䥵���С�
# �δĶ��ˤ��碌���ѹ����Ƥ���������

# �� �����оݥե����
# �����оݤΥե����̾����ꤷ�Ƥ���������http://�� �Τ褦��URL����ꤹ
# �뤳�ȤϤǤ��ޤ���ʣ�����ꤹ����ϥ��ڡ����Ƕ��ڤäƤ����������ɥ�
# �ȥɥå�(..)�ϡ֤ҤȤľ�Υե�����פ��̣���ޤ���
$target_dir = '../../Public/news/data/html/2003 ../../Public/news/data/html/2004 ../../Public/news/data/html/2005 ../../Public/news/data/html/2006 ../../Public/news/data/html/2007';

# �� �����оݥե�����
# �����оݤȤ���ե�����γ�ĥ�Ҥ���ꤷ�ޤ���.htm �� .txt �ʤɤΥƥ�����
# �ե�����Τ߻���Ǥ��ޤ���.doc �� .xls �ʤɤ����ѥ��ץꥱ�������ɬ��
# �ʤ�Τϻ���Ǥ��ޤ���
$suffix = ".htm .html";

# �� ���̥ե���������ե饰
# ���̤Υե�������Ū�˸����������1����ꤷ�Ƥ���������
$recursive_flag = 0;

# �� [���]�ܥ���
# [���]�Υ�󥯤򥯥�å����줿���˥����פ�����Υڡ�������ꤷ��
# ����������http://�� �ǤϤ��ޤ�URL������ǽ�Ǥ���
$return_url = './';

# �� �����оݥե�����δ���������
# �����оݤΥե�����δ��������ɤ���ꤷ�Ƥ������������ե�JIS�ξ��� "sjis"��
# EUC�ξ��� "euc"��JIS�����ɤ������ʾ��� "unknown" ����ꤷ�Ƥ���������
# sjis �� euc �ξ��ϸ������᤯�ʤ�ޤ���
$kcode_file = "euc";

# �� ������̥ҥ�Ȥ�ɽ���Կ�
# ������̤ˡ��ե���������ƤΥҥ�ȤȤ���ɽ������Կ�����ꤷ�ޤ���
$how_many_lines = 2;			# �ޥå������Ԥ����岿�Ԥ�ɽ�����뤫

# �� �ǥХå��⡼��
# �ǥХå���Ԥ�����1����ꤷ�Ƥ���������
$debug_mode = 0;

# �� ���󥰥ե饰
# wwwsrch.log �ե�����˥��󥰤�Ԥ����� 1 ����ꤷ�Ƥ���������
$do_logging = 1;

# �� ���ե�����̾
# ���󥰤�Ԥ��ե�����̾ wwwsrch.log ���ѹ������������ѹ����Ƥ���������
$logging_file = "wwwsrch.log";

# �� �ե�����̾ɽ��
# ������̤Υ����ȥ�β��˥ե�����̾��ɽ���������1��ɽ�����ʤ�����0��
# ���ꤷ�Ƥ���������
$print_filename = 0;

# �� �ǥ�����
#$bgcolor = "#FFFFFF";
#$text_color = "#000000";
#$link_color = "#0000EE";
#$alink_color = "#FF0000";
#$vlink_color = "#000080";

# =================================================================
# ����
# =================================================================

#
# CGI�ƥ�����
#
if ("$ARGV[0]" eq "test") {
	print "Content-type: text/html\n";
	print "\n";
	print "CGI Script OK.\n";
	exit(0);
}

#
# �������
#
$| = 1;				# ���Ϥ�Хåե���󥰤��ʤ��褦�ˤ���
$found_count = 0;		# ���Ĥ��ä����

#
# ���Υ�����ץȤδ��������ɤ�Ĵ�٤�
#
if ((ord("��") == 0xb4) || (ord("��") == -76)) { $kcode_cgi = "euc"; }
if ((ord("��") == 0x8a) || (ord("��") == -118)) { $kcode_cgi = "sjis"; }
if (ord("��") == 0x1b) { $kcode_cgi = "jis"; }

#
# �ᥤ��롼����
#
{
	# �����������Ѵ��饤�֥����ɤ߹���
	if (-f "jcode.pl") {
		require "jcode.pl";
	} else {
		&errexit("jcode.pl������ޤ���\n");
	}

	# ���ե��å�����ʬ�򤹤�
	foreach $tmp (split(/ +/, $suffix)) {
		$suffix{$tmp} = 1;
	}

	# �ե����फ������ϥǡ������ɤ߹���
	&readform();

	# �������ɬ�פ˱�����SJIS/EUC���Ѵ�����
	$word = $FORM{'WORD'};
	if ($word =~ /[\x80-\xff]/) {

		# ���ܸ줬�ޤޤ�Ƥ���ե饰
		$jflag = 1;			# ���ܸ줬�ޤޤ�Ƥ���

		# ����EUC���Ѵ�����
		&jcode'convert(*word, "euc");

		# ���Ѷ����Ⱦ�Ѷ�����ִ�����(EUC�ζ����#A1A1)
		$word =~ s/([\x80-\xff][\x80-\xff]|[\x00-\x7f])/($1 eq "\xa1\xa1") ? " " : $1/eg;

		# SJIS�⡼�ɤǤ����SJIS���Ѵ�����
		if ($kcode_file eq "sjis") {
			&jcode'convert(*word, "sjis");
		}
	}

	# ����������ɲä���
	if ($do_logging && ($word ne "")) {
		($sec, $min, $hour, $mday, $mon, $year) = localtime(time);
		$tmp = $word;
		&jcode'convert(*tmp, $kcode_cgi);
		open(OUT, ">> $logging_file");
		printf(OUT "%04d-%02d-%02d %02d:%02d:%02d %s %s\n",
			$year + 1900, $mon + 1, $mday, $hour, $min, $sec,
			$ENV{'REMOTE_ADDR'}, $tmp);
		close(OUT);
	}

	# HTMLʸ���񤭽Ф�
	print "Content-type: text/html; charset=EUC-JP\n";
	print "\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "<TITLE>���˥塼������</TITLE>\n";
	print "<META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\">\n";
	print "<meta http-equiv=\"content-style-type\" content=\"text/css\">";
	print "<link rel=\"stylesheet\" href=\"theme/citrus/citrus.css\" title=\"citrus\" type=\"text/css\" media=\"all\">";
	print "</HEAD>\n";
#	print "<BODY BGCOLOR=\"$bgcolor\" TEXT=\"$text_color\" LINK=\"$link_color\" ALINK=\"$alink_color\" VLINK=\"$vlink_color\">\n";
	print "<BODY>\n";
	print "<div class=\"body\">\n";
	print "<H3>���˥塼������</H3>\n";
	print "<FORM METHOD=POST ACTION=\"wwwsrch.cgi\">\n";
	print "<NOBR>\n";
	$tmp = $word;
	&jcode'convert(*tmp, $kcode_cgi);
	$tmp =~ s/&/&amp;/g;
	$tmp =~ s/</&lt;/g;
	$tmp =~ s/>/&gt;/g;
	$tmp =~ s/"/&quot;/g;
	print "<INPUT TYPE=text NAME=WORD SIZE=25 VALUE=\"$tmp\">\n";
	print "<INPUT TYPE=submit VALUE=\"����\">\n";
	if ($FORM{'ANDOR'} eq "or") {
		print "<INPUT TYPE=radio NAME=ANDOR VALUE=and>AND\n";
		print "<INPUT TYPE=radio NAME=ANDOR VALUE=or CHECKED>OR\n";
	} else {
		print "<INPUT TYPE=radio NAME=ANDOR VALUE=and CHECKED>AND\n";
		print "<INPUT TYPE=radio NAME=ANDOR VALUE=or>OR\n";
	}
	print "</NOBR>\n";
	print "</FORM>\n";
	print "<UL>\n";
	print "<LI>���˥塼���򸡺����ޤ���\n";
	print "<LI>ʣ����ñ������Ϥ�����ϥ��ڡ����Ƕ��ڤäƤ���������\n";
	print "<LI>�ʬ���äƤ�����ϡ�hogehoge 2003-06�פȤ�������ǯ��򸡺�ñ��˲ä��Ƥ���������\n";
	print "</UL>\n";
	if ($return_url ne "") {
		print "<A HREF=\"$return_url\">[���]</A>\n";
	}
	print "<HR>\n";
	if (defined($FORM{'WORD'})) {

		# �᥿ʸ����̵��������
		if (!$jflag) {
			$word =~ s/([\+\*\.\?\^\$\[\-\]\|\(\)\\])/\\$1/g;
		}

		# �������ʬ�䤹��
		@words = split(/ +/, $word);

		# ��������
		print "<DL>\n";
		@dirs = split(/ +/, $target_dir);
		foreach $dir (@dirs) {
			&search1($dir);
		}
		print "</DL>\n";

		# ��̤�񤭽Ф�
		print "<HR>\n";
		if ($found_count) {
			print "$found_count ��ߤĤ���ޤ�����\n";
		} else {
			print "1���ߤĤ���ޤ���Ǥ�����\n";
			$word =~ s/(\W)/'%'.unpack("H2", $1)/ego;
			print "[ <a href=\"http://www.google.com/search?lr=lang_ja&q=$word\">Google�Ǹ���</a> ]\n";
		}
	}
	print "</div>\n";
	print "</BODY>\n";
	print "</HTML>\n";
}

#
# �ե����फ������ϥǡ������ɤ߹���� $FORM{'XXXX'} �����ꤹ��
#
sub readform {
	if ($ENV{'REQUEST_METHOD'} eq "POST") {
		read(STDIN, $query_string, $ENV{'CONTENT_LENGTH'});
	} else {
		$query_string = $ENV{'QUERY_STRING'};
	}
	@a = split(/&/, $query_string);
	foreach $x (@a) {
		($name, $value) = split(/=/, $x);
		$value =~ tr/+/ /;
		$value =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("C", hex($1))/eg;
		$FORM{$name} = $value;
	}
}

#
# ���٤ƤΥե������ʤ��
#
sub search1 {
	local($dir) = $_[0];
	local(@filelist, $file, $filename);
	opendir(DIR, $dir);
	@filelist = readdir(DIR);
	closedir(DIR);
	foreach $file (@filelist) {
		if ($file eq ".") { next; }
		if ($file eq "..") { next; }
		$filename = "$dir/$file";
		if (-d $filename) {
			if ($recursive_flag) {
				&search1($filename);
			}
		} else {
			&search2($filename, $dir);
		}
	}
}

#
# �ե��������Ȥ򸡺�����
#
sub search2 {
	local($target, $tdir) = @_;

	# ���ꤷ�Ƥ��ʤ���ĥ�ҤΥե������̵�뤹��
	$fname = substr($target, rindex($target, "."));
	if ($suffix{$fname} != 1) {
		return;
	}

	# �ǥХå�ʸ
	if ($debug_mode) {
		print "<DT>�����桧$target...<BR>";
	}

	# �Ƽ��ѿ�����������
	undef %wordflag;
	$title = "";
	$match_count = 0;

	# �ե�������ɤ߹���
	open(IN, $target);
	@lines = <IN>;
	close(IN);

	# Mac�� \r ���ԤΥե�������Ф����θ
	if (($#lines == 0) && ($lines[0] =~ /\r[^\n]/)) {
		@lines = split(/\r/, $lines[0]);
	}

	# ���줾��ιԤ��Ф�������
	loop: for ($i = 0; $i <= $#lines; $i++) {
		$line = $lines[$i];

		# ���������ɤ��Ѵ�����
		if ($jflag && ($kcode_file eq "unknown")) {
			&jcode'convert(*line, "euc");
		}

		# �����ȥ��Ф��Ƥ���
		if (($title eq "") && ($line =~ /<TITLE>/i)) {
			$title = $line;
		}

		# ���줾��θ�������Ф��ơ�����
		foreach $word (@words) {
			# ���Ǥ˸��Ĥ��äƤ���ʤ鼡�ι�
			if ($wordflag{$word} == 1) { next; }

			# �����줬���Ĥ���ʤ��ʤ鼡�ι�
			if ($jflag) {
				if (index($line, $word) == -1) { next; }
			} else {
				if ($line !~ /$word/i) { next; }
			}

			# ���Ĥ��ä����Ȥ�Ф��Ƥ���
			$wordflag{$word} = 1;

			# AND�����Ǥ��٤Ƹ��Ĥ��ä��ΤǤʤ��ʤ鼡�ι�
			if (($FORM{'ANDOR'} eq "and") &&
					(++$match_count != $#words + 1)) {
				next;
			}

			# URL�ִ���Ԥ�
			# $target =~ s|������|������|;
			$target =~ s|../../Public/news/data/html/(\d+)/(\d+).html|/~kaku/tdiary/$1$2.html|;

			# ɽ������
			$found_count++;
			print "<P>\n";
			print "<DT>$found_count��<A HREF=\"$target\">";
			$title =~ s/<[^>]*(>|$)//g;
			$title =~ s/[\r\n]+//g;
			&jcode'convert(*title, $kcode_cgi);
			if ($title eq "") {
				$title = $target;
			}
			print "$title</A>\n";
			if ($print_filename) {
				print "( <A HREF=\"$target\">";
				$target =~ s/$tdir\/?//;
				print "$target</A> )\n";
			}
			print "<DD>";
			$imin = $i - $how_many_lines;
			if ($imin < 0) { $imin = 0; }
			$imax = $i + $how_many_lines;
			if ($imax > $#lines) { $imax = $#lines; }
			for ($j = $imin; $j <= $imax; $j++) {
				$line = $lines[$j];
				&jcode'convert(*line, "euc");
				$line =~ s/<[^>]*(>|$)//g;
				$tmp = $word;
				&jcode'convert(*tmp, "euc");
				if ($jflag) {
					$tmp =~ s/([\+\*\.\?\^\$\[\-\]\|\(\)\\])/\\$1/g;
				}
				$line =~ s/($tmp)/<span id="search_highlight" style="font-weight: bold; color: black; background-color: #ffff66">$1<\/span>/ig;
				&jcode'convert(*line, $kcode_cgi, "euc");
				print "$line ";
			}
			print "\n";
			last loop;
		}
	}
}

#
# ���顼��λ����
#
sub errexit {
	local($msg) = @_;
#===============================
print <<END_OF_DATA;
Content-type: text/html

<HTML>
<HEAD>
<TITLE>���˥塼������</TITLE>
</HEAD>
<BODY>
$msg
</BODY>
</HTML>
END_OF_DATA
#===============================
exit(1);
}

