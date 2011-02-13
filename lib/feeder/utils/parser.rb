module Feeder
  
  class Parser
    
    attr_accessor :current_feeds, :queue, :toggle
            
    def initialize(current_feeds,queue,toggle)
      @current_feeds ||= current_feeds
      @queue ||= queue
      @toggle ||= toggle
    end
    
    # this would be used as a hook to resque later on. a method in mailer would be called here later, when feeds are found to have updates.
    # resque would poll this at regular intervals.
    def perform
      @current_feeds.each do |feed_id, feed|
        @queue << feed_id if Feedzirra::Feed.update(feed).updated?
      end
      puts "i was here!"
      parse    
    end
    
    def async(current_feeds,queue,toggle)
        Resque.enqueue(Worker,current_feeds,queue,toggle)
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
    
    # ensures that only feeds that require updating are updated and corresponding posts
    # created accordingly in the methods below, genius!!!
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