$:.unshift(File.dirname(__FILE__))

require 'feedzirra'
require 'utils/mailer'
require 'utils/parser'


module Feeder
  
  
  class Worker
        
    @queue = :master
    
    
    def self.perform(current_feeds,queue,toggle)
        parser = Parser.new(current_feeds,queue,toggle)
        parser.perform
        parser.async(parser.current_feeds,parser.queue,parser.toggle)
    end
    
    # perform is standard method for resque
    def parse!
      @parser = Parser.new
      @parser.perform
    end
    
    def mail!
      mailer = Mailer.new
      mailer.perform
    end
    
  end
  
end