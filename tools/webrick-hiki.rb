#!/usr/bin/env ruby
require 'webrick'

document_root = './'
rubybin = '/usr/bin/ruby'

server = WEBrick::HTTPServer.new({ :DocumentRoot => document_root,
                                   :DocumentRootOptions => {
                                     :FancyIndexing => true,
                                     :UserDir => nil,
                                   },
                                   :BindAddress => '127.0.0.1',
                                   :CGIInterpreter => rubybin,
                                   :Port => 10080
                                 })

server.mount('/hiki/', WEBrick::HTTPServlet::FileHandler,
             document_root + 'hiki-0.8.7/', {
               :NondisclosureName => [".ht*", "*~", "hikiconf.rb"],
               :FancyIndexing => true,
               :UserDir => nil,
             })

['INT', 'TERM'].each do |signal|
  Signal.trap(signal) { server.shutdown }
end

server.start

