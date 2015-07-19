#!/usr/bin/perl

# =================================================================
# 名前: wwwsrch.cgi Ver3.13
# 機能: ホームページの内容を検索するCGIスクリプト。
# 種別：フリーソフト（私用・商用問わず、利用・改造・流用・再配布可）
# 作者: 杜甫々
# 参照: http://tohoho.wakusei.ne.jp/
# =================================================================

# =================================================================
# 初期化パラメータ
# =================================================================

# ★ Perlのパス名
# 1行目の #!/usr/local/bin/perl の行を、使用しているプロバイダやサーバー
# の環境にあわせて変更してください。

# ★ 検索対象フォルダ
# 検索対象のフォルダ名を指定してください。http://〜 のようなURLを指定す
# ることはできません。複数指定する場合はスペースで区切ってください。ドッ
# トドット(..)は「ひとつ上のフォルダ」を意味します。
$target_dir = '../../Public/news/data/html/2003 ../../Public/news/data/html/2004 ../../Public/news/data/html/2005 ../../Public/news/data/html/2006 ../../Public/news/data/html/2007';

# ★ 検索対象ファイル
# 検索対象とするファイルの拡張子を指定します。.htm や .txt などのテキスト
# ファイルのみ指定できます。.doc や .xls などの専用アプリケーションが必要
# なものは指定できません。
$suffix = ".htm .html";

# ★ 下位フォルダ検索フラグ
# 下位のフォルダを回帰的に検索する場合は1を指定してください。
$recursive_flag = 0;

# ★ [戻る]ボタン
# [戻る]のリンクをクリックされた時にジャンプする先のページを指定して
# ください。http://〜 ではじまるURLも指定可能です。
$return_url = './';

# ★ 検索対象ファイルの漢字コード
# 検索対象のファイルの漢字コードを指定してください。シフトJISの場合は "sjis"、
# EUCの場合は "euc"、JISコードや不明な場合は "unknown" を指定してください。
# sjis や euc の場合は検索が早くなります。
$kcode_file = "euc";

# ★ 検索結果ヒントの表示行数
# 検索結果に、ファイルの内容のヒントとして表示する行数を指定します。
$how_many_lines = 2;			# マッチした行の前後何行を表示するか

# ★ デバッグモード
# デバッグを行う場合は1を指定してください。
$debug_mode = 0;

# ★ ロギングフラグ
# wwwsrch.log ファイルにロギングを行う場合は 1 を指定してください。
$do_logging = 1;

# ★ ログファイル名
# ロギングを行うファイル名 wwwsrch.log を変更したい場合に変更してください。
$logging_file = "wwwsrch.log";

# ★ ファイル名表示
# 検索結果のタイトルの横にファイル名を表示する場合は1を、表示しない場合は0を
# 指定してください。
$print_filename = 0;

# ★ デザイン
#$bgcolor = "#FFFFFF";
#$text_color = "#000000";
#$link_color = "#0000EE";
#$alink_color = "#FF0000";
#$vlink_color = "#000080";

# =================================================================
# 本体
# =================================================================

#
# CGIテスト用
#
if ("$ARGV[0]" eq "test") {
	print "Content-type: text/html\n";
	print "\n";
	print "CGI Script OK.\n";
	exit(0);
}

#
# 初期設定
#
$| = 1;				# 出力をバッファリングしないようにする
$found_count = 0;		# 見つかった件数

#
# このスクリプトの漢字コードを調べる
#
if ((ord("漢") == 0xb4) || (ord("漢") == -76)) { $kcode_cgi = "euc"; }
if ((ord("漢") == 0x8a) || (ord("漢") == -118)) { $kcode_cgi = "sjis"; }
if (ord("漢") == 0x1b) { $kcode_cgi = "jis"; }

