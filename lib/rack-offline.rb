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
      
      puts block.inspect
      
      block = cache_block(Pathname.new(root)) unless block_given?

      puts block.inspect
      
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
          files = Dir[
            "#{root}/stylesheets/**/*.css",
            "#{root}/javascripts/**/*.js",
            "#{root}/images/**/*.*",
            "#{Rails.root}/public/*.html"
          ]

        files.each do |file|
          file_path = Pathname.new(file).relative_path_from( root )
          file_path = file_path.to_s.split("/")
          
          if file_path.last =~ /^*.html$/
            3.times{ file_path.shift }
          else
            file_path[0] = "assets"
          end
          file_path = file_path.join("/")
          
          cache file_path
        end
                
        network "/"
      end
    end

  end
end