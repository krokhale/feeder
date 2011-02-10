module Feeder
  
  class Parser
    
    attr_reader :queue
    
    def initialize
      @current_feeds ||= {}
      @queue ||= refresh
    end
    
    def parse
      sources.each do |source|
        @queue.include?(source.id) ? feed = Feedzirra::Feed.update(@current_feeds.fetch(source.id)) : feed = Feedzirra::Feed.fetch_and_parse(source.url)
        feed.eql?(404) ? feed : eval(feed,source.id)
      end 
    end
    
    
    protected
    
    def refresh
      status = []
      if @current_feeds.empty?
        status
      else
        @current_feeds.each do |feed_id, feed|
          status << feed_id if Feedzirra::Feed.update(feed).updated?
        end
      end    
    end
    
    def sources
      @queue.empty? ? Feed.all : Feed.all.select{|feed| @queue.include?(feed.id) }
    end
    
    def eval(feed,id)
      populate_records(feed,id)
      @current_feeds.merge({id => feed})
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