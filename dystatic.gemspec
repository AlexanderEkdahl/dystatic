Gem::Specification.new do |s|
  s.name          = 'dystatic'
  s.version       = '0.1.0'
  s.date          = '2013-01-17'
  s.summary       = "Simplifies static site upload"
  s.description   = "Deploy your static site to S3"
  s.authors       = ["Alexander Ekdahl"]
  s.email         = 'ekdahlsandor@gmail.com'
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.homepage      = 'https://github.com/AlexanderEkdahl/dystatic'
  s.license       = 'MIT'

  s.add_dependency 'commander', '~> 4.1.3'
  s.add_dependency 'aws-sdk', '~> 1.8'
  s.add_dependency 'mime-types', '~> 1.19'

  s.executables = ['dystatic']
end
