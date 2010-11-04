require 'rack/utils'

module Mangar
  class SystemStaticMiddleware
    FILE_METHODS = %w(GET HEAD).freeze

    def initialize(app)
      @app = app
      @system_file_server = ::Rack::File.new('.')
      @books_server = ::Rack::File.new('.')
    end

    def call(env)
      @system_file_server.root = system_root
      @books_server.root = books_root

      path   = env['PATH_INFO'].chomp('/')
      method = env['REQUEST_METHOD']

      if FILE_METHODS.include?(method)
        return @system_file_server.call(env) if path =~ /^\/system\//

        if path =~ /^\/book_images\//
          env['PATH_INFO'].gsub!(/^\/book_images/, '')
          return @books_server.call(env)
        end
      end

      @app.call(env)
    end

    private
      def system_root
        "#{Mangar.mangar_dir}/public"
      end

      def books_root
        "#{Mangar.dir}/"
      end
  end
end