# makerss_zatta.rb: $Revision: 1.26 $
#
# generate RSS file when updating.
#
# options configurable through settings:
#   @conf['makerss_zatta.hidecomment'] : hide tsukkomi's. default: false
#   @conf['makerss_zatta.hidecontent'] : hide full-text content. default: false
#   @conf['makerss_zatta.shortdesc'] : shorter description. default: false
#
# options to be edited in tdiary.conf:
#   @conf['makerss_zatta.file']  : local file name of RSS file. default: 'zatta.rdf'.
#   @conf['makerss_zatta.url']   : URL of RSS file.
#   @conf.icon             : URL of site icon image (can be relative)
#   @conf.description      : desciption of the diary
#   @conf['makerss_zatta.partial'] : how much portion of body to be in description
#                              used when makerss_zatta.shortdesc, default: 0.25
#
#   CAUTION: Before using, make 'zatta.rdf' file into the directory of your diary,
#            and permit writable to httpd.
#
# Copyright (c) 2004 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
$KCODE = 'EUC'
# backward compatibility
item = 'makerss_zatta.hidecomment'
if true == @conf[item] then
  @conf[item] = 'content'
end

if /^append|replace|comment|showcomment|trackbackreceive|pingbackreceive$/ =~ @mode then
	unless @conf.description
		@conf.description = @conf['whatsnew_list.rdf.description']
	end
	eval( <<-TOPLEVEL_CLASS, TOPLEVEL_BINDING )
		module TDiary
			class RDFSection
				attr_reader :id, :time, :section, :diary_title

				# 'id' has 'YYYYMMDDpNN' format (p or c).
				# 'time' is Last-Modified this section as a Time object.
				def initialize( id, time, section )
					@id, @time, @section, @diary_title = id, time, section, diary_title
				end
		
				def time_string
					g = @time.dup.gmtime
					l = Time::local( g.year, g.month, g.day, g.hour, g.min, g.sec )
					tz = (g.to_i - l.to_i)
					zone = sprintf( "%+03d:%02d", tz / 3600, tz % 3600 / 60 )
					@time.strftime( "%Y-%m-%dT%H:%M:%S" ) + zone
				end

				def <=>( other )
					other.time <=> @time
				end
			end
		end
	TOPLEVEL_CLASS
end

def makerss_zatta_update
	date = @date.strftime( "%Y%m%d" )
	diary = @diaries[date]

	uri = @conf.index.dup
	uri[0, 0] = @conf.base_url if %r|^https?://|i !~ @conf.index
	uri.gsub!( %r|/\./|, '/' )

	require 'pstore'
	cache = {}
	xml = ''
	seq = ''
	body = ''
	PStore::new( "#{@cache_path}/makerss_zatta.cache" ).transaction do |db|
		begin
			cache = db['cache_zatta'] if db.root?( 'cache_zatta' )
	
			if /^append|replace$/ =~ @mode then
				index = 0
				diary.each_section do |section|
					index += 1
					id = "#{date}p%02d" % index
					if diary.visible? and !cache[id] then
						cache[id] = RDFSection::new( id, Time::now, section )
					elsif !diary.visible? and cache[id]
						cache.delete( id )
					elsif diary.visible? and cache[id]
						if cache[id].section.body_to_html != section.body_to_html or
								cache[id].section.subtitle_to_html != section.subtitle_to_html then
							cache[id] = RDFSection::new( id, Time::now, section )
						end
					end
				end
			elsif /^comment$/ =~ @mode and @conf.show_comment
				id = "#{date}c%02d" % diary.count_comments( true )
				cache[id] = RDFSection::new( id, @comment.date, @comment )
			elsif /^showcomment$/ =~ @mode
				index = 0
				diary.each_comment( 100 ) do |comment|
					index += 1
					id = "#{date}c%02d" % index
					if !cache[id] and (@conf.show_comment and comment.visible? and /^(TrackBack|Pingback)$/i !~ comment.name) then
						cache[id] = RDFSection::new( id, comment.date, comment )
					elsif cache[id] and !(@conf.show_comment and comment.visible? and /^(TrackBack|Pingback)$/i !~ comment.name)
						cache.delete( id )
					end
				end
			end
	
			xml << makerss_zatta_header( uri )
			seq << "<items><rdf:Seq>\n"
			item_max = 50
			zatta_flag = 0;
