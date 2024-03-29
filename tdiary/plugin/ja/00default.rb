#
# ja/00default.rb: Japanese resources of 00default.rb.
#

#
# header
#
def title_tag
	r = "<title>#{CGI::escapeHTML( @html_title )}"
	case @mode
	when 'day', 'comment'
		r << "(#{@date.strftime( '%Y-%m-%d' )})" if @date
	when 'month'
		r << "(#{@date.strftime( '%Y-%m' )})" if @date
	when 'form'
		r << '(追記)'
	when 'edit'
		r << '(編集)'
	when 'preview'
		r << '(プレビュー)'
	when 'showcomment'
		r << '(変更完了)'
	when 'conf'
		r << '(設定)'
	when 'saveconf'
		r << '(設定完了)'
	when 'nyear'
		years = @diaries.keys.map {|ymd| ymd.sub(/^\d{4}/, "")}
		r << "(#{@cgi.params['date'][0].sub( /^(\d\d)/, '\1-')}[#{nyear_diary_label @date, years}])" if @date
	end
	r << '</title>'
end

#
# TSUKKOMI mail
#
def comment_mail_mime( str )
	require 'nkf'
	NKF::nkf( "-j -m0 -f50", str ).collect do |s|
		%Q|=?ISO-2022-JP?B?#{[s.chomp].pack( 'm' ).gsub( /\n/, '' )}?=|
	end
end

def comment_mail_conf_label; 'ツッコミメール'; end

def comment_mail_basic_html
	@conf['comment_mail.header'] = '' unless @conf['comment_mail.header']
	@conf['comment_mail.receivers'] = '' unless @conf['comment_mail.receivers']

	<<-HTML
	<h3 class="subtitle">ツッコミメールを送る</h3>
	#{"<p>ツッコミがあった時に、メールを送るかどうかを選択します。</p>" unless @conf.mobile_agent?}
	<p><select name="comment_mail.enable">
		<option value="true"#{if @conf['comment_mail.enable'] then " selected" end}>送る</option>
        <option value="false"#{if not @conf['comment_mail.enable'] then " selected" end}>送らない</option>
	</select></p>
	<h3 class="subtitle">送付先</h3>
	#{"<p>メールの送付先を指定します。1行に1メールアドレスの形で、複数指定可能です。指定のない場合には、あなたのメールアドレスに送られます。</p>" unless @conf.mobile_agent?}
	<p><textarea name="comment_mail.receivers" cols="40" rows="3">#{CGI::escapeHTML( @conf['comment_mail.receivers'].gsub( /[, ]+/, "\n") )}</textarea></p>
	<h3 class="subtitle">メールヘッダ</h3>
	#{"<p>メールのSubjectにつけるヘッダ文字列を指定します。振り分け等に便利なように指定します。実際のSubjectには「指定文字列:日付-1」のように、日付とコメント番号が付きます。ただし指定文字列中に、%に続く英字があった場合、それを日付フォーマット指定を見なします。つまり「日付」の部分は自動的に付加されなくなります(コメント番号は付加されます)。</p>" unless @conf.mobile_agent?}
	<p><input name="comment_mail.header" value="#{CGI::escapeHTML( @conf['comment_mail.header'])}"></p>
	HTML
end

#
# link to HOWTO write diary
#
def style_howto
	%Q|/<a href="http://docs.tdiary.org/ja/?#{@conf.style}%A5%B9%A5%BF%A5%A4%A5%EB">書き方</a>|
end

#
# labels (normal)
#
def no_diary; "#{@date.strftime( @conf.date_format )}の日記はありません。"; end
def comment_today; '本日のツッコミ'; end
def comment_total( total ); "(全#{total}件)"; end
def comment_new; 'ツッコミを入れる'; end
def comment_description; 'ツッコミ・コメントがあればどうぞ! E-mailアドレスは公開されません。'; end
def comment_description_short; 'ツッコミ!!'; end
def comment_name_label; 'お名前'; end
def comment_name_label_short; '名前'; end
def comment_mail_label; 'E-mail'; end
def comment_mail_label_short; 'Mail'; end
def comment_body_label; 'コメント'; end
def comment_body_label_short; '本文'; end
def comment_submit_label; '投稿'; end
def comment_submit_label_short; '投稿'; end
def comment_date( time ); time.strftime( "(#{@date_format} %H:%M)" ); end
def referer_today; '本日のリンク元'; end
def trackback_today; '本日のTrackBacks'; end
def trackback_total( total ); "(全#{total}件)"; end

