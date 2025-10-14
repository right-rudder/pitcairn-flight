class Rack::Attack
  # Example: Throttle POST requests to the contact form
  throttle('limit form submissions per IP', limit: 5, period: 1.hour) do |req|
    if req.path == '/contact' && req.post?
      req.ip
    end
  end

  # Optional: block suspicious bots
  Rack::Attack.blocklist('block suspicious user agents') do |req|
    req.user_agent.nil? || req.user_agent.match?(/curl|Wget|HTTrack|bot/i)
  end
end


# config/initializers/rack_attack.rb
# class Rack::Attack
#   throttle('limit messages per ip', limit: 5, period: 1.hour) do |req|
#     if req.path == '/your_form_endpoint' && req.post?
#       req.ip
#     end
#   end

#   # Optional: Block suspicious IPs
#   # blacklist('block 1.2.3.4') do |req|
#   #   '1.2.3.4' == req.ip
#   # end
# end

# class Rack::Attack
#   # Block requests if they exceed limit
#   throttle('limit messages per ip', limit: 5, period: 1.hour) do |req|
#     if req.path == '/messages' && req.post?
#       req.ip
#     end
#   end

#   # Optional: custom response
#   self.throttled_response = lambda do |env|
#     [
#       429,
#       { 'Content-Type' => 'text/plain' },
#       ["Too many requests. Please try again later.\n"]
#     ]
#   end
# end
