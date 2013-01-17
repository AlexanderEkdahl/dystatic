module Jekyll
  class S3
    attr_accessor :source, :bucket, :static

    def initialize config
      s3 = AWS::S3.new(:access_key_id     => config['s3_id'],
                       :secret_access_key => config['s3_secret'],
                       :s3_endpoint       => config['s3_endpoint'] )

      self.source             = File.expand_path(config['source'])
      self.bucket             = s3.buckets[config['s3_bucket']]
      self.static             = config['static'].split
    end

    def process
      local  = self.local
      remote = self.bucket.objects.map(&:key)

      (local & remote).each do |f|
        obj = self.bucket.objects[f]

        upload(f) if md5(f) != md5(obj)
      end

      (local - remote).each do |f|
        upload(f)
      end

      (remote - local).each do |f|
        delete(f)
      end
    end

    def local
      Dir[self.source + '/**/{*,.*}']
        .delete_if { |f| File.directory?(f) }
        .map       { |f| f.sub(/#{source}\//, '') }
    end

    def path file
      File.join(self.source, file)
    end

    def md5 file
      if file.respond_to? :etag
        return file.etag.gsub('"', '')
      end
      Digest::MD5.hexdigest(File.read(path(file)))
    end

    def gzipped? file
      File.read(path(file), 2) == [0x1F,0x8B].pack('c*').freeze
    end

    def headers file
      headers = {}

      headers[:content_type] = MIME::Types.type_for(path(file)).first
      headers[:content_encoding] = :gzip if gzipped?(file)

      self.static.each do |s|
        headers[:cache_control] = :"max-age=31536000, public" if /#{s}\// =~ file
      end

      headers
    end

    def upload file
      self.bucket.objects[file].write(File.read(path(file)), headers(file))
      puts("#{file} uploaded")
    end

    def delete file
      self.bucket.objects[file].delete
      puts "#{file} deleted"
    end
  end
end