#			cache.values.sort{|a,b| b.time <=> a.time}.each_with_index do |rdfsec, idx|
			cache.values.sort{|a,b| (a.id[9..10] <=> b.id[9..10] if ( a.id[0..7] <=> b.id[0..7] ) == 0) || b.id[0..7] <=> a.id[0..7] }.each_with_index do |rdfsec, idx|
				if idx < item_max then
					if rdfsec.section.respond_to?( :visible? ) and !rdfsec.section.visible?
						item_max += 1
					else
					  subtitle = makerss_zatta_subtitle(rdfsec)
					  if /^絰諸生正/ =~ subtitle
					    zatta_flag = 0;
					  end
					  if zatta_flag == 1 then
						seq << makerss_zatta_seq( uri, rdfsec )
						body << makerss_zatta_body( uri, rdfsec )
					  else
					    item_max += 1
				      end
					  if /^豪聶生正/ =~ subtitle
					    zatta_flag = 1;
					  end
					end
				elsif idx > 100
					cache.delete( rdfsec.id )
				end
			end
	
			db['cache_zatta'] = cache
		rescue PStore::Error
		end
	end

	if @conf.icon and not @conf.icon.empty?
		if /^http/ =~ @conf.icon
			rdf_image = @conf.icon
		else
			rdf_image = @conf.base_url + @conf.icon
		end
		xml << %Q[<image rdf:resource="#{rdf_image}" />\n]
	end

	xml << seq << "</rdf:Seq></items>\n</channel>\n"
	xml << makerss_zatta_image( uri, rdf_image ) if rdf_image
	xml << body
	xml << makerss_zatta_footer
	rdf_file = 'zatta.rdf'
	rdf_file = 'zatta.rdf' if rdf_file.length == 0
	File::open( rdf_file, 'w' ) do |f|
		f.write( @makerss_encoder.call( xml ) )
	end
end

def makerss_zatta_subtitle(rdfsec)
	subtitle = ''
	if rdfsec.section.respond_to?( :body_to_html ) then
		a = rdfsec.id.scan( /(\d{4})(\d\d)(\d\d)/ ).flatten.map{|s| s.to_i}
		date = Time::local( *a )
		body_enter_proc( date )
		old_apply_plugin = @conf['apply_plugin']
		@conf['apply_plugin'] = true
		subtitle = apply_plugin( rdfsec.section.subtitle_to_html, true ).strip
		if subtitle.empty?
			subtitle = apply_plugin( rdfsec.section.body_to_html, true ).strip
			subtitle.gsub!(/(http:\/\/|https:\/\/|ftp:\/\/|mailto:)\S+/, '')
			subtitle.strip
		end
		subtitle.gsub!( /\n/, '' )
    end
	CGI::escapeHTML( subtitle )
end

def makerss_zatta_header( uri )
	rdf_url = @conf['makerss_zatta.url'] || "#{@conf.base_url}zatta.rdf"
	rdf_url = "#{@conf.base_url}zatta.rdf" if rdf_url.length == 0

	desc = @conf.description || ''

	copyright = Time::now.strftime( "Copyright %Y #{@conf.author_name}" )
	copyright += " <#{@conf.author_mail}>" if @conf.author_mail and not @conf.author_mail.empty?
	copyright += ", copyright of comments by respective authors"
    
	xml = %Q[<?xml version="1.0" encoding="#{@makerss_encode}"?>
<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xml:lang="#{@conf.html_lang}">
	<channel rdf:about="#{rdf_url}">
	<title>#{CGI::escapeHTML( @conf.html_title )} 豪聶生正</title>
	<link>#{uri}</link>
	<description>#{desc ? CGI::escapeHTML( desc ) : ''}</description>
	<dc:creator>#{CGI::escapeHTML( @conf.author_name )}</dc:creator>
	<copyright>#{CGI::escapeHTML( copyright )}</copyright>
	]
end

def makerss_zatta_seq( uri, rdfsec )
	%Q|<rdf:li rdf:resource="#{uri}#{anchor rdfsec.id}"/>\n|
end

def makerss_zatta_image( uri, rdf_image )
	%Q[<image rdf:about="#{rdf_image}">
	<title>#{@conf.html_title}</title>
	<url>#{rdf_image}</url>
	<link>#{uri}</link>
	</image>
	]
end

def makerss_zatta_desc_shorten( text )
	if @conf['makerss_zatta.shortdesc'] then
		@conf['makerss_zatta.partial'] = 0.25 unless @conf['makerss_zatta.partial']
		len = ( text.size.to_f * @conf['makerss_zatta.partial'] ).ceil.to_i
		len = 500 if len > 500
	else
		len = 500
	end
	@conf.shorten( text, len )
end

def makerss_zatta_body( uri, rdfsec )
	rdf = ""
	if rdfsec.section.respond_to?( :body_to_html ) then
		rdf = %Q|<item rdf:about="#{uri}#{anchor rdfsec.id}">\n|
