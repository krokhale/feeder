module Feeder
  
  class Parser
    
    def initialize
      @feeds ||= []
    end
    
    def parse
      sources.each do |source|
        feed = Feedzirra::Feed.fetch_and_parse(source.url)
        populate_record(feed,source.id) if feed != 404
      end 
    end
    
    
    protected
    
    
    def sources
      Feed.all
    end
    
    def populate_record(feed,id)
      feed.entries.each do |entry|
        Post.create(:title => entry.title.sanitize, :url => entry.url, :date => entry.published,
         :text => entry.content.sanitize, :feed_id => id)
         puts "#{entry.title.sanitize}  : Post Created!" 
      end
    end 
    
  end
  
end