#
# メインルーチン
#
{
	# 漢字コード変換ライブラリを読み込む
	if (-f "jcode.pl") {
		require "jcode.pl";
	} else {
		&errexit("jcode.plがありません。\n");
	}

	# サフィックスを分解する
	foreach $tmp (split(/ +/, $suffix)) {
		$suffix{$tmp} = 1;
	}

	# フォームからの入力データを読み込む
	&readform();

	# 検索語を必要に応じてSJIS/EUCに変換する
	$word = $FORM{'WORD'};
	if ($word =~ /[\x80-\xff]/) {

		# 日本語が含まれているフラグ
		$jflag = 1;			# 日本語が含まれている

		# 一度EUCに変換する
		&jcode'convert(*word, "euc");

		# 全角空白を半角空白に置換する(EUCの空白は#A1A1)
		$word =~ s/([\x80-\xff][\x80-\xff]|[\x00-\x7f])/($1 eq "\xa1\xa1") ? " " : $1/eg;

		# SJISモードであればSJISに変換する
		if ($kcode_file eq "sjis") {
			&jcode'convert(*word, "sjis");
		}
	}

	# 検索語ログに追加する
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

	# HTML文書を書き出す
	print "Content-type: text/html; charset=EUC-JP\n";
	print "\n";
	print "<HTML>\n";
	print "<HEAD>\n";
	print "<TITLE>過去ニュース検索</TITLE>\n";
	print "<META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\">\n";
	print "<meta http-equiv=\"content-style-type\" content=\"text/css\">";
	print "<link rel=\"stylesheet\" href=\"theme/citrus/citrus.css\" title=\"citrus\" type=\"text/css\" media=\"all\">";
	print "</HEAD>\n";
#	print "<BODY BGCOLOR=\"$bgcolor\" TEXT=\"$text_color\" LINK=\"$link_color\" ALINK=\"$alink_color\" VLINK=\"$vlink_color\">\n";
	print "<BODY>\n";
	print "<div class=\"body\">\n";
	print "<H3>過去ニュース検索</H3>\n";
	print "<FORM METHOD=POST ACTION=\"wwwsrch.cgi\">\n";
	print "<NOBR>\n";
	$tmp = $word;
	&jcode'convert(*tmp, $kcode_cgi);
	$tmp =~ s/&/&amp;/g;
	$tmp =~ s/</&lt;/g;
	$tmp =~ s/>/&gt;/g;
	$tmp =~ s/"/&quot;/g;
	print "<INPUT TYPE=text NAME=WORD SIZE=25 VALUE=\"$tmp\">\n";
	print "<INPUT TYPE=submit VALUE=\"検索\">\n";
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
	print "<LI>過去ニュースを検索します。\n";
	print "<LI>複数の単語を入力する時はスペースで区切ってください。\n";
	print "<LI>月が分かっている場合は「hogehoge 2003-06」という風に年月を検索単語に加えてください。\n";
	print "</UL>\n";
	if ($return_url ne "") {
		print "<A HREF=\"$return_url\">[戻る]</A>\n";
	}
	print "<HR>\n";
	if (defined($FORM{'WORD'})) {

		# メタ文字を無効化する
		if (!$jflag) {
			$word =~ s/([\+\*\.\?\^\$\[\-\]\|\(\)\\])/\\$1/g;
		}

		# 検索語を分割する
		@words = split(/ +/, $word);

		# 検索する
		print "<DL>\n";
		@dirs = split(/ +/, $target_dir);
		foreach $dir (@dirs) {
			&search1($dir);
		}
		print "</DL>\n";

		# 結果を書き出す
		print "<HR>\n";
		if ($found_count) {
			print "$found_count 件みつかりました。\n";
		} else {
			print "1件もみつかりませんでした。\n";
			$word =~ s/(\W)/'%'.unpack("H2", $1)/ego;
			print "[ <a href=\"http://www.google.com/search?lr=lang_ja&q=$word\">Googleで検索</a> ]\n";
		}
	}
	print "</div>\n";
	print "</BODY>\n";
	print "</HTML>\n";
}

#
# フォームからの入力データを読み込んで $FORM{'XXXX'} に設定する
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
# すべてのファイルをなめ回す
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
# ファイルの中身を検索する
#
sub search2 {
	local($target, $tdir) = @_;

	# 指定していない拡張子のファイルは無視する
	$fname = substr($target, rindex($target, "."));
	if ($suffix{$fname} != 1) {
		return;
	}

	# デバッグ文
	if ($debug_mode) {
		print "<DT>検索中：$target...<BR>";
	}

	# 各種変数を初期化する
	undef %wordflag;
	$title = "";
	$match_count = 0;

	# ファイルを読み込む
	open(IN, $target);
	@lines = <IN>;
	close(IN);

	# Macの \r 改行のファイルに対する考慮
	if (($#lines == 0) && ($lines[0] =~ /\r[^\n]/)) {
		@lines = split(/\r/, $lines[0]);
	}

	# それぞれの行に対し・・・
	loop: for ($i = 0; $i <= $#lines; $i++) {
		$line = $lines[$i];

		# 漢字コードを変換する
		if ($jflag && ($kcode_file eq "unknown")) {
			&jcode'convert(*line, "euc");
		}

		# タイトルを覚えておく
		if (($title eq "") && ($line =~ /<TITLE>/i)) {
			$title = $line;
		}

		# それぞれの検索語に対して・・・
		foreach $word (@words) {
			# すでに見つかっているなら次の行
			if ($wordflag{$word} == 1) { next; }

			# 検索語が見つからないなら次の行
			if ($jflag) {
				if (index($line, $word) == -1) { next; }
			} else {
				if ($line !~ /$word/i) { next; }
			}

			# 見つかったことを覚えておく
			$wordflag{$word} = 1;

			# AND検索ですべて見つかったのでないなら次の行
			if (($FORM{'ANDOR'} eq "and") &&
					(++$match_count != $#words + 1)) {
				next;
			}

			# URL置換を行う
			# $target =~ s|○○○|△△△|;
			$target =~ s|../../Public/news/data/html/(\d+)/(\d+).html|/~kaku/tdiary/$1$2.html|;

			# 表示する
			$found_count++;
			print "<P>\n";
			print "<DT>$found_count．<A HREF=\"$target\">";
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
# エラー終了する
#
sub errexit {
	local($msg) = @_;
#===============================
print <<END_OF_DATA;
Content-type: text/html

<HTML>
<HEAD>
<TITLE>過去ニュース検索</TITLE>
</HEAD>
<BODY>
$msg
</BODY>
</HTML>
END_OF_DATA
#===============================
exit(1);
}

