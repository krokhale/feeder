module Feeder
  
  class Parser
            
    def initialize
      @current_feeds ||= {}
      @queue ||= []
      @toggle = false
    end
    
    # this would be used as a hook to resque later on. a method in mailer would be called here later, when feeds are found to have updates.
    # resque would poll this at regular intervals.
    def perform
      @current_feeds.each do |feed_id, feed|
        @queue << feed_id if Feedzirra::Feed.update(feed).updated?
      end
      parse    
    end
    
    
    protected
    
    def parse
      sources.each do |source|
          @queue.include?(source.id) ? feed = Feedzirra::Feed.update(@current_feeds.fetch(source.id)) : feed = Feedzirra::Feed.fetch_and_parse(source.url)
          eval(feed,source.id) unless feed.eql?(404)
      end
      @toggle = true
      sources 
    end
    
    
    def sources
      @current_feeds.empty? ? Feed.all : ( @toggle ? Feed.all.select{|feed| @queue.include?(feed.id) } : [])
    end
    
    def eval(feed,id)
      populate_records(feed,id)
      @current_feeds.merge!({id => feed})
    end
    
    def populate_records(feed,id)
      feed.entries.each do |entry|
        Post.create(:title => entry.title.sanitize, :url => entry.url, :date => entry.published,
         :text => entry.content.sanitize, :feed_id => id)
         puts "Post created for #{Feed.find(id).url}" 
      end
    end 
    
  end
  
end