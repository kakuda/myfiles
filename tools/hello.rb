require 'cgi'

cgi = CGI.new('html3')
cgi.out {
  cgi.html {
    cgi.head {
      cgi.title{'Hello'}
    } +
    cgi.body {
      'Hello, Ruby!'
    }
  }
}
