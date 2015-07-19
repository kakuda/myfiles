# sudo gem install -y wirble
require 'irb/completion'
require 'rubygems'
require 'wirble'
require 'pathname'
require 'enumerator'

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:PROMPT_MODE] = :INF_RUBY
IRB.conf[:USE_READLINE] = true

Wirble.init
Wirble.colorize

def refe arg
  puts `refe #{arg}`
end

class Module
  def refe(meth=nil)
    if meth
      if instance_methods(false).include? meth.to_s
        puts `refe #{self}##{meth}`
      else
        super
      end
    else
      puts `refe #{self}`
    end
  end
end

class IO
  # ɸ����Ϥκ����ؤ�
  def redirect(&block)
    backup=nil
    begin
      backup=$stdout
      $stdout=self
      block.call
    ensure
      $stdout=backup
    end
  end
end

# Pathname�Υ�åѡ�
class String
  def to_path
    Pathname.new(self)
  end
  def cleanpath
    to_path.cleanpath.to_s
  end
  def realpath
    to_path.realpath.to_s
  end
end

# ��Ԥǥե�����񤭹��߽����򤹤뤿��
class Object
  def write_to_file(filepath)
    File.open(filepath, "w") { |file|
      file.write( self )
    }
  end
end

# ����ӥ˥���ȥ᥽�å�
class Integer
  def threads(&block)
    threads = []
    self.times{
      threads << Thread.new{
        block.call
      }
    }

    threads.each{ |th|
      th.join
    }
  end
end

