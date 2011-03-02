require File.dirname(__FILE__) + '/../test_helper'
require 'pp'
class MessagesTest < Test::Unit::TestCase
#  fixtures :messages
  include MessagesHelper
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_sanitize
    ar = Array.new
    s = '<body>
    <js>
    javascript0
    <table>
    javascritp55
    </table>
    </js>
    <table>block1</table>
    <code>block2<table>table2</table></code>
    <table>block3</table><code>block4
    </code><table>block5</table>
    <img  src="asdf" />
        <img  src=\'asdf\' />
    <br>
     block_ruby1
     <ruby>
     <%dfg dgdfg%>
     <table>
     block_ruby2
     </table>
     </ruby>
     block_ruby3
     <ruby>
     block_ruby4 
     </ruby>
     end1
     <js>
     javascript
     <table>
     table javascript
     </table>
     </js>
     end2
    </body>'
    
#    s = "<img src='qqqqqqqqq'>"
#    s+= '<img src="qqqqqqqqq2">'
#    p s
#    rm =  /(.*)(<code>.*<\/code>)(.*)/m.match(s)
#    rm =  /(.*)(<code>.*<\/code>|<ruby>.*<\/ruby>)(.*)/m.match(s)
    
#      p rm[3]
#      p "------------"
#      p rm[2]
#      p "-------------"
#      p rm[1]
     
#    while !rm.nil? do
#      ar << message_sanitize(rm[3])
#      p rm[3]
#      p rm[2]
#      p rm[1]
#      p"------------------------------------------"
#      ar << rm[3]
#      ar << rm[2]
#      s = rm[1]
#      rm =  /(.*)(<code>.*<\/code>)(.*)/.match(s)
#     rm =  /(.*)(<code>.*<\/code>|<ruby>.*<\/ruby>)(.*)/m.match(s)
#    end
    #ar << message_sanitize(s)   
#    ar << s
#     p s
#    p ar.inspect
#    p colorize(ar.reverse!.to_s)
    p message_sanitize(s) 
    assert true
  end
end
