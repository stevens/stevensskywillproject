class TestController < ApplicationController
  
  def index
    require 'memcache'
    cache = MemCache.new('127.0.0.1:11211')
    cache.add('uid', 1001)
    @test = cache.get('uid')
    #render:text => "hello world"  
    render:text => @test
    cache.delete('uid')
  end

end
