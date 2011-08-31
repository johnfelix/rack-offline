require "rack/offline"

module Rails
  class Offline < ::Rack::Offline
    def self.call(env)
      @app ||= new
      @app.call(env)
    end

    def initialize(options = {}, app = Rails.application, &block)
      config = app.config
      root = Rails.version < "3.1" ? config.paths.public.to_a.first : "#{Rails.root}"

      block = cache_block(Pathname.new(root)) unless block_given?

      opts = {
        :cache => config.cache_classes,
        :root => root,
        :logger => Rails.logger
      }.merge(options)

      super opts, &block
    end

  private

    def cache_block(root)
      Proc.new do
        if Rails.version < "3.1"
          files = Dir[
            "#{root}/stylesheets/**/*.css",
            "#{root}/javascripts/**/*.js",
            "#{root}/images/**/*.*"]
        else 
          files = Dir[
            "#{root}/app/assets/**/*.css",
            "#{root}/app/assets/**/*.js"
            ]
        end
        
        files.each do |file|
          if Rails.version >= "3.1"
            file = file.split("/")
            file.delete_at(-2)
            file.delete_at(-3)
            file = file.join("/")
          end
          
          cache Pathname.new(file).relative_path_from(root)
        end
        
        files = Dir[
          "#{root}/public/*.html"
        ]
        
        files.each do |file|
          cache Pathname.new(file).relative_path_from(root)
        end
        
        network "/"
      end
    end

  end
end