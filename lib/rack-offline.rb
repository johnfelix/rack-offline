require "rack/offline"

module Rails
  class Offline < ::Rack::Offline
    def self.call(env)
      @app ||= new
      @app.call(env)
    end

    def initialize(options = {}, app = Rails.application, &block)
      config = app.config
      root = Rails.version < "3.1" ? config.paths.public.to_a.first : Pathname.new("#{Rails.root}/app/assets")

      block = cache_block(Pathname.new(root)) unless block_given?

      opts = {
        :cache => config.cache_classes,
        :root => root,
        :logger => Rails.logger
      }.merge(options)

      super opts, &block
    end
    
    def relative_path(file, root)
      path = Pathname.new(file).relative_path_from( root )
      path = path.to_s.split("/")
      path[0] = "assets"
      path.join("/")
    end

  private

    def cache_block(root)
      Proc.new do
        files = Dir[
          "#{root}/stylesheets/**/*.css",
          "#{root}/javascripts/**/*.js",
          "#{root}/images/**/*.*"
        ]
        
        files.each do |file|
          file_path = Rails.version < "3.1" ? Pathname.new(file).relative_path_from( root ) : relative_path(file, root)
          puts file_path
        end
                
        network "/"
      end
    end

  end
end