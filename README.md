# Dystatic

Deploy your Jekyll/Nanoc/Blacksmith site to S3.

## Features

* Only uploads new/changed files
* Deletes files no longer present locally
* Adds appropriate headers for gzipped files
* Cache control for static-static files

## Installation

        git clone https://github.com/AlexanderEkdahl/dystatic.git
        cd dystatic
        gem build dystatic.gemspec
        gem install dystatic-0.1.0.gem
        
This gem is not on RubyGems yet because of the lack of tests.

## Usage

1. Go to the folder containing the source of your static site

1. Create a file named ```_dystatic.yml``` containing:

        s3_id: YOUR_ACCESS_ID
        s3_secret: YOUR_ACCESS_SECRET
        s3_bucket: BUCKET_NAME

1. Run ```dystatic deploy``` and it will deploy all of the contents from ```_site/```

##Additional features

###Using non-standard AWS regions

By default, dystatic uses the US Standard Region but can be changed by passing the ```s3_endpoint``` setting

For example, if your bucket is in EU, add ```s3_endpoint: s3-eu-west-1.amazonaws.com``` to ```_dystatic.yml```

###Custom source directory

Add ```source: YOUR_FOLDER``` to ```_dystatic.yml``` or use ```dystatic deploy -s [DIR]```

###Deploying from your current folder

      dystatic deploy -s . --s3_id YOUR_ACCESS_ID --s3_secret YOUR_ACCESS_SECRET --s3_bucket BUCKET_NAME

__For more settings use ```dystatic -h```__

## Known issues

* Gzipping files adds a timestamp. This timestamp may incorrectly lead dystatic into believing the file has changed. To fix this add the -n flag when gzipping.

## TODO

* Push tests(they are currently using private data)
* Cloudfront invalidation
* Create gem
* dystatic.yml erb support
* Website configuration
* Speed up etag retrieval https://github.com/aws/aws-sdk-ruby/pull/84 with refinements
