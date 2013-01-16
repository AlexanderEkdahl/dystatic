module Jekyll
  module S3
    class Base
      attr_accessor :md5

      def initialize(source, path)
        @source = source
        @path = path
        self.md5 = Digest::MD5.hexdigest(File.read(self.path))
      end

      def path
        File.join(@source, @path)
      end

      def gzipped?
        false
      end

      def upload(site)
        mime_type = MIME::Types.type_for(path).first

        upload_succeeded = site.bucket.objects[@path].write(
          File.read(path),
          :content_type => mime_type
        )

        if upload_succeeded
          puts("#{@path} upload successful!")
        else
          puts("#{@path} upload FAILED!")
        end
      end
    end
  end
end