#		rdf << %Q|<link>#{uri}#{anchor rdfsec.id}</link>\n|
#		rdf << %Q|<dc:date>#{rdfsec.time_string}</dc:date>\n|
		a = rdfsec.id.scan( /(\d{4})(\d\d)(\d\d)/ ).flatten.map{|s| s.to_i}
		date = Time::local( *a )
		body_enter_proc( date )
		old_apply_plugin = @conf['apply_plugin']
		@conf['apply_plugin'] = true

		link = apply_plugin( rdfsec.section.body_to_html ).strip
		link.gsub!( /\&/, '&amp;' )
		regex = %r!href\s*=\s*(['"])?((?:http://|https://|ftp://|mailto:)\S+?)\1!i
		urls = []
		link.scan(regex) { urls.push($2) }
		if urls.size == 0
			rdf << %Q|<link>#{uri}#{anchor rdfsec.id}</link>\n|
		else
#			rdf << %Q|<link>#{CGI::escapeHTML( urls )}</link>\n|
			rdf << %Q|<link>#{urls}</link>\n|
		end
		rdf << %Q|<dc:date>#{rdfsec.time_string}</dc:date>\n|
		# <title>, <dc:creator>
		subtitle = apply_plugin( rdfsec.section.subtitle_to_html, true ).strip
		if subtitle.empty?
			subtitle = apply_plugin( rdfsec.section.body_to_html, true ).strip
			subtitle.gsub!(/(http:\/\/|https:\/\/|ftp:\/\/|mailto:)\S+/, '')
			subtitle.strip
		end
		subtitle.gsub!( /\n/, '' )
		rdf << %Q|<title>#{CGI::escapeHTML( subtitle )}</title>\n|
		rdf << %Q|<dc:creator>#{CGI::escapeHTML( @conf.author_name )}</dc:creator>\n|
		if ! rdfsec.section.categories.empty?
			rdfsec.section.categories.each do |category|
				rdf << %Q|<dc:subject>#{CGI::escapeHTML( category )}</dc:subject>\n|
			end
		end
		# <description>
#		desc = apply_plugin( rdfsec.section.subtitle_to_html, true ).strip +
#			apply_plugin( rdfsec.section.body_to_html, true ).strip
#		desc.gsub!( /&.*?;/, '' )
#		rdf << %Q|<description>#{@conf.shorten( CGI::escapeHTML( desc ), 500 )}</description>\n|
#		rdf << %Q|<description>#{CGI::escapeHTML( subtitle )}</description>\n|
		if urls.size == 0
			rdf << %Q|<description>#{CGI::escapeHTML( subtitle )}</description>\n|
		else
			rdf << %Q|<description></description>\n|
		end
		# <content:encoded>
#		text = '<h3>' + apply_plugin( rdfsec.section.subtitle_to_html ).strip + '</h3>' +
#			apply_plugin( rdfsec.section.body_to_html ).strip
#		text.gsub!( /\]\]>/, ']]&gt;' )
#		rdf << %Q|<content:encoded><![CDATA[#{text}]]></content:encoded>\n|
		rdf << %Q|<content:encoded></content:encoded>\n|

		body_leave_proc( date )
		@conf['apply_plugin'] = old_apply_plugin
		rdf << "</item>\n"
	else # TSUKKOMI
		unless 'any' == @conf['makerss_zatta.hidecomment'] then
			rdf = %Q|<item rdf:about="#{uri}#{anchor rdfsec.id}">\n|
			rdf << %Q|<link>#{uri}#{anchor rdfsec.id}</link>\n|
			rdf << %Q|<dc:date>#{rdfsec.time_string}</dc:date>\n|
			rdf << %Q|<title>#{makerss_zatta_tsukkomi_label( rdfsec.id )} (#{CGI::escapeHTML( rdfsec.section.name )})</title>\n|
			rdf << %Q|<dc:creator>#{CGI::escapeHTML( rdfsec.section.name )}</dc:creator>\n|
			unless 'text' == @conf['makerss_zatta.hidecomment']
				text = makerss_zatta_desc_shorten( rdfsec.section.body )
				rdf << %Q|<description>#{CGI::escapeHTML( text )}</description>\n|
				unless @conf['makerss_zatta.hidecontent']
					rdf << %Q|<content:encoded><![CDATA[#{text.make_link.gsub( /\n/, '<br>' ).gsub( /<br><br>\Z/, '' ).gsub( /\]\]>/, ']]&gt;' )}]]></content:encoded>\n|
				end
			end
			rdf << "</item>\n"
		end
	end
	rdf
end

def makerss_zatta_footer
	"</rdf:RDF>\n"
end

add_update_proc do
	makerss_zatta_update
end

add_header_proc {
	rdf_url = @conf['makerss_zatta.url'] || "#{@conf.base_url}zatta.rdf"
	rdf_url = "#{@conf.base_url}zatta.rdf" if rdf_url.length == 0
	%Q|\t<link rel="alternate" type="application/rss+xml" title="RSS" href="#{rdf_url}">\n|
}
