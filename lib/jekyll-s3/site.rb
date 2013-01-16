module Jekyll
  module S3
    class Site
      attr_accessor :source, :bucket, :reduced_redundancy

      def initialize config
        s3 = AWS::S3.new(:access_key_id     => config['s3_id'],
                         :secret_access_key => config['s3_secret'],
                         :s3_endpoint       => config['s3_endpoint'] )

        self.source             = File.expand_path(config['source'])
        self.bucket             = s3.buckets[config['s3_bucket']]
        self.reduced_redundancy = config['s3_reduced_redundancy'] || false
      end

      def process
        local  = self.local
        remote = self.bucket.objects.map(&:key)

        (local & remote).each do |f|
          file = Base.new(self.source, f)
          etag = self.bucket.objects[f].etag.gsub('"', '')

          if file.md5 != etag
            file.upload(self.bucket)
          end
        end

        (local - remote).each do |f|
          Base.new(self.source, f).upload(self.bucket)
        end

        (remote - local).each do |f|
          self.bucket.objects[f].delete
          puts "#{f} deleted"
        end
      end

      def local
        Dir[self.source + '/**/{*,.*}']
          .delete_if { |f| File.directory?(f) }
          .map       { |f| f.sub(self.source + '/', '') }
      end

      def path
      end
    end
  end
end
