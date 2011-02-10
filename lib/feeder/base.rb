module Feeder
  
  
  class Worker
    
    attr_reader :id
    
    @@counter = 1
    
    def initialize
      @id = @@counter
      @@counter = @@counter + 1
    end
    
    def parse!
      parser = Parser.new
      parser.parse
    end
    
    def mail!
      mailer = Mailer.new
      mailer.mail
    end
    
  end
  
end