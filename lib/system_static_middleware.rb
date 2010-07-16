require 'rack/utils'

module Mangar
  class SystemStaticMiddleware
    FILE_METHODS = %w(GET HEAD).freeze

    def initialize(app)
      @app = app
      @file_server = ::Rack::File.new(root)
    end

    def call(env)
      @file_server.root = root

      path   = env['PATH_INFO'].chomp('/')
      method = env['REQUEST_METHOD']

      return @file_server.call(env) if FILE_METHODS.include?(method) && path =~ /^\/system\// && file_exist?(path)

      @app.call(env)
    end

    private
      def file_exist?(path)
        full_path = "#{root}/#{::Rack::Utils.unescape(path)}"
        File.file?(full_path) && File.readable?(full_path)
      end

      def root
        "#{Mangar.mangar_dir}/public"
      end
  end
end