#!/usr/local/bin/ruby
#
# index.rb $Revision: 1.26 $
#
# Copyright (C) 2001-2003, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
BEGIN { $defout.binmode }
$KCODE = 'n'

begin
	if FileTest::symlink?( __FILE__ ) then
		org_path = File::dirname( File::readlink( __FILE__ ) )
	else
		org_path = File::dirname( __FILE__ )
	end
	$:.unshift( org_path.untaint )
	require 'tdiary'

	@cgi = CGI::new
	conf = TDiary::Config::new
	tdiary = nil
	status = nil
	if %r[/\d{4,8}\.html?$] =~ ENV['REDIRECT_URL'] and not @cgi.valid?( 'date' ) then
		@cgi.params['date'] = [ENV['REDIRECT_URL'].sub( /.*\/(\d+)\.html$/, '\1' )]
		status = '200 OK'
	end

	begin
		if @cgi.valid?( 'comment' ) then
			tdiary = TDiary::TDiaryComment::new( @cgi, "day.rhtml", conf )
		elsif @cgi.valid?( 'date' )
			date = @cgi.params['date'][0]
			if /^\d{8}$/ =~ date then
				tdiary = TDiary::TDiaryDay::new( @cgi, "day.rhtml", conf )
			elsif /^\d{6}$/ =~ date then
				tdiary = TDiary::TDiaryMonth::new( @cgi, "month.rhtml", conf )
			elsif /^\d{4}$/ =~ date then
				tdiary = TDiary::TDiaryNYear::new( @cgi, "month.rhtml", conf )
			end
		elsif @cgi.valid?( 'category' )
			tdiary = TDiary::TDiaryCategoryView::new( @cgi, "category.rhtml", conf )
		else
			tdiary = TDiary::TDiaryLatest::new( @cgi, "latest.rhtml", conf )
		end
	rescue TDiary::PermissionError
		raise
	rescue TDiary::TDiaryError
	end
	tdiary = TDiary::TDiaryLatest::new( @cgi, "latest.rhtml", conf ) if not tdiary

	begin
		head = {
			'type' => 'text/html',
			'Vary' => 'User-Agent'
		}
		head['status'] = status if status
		body = ''
		head['Last-Modified'] = CGI::rfc1123_date( tdiary.last_modified )

		# ETag testing code
		#require 'md5'
		#head['ETag'] = MD5::md5( body )

		if /HEAD/i !~ @cgi.request_method then
			if @cgi.mobile_agent? then
				body = conf.to_mobile( tdiary.eval_rhtml( 'i.' ) )
				head['charset'] = conf.mobile_encoding
				head['Content-Length'] = body.size.to_s
			else
				body = tdiary.eval_rhtml
				head['charset'] = conf.encoding
				head['Content-Length'] = body.size.to_s
				head['Pragma'] = 'no-cache'
				head['Cache-Control'] = 'no-cache'
			end
			head['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
			print @cgi.header( head )
			print body
		else
			head['Pragma'] = 'no-cache'
			head['Cache-Control'] = 'no-cache'
			print @cgi.header( head )
		end
	rescue TDiary::ForceRedirect
		head = {
			#'Location' => $!.path
			'type' => 'text/html',
		}
		head['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
		print @cgi.header( head )
		print %Q[
			<html>
			<head>
			<meta http-equiv="refresh" content="1;url=#{$!.path}">
			<title>moving...</title>
			</head>
			<body>Wait or <a href="#{$!.path}">Click here!</a></body>
			</html>]
	end
rescue Exception
	if @cgi then
		print @cgi.header( 'type' => 'text/plain' )
	else
		print "Content-Type: text/plain\n\n"
	end
	puts "#$! (#{$!.class})"
	puts ""
	puts $@.join( "\n" )
end

