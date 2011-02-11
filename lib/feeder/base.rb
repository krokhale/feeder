$:.unshift(File.dirname(__FILE__))

require 'feedzirra'
require 'utils/mailer'
require 'utils/parser'


module Feeder
  
  
  class Worker
    
    attr_reader :id
    
    @@counter = 1
    
    def initialize
      @id = @@counter
      @@counter = @@counter + 1
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