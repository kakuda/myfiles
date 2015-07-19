#!/usr/bin/env ruby
require 'webrick'

document_root = '.'
rubybin = '/usr/bin/ruby'
phpbin = '/usr/bin/php'

server = WEBrick::HTTPServer.new({ :DocumentRoot => document_root,
                                   :BindAddress => '0.0.0.0',
                                   :CGIInterpreter => phpbin,
                                   :Port => 80
                                 })

['/get.php'].each do |cgi_file|
  server.mount(cgi_file, WEBrick::HTTPServlet::CGIHandler, document_root + cgi_file)
end

['INT', 'TERM'].each do |signal|
  Signal.trap(signal) { server.shutdown }
end

server.start