def navi_index; 'トップ'; end
def navi_latest; '最新'; end
def navi_oldest; '最古'; end
def navi_update; "追記"; end
def navi_edit; "編集"; end
def navi_preference; "設定"; end
def navi_prev_diary(date); "前の日記(#{date.strftime(@date_format)})"; end
def navi_next_diary(date); "次の日記(#{date.strftime(@date_format)})"; end
def navi_prev_nyear(date); "前の日(#{date.strftime('%m-%d')})"; end
def navi_next_nyear(date); "次の日(#{date.strftime('%m-%d')})"; end

def submit_label
	if @mode == 'form' or @cgi.valid?( 'appendpreview' ) then
		'追記'
	else
		'登録'
	end
end
def preview_label; 'プレビュー'; end

def label_no_referer; 'リンク元記録除外リスト'; end
def label_referer_table; 'リンク置換リスト'; end

def nyear_diary_label(date, years); "長年日記"; end
def nyear_diary_title(date, years); "長年日記"; end

#
# labels (for mobile)
#
def mobile_navi_latest; '最新'; end
def mobile_navi_update; "追記"; end
def mobile_navi_preference; "設定"; end
def mobile_navi_prev_diary; "前"; end
def mobile_navi_next_diary; "次"; end
def mobile_label_hidden_diary; 'この日は【非表示】です'; end

#
# category
#
def category_anchor(c); "[#{c}]"; end

#
# preferences (resources)
#
add_conf_proc( 'default', '基本' ) do
	saveconf_default
	<<-HTML
	<h3 class="subtitle">著者名</h3>
	#{"<p>あなたの名前を指定します。HTMLヘッダ中に展開されます。</p>" unless @conf.mobile_agent?}
	<p><input name="author_name" value="#{CGI::escapeHTML @conf.author_name}" size="40"></p>
	<h3 class="subtitle">メールアドレス</h3>
	#{"<p>あなたのメールアドレスを指定します。HTMLヘッダ中に展開されます。</p>" unless @conf.mobile_agent?}
	<p><input name="author_mail" value="#{@conf.author_mail}" size="40"></p>
	<h3 class="subtitle">トップページURL</h3>
	#{"<p>日記よりも上位のコンテンツがあれば指定します。存在しない場合は何も入力しなくてかまいません。</p>" unless @conf.mobile_agent?}
	<p><input name="index_page" value="#{@conf.index_page}" size="50"></p>
	<h3 class="subtitle">時差調整</h3>
	#{"<p>更新時、フォームに挿入される日付を時間単位で調整できます。例えば午前2時までは前日として扱いたい場合には「-2」のように指定することで、2時間分引かれた日付が挿入されるようになります。また、この日付はWebサーバ上の時刻になっているので、海外のサーバで運営している場合の時差調整にも利用できます。</p>" unless @conf.mobile_agent?}
	<p><input name="hour_offset" value="#{@conf.hour_offset}" size="5"></p>
	HTML
end

add_conf_proc( 'header', 'ヘッダ・フッタ' ) do
	saveconf_header

	<<-HTML
	<h3 class="subtitle">タイトル</h3>
	#{"<p>HTMLの&lt;title&gt;タグ中および、モバイル端末からの参照時に使われるタイトルです。HTMLタグは使えません。</p>" unless @conf.mobile_agent?}
	<p><input name="html_title" value="#{ CGI::escapeHTML @conf.html_title }" size="50"></p>
	<h3 class="subtitle">ヘッダ</h3>
	#{"<p>日記の先頭に挿入される文章を指定します。HTMLタグが使えます。「&lt;%=navi%&gt;」で、ナビゲーションボタンを挿入できます(これがないと更新ができなくなるので削除しないようにしてください)。また、「&lt;%=calendar%&gt;」でカレンダーを挿入できます。その他、各種プラグインを記述できます。</p>" unless @conf.mobile_agent?}
	<p><textarea name="header" cols="70" rows="10">#{ CGI::escapeHTML @conf.header }</textarea></p>
	<h3 class="subtitle">フッタ</h3>
	#{"<p>日記の最後に挿入される文章を指定します。ヘッダと同様に指定できます。</p>" unless @conf.mobile_agent?}
	<p><textarea name="footer" cols="70" rows="10">#{ CGI::escapeHTML @conf.footer }</textarea></p>
	HTML
