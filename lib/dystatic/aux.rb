module Dystatic
  module Auxiliary
    def policy bucket
      AWS::S3::Policy.new do |policy|
        policy.allow(:action     => 's3:GetObject',
                     :resource   => "arn:aws:s3:::#{bucket.name}/*",
                     :principals => :any)
      end
    end

    def gzipped? path
      File.read(path, 2) == [0x1F,0x8B].pack('c*').freeze
    end

    def files source
      Dir[source + '/**/{*,.*}']
        .delete_if { |f| File.directory?(f) }
        .map       { |f| f.sub(/#{source}\//, '') }
    end
  end
end
