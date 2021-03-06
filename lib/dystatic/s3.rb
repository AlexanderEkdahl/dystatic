module Dystatic
  class S3
    include Auxiliary

    attr_accessor :s3, :source, :bucket, :static, :config

    def initialize config
      self.s3 = AWS::S3.new(:access_key_id     => config['s3_id'],
                            :secret_access_key => config['s3_secret'],
                            :s3_endpoint       => config['s3_endpoint'] )

      self.source = File.expand_path(config['source'])
      self.static = config['static'].split
      self.bucket = s3.buckets[config['s3_bucket']]
      self.config = config
    end

    def setup
      self.bucket = s3.buckets.create(config['s3_bucket'])

      # Mitigates an issue with aws reporting that the bucket does not exists
      sleep 1

      bucket.configure_website
      bucket.policy = policy
    end

    def deploy
      setup unless bucket.exists?

      local  = files
      remote = bucket.objects.map(&:key)

      (local & remote).each do |f|
        obj = bucket.objects[f]

        if md5(f) != md5(obj)
          puts "Uploading changed: #{f}"
          upload(f)
        end
      end

      (local - remote).each do |f|
        puts "Uploading: #{f}"
        upload(f)
      end

      (remote - local).each do |f|
        puts "Deleting: #{f}"
        delete(f)
      end
    end

    def upload file
      bucket.objects[file].write(File.read(path(file)), headers(file))
    end

    def delete file
      bucket.objects[file].delete
    end
  end
end
