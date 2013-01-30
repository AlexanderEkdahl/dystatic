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

      setup unless bucket.exists?
    end

    def setup
      self.bucket = s3.buckets.create(config['s3_bucket'])

      # Mitigates an issue with aws reporting that the bucket does not exists
      sleep 1

      bucket.configure_website
      bucket.policy = policy
    end

    def deploy
      local  = files(source)
      remote = bucket.objects.map(&:key)

      (local & remote).each do |f|
        obj = bucket.objects[f]

        upload(f) if md5(f) != md5(obj)
      end

      (remote - local).each do |f|
        delete(f)
      end

      (local - remote).each do |f|
        upload(f)
      end
    end

    def upload file
      bucket.objects[file].write(File.read(path(file)), headers(file))
      puts("#{file} uploaded")
    end

    def delete file
      bucket.objects[file].delete
      puts "#{file} deleted"
    end
  end
end
