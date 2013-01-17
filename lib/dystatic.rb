require 'yaml'
require 'aws-sdk'
require 'mime/types'
require 'digest/md5'

require 'dystatic/s3'

module Dystatic
  VERSION = '0.1.0'

  DEFAULTS = {
    'source' => File.join(Dir.pwd, '_site'),

    's3_id'       => '',
    's3_secret'   => '',
    's3_bucket'   => '',
    's3_endpoint' => 's3.amazonaws.com',

    'static' => 'assets'
  }

  def self.configuration(override)
    # Convert any symbol keys to strings and remove the old key/values
    override = override.reduce({}) { |hash, (k,v)| hash.merge(k.to_s => v) }

    # _jekyll_s3.yml may override default source location, but until
    # then, we need to know where to look for _config.yml
    source = override['source'] || DEFAULTS['source']

    # Get configuration from <source>/_jekyll_s3.yml
    config_file = File.join(source, '../_dystatic.yml')
    begin
      config = YAML.load_file(config_file)
      raise "Invalid configuration - #{config_file}" unless config.is_a?(Hash)
      $stdout.puts "Configuration from #{config_file}"
    rescue => err
      $stderr.puts "WARNING: Could not read configuration. " +
                   "Using defaults (and options)."
      $stderr.puts "\t" + err.to_s
      config = {}
    end

    # DEFAULTS < config < override
    DEFAULTS.merge(config).merge(override)
  end
end
