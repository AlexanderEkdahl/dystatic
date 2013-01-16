require 'yaml'
require 'jekyll'
require 'aws-sdk'
require 'mime/types'
require 'digest/md5'

require 'jekyll-s3/s3'

module Jekyll
  class S3
    DEFAULTS = {
      's3_id'     => '',
      's3_secret' => '',
      's3_bucket' => '',

      's3_endpoint'           => 's3.amazonaws.com',
      's3_reduced_redundancy' => false
    }

    def self.configuration(override)
      # Convert any symbol keys to strings and remove the old key/values
      override = override.reduce({}) { |hash, (k,v)| hash.merge(k.to_s => v) }

      jekyll_config = Jekyll::configuration({})

      # _jekyll_s3.yml may override default source location, but until
      # then, we need to know where to look for _config.yml
      source = override['source'] || jekyll_config['source']

      # Get configuration from <source>/_jekyll_s3.yml
      config_file = File.join(source, '_jekyll_s3.yml')
      begin
        config = YAML.load_file(config_file)
        raise "Invalid configuration - #{config_file}" if !config.is_a?(Hash)
        $stdout.puts "Configuration from #{config_file}"
      rescue => err
        $stderr.puts "WARNING: Could not read configuration. " +
                     "Using defaults (and options)."
        $stderr.puts "\t" + err.to_s
        config = {}
      end

      # Rename jekyll destination key to jekyll-s3 source key
      jekyll_config['source'] = jekyll_config.delete('destination')

      # Jekyll::configuration < Jekyll::S3::DEFAULTS < config < override
      jekyll_config.merge(DEFAULTS).merge(config).merge(override)
    end
  end
end