end

add_conf_proc( 'display', '表示一般' ) do
	saveconf_display

	<<-HTML
	<h3 class="subtitle">セクションアンカー</h3>
	#{"<p>日記のセクションの先頭(サブタイトルの行頭)に挿入される、リンク用のアンカー文字列を指定します。なお「&lt;span class=\"sanchor\"&gt;_&lt;/span&gt;」を指定すると、テーマによっては自動的に画像アンカーがつくようになります。</p>" unless @conf.mobile_agent?}
	<p><input name="section_anchor" value="#{ CGI::escapeHTML @conf.section_anchor }" size="40"></p>
	<h3 class="subtitle">ツッコミアンカー</h3>
	#{"<p>読者からのツッコミの先頭に挿入される、リンク用のアンカー文字列を指定します。なお「&lt;span class=\"canchor\"&gt;_&lt;/span&gt;」を指定すると、テーマによっては自動的に画像アンカーがつくようになります。</p>" unless @conf.mobile_agent?}
	<p><input name="comment_anchor" value="#{ CGI::escapeHTML @conf.comment_anchor }" size="40"></p>
	<h3 class="subtitle">日付フォーマット</h3>
	#{"<p>日付の表示部分に使われるフォーマットを指定します。任意の文字が使えますが、「%」で始まる英字には次のような特殊な意味があります。「%Y」(西暦年)、「%m」(月数値)、「%b」(短月名)、「%B」(長月名)、「%d」(日)、「%a」(短曜日名)、「%A」(長曜日名)。</p>" unless @conf.mobile_agent?}
	<p><input name="date_format" value="#{ CGI::escapeHTML @conf.date_format }" size="30"></p>
	<h3 class="subtitle">最新表示の最大日数</h3>
	#{"<p>最新の日記を表示するときに、そのページ内に何日分の日記を表示するかを指定します。</p>" unless @conf.mobile_agent?}
	<p>最大<input name="latest_limit" value="#{ @conf.latest_limit }" size="2">日分</p>
	<h3 class="subtitle">長年日記の表示</h3>
	#{"<p>長年日記を表示するためのリンクを表示するかどうかを指定します。</p>" unless @conf.mobile_agent?}
	<p><select name="show_nyear">
		<option value="true"#{if @conf.show_nyear then " selected" end}>表示</option>
        <option value="false"#{if not @conf.show_nyear then " selected" end}>非表示</option>
	</select></p>
	HTML
end

@theme_location_comment = "<p>ここにないテーマは<a href=\"http://www.tdiary.org/20021001.html\">テーマ・ギャラリー</a>から入手できます。</p>"

add_conf_proc( 'theme', 'テーマ' ) do
	saveconf_theme

	 r = <<-HTML
	<h3 class="subtitle">テーマの指定</h3>
	#{"<p>日記のデザインをテーマ、もしくはCSSの直接入力で指定します。ドロップダウンメニューから「CSS指定→」を選択した場合には、右の欄にCSSのURLを入力してください。</p>" unless @conf.mobile_agent?}
	<p>
	<select name="theme">
		<option value="">CSS指定→</option>
	HTML
	@conf_theme_list.each do |theme|
		r << %Q|<option value="#{theme[0]}"#{if theme[0] == @conf.theme then " selected" end}>#{theme[1]}</option>|
	end
	r << <<-HTML
	</select>
	<input name="css" size="50" value="#{ @conf.css }">
	</p>
	#{@theme_location_comment unless @conf.mobile_agent?}
	HTML
end

