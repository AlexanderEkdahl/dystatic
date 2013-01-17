#Work in progress

## Usage
Deploying from same folder

```dystatic deploy -s . --s3_id YOUR_ACCESS_ID --s3_secret YOUR_ACCESS_SECRET --s3_bucket BUCKET_NAME```

## Known issues

Gzipping files adds a timestamp. This timestamp may incorrectly lead jekyll-s3 into believe the file has changed. To fix this add the -n flag when gzipping.

## TODO

* Add ```dystatic setup``` to setup remote bucket and settings for faster initialization of new website
* Push tests(they are currently using private data)
* Add the feature to support custom baseurl
* Cloudfront invalidation
* Create gem
* dystatic.yml erb support
