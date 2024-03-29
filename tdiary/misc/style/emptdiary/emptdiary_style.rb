=begin
= emptDiary style((-$Id: emptdiary_style.rb,v 1.6.2.1 2005/03/11 07:44:37 tadatadashi Exp $-))

== Summary
This style is an extension to the tDiary style which allows plug-in
arguments to have empty lines. In short, this style preserves empty
lines between <% and %> when splltting the input into sections.

The latest version of this file can be downloaded from
((<URL:http://zunda.freeshell.org/d/misc/style/emptdiary/emptdiary_style.rb>)).

== Usage
if you want to use this style, add the following line into tdiary.conf:
  @style = 'emptdiary'
Please see  README.rd or README.rd.en for further explanation.

== Acknowledgements
This style is realized using TdiarySection and TdiaryDiary as
super-classes. I thank the authors of tdiary_style.rb for providing such
flexible classes.

EmptdiaryDiary::to_html4 and EmptdiaryDiary::to_chtml are copied from
tdiary_style.rb and slightly edited as follows:
* split_unless_plugin() is inserted before each collect()
* Regexp is chanegd from ^ to \A

== Copyright
Copyright 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution,
and distribution of modified versions of this work under the terms
of GPL version 2 or later.                                                  
=end
=begin ChangeLog
* Mon Feb 17, 2003 zunda <zunda at freeshell.org>
- copied from zunda_style.rb, with which I used for preliminary tests.
* Wed Feb 26, 2003 zunda <zunda at freeshell.org>
- TDiary::Emptdiary::String class to handle strings better
	(Thanks to Mitsuru Shimamura <mitsuru at diana.dti.ne.jp> for the
	error report)
* Wed Dec 22, 2004 zunda <zunda at freeshell.org>
- override body_to_html
=end
 
require 'tdiary/tdiary_style'

=begin
== Classes and methods defined in this style
Please note that not all are documented.
=end

module TDiary
=begin
=== TDiary::Emptdiary::EmptdiaryString < String
Extended String class not to divide things between <% and %>.

--- TDiary::Emptdiary::EmptdiaryString.split_unless_plugin ( delimiter = "\n\n" )
      Returns an array of EmptdiaryString splitted at ((|delimiter|))
      which is outside of <% and %> pairs. Specify ((|delimiter|)) as a
      String showing a fragment of Regexp. This will be combined in a
      Regexp like: /(#{delimiter)|<%|%>)/.
=end
	class Emptdiary
		class EmptdiaryString < String
			def split_unless_plugin( delimiter = "\n\n+" )
				result = Array.new
				fragment = ''
				nest = 0
				remain = self.gsub(/.*?(#{delimiter}|<%|%>)/m) do
					fragment += $&
					case $1
					when '<%'
						nest += 1
					when '%>'
						nest -= 1
					else
						if nest == 0 then
							fragment.sub!( /#{delimiter}\z/, '' )
							result << Emptdiary::EmptdiaryString.new( fragment ) unless fragment.empty?
							fragment = ''
						end
					end
					''
				end
				fragment += remain
				fragment.sub!( /#{delimiter}\z/, '' )
				result << Emptdiary::EmptdiaryString.new( fragment ) unless fragment.empty?
				result
			end
		end
	end

=begin
=== TDiary::EmptdiartySection < TdiarySection
Almost the same as TdiarySection but usess split_unless_plugin instead
of split. initialize method is overrideen.
=end
	class EmptdiarySection < TdiarySection
		def initialize( fragment, author = nil )
			@author = author
			lines = fragment.split_unless_plugin( "\n+" )
			if lines.size > 1 then
				if /\A<</ =~ lines[0]
					@subtitle = lines.shift.chomp.sub( /\A</, '' )
				elsif /\A[　 <]/e !~ lines[0]
					@subtitle = lines.shift.chomp
				end
			end
			@body = Emptdiary::EmptdiaryString.new( lines.join( "\n" ) )
			@categories = get_categories
			@stripped_subtitle = strip_subtitle
		end

		def body_to_html
			html = ""
			@body.split_unless_plugin( "\n" ).each do |p|
				if /\A</ =~ p then
					html << p
				else
					html << "<p>#{p}</p>"
				end
			end
			html
		end
	end

=begin
=== TDiary::EmptdiaryDiary < TdiaryDiary
Almost the same as TdiarySection but usess split_unless_plugin instead
of split. append method is overriden and makes EmptdiarySection with
body being an EmptdiaryString. Also, to_html4 and to_chtml methods are
overridden to split_unless_plugin before collect'ing the body of the
sections.
=end
	class EmptdiaryDiary < TdiaryDiary
		def style
		  'emptdiary'
		end
	
		def append( body, author = nil )
			Emptdiary::EmptdiaryString.new(body.gsub( /\r/, '' )).split_unless_plugin( "\n\n+" ).each do |fragment|
				section = EmptdiarySection::new( fragment, author )
				@sections << section if section
			end
			@last_modified = Time::now
			self
		end

		def to_html4( opt )
			idx = 1
			r = ''
			each_section do |section|
				r << %Q[<div class="section">\n]
				if section.subtitle then
					r << %Q[<h3><a ]
					if opt['anchor'] then
						r << %Q[name="p#{'%02d' % idx}" ]
					end
					r << %Q[href="#{opt['index']}<%=anchor "#{date.strftime( '%Y%m%d' )}#p#{'%02d' % idx}" %>">#{opt['section_anchor']}</a> ]
					if opt['multi_user'] and section.author then
						r << %Q|[#{section.author}]|
					end
					r << %Q[#{section.categorized_subtitle}</h3>]
				end
				if /\A</ =~ section.body then
					r << %Q[#{section.body}]
				elsif section.subtitle
					r << %Q[<p>#{section.body.split_unless_plugin( "\n+" ).collect{|l|l.chomp.sub( /\A[　 ]/e, '')}.join( "</p>\n<p>" )}</p>]
				else
					r << %Q[<p><a ]
					if opt['anchor'] then
						r << %Q[name="p#{'%02d' % idx}" ]
					end
					r << %Q[href="#{opt['index']}<%=anchor "#{date.strftime( '%Y%m%d' )}#p#{'%02d' % idx}" %>">#{opt['section_anchor']}</a> #{section.body.split_unless_plugin( "\n+" ).collect{|l|l.chomp.sub( /\A[　 ]/e, '' )}.join( "</p>\n<p>" )}</p>]
				end
				r << %Q[</div>]
				idx += 1
			end
			r
		end

		def to_chtml( opt )
			idx = 0
			r = ''
			each_section do |section|
				if section.subtitle then
					r << %Q[<H3><A NAME="p#{'%02d' % idx += 1}">*</A> #{section.subtitle}</H3>]
				end
				if /\A</ =~ section.body then
					idx += 1
					r << section.body
				elsif section.subtitle
					r << %Q[<P>#{section.body.split_unless_plugin( "\n+" ).collect{|l|l.chomp.sub( /\A[　 ]/e, '' )}.join( "</P>\n<P>" )}</P>]
				else
					r << %Q[<P><A NAME="p#{'%02d' % idx += 1}">*</A> ]
					if opt['multi_user'] and section.author then
						r << %Q|[#{section.author}]|
					end
					r << %Q[#{section.body.split_unless_plugin( "\n+" ).collect{|l|l.chomp.sub( /\A[　 ]/e, '' )}.join( "</P>\n<P>" )}</P>]
				end
			end
			r
		end

	end
end
