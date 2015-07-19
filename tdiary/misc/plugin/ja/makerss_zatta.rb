# makerss_zatta.rb Japanese resources
begin
	require 'uconv'
	@makerss_encode = 'UTF-8'
	@makerss_encoder = Proc::new {|s| Uconv.euctou8( s ) }
rescue LoadError
	@makerss_encode = @conf.encoding
	@makerss_encoder = Proc::new {|s| s }
end

def makerss_zatta_tsukkomi_label( id )
	"#{id[0,4]}-#{id[4,2]}-#{id[6,2]}のツッコミ[#{id[9,2].sub( /^0/, '' )}]"
end
