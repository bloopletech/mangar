require 'rack/utils'

module Mangar
  class SystemStaticMiddleware
    FILE_METHODS = %w(GET HEAD).freeze

    def initialize(app)
      @app = app
      @file_server = ::Rack::File.new('.')      
    end

    def call(env)
      @file_server.root = "#{Mangar.mangar_dir}/public"      

      path   = env['PATH_INFO'].chomp('/')
      method = env['REQUEST_METHOD']
      
      return @file_server.call(env) if FILE_METHODS.include?(method) && path =~ /^\/system\//

      @app.call(env)
    end
  end
end