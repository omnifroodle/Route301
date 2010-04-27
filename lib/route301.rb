require 'rubygems'
require 'rack'
#require 'PP'

class Route301
  def initialize(app, options = {})
    @app = app
    
    @routes = options[:routes]
  end
  
  def call(env, options={})
    
    @status, @headers, @response = @app.call(env)
    if [404, 406].include? @status
      route = find_301(env['PATH_INFO'])
      if route 
        location = forwarding_url(env, route)
        if location
          puts "forwarding to #{location}"
          return [301, {'Location' => location, 'Content-Type' => 'text/html'}, ['redirecting...']]
        else
          return [@status, @headers, @response]
        end
      end
    end
    
    [@status, @headers, @response]
  end
  
  private
  
  def find_301(path)
    puts "find_301 #{path}"
    @routes.detect{|route| match_route(path, route)}
  end
  
  def match_route(path, route)
    puts "match_route #{path} route #{route.to_s}"
    puts "match: #{route[:when] === path}"
    route[:when] === path
  end
  
  def forwarding_url(env, route)
    route[:send_to].respond_to?(:call) ? route[:send_to].call(env) : route[:send_to]
  end
end
