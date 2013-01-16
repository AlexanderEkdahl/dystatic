module Jekyll
  class S3
    attr_accessor :source, :bucket, :reduced_redundancy

    def initialize config
      s3 = AWS::S3.new(:access_key_id     => config['s3_id'],
                       :secret_access_key => config['s3_secret'],
                       :s3_endpoint       => config['s3_endpoint'] )

      self.source             = File.expand_path(config['source'])
      self.bucket             = s3.buckets[config['s3_bucket']]
      self.reduced_redundancy = config['s3_reduced_redundancy']
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

    def upload file
      headers = {}

      headers[:content_type] = MIME::Types.type_for(path(file)).first
      headers[:content_encoding] = :gzip if gzipped?(file)

      if self.bucket.objects[file].write(File.read(path(file)), headers)
        puts("#{file} uploaded")
      else
        puts("#{file} upload FAILED!")
      end
    end

    def delete file
      self.bucket.objects[file].delete
      puts "#{file} deleted"
    end
  end
end
