require 'rack/utils'

module Mangar
  class SystemStaticMiddleware
    FILE_METHODS = %w(GET HEAD).freeze

    def initialize(app)
      @app = app
      @file_server = ::Rack::File.new("#{Mangar.mangar_dir}/public")
    end

    def call(env)
      path   = env['PATH_INFO'].chomp('/')
      method = env['REQUEST_METHOD']

      return @file_server.call(env) if FILE_METHODS.include?(method) && path =~ /\A\/system\//

      @app.call(env)
    end
  end
end