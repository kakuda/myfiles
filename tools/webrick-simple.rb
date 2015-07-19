#!/usr/bin/env ruby
require 'webrick'

document_root = './'
mimes = WEBrick::HTTPUtils::DefaultMimeTypes
mimes['svg'] = 'image/svg+xml'

server = WEBrick::HTTPServer.new({ :DocumentRoot => document_root,
                                   :BindAddress => '127.0.0.1',
                                   :MimeTypes => mimes,
                                   :Port => 80
                                 })
['INT', 'TERM'].each do |signal|
  Signal.trap(signal) { server.shutdown }
end

server.start

