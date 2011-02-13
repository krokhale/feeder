module Feeder
  
  class Mailer
    
    def initialize(feed_id)
      @feed ||= Feed.find(feed_id)
      @users ||= @feed.users 
    end
    
    def async
      @users.each do |user|
        mail = Mail.new do
          from 'me@test.net'
          to user.email
          subject 'RSS feed has been updated!'
          body 'RSS feed has new post!'
        end
        mail.deliver!
      end
    end
    
  end
  
end