add_conf_proc( 'comment', 'ツッコミ' ) do
	saveconf_comment

	<<-HTML
	<h3 class="subtitle">ツッコミの表示</h3>
	#{"<p>読者からのツッコミを表示するかどうかを指定します。</p>" unless @conf.mobile_agent?}
	<p><select name="show_comment">
		<option value="true"#{if @conf.show_comment then " selected" end}>表示</option>
		<option value="false"#{if not @conf.show_comment then " selected" end}>非表示</option>
	</select></p>
	<h3 class="subtitle">ツッコミリスト表示数</h3>
	#{"<p>最新もしくは月別表示時に表示する、ツッコミの最大件数を指定します。なお、日別表示時にはここの指定にかかわらずすべてのツッコミが表示されます。</p>" unless @conf.mobile_agent?}
	<p>最大<input name="comment_limit" value="#{ @conf.comment_limit }" size="3">件</p>
	HTML
end

add_conf_proc( 'referer', 'リンク元' ) do
	saveconf_referer

	<<-HTML
	<h3 class="subtitle">リンク元の表示</h3>
	#{"<p>リンク元リストを表示するかどうかを指定します。</p>" unless @conf.mobile_agent?}
	<p><select name="show_referer">
		<option value="true"#{if @conf.show_referer then " selected" end}>表示</option>
		<option value="false"#{if not @conf.show_referer then " selected" end}>非表示</option>
	</select></p>
	<h3 class="subtitle">リンク元リスト表示数</h3>
	#{"<p>最新もしくは月別表示時に表示する、リンク元リストの最大件数を指定します。なお、日別表示時にはここの指定にかかわらずすべてのリンク元が表示されます。</p>" unless @conf.mobile_agent?}
	<p>最大<input name="referer_limit" value="#{@conf.referer_limit}" size="3">サイト</p>
	<h3 class="subtitle">リンク元の記録制御</h3>
	#{"<p>日付指定のアクセス時のリンク元だけを記録するかどうかを指定します。この指定をするとアンテナやリンク集からの情報が記録されなくなるので、リンク元のノイズが減少します。</p>" unless @conf.mobile_agent?}
	<p><select name="referer_day_only">
		<option value="true"#{if @conf.referer_day_only then " selected" end}>日付指定時のアクセスのみ記録する</option>
		<option value="false"#{if not @conf.referer_day_only then " selected" end}>すべてのアクセスで記録する</option>
	</select></p>
	<h3 class="subtitle">リンク元記録除外リスト</h3>
	#{"<p>リンク元リストに追加しないURLを指定します。正規表現で指定できます。1件1行で入力してください。</p>" unless @conf.mobile_agent?}
	<p>→<a href="#{@conf.update}?referer=no" target="referer">既存設定はこちら</a></p>
	<p><textarea name="no_referer" cols="70" rows="10">#{@conf.no_referer2.join( "\n" )}</textarea></p>
	<h3 class="subtitle">リンク元置換リスト</h3>
	#{"<p>リンク元リストのURLを、特定の文字列に変換する対応表を指定できます。1件につき、URLと表示文字列を空白で区切って指定します。正規表現が使えるので、URL中に現れた「(〜)」は、置換文字列中で「\\1」のような「\数字」で利用できます。</p>" unless @conf.mobile_agent?}
	<p>→<a href="#{@conf.update}?referer=table" target="referer">既存設定はこちら</a></p>
	<p><textarea name="referer_table" cols="70" rows="10">#{@conf.referer_table2.collect{|a|a.join( " " )}.join( "\n" )}</textarea></p>
	HTML
end

