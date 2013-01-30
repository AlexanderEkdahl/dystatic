module Dystatic
  module Auxiliary
    def policy
      AWS::S3::Policy.new do |policy|
        policy.allow(:action     => 's3:GetObject',
                     :resource   => "arn:aws:s3:::#{bucket.name}/*",
                     :principals => :any)
      end
    end

    def files source
      Dir[source + '/**/{*,.*}']
        .delete_if { |f| File.directory?(f) }
        .map       { |f| f.sub(/#{source}\//, '') }
    end

    def path file
      File.join(source, file)
    end

    def md5 file
      if file.respond_to? :etag
        return file.etag[1..32]
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

      static.each do |s|
        if /#{s}\// =~ file
          headers[:cache_control] = :"max-age=31536000, public"
        end
      end

      headers
    end
  end
end
