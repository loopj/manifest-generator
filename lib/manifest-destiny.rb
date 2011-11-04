# Generate a cache.manifest file for your html5 offline app
# 
# The `watch` and `watch_path` methods will only affect the version hash
#
# Usage:
#
#   manifest = ManifestDestiny.configure do
#     cache "path"
#     network "path"
#   end

require "digest"
require "pathname"

class ManifestDestiny
  class Config
    def initialize(root, &block)
      @cache = []
      @watch = []
      @network = []
      @fallback = {}
      @root = root
      instance_eval(&block) if block_given?
    end

    def cache_path(*patterns)
      add_path(@cache, patterns)
    end
    
    def cache(*names)
      add(@cache, names)
    end

    def watch_path(*patterns)
      add_path(@watch, patterns)
    end
    
    def watch(*names)
      add(@watch, names)
    end

    def network(*names)
      @network.concat(names)
    end

    def fallback(hash = {})
      @fallback.merge!(hash)
    end

    def root
      @root
    end

    private

    def add_path(collection, patterns)
      patterns.each do |pattern|
        Dir[File.join(@root, pattern)].each do |file|
          collection << file.split(root).second
        end
      end
    end

    def add(collection, names)
      flat_names = names.map do |n|
        if (n =~ Regexp.new(root.to_s)) == 0
          n.split(root).second
        else
          n
        end
      end
      
      collection.concat(flat_names)
    end
  end
  
  def self.configure(*args, &block)
    new(*args, &block)
  end

  def initialize(options = {}, &block)
    @cache = options[:cache]
    @root = Pathname.new(options[:root] || Dir.pwd)
    
    if block_given?
      @config = Config.new(@root, &block)
    end
  end

  def to_s
    body = ["CACHE MANIFEST"]

    # Generate sha hash of cache and watch files
    hash = (@config.cache + @config.watch).map do |item|
      if (item =~ /:\/\//)
        Digest::SHA2.hexdigest(item)
      else
        begin
          path = File.new(File.join(@root, item))
          Digest::SHA2.hexdigest(path.read) if ::File.file?(path)
        rescue
          $stderr.puts "Couldn't find file #{File.join(@root, item)}, not adding to cache hash"
          nil
        end
      end
    end
    body << "# #{Digest::SHA2.hexdigest(hash.compact.join)}"

    unless @config.cache.empty?
      body << "" << "CACHE:"
      body.concat @config.cache.uniq
    end

    unless @config.network.empty?
      body << "" << "NETWORK:"
      body.concat @config.network.uniq
    end

    unless @config.fallback.empty?
      body << "" << "FALLBACK:"
      @config.fallback.each do |namespace, url|
        body << "#{namespace} #{URI.escape(url.to_s)}"
      end
    end
    
    return body.join("\n")
  end
  
  private
  # Rails 2.3.x support
  module Rails
    def render_manifest(root=::Rails.public_path, &block)
      manifest = ManifestDestiny.configure(:root => root, &block)
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
      render :text => manifest, :layout => false, :content_type => "text/cache-manifest"
    end
  end
end