add_conf_proc( 'csrf_protection', 'CSRF(乗っ取り)対策' ) do
	err = saveconf_csrf_protection
	errstr = ''
	case err
	when :param
		errstr = '<p class="message">不正な組み合わせです。変更されませんでした。</p>'
	when :key
		errstr = '<p class="message">鍵が空です。変更されませんでした。</p>'
	end
	csrf_protection_method = @conf.options['csrf_protection_method'] || 1
	csrf_protection_key = @conf.options['csrf_protection_key'] || ''
	<<-HTML
	#{errstr}
	<p>クロスサイト・リクエストフォージェリ(CSRF)の対策手法を設定します。</p>
	<p>CSRF攻撃は、悪意のある人間がWebページに罠を仕掛けます。
	その罠を仕掛けたページをあなたが閲覧すると、あなたのブラウザは
	tDiaryに偽の書き込み要求を送出してしまいます。あなたのブラウザが
	偽要求を送出してしまうため、暗号化・パスワード保護だけでは対策になりません。
	tDiaryでは、この種の攻撃に対して、「Refererチェック」と「CSRFキー」という
	2種類の防衛手段を用意しています。</p>
	<div class="section">
	<h3 class="subtitle">Refererチェックによる防衛</h3>
	<h4>Refererの正当性の検査</h4>
	<p>#{if [0,1,2,3].include?(csrf_protection_method) then
            '<input type="checkbox" name="check_enabled2" value="true" checked disabled>
            <input type="hidden" name="check_enabled" value="true">'
          else
            '<input type="checkbox" name="check_enabled" value="true">'
        end}する(標準)</input>
	</p>
	#{"<p>あなたのブラウザが送出するReferer(リンク元情報)を検査します。
	書き込み要求が正しいページから送出されたことを確認することで、
	偽ページからの要求を防ぎます。不正なページからの要求を検出した場合、
	更新リクエストを拒否します。
	この設定画面では、無効にすることは出来ません。</p>
	" unless @conf.mobile_agent?}
	<h4>Refererを送出しないブラウザを拒否</h4>
	<p><input type="radio" name="check_referer" value="true" #{if [1,3].include?(csrf_protection_method) then " checked" end}>する(標準)</input>
	<input type="radio" name="check_referer" value="false" #{if [0,2].include?(csrf_protection_method) then " checked" end}>しない</input>
	</p>
	#{"<p>ブラウザからRefererが送られてこなかった場合の動作を指定します。</p>
	<p>標準では、Refererが送出されない場合、不正なリクエストを
	判別できないため、書き込み・設定変更を拒否します。
	あなたのブラウザがRefererを送出しない設定の場合、
	この設定が「する」になっていると、正規の書き込み要求も拒否してしまいます。
	ブラウザを設定を変更しRefererを送出するようにしてください。
	どうしてもRefererを送出する設定に出来ない場合、「しない」にしてください。
	この場合、Refererが全く送出されなかった場合にも、
	書き込み・設定変更を許すようになりますが、
	CSRFによる攻撃と区別できなくなりますので、必ず次の「CSRF防止キー」の
	設定と併用して下さい。</p>
	</div>
	" unless @conf.mobile_agent?}
	<div class="section">
	<h3 class="subtitle">CSRF防止キーによる防衛</h3>
	<h4>CSRF防止キーの検査</h4>
	<p><input type="radio" name="check_key" value="true" #{if [2,3].include?(csrf_protection_method) then " checked" end}>する</input>
	<input type="radio" name="check_key" value="false" #{if [0,1].include?(csrf_protection_method) then " checked" end}>しない(標準)</input>
	</p>
	#{"<p>書き込みフォームに偽装書き込み防止のためのキーを設定し、CSRFを防ぎます。
	偽ページが秘密のキーを知らない限り、
	偽の書き込み要求を生成することができなくなります。
	この検査を「する」に設定する場合、次の鍵も設定して下さい。
	上の設定と両方「しない」にすることはできません。</p>
	<p>この設定を「する」にした場合、この機構に対応していない一部の
	プラグインが動作しなくなることがあります。</p>
	" unless @conf.mobile_agent?}
	<h4>CSRF 防止キー</h4>
	<p><input type="text" name="key" value="#{CGI::escapeHTML csrf_protection_key}" size="30"></p>
	#{"<p>偽装防止キーを設定します。推測しにくい適当な文字列を指定して下さい。
	この鍵が外部に洩れると、CSRF攻撃を受ける可能性があります。
	他のパスワードと共用はしてはいけません。なお、設定した文字列をあなたが覚えておく必要はありません。</p>" unless @conf.mobile_agent?}
	#{"<p class=\"message\">注意: 
	あなたのブラウザは現在Refererを送出していないようです。
	<a href=\"#{@conf.update}?conf=csrf_protection\">このリンクからもう一回
	このページを開いてみて下さい</a>。
	それでもこのメッセージが出る状況では、この設定を変える場合、
	一時的にRefererを送出する設定にするか、
	直接tdiary.confを編集して下さい。</p>
	</div>" if [1,3].include?(csrf_protection_method) && ! @cgi.referer && !@cgi.valid?('referer_exists')}
	HTML
end
