module Feeder
  
  class Parser
                
    def initialize
      Feed.all.each do |feed|
        feed.update_attributes(:raw => Base64.encode64(Marshal.dump(Feedzirra::Feed.fetch_and_parse(feed.url))), :updates => false)
      end
    end
    
    def perform
      Feed.all.each do |feed|
        raw = Marshal.load(Base64.decode64(feed.raw))
        feed.update_attribute(:updates, true) unless Feedzirra::Feed.update(raw).new_entries.empty?
      end
      puts "i was here!"
      parse    
    end
    
    def async
        Resque.enqueue(Worker)
    end
    
    
    protected
    
    def parse
      sources.each do |source|
          source.updates ? feed = Feedzirra::Feed.update(Marshal.load(Base64.decode64(source.raw))) : feed = Feedzirra::Feed.fetch_and_parse(source.url)
          eval(feed,source.id,source.updates,source.url) unless feed.eql?(404)
      end
    end
    

    def sources
       Feed.find_all_by_updates(true) 
    end
    
    def eval(feed,id,updates,url)
      if updates
        feed.new_entries.each do |entry|
          populate_record(entry,id)
        end
        Resque.enqueue(Worker,feed_id = id)
      else
        feed.entries.each do |entry|
          populate_record(entry,id)
        end
      end
      Feed.find(id).update_attributes(:raw => Base64.encode64(Marshal.dump(Feedzirra::Feed.fetch_and_parse(feed.url))), :updates => false)
    end
    
    def populate_record(entry,id)
        Post.create(:title => entry.title.sanitize, :url => entry.url, :date => entry.published,
         :text => entry.content.sanitize, :feed_id => id)
         puts "Post created for #{Feed.find(id).url}" 
    end 
    
  end
  
end