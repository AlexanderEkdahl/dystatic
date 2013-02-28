require 'yaml'
require 'digest/md5'

require 'aws-sdk'
require 'mime/types'

require 'dystatic/aux'
require 'dystatic/s3'

module Dystatic
  VERSION = '0.1.0'

  DEFAULTS = {
    'source' => File.join(Dir.pwd, '_site'),
    'config' => File.join(Dir.pwd, '_dystatic.yml'),

    's3_id'       => '',
    's3_secret'   => '',
    's3_bucket'   => '',
    's3_endpoint' => 's3.amazonaws.com',

    'static' => 'assets'
  }

  def self.configuration(override)
    config_file = override['config'] || DEFAULTS['config']

    begin
      config = YAML.load_file(config_file)
      raise "Configuration file: (INVALID) #{config_file}" if !config.is_a?(Hash)
      $stdout.puts "Configuration file: #{config_file}"
    rescue SystemCallError
      # Errno:ENOENT = file not found
      $stderr.puts "Configuration file: none"
      config = {}
    rescue => err
      $stderr.puts "           " +
                   "WARNING: Error reading configuration. " +
                   "Using defaults (and options)."
      $stderr.puts "#{err}"
      config = {}
    end

    # DEFAULTS < config < override
    DEFAULTS.merge(config).merge(override)
  end
end
