=begin
== NAME
tDiary: the "tsukkomi-able" web diary system.
tdiary.rb $Revision: 1.195.2.5 $

Copyright (C) 2001-2005, TADA Tadashi <sho@spc.gr.jp>
You can redistribute it and/or modify it under GPL2.
=end

TDIARY_VERSION = '2.0.2'

require 'cgi'
require 'uri'
begin
    require 'erb_fast'
    ERbLight = ERB
rescue LoadError
    begin
        require 'erb'
        ERbLight = ERB
    rescue LoadError
        require 'erb/erbl'
    end
end

=begin
== String class
enhanced String class
=end
class String
    def make_link
        r = %r<(((http[s]{0,1}|ftp)://[\(\)%#!/0-9a-zA-Z_$@.&+-,'"*=;?:~-]+)|([0-9a-zA-Z_.-]+@[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+\.[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+))>
        return self.
            gsub( / /, "\001" ).
            gsub( /</, "\002" ).
            gsub( />/, "\003" ).
            gsub( /&/, '&amp;' ).
            gsub( /\"/, "\004").
            gsub( r ){ $1 == $2 ? "<a href=\"#$2\">#$2</a>" : "<a href=\"mailto:#$4\">#$4</a>" }.
            gsub( /\004/, '&quot;' ).
            gsub( /\003/, '&gt;' ).
            gsub( /\002/, '&lt;' ).
            gsub( /^\001+/ ) { $&.gsub( /\001/, '&nbsp;' ) }.
            gsub( /\001/, ' ' ).
            gsub( /\t/, '&nbsp;' * 8 )
    end
end

=begin
== CGI class
enhanced CGI class
=end
class CGI
    def valid?( param, idx = 0 )
        begin
            self.params[param] and self.params[param][idx] and self.params[param][idx].length > 0
        rescue NameError # for Tempfile class of ruby 1.6
            self.params[param][idx].stat.size > 0
        end
    end

    def mobile_agent?
        self.user_agent =~ %r[(DoCoMo|J-PHONE|Vodafone|MOT-|UP\.Browser|DDIPOCKET|ASTEL|PDXGW|Palmscape|Xiino|sharp pda browser|Windows CE|L-mode|WILLCOM|SoftBank|Semulator|Vemulator|J-EMULATOR|emobile|Mediapartners-Google|Googlebot-Mobile|Y!J-SRD|Y!J-MBS)]i
    end
end

=begin
== Safe module
=end
require 'thread'
module Safe
    def safe( level = 4 )
        result = nil
        if $SAFE < level then
            Thread.start {
                $SAFE = level
                result = yield
            }.join
        else
            result = yield
        end
        result
  end
  module_function :safe
end

#
# module TDiary
#
module TDiary
    PATH = File::dirname( __FILE__ )

    #
    # class Comment
    #  Management a comment.
    #
    class Comment
        attr_reader :name, :mail, :body, :date

        def initialize( name, mail, body, date = Time::now )
            @name, @mail, @body, @date = name, mail, body, date
            @show = true
        end

        def shorten( length = 120 )
            matched = body.gsub( /\n/, ' ' ).scan( /^.{0,#{length - 2}}/ )[0]
            unless $'.empty? then
                matched + '..'
            else
                matched
            end
        end

        def visible?; @show; end
        def show=( s ); @show = s; end

        def ==( c )
            (@name == c.name) and (@mail == c.mail) and (@body == c.body)
        end
    end

    #
    # module CommentManager
    #  Management comments in a day. Include in Diary class.
    #
    module CommentManager
    private
        #
        # call this method when initialize
        #
        def init_comments
            @comments = []
        end

    public
        def add_comment( com )
            @comments << com
            if not @last_modified or @last_modified < com.date
                @last_modified = com.date
            end
            com
        end

        def count_comments( all = false )
            i = 0
            @comments.each do |comment|
                i += 1 if all or comment.visible?
            end
            i
        end

        def each_comment( limit = 3 )
            @comments.each_with_index do |com,idx|
                break if idx >= limit
                yield com
            end
        end

        def each_comment_tail( limit = 3 )
            idx = 0
            comments = @comments.collect {|c|
                idx += 1
                if c.visible? then
                    [c, idx]
                else
                    nil
                end
            }.compact
            s = comments.size - limit
            s = 0 if s < 0
            for idx in s...comments.size
                yield comments[idx][0], comments[idx][1] # idx is start with 1.
            end
        end

        def each_visible_comment( limit = 3 )
            @comments.each_with_index do |com,idx|
                break if idx >= limit
                next unless com.visible?
                yield com,idx+1 # idx is start with 1.
            end
        end

        def each_visible_trackback( limit = 3 )
            i = 0
            @comments.find_all {|com|
                com.visible_true? and /^(Track|Ping)Back$/ =~ com.name
            }[0,limit].each do |com|
                i += 1 # i starts with 1.
                yield com,i
            end
        end

        def each_visible_trackback_tail( limit = 3 )
            i = 0
            @comments.find_all {|com|
                com.visible_true? and /^(Track|Ping)Back$/ =~ com.name
            }.reverse[0,limit].reverse.each do |com|
                i += 1 # i starts with 1.
                yield com,i
            end
        end
    end

    #
    # module RefererManager
    #  Management referers in a day. Include in Diary class.
    #
    module RefererManager
    private
        #
        # call this method when initialize
        #
        def init_referers
            @referers = {}
            @new_referer = true # for compatibility
        end

    public
        def add_referer( ref, count = 1 )
            newer_referer
            ref = ref.sub( /#.*$/, '' ).sub( /\?\d{8}$/, '' )
            if /^([^:]+:\/\/)([^\/]+)/ =~ ref
                ref = $1 + $2.downcase + $'
            end
            uref = CGI::unescape( ref )
            if pair = @referers[uref] then
                pair = [pair, ref] if pair.class != Array # for compatibility
                @referers[uref] = [pair[0] + count, pair[1]]
            else
                @referers[uref] = [count, ref]
            end
        end

        def count_referers
            @referers.size
        end

        def each_referer( limit = 10 )
            newer_referer
            @referers.values.sort.reverse.each_with_index do |ary,idx|
                break if idx >= limit
                yield ary[0], ary[1]
            end
        end

    private
        def newer_referer
            unless @new_referer then # for compatibility
                @referers.keys.each do |ref|
                    count = @referers[ref]
                    if count.class != Array then
                        @referers.delete( ref )
                        @referers[CGI::unescape( ref )] = [count, ref]
                    end
                end
                @new_referer = true
            end
        end
    end

    #
    # module/class Filter
    #
    module Filter
        class Filter
            def initialize( cgi, conf )
                @cgi, @conf = cgi, conf
            end

            def comment_filter( diary, comment )
                true
            end

            def referer_filter( referer )
                true
            end
        end
    end

    #
    # module DiaryBase
    #  Base module of Diary.
    #
    module DiaryBase
        include CommentManager
        include RefererManager

        def init_diary
            init_comments
            init_referers
            @show = true
        end

        def date
            @date
        end

        def set_date( date )
            if date.class == String then
                y, m, d = date.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0]
                raise ArgumentError::new( 'date string needs YYYYMMDD format.' ) unless y
                @date = Time::local( y, m, d )
            else
                @date = date
            end
        end

        def title
            @title || ''
        end

        def set_title( title )
            @title = title
            @last_modified = Time::now
        end

        def show( s )
            @show = s
        end

        def visible?
            @show != false;
        end

        def last_modified
            @last_modified ? @last_modified : Time::at( 0 )
        end

        def last_modified=( lm )
            @last_modified  = lm
        end

        def eval_rhtml( opt, path = '.' )
            ERbLight::new( File::open( "#{path}/skel/#{opt['prefix']}diary.rhtml" ){|f| f.read }.untaint ).result( binding )
        end
    end

    #
    # exception classes
    #
    class TDiaryError < StandardError; end
    class PermissionError < TDiaryError; end
    class PluginError < TDiaryError; end
    class BadStyleError < TDiaryError; end

    #
    # class IOBase
    #  base of IO class
    #
    class IOBase
        def calendar
            raise StandardError, 'not implemented'
        end

        def transaction( date )
            raise StandardError, 'not implemented'
        end

        def diary_factory( date, title, body, style = nil )
            raise StandardError, 'not implemented'
        end

        def styled_diary_factory( date, title, body, style = 'tDiary' )
            if style_class = style( style.downcase )
                return style_class::new( date, title, body )
            else
                raise BadStyleError, "bad style: #{style}"
            end
        end

        def load_styles
            @styles = {}
            Dir::glob( "#{TDiary::PATH}/tdiary/*_style.rb" ) do |style_file|
                require style_file.untaint
                style = File::basename( style_file ).sub( /_style\.rb$/, '' )
                @styles[style] = TDiary::const_get( "#{style.capitalize}Diary" )
            end
        end

        def style( s )
            @styles ? @styles[s.downcase] : nil
        end
    end

    # class ForceRedirect
    #  force redirect to another page
    #
    class ForceRedirect < StandardError
        attr_reader :path
        def initialize( path )
            @path = path
        end
    end

    #
    # class Config
    #  configuration class
    #
    class Config
        def initialize
            load

            instance_variables.each do |v|
                v.sub!( /@/, '' )
                instance_eval( <<-SRC
                    def #{v}
                        @#{v}
                    end
                    def #{v}=(p)
                        @#{v} = p
                    end
                    SRC
                )
            end

            bot = ["googlebot", "Hatena Antenna", "moget@goo.ne.jp"]
            bot += @options['bot'] || []
            @bot = Regexp::new( "(#{bot.uniq.join( '|' )})", true )
        end

        # saving to tdiary.conf in @data_path
        def save
            result = ERbLight::new( File::open( "#{PATH}/skel/tdiary.rconf" ){|f| f.read }.untaint ).result( binding )
            result.untaint unless @secure
            Safe::safe( @secure ? 4 : 1 ) do
                eval( result, binding, "(TDiary::Config#save)", 1 )
            end
            File::open( "#{@data_path}tdiary.conf", 'w' ) do |o|
                o.print result
            end
        end

        def mobile_agent?
            %r[(DoCoMo|J-PHONE|Vodafone|MOT-|UP\.Browser|DDIPOCKET|ASTEL|PDXGW|Palmscape|Xiino|sharp pda browser|Windows CE|L-mode|WILLCOM|SoftBank|Semulator|Vemulator|J-EMULATOR|emobile|Mediapartners-Google|Googlebot-Mobile|Y!J-SRD|Y!J-MBS)]i =~ ENV['HTTP_USER_AGENT']
        end

        def bot?
            @bot =~ ENV['HTTP_USER_AGENT']
        end

        #
        # get/set/delete plugin options
        #
        def []( key )
            @options[key]
        end

        def []=( key, val )
            @options2[key] = @options[key] = val
        end

        def delete( key )
            @options.delete( key )
            @options2.delete( key )
        end

        def base_url
            return '' unless ENV['SCRIPT_NAME']
            if ENV['HTTPS']
                port = (ENV['SERVER_PORT'] == '443') ? '' : ':' + ENV['SERVER_PORT'].to_s
                "https://#{ ENV['SERVER_NAME'] }#{ port }#{File::dirname(ENV['SCRIPT_NAME'])}/"
            else
                port = (ENV['SERVER_PORT'] == '80') ? '' : ':' + ENV['SERVER_PORT'].to_s
                "http://#{ ENV['SERVER_NAME'] }#{ port }#{File::dirname(ENV['SCRIPT_NAME'])}/"
            end.sub(%r|/+$|, '/')
        end

    private
        # loading tdiary.conf in current directory
        def load
            @secure = true unless @secure
            @options = {}
            eval( File::open( "tdiary.conf" ){|f| f.read }.untaint, binding, "(tdiary.conf)", 1 )

            # language setup
            @lang = 'ja' unless @lang
            begin
                instance_eval( File::open( "#{TDiary::PATH}/tdiary/lang/#{@lang}.rb" ){|f| f.read }.untaint, "(tdiary/lang/#{@lang}.rb)", 1 )
            rescue Errno::ENOENT
                @lang = 'ja'
                retry
            end

            @data_path += '/' if /\/$/ !~ @data_path
            @style = 'tDiary' unless @style
            @index = './' unless @index
            @update = 'update.rb' unless @update
            @hide_comment_form = false unless defined?( @hide_comment_form )

            @author_name = '' unless @author_name
            @index_page = '' unless @index_page
            @hour_offset = 0 unless @hour_offset

            @html_title = '' unless @html_title
            @header = '' unless @header
            @footer = '' unless @footer

            @section_anchor = '<span class="sanchor">_</span>' unless @section_anchor
            @comment_anchor = '<span class="canchor">_</span>' unless @comment_anchor
            @date_format = '%Y-%m-%d' unless @date_format
            @latest_limit = 10 unless @latest_limit
            @show_nyear = false unless @show_nyear

            @theme = 'default' if not @theme and not @css
            @css = '' unless @css

            @show_comment = true unless defined?( @show_comment )
            @comment_limit = 3 unless @comment_limit

            @show_referer = true unless defined?( @show_referer )
            @referer_limit = 10 unless @referer_limit
            @referer_day_only = false unless defined?( @referer_day_only )
            @no_referer = [] unless @no_referer
            @no_referer2 = [] unless @no_referer2
            @no_referer = @no_referer2 + @no_referer
            @referer_table = [] unless @referer_table
            @referer_table2 = [] unless @referer_table2
            @referer_table = @referer_table2 + @referer_table

            @options = {} unless @options.class == Hash
            if @options2 then
                @options.update( @options2 )
            else
                @options2 = {}.taint
            end
            @options.taint

            # for 1.4 compatibility
            @section_anchor = @paragraph_anchor unless @section_anchor
        end

        # loading tdiary.conf in @data_path.
        def load_cgi_conf
            raise TDiaryError, 'No @data_path variable.' unless @data_path

            @data_path += '/' if /\/$/ !~ @data_path
            raise TDiaryError, 'Do not set @data_path as same as tDiary system directory.' if @data_path == "#{PATH}/"

            variables = [
                :author_name, :author_mail, :index_page, :hour_offset,
                :html_title, :header, :footer,
                :section_anchor, :comment_anchor, :date_format, :latest_limit, :show_nyear,
                :theme, :css,
                :show_comment, :comment_limit, :mail_on_comment, :mail_header,
                :show_referer, :referer_limit, :referer_day_only, :no_referer2, :referer_table2,
                :options2,
            ]
            begin
                cgi_conf = File::open( "#{@data_path}tdiary.conf" ){|f| f.read }
                cgi_conf.untaint unless @secure
                def_vars = ""
                variables.each do |var| def_vars << "#{var} = nil\n" end
                eval( def_vars )
                Safe::safe( @secure ? 4 : 1 ) do
                    eval( cgi_conf, binding, "(TDiary::Config#cgi_conf)", 1 )
                end
                variables.each do |var| eval "@#{var} = #{var} if #{var} != nil" end
            rescue IOError, Errno::ENOENT
            end
        end

        def method_missing( *m )
            if m.length == 1 then
                instance_eval( <<-SRC
                    def #{m[0]}
                        @#{m[0]}
                    end
                    def #{m[0]}=( p )
                        @#{m[0]} = p
                    end
                    SRC
                )
            end
            nil
        end
    end

    #
    # class Plugin
    #  plugin management class
    #
    class Plugin
        attr_reader :cookies

        def initialize( params )
            @header_procs = []
            @footer_procs = []
            @update_procs = []
            @body_enter_procs = []
            @body_leave_procs = []
            @edit_procs = []
            @form_procs = []
            @conf_keys = []
            @conf_procs = {}
            @cookies = []

            params.each_key do |key|
                eval( "@#{key} = params['#{key}']" )
            end

            # for 1.4 compatibility
            @index = @conf.index
            @update = @conf.update
            @author_name = @conf.author_name || ''
            @author_mail = @conf.author_mail || ''
            @index_page = @conf.index_page || ''
            @html_title = @conf.html_title || ''
            @theme = @conf.theme
            @css = @conf.css
            @date_format = @conf.date_format
            @referer_table = @conf.referer_table
            @options = @conf.options

            # for ruby 1.6.x support
            if @conf.secure then
                @cgi.params.each_value do |p|
                    p.each {|v| v.taint}
                end
            end

            # loading plugins
            @plugin_files = []
            plugin_path = @conf.plugin_path || "#{PATH}/plugin"
            plugin_file = ''
            begin
                Dir::glob( "#{plugin_path}/*.rb" ).sort.each do |file|
                    plugin_file = file
                    load_plugin( file )
                    @plugin_files << plugin_file
                end
            rescue Exception
                raise PluginError::new( "Plugin error in '#{File::basename( plugin_file )}'.\n#{$!}\n#{$!.backtrace[0]}" )
            end
        end

        def load_plugin( file )
            @resource_loaded = false
            begin
                res_file = File::dirname( file ) + "/#{@conf.lang}/" + File::basename( file )
                open( res_file.untaint ) do |src|
                    instance_eval( src.read.untaint, "(plugin/#{@conf.lang}/#{File::basename( res_file )})", 1 )
                end
                @resource_loaded = true
            rescue IOError, Errno::ENOENT
            end
            File::open( file.untaint ) do |src|
                instance_eval( src.read.untaint, "(plugin/#{File::basename( file )})", 1 )
            end
        end

        def eval_src( src, secure )
            self.taint
            @conf.taint
            @body_enter_procs.taint
            @body_leave_procs.taint
            return Safe::safe( secure ? 4 : 1 ) do
                eval( src, binding, "(TDiary::Plugin#eval_src)", 1 )
            end
        end

    private
        def add_header_proc( block = Proc::new )
            @header_procs << block
        end

        def header_proc
            r = []
            @header_procs.each do |proc|
                r << proc.call
            end
            r.join.chomp
        end

        def add_footer_proc( block = Proc::new )
            @footer_procs << block
        end

        def footer_proc
            r = []
            @footer_procs.each do |proc|
                r << proc.call
            end
            r.join.chomp
        end

        def add_update_proc( block = Proc::new )
            @update_procs << block
        end

        def update_proc
            @update_procs.each do |proc|
                proc.call
            end
            ''
        end

        def add_body_enter_proc( block = Proc::new )
            @body_enter_procs << block
        end

        def body_enter_proc( date )
            r = []
            @body_enter_procs.each do |proc|
                r << proc.call( date )
            end
            r.join
        end

        def add_body_leave_proc( block = Proc::new )
            @body_leave_procs << block
        end

        def body_leave_proc( date )
            r = []
            @body_leave_procs.each do |proc|
                r << proc.call( date )
            end
            r.join
        end

        def add_edit_proc( block = Proc::new )
            @edit_procs << block
        end

        def edit_proc( date )
            r = []
            @edit_procs.each do |proc|
                r << proc.call( date )
            end
            r.join
        end

        def add_form_proc( block = Proc::new )
            @form_procs << block
        end

        def form_proc( date )
            r = []
            @form_procs.each do |proc|
                r << proc.call( date )
            end
            r.join
        end

        def add_conf_proc( key, label, block = Proc::new )
            return unless @mode =~ /^(conf|saveconf)$/
            @conf_keys << key unless @conf_keys.index( key )
            @conf_procs[key] = [label, block]
        end

        def each_conf_key
            @conf_keys.each do |key|
                yield key
            end
        end

        def conf_proc( key )
            r = ''
            label, block = @conf_procs[key]
            r = block.call if block
            r
        end

        def conf_label( key )
            label, block = @conf_procs[key]
            label
        end

        def add_cookie( cookie )
            begin
                @cookies << cookie
            rescue SecurityError
                raise SecurityError, "can't use cookies in plugin when secure mode"
            end
        end

        def apply_plugin( str, remove_tag = false )
            return '' unless str
            r = str.dup
            if @options['apply_plugin'] and str.index( '<%' ) then
                r = str.untaint if $SAFE < 3
                Safe::safe( @conf.secure ? 4 : 1 ) do
                    r = ERbLight.new( r ).result( binding )
                end
            end
            r.gsub!( /<[^"'<>]*(?:"[^"]*"[^"'<>]*|'[^']*'[^"'<>]*)*(?:>|(?=<)|$)/, '' ) if remove_tag
            r
        end

        def disp_referer( table, ref )
            ref = @conf.to_native( CGI::unescape( ref ) )
            str = nil
            table.each do |url, name|
                if /#{url}/i =~ ref then
                    str = ref.gsub( /#{url}/in, name )
                    break
                end
            end
            str ? str : ref
        end

        def bot?
            @conf.bot?
        end

        def method_missing( *m )
            super if @debug
            # ignore when no plugin
        end
    end

    #
    # module CategorizableDiary
    #
    module CategorizableDiary
        def categorizable?; true; end
    end

    #
    # module UncategorizableDiary
    #
    module UncategorizableDiary
        def categorizable?; false; end
    end

    #
    # class TDiaryBase
    #  tDiary CGI
    #
    class TDiaryBase
        DIRTY_NONE = 0
        DIRTY_DIARY = 1
        DIRTY_COMMENT = 2
        DIRTY_REFERER = 4

        attr_reader :cookies
        attr_reader :conf

        def initialize( cgi, rhtml, conf )
            @cgi, @rhtml, @conf = cgi, rhtml, conf
            @diaries = {}
            @cookies = []

            unless @conf.io_class then
                require 'tdiary/defaultio'
                @conf.io_class = DefaultIO
            end
            @io = @conf.io_class.new( self )
        end

        def eval_rhtml( prefix = '' )
            begin
                r = do_eval_rhtml( prefix )
            rescue PluginError, SyntaxError, ArgumentError
                r = ERbLight::new( File::open( "#{PATH}/skel/plugin_error.rhtml" ) {|f| f.read }.untaint ).result( binding )
            rescue Exception
                raise
            end
            return r
        end

        def restore_parser_cache( date, key )
            parser_cache( date, key )
        end

        def store_parser_cache( date, key, obj )
            parser_cache( date, key, obj )
        end

        def clear_parser_cache( date )
            parser_cache( date )
        end

        def last_modified
            nil
        end

    protected
        def do_eval_rhtml( prefix )
            # load plugin files
            load_plugins

            # load and apply rhtmls
            if cache_enable?( prefix ) then
                r = File::open( "#{cache_path}/#{cache_file( prefix )}" ) {|f| f.read } rescue nil
            end
            if r.nil?
                files = ["header.rhtml", @rhtml, "footer.rhtml"]
                rhtml = files.collect {|file|
                    path = "#{PATH}/skel/#{prefix}#{file}"
                    begin
                        File::open( "#{path}.#{@conf.lang}" ) {|f| f.read }
                    rescue
                        File::open( path ) {|f| f.read }
                    end
                }.join
                r = ERbLight::new( rhtml.untaint ).result( binding )
                r = ERbLight::new( r ).src
                store_cache( r, prefix ) unless @diaries.empty?
            end

            # apply plugins
            r = @plugin.eval_src( r.untaint, @conf.secure ) if @plugin
            @cookies += @plugin.cookies
            r
        end

        def mode
            self.class.to_s.sub( /^TDiary::TDiary/, '' ).downcase
        end

        def load_plugins
            calendar
            @plugin = Plugin::new(
                'conf' => @conf,
                'mode' => mode,
                'diaries' => @diaries,
                'cgi' => @cgi,
                'years' => @years,
                'cache_path' => cache_path,
                'date' => @date,
                'comment' => @comment,
                'last_modified' => last_modified
            )
        end

        def []( date )
            @diaries[date.strftime( '%Y%m%d' )]
        end

        def <<( diary )
            @diaries[diary.date.strftime( '%Y%m%d' )] = diary
        end

        def delete( date )
            @diaries.delete( date.strftime( '%Y%m%d' ) )
        end

        def cache_path
            @conf.cache_path || "#{@conf.data_path}cache"
        end

        def cache_file( prefix )
            nil
        end

        def cache_enable?( prefix )
            cache_file( prefix ) and FileTest::file?( "#{cache_path}/#{cache_file( prefix )}" )
        end

        def store_cache( cache, prefix )
            unless FileTest::directory?( cache_path ) then
                begin
                    Dir::mkdir( cache_path )
                rescue Errno::EEXIST
                end
            end
            if cache_file( prefix ) then
                File::open( "#{cache_path}/#{cache_file( prefix )}", 'w' ) do |f|
                    f.flock(File::LOCK_EX)
                    f.write( cache )
                end
            end
        end

        def clear_cache( target = /.*/ )
            Dir::glob( "#{cache_path}/*.r[bh]*" ).each do |c|
                File::delete( c.untaint ) if target =~ c
            end
        end

        def parser_cache( date, key = nil, obj = nil )
            return nil if @ignore_parser_cache

            require 'pstore'
            unless FileTest::directory?( cache_path ) then
                begin
                    Dir::mkdir( cache_path )
                rescue Errno::EEXIST
                end
            end
            file = date.strftime( "#{cache_path}/%Y%m.parser" )

            unless key then
                begin
                    File::delete( file )
                    File::delete( file + '~' )
                rescue
                end
                return nil
            end

            begin
                PStore::new( file ).transaction do |cache|
                    begin
                        unless obj then # restore
                            ver = cache.root?('version') ? cache['version'] : nil
                            if ver == TDIARY_VERSION and cache.root?(key)
                                obj = cache[key]
                            else
                                clear_cache
                            end
                            cache.abort
                        else # store
                            cache[key] = obj
                            cache['version'] = TDIARY_VERSION
                        end
                    rescue PStore::Error
                    end
                end
            rescue
                begin
                    File::delete( file )
                    File::delete( file + '~' )
                rescue
                end
                return nil
            end
            obj
        end

        def calendar
            @years = @io.calendar unless @years
        end

        def load_filters
            return if @filters

            @filters = []
            filter_path = @conf.filter_path || "#{PATH}/tdiary/filter"
            Dir::glob( "#{filter_path}/*.rb" ).sort.each do |file|
                require file.untaint
                @filters << TDiary::Filter::const_get( "#{File::basename( file, '.rb' ).capitalize}Filter" )::new( @cgi, @conf )
            end
        end

        def comment_filter( diary, comment )
            load_filters unless @filters
            @filters.each do |filter|
                return false unless filter.comment_filter( diary, comment )
            end
            true
        end

        def referer_filter( referer )
            load_filters unless @filters
            @filters.each do |filter|
                return false unless filter.referer_filter( referer )
            end
            true
        end
    end

    #
    # class TDiaryAuthorOnlyBase
    #  base class for author-only access pages
    #
    class TDiaryAuthorOnlyBase < TDiaryBase
        def csrf_protection_get_is_okay
            false
        end

        def initialize( cgi, rhtml, conf )
            super
            csrf_check( cgi, conf )
        end
        private

        def csrf_check( cgi, conf )
            # CSRF condition check
            protection_method = conf.options['csrf_protection_method']
            masterkey = conf.options['csrf_protection_key']
            updaterb_regexp = conf.options['csrf_protection_allowed_referer_regexp_for_update']

            protection_method = 1 unless protection_method

            return if protection_method == -1 # don't use this setting!

            check_key = (protection_method & 2 != 0)
            check_referer = (protection_method & 1 != 0)

            masterkey = '' unless masterkey

            updaterb_regexp = '' unless updaterb_regexp

            if (masterkey != '' && check_key)
                @csrf_protection="<input type=\"hidden\" name=\"csrf_protection_key\" value=\"#{CGI::escapeHTML(masterkey)}\">"
            else
                @csrf_protection="<!-- no CSRF protection key used -->"
            end

            referer = cgi.referer || ''
            referer = referer.sub(/\?.*$/, '')
            base_uri = URI.parse(conf.base_url)
            config_uri = URI.parse(conf.base_url) + conf.update

            referer_is_empty = referer == ''
            referer_uri = URI.parse(referer) if !referer_is_empty
            referer_is_config = !referer_is_empty && config_uri == referer_uri
            referer_is_config ||= Regexp.new(updaterb_regexp) =~ referer if !referer_is_empty && updaterb_regexp != ''
            is_post = cgi.request_method == 'POST'

            given_key = nil
            if cgi.valid?('csrf_protection_key')
                given_key = cgi.params['csrf_protection_key'][0]
                case given_key
                when String
                else
                    given_key = given_key.read
                end
            end

            is_key_ok = masterkey != '' && given_key == masterkey

            keycheck_ok = !check_key || is_key_ok
            referercheck_ok = referer_is_config || (!check_referer && referer_is_empty)

            if csrf_protection_get_is_okay then
                return if is_post || given_key == nil
            else
                    return if keycheck_ok && referercheck_ok
            end

            raise Exception.new(<<"EOS")
Security Error: Possible Cross-site Request Forgery (CSRF)

        Diagnostics:
                - Protection Method is #{ protection_method }
                - Mode is #{ self.mode || 'unknown' }
                    - GET is #{ csrf_protection_get_is_okay ? '' : 'not '}allowed
                - Request Method is #{ is_post ? 'POST' : 'not POST' }
                - Referer is #{ referer_is_empty ? 'empty' : referer_is_config ? 'config' : 'another page' }
                    - Given referer:       #{ CGI::escapeHTML( referer_uri.to_s )}
                    - Expected base URI:   #{ CGI::escapeHTML( base_uri.to_s )}
                    - Expected update URI: #{ CGI::escapeHTML( config_uri.to_s )}
                - CSRF key is #{ is_key_ok ? 'OK' : given_key ? 'NG (' + (given_key || '') + ')' : 'nothing' }
EOS
        end

        def load_plugins
            super
            @plugin.instance_eval("def csrf_protection\n#{(@csrf_protection.untaint || '').dump}\nend;")
        end
    end

    #
    # class TDiaryAdmin
    #  base class of administration
    #
    class TDiaryAdmin < TDiaryAuthorOnlyBase
        def initialize( cgi, rhtml, conf )
            super
            begin
                @date = Time::local( @cgi.params['year'][0].to_i, @cgi.params['month'][0].to_i, @cgi.params['day'][0].to_i )
            rescue ArgumentError, NameError
                raise TDiaryError, 'bad date'
            end
        end
    end

    #
    # class TDiaryForm
    #  show diary append form
    #
    class TDiaryForm < TDiaryAdmin
        def csrf_protection_get_is_okay; true; end

        def initialize( cgi, rhtml, conf )
            begin
                super
            rescue TDiaryError
            end
            @date = Time::now + (@conf.hour_offset * 3600).to_i
            @diary = @io.diary_factory( @date, '', '', @conf.style )
        end
    end

    #
    # class TDiaryEdit
    #  show edit diary form
    #
    class TDiaryEdit < TDiaryAdmin
        def csrf_protection_get_is_okay; true; end

        def initialize( cgi, rhtm, conf )
            super

            @io.transaction( @date ) do |diaries|
                @diaries = diaries
                @diary = self[@date]
                if @diary then
                    @conf.style = @diary.style
                else
                    @diary =  @io.diary_factory( @date, '', '', @conf.style )
                end
                DIRTY_NONE
            end
        end
    end

    #
    # class TDiaryPreview
    #  preview diary
    #
    class TDiaryPreview < TDiaryAdmin
        def initialize( cgi, rhtm, conf )
            super

            @title = @conf.to_native( @cgi.params['title'][0] )
            @body = @conf.to_native( @cgi.params['body'][0] )
            @old_date = @cgi.params['old'][0]
            @hide = @cgi.params['hide'][0] == 'true' ? true : false

            @io.transaction( @date ) do |diaries|
                @diaries = diaries
                diary = @diaries[@date.strftime( '%Y%m%d' )]
                @conf.style = diary.style if diary
                @diary = @io.diary_factory( @date, @title, @body, @conf.style )
                @diary.show( ! @hide )
                DIRTY_NONE
            end
        end

        def eval_rhtml( prefix = '' )
            begin
                @show_result = true
                r = do_eval_rhtml( prefix )
            rescue PluginError, SyntaxError, ArgumentError
                @exception = $!.dup
                @show_result = false
                r = super
            end
            r
        end
    end

    #
    # class TDiaryUpdate
    #  super class of diary saving classes
    #
    class TDiaryUpdate < TDiaryAdmin
        def initialize( cgi, rhtml, conf )
            @title = conf.to_native( cgi.params['title'][0] )
            @body = conf.to_native( cgi.params['body'][0] )
            @hide = cgi.params['hide'][0] == 'true' ? true : false
            super
        end

    protected
        def do_eval_rhtml( prefix )
            super
            @plugin.instance_eval { update_proc }
            anchor = @plugin.instance_eval( %Q[anchor "#{@diary.date.strftime('%Y%m%d')}"].untaint )
            clear_cache( /(latest|#{@date.strftime( '%Y%m' )})/ )
            raise ForceRedirect::new( "#{@conf.index}#{anchor}" )
        end
    end

    #
    # class TDiaryAppend
    #  append diary
    #
    class TDiaryAppend < TDiaryUpdate
        def initialize( cgi, rhtml, conf )
            begin
                super
            rescue TDiaryError
                @date = newdate
            end
            @author = @conf.multi_user ? @cgi.remote_user : nil

            @io.transaction( @date ) do |diaries|
                @diaries = diaries
                @diary = self[@date] || @io.diary_factory( @date, @title, '', @conf.style )
                self << @diary.append( @body, @author )
                @diary.set_title( @title ) unless @title.empty?
                @diary.show( ! @hide )
                DIRTY_DIARY
            end
        end

    protected
        def newdate
            Time::now + (@conf.hour_offset * 3600).to_i
        end
    end

    #
    # class TDiaryReplace
    #  replace diary
    #
    class TDiaryReplace < TDiaryUpdate
        def initialize( cgi, rhtm, conf )
            super
            old_date = @cgi.params['old'][0]

            @io.transaction( @date ) do |diaries|
                @diaries = diaries
                @diary = self[@date]
                if @diary then
                    if @date.strftime( '%Y%m%d' ) != old_date then
                        @diary.append( @body, @append )
                        @diary.set_title( @title ) if @title.length > 0
                    else
                        @diary.replace( @date, @title, @body )
                    end
                else
                    @diary = @io.diary_factory( @date, @title, @body, @conf.style )
                end
                @diary.show( ! @hide )
                self << @diary
                DIRTY_DIARY
            end
        end
    end

    #
    # class TDiaryShowComment
    #  change visible mode of comments
    #
    class TDiaryShowComment < TDiaryAdmin
        def initialize( cgi, rhtml, conf )
            super

            @io.transaction( @date ) do |diaries|
                @diaries = diaries
                dirty = DIRTY_NONE
                @diary = self[@date]
                if @diary then
                    idx = 0
                    @diary.each_comment( 100 ) do |com|
                        com.show = @cgi.params[(idx += 1).to_s][0] == 'true' ? true : false;
                    end
                    self << @diary
                    clear_cache( /(latest|#{@date.strftime( '%Y%m' )})/ )
                    dirty = DIRTY_COMMENT
                end
                dirty
            end
        end
    end

    #
    # class TDiaryFormPlugin
    #  show edit diary form after calling form plugin.
    #
    class TDiaryFormPlugin < TDiaryAuthorOnlyBase
        def initialize( cgi, rhtm, conf )
            super

            if @cgi.valid?( 'date' ) then
                if @cgi.params['date'][0].kind_of?( String ) then
                    date = @cgi.params['date'][0]
                else
                    date = @cgi.params['date'][0].read
                end
                @date = Time::local( *date.scan( /(\d{4})(\d\d)(\d\d)/ )[0] )
            else
                @date = Time::now + (@conf.hour_offset * 3600).to_i
                @diary = @io.diary_factory( @date, '', '', @conf.style )
            end

            @io.transaction( @date ) do |diaries|
                @diaries = diaries
                @diary = self[@date]
                if @diary then
                    @conf.style = @diary.style
                else
                    @diary =  @io.diary_factory( @date, '', '', @conf.style )
                end
                DIRTY_NONE
            end
        end
    end

    #
    # class TDiaryConf
    #  show configuration form
    #
    class TDiaryConf < TDiaryAuthorOnlyBase
        def csrf_protection_get_is_okay; true; end

        def initialize( cgi, rhtml, conf )
            super
            @key = @cgi.params['conf'][0]
        end
    end

    #
    # class TDiarySaveConf
    #  save configuration
    #
    class TDiarySaveConf < TDiaryConf
        def csrf_protection_get_is_okay; false; end

        def initialize( cgi, rhtml, conf )
            super
        end

        def eval_rhtml( prefix = '' )
            r = super

            begin
                @conf.save
                clear_cache
            rescue
                @error = [$!.dup, $@.dup]
            end

            r
        end
    end

    #
    # class TDiaryView
    #  base of view mode classes
    #
    class TDiaryView < TDiaryBase
        def initialize( cgi, rhtml, conf )
            super

            # save referer to latest
            if (!@conf.referer_day_only or (@cgi.params['date'][0] and @cgi.params['date'][0].length == 8)) and referer_filter( @cgi.referer ) then
                ym = latest_month
                @date = ym ? Time::local( ym[0], ym[1] ) : Time::now
                @io.transaction( @date ) do |diaries|
                    @diaries = diaries
                    dirty = DIRTY_NONE
                    @diaries.keys.sort.reverse_each do |key|
                        @diary = @diaries[key]
                        break if @diary.visible?
                    end
                    if @diary then
                        @diary.add_referer( @cgi.referer )
                        dirty = DIRTY_REFERER
                    end
                    dirty
                end
            end
        end

        def last_modified
            lm = Time::at( 0 )
            @diaries.each_value do |diary|
                lmd = diary.last_modified
                lm = lmd if lm < lmd and diary.visible?
            end
            lm
        end

    protected
        def each_day
            @diaries.keys.sort.each do |date|
                diary = @diaries[date]
                next unless diary.visible?
                yield diary
            end
        end

        def latest_month
            result = nil
            calendar
            @years.keys.sort.reverse_each do |year|
                @years[year.to_s].sort.reverse_each do |month|
                    result = [year, month]
                    break
                end
                break
            end
            result
        end

        def oldest_month
            result = nil
            calendar
            @years.keys.sort.each do |year|
                @years[year.to_s].sort.each do |month|
                    result = [year, month]
                    break
                end
                break
            end
            result
        end

        def cache_enable?( prefix )
            super and (File::mtime( "#{cache_path}/#{cache_file( prefix )}" ) > last_modified )
        end
    end

    #
    # class TDiaryDay
    #  show day mode view
    #
    class TDiaryDay < TDiaryView
        def initialize( cgi, rhtm, conf )
            super
            begin
                # time is noon for easy to calc leap second.
                load( Time::local( *@cgi.params['date'][0].scan( /^(\d{4})(\d\d)(\d\d)$/ )[0] ) + 12*60*60 )
            rescue ArgumentError, NameError
                raise TDiaryError, 'bad date'
            end
            @diary = nil if @diary and not @diary.visible?
        end

        def last_modified
            @diary ? @diary.last_modified : Time::at( 0 )
        end

    protected
        def load( date )
            if not @diary or (@diary.date.dup + 12*60*60).gmtime.strftime( '%Y%m%d' ) != date.dup.gmtime.strftime( '%Y%m%d' ) then
                @date = date
                @io.transaction( @date ) do |diaries|
                    @diaries = diaries
                    dirty = DIRTY_NONE
                    @diary = self[@date]
                    if @diary and referer_filter( @cgi.referer ) then
                        @diary.add_referer( @cgi.referer )
                        dirty = DIRTY_REFERER
                    end
                    dirty
                end
            else
                @date = date
                @diary = self[@date]
            end
        end

        def cookie_name
            @cgi.cookies['tdiary'][0] or ''
        end

        def cookie_mail
            @cgi.cookies['tdiary'][1] or ''
        end
    end

    #
    # class TDiaryComment
    #  save a comment
    #
    class TDiaryComment < TDiaryDay
        def initialize( cgi, rhtml, conf )
            super
        end

    protected
        def load( date )
            @date = date
            @name = @conf.to_native( @cgi.params['name'][0] )
            @mail = @cgi.params['mail'][0]
            @body = @conf.to_native( @cgi.params['body'][0] )
            @comment = Comment::new( @name, @mail, @body )

            dirty = DIRTY_NONE
            @io.transaction( @date ) do |diaries|
                @diaries = diaries
                @diary = self[@date]
                if @diary and comment_filter( @diary, @comment ) then
                    @diary.add_comment( @comment )
                    dirty = DIRTY_COMMENT
                    cookie_path = File::dirname( @cgi.script_name )
                    cookie_path += '/' if cookie_path !~ /\/$/
                    @cookies << CGI::Cookie::new( {
                        'name' => 'tdiary',
                        'value' => [@name,@mail],
                        'path' => cookie_path,
                        'expires' => Time::now.gmtime + 90*24*60*60 # 90days
                    } )
                else
                    @comment = nil
                end
                dirty
            end
        end

        def do_eval_rhtml( prefix )
            load_plugins
            @plugin.instance_eval { update_proc } if @comment
            anchor = @plugin.instance_eval( %Q[anchor "#{@diary.date.strftime('%Y%m%d')}"].untaint )
            raise ForceRedirect::new( "#{@conf.index}#{anchor}#c#{'%02d' % @diary.count_comments( true )}" )
        end
    end

    #
    # class TDiaryMonth
    #  show month mode view
    #
    class TDiaryMonth < TDiaryView
        def initialize( cgi, rhtml, conf )
            super

            begin
                date = Time::local( *@cgi.params['date'][0].scan( /^(\d{4})(\d\d)$/ )[0] )
                d1 = @date.dup.gmtime if @date
                d2 = date.dup.gmtime
                if not @date or d1.year != d2.year or d1.month != d2.month then
                    @date = date
                    @io.transaction( @date ) do |diaries|
                        @diaries = diaries
                        @diary = @diaries[@diaries.keys.sort.reverse[0]]
                        DIRTY_NONE
                    end
                end
            rescue ArgumentError, NameError
                raise TDiaryError, 'bad date'
            end
        end

    protected
        def cache_file( prefix )
            "#{prefix}#{@rhtml.sub( /month/, @date.strftime( '%Y%m' ) ).sub( /\.rhtml$/, '.rb' )}"
        end
    end

    #
    # class TDiaryNYear
    #  show nyear mode view
    #
    class TDiaryNYear < TDiaryView
        def initialize(cgi, rhtml, conf)
            super

            @diaries = {}
            month, day = @cgi.params['date'][0].scan(/^(\d\d)(\d\d)$/)[0]
            nyear(month).each do |y, m|
                @date = Time::local(y, m)
                @io.transaction(@date) do |diaries|
                    ymd = y + m + day
                    @diaries[ymd] = diaries[ymd] if diaries[ymd]
                    DIRTY_NONE
                end
            end
        end

    protected
        def nyear(month)
            r = []
            calendar
            @years.keys.reverse_each do |year|
                r << [year, month] if @years[year].include? month
            end
            r
        end
    end


    #
    # class TDiaryLatest
    #  show latest mode view
    #
    class TDiaryLatest < TDiaryView
        def initialize( cgi, rhtml, conf )
            super
            ym = latest_month
            unless @date then
                @date = ym ? Time::local( ym[0], ym[1] ) : Time::now
                @io.transaction( @date ) do |diaries|
                    @diaries = diaries
                    @diary = @diaries[@diaries.keys.sort.reverse[0]]
                    DIRTY_NONE
                end
            end

            if ym then
                y = ym[0].to_i
                m = ym[1].to_i
                oldest = oldest_month
                calc_diaries_size
                while ( oldest and @diaries_size < @conf.latest_limit )
                    date = if m == 1 then
                        Time::local( y -= 1, m = 12 )
                    else
                        Time::local( y, m -= 1 )
                    end
                    break if date < Time::local( *oldest )
                    @io.transaction( date ) do |diaries|
                        @diaries.update( diaries )
                        calc_diaries_size
                        DIRTY_NONE
                    end
                end
            end
        end

    protected
        def calc_diaries_size
            @diaries_size = 0
            @diaries.each_value do |diary|
                @diaries_size += 1 if diary.visible?
            end
        end

        def latest( limit = 5 )
            idx = 0
            @diaries.keys.sort.reverse_each do |date|
                break if idx >= limit
                diary = @diaries[date]
                next unless diary.visible?
                yield diary
                idx += 1
            end
        end

        def cache_file( prefix )
            "#{prefix}#{@rhtml.sub( /\.rhtml$/, '.rb' )}"
        end
    end

    #
    # class TDiaryCategoryView
    #  base of category view mode classes
    #
    class TDiaryCategoryView < TDiaryBase
        attr_reader :last_modified
        def initialize(cgi, rhtml, conf)
            super
            @last_modified = Time.now
        end
    end

    #
    # exception class for TrackBack
    #
    class TDiaryTrackBackError < StandardError
    end

    #
    # class TDiaryTrackBackBase
    #
    class TDiaryTrackBackBase < TDiaryBase
        public :mode
        def initialize( cgi, rhtml, conf )
            super
            date = ENV['REQUEST_URI'].scan(%r!/(\d{4})(\d\d)(\d\d)!)[0]
            if date
                @date = Time::local(*date)
            else
                @date = Time::now
            end
        end

        def diary_url
            @conf.base_url + @conf.index.sub(%r|^\./|, '') + @plugin.instance_eval(%Q|anchor "#{@date.strftime('%Y%m%d')}"|)
        end

        def self.success_response
            <<HERE
<?xml version="1.0" encoding="iso-8859-1"?>
<response>
<error>0</error>
</response>
HERE
        end

        def self.fail_response(reason)
            <<HERE
<?xml version="1.0" encoding="iso-8859-1"?>
<response>
<error>1</error>
<message>#{reason}</message>
</response>
HERE
        end
    end

    #
    # class TDiaryTrackBackRSS
    #  generate RSS
    #
    class TDiaryTrackBackRSS < TDiaryTrackBackBase
        def initialize( cgi, rhtml, conf )
            super
            @io.transaction( @date ) do |diaries|
                @diaries = diaries
                @diary = @diaries[@date.strftime('%Y%m%d')]
                DIRTY_NONE
            end
        end

        def eval_rhtml( prefix = '' )
            raise TDiaryTrackBackError.new("invalid date: #{@date.strftime('%Y%m%d')}") unless @diary
            load_plugins
            r = <<RSSHEAD
<?xml version="1.0" encoding="#{@conf.encoding}"?>
<response>
<error>0</error>
<rss version="0.91">
<channel>
<title>#{@diary.title}</title>
<link>#{diary_url}</link>
<description></description>
<language>#{@conf.html_lang}</language>
RSSHEAD
            @diary.each_comment(100) do |com, idx|
                begin
                    next unless com.visible_true?
                rescue NameError, NoMethodError
                    next unless com.visible?
                end
                next unless /^(Track|Ping)Back$/ =~ com.name
                url, blog_name, title, excerpt = com.body.split(/\n/, 4)
                r << <<RSSITEM
<item>
<title>#{CGI::escapeHTML( title )}</title>
<link>#{CGI::escapeHTML( url )}</link>
<description>#{CGI::escapeHTML( excerpt )}</description>
</item>
RSSITEM
            end
            r << <<RSSFOOT
</channel>
</rss>
</response>
RSSFOOT
        end
    end

    #
    # class TDiaryTrackBackReceive
    #  receive TrackBack ping and store as comment
    #
    class TDiaryTrackBackReceive < TDiaryTrackBackBase
        def initialize( cgi, rhtml, conf )
            super
            @error = nil

            url = @cgi.params['url'][0]
            blog_name = @conf.to_native( @cgi.params['blog_name'][0] || '' )
            title = @conf.to_native( @cgi.params['title'][0] || '' )
            excerpt = @conf.to_native( @cgi.params['excerpt'][0] || '' )
            if excerpt.length > 255
                excerpt = @conf.shorten( excerpt, 252 )
            end

            body = [url, blog_name, title, excerpt].join("\n")
            @cgi.params['name'] = ['TrackBack']
            @cgi.params['body'] = [body]

            @comment = Comment::new('TrackBack', '', body)
            begin
                @io.transaction( @date ) do |diaries|
                    @diaries = diaries
                    @diary = @diaries[@date.strftime('%Y%m%d')]
                    if @diary and comment_filter( @diary, @comment ) then
                        @diary.add_comment(@comment)
                        DIRTY_COMMENT
                    else
                        @comment = nil
                        DIRTY_NONE
                    end
                end
            rescue
                @error = $!.message
            end
        end

        def eval_rhtml( prefix = '' )
            raise TDiaryTrackBackError.new(@error) if @error
            load_plugins
            @plugin.instance_eval { update_proc }
            TDiaryTrackBackBase::success_response
        end
    end

    #
    # class TDiaryTrackBackShow
    #  show TrackBacks
    #
    class TDiaryTrackBackShow < TDiaryTrackBackBase
        def eval_rhtml( prefix = '' )
            load_plugins
            anchor = @plugin.instance_eval(%Q|anchor "#{@date.strftime('%Y%m%d')}"|)
            url = "#{@conf.index}#{anchor}#t"
            url[0, 0] = '../' if %r|^https?://|i !~ @conf.index
            raise ForceRedirect::new( url )
        end
    end
end

# vim: ts=3
