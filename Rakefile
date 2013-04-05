def gemspec
  Dir['*.gemspec'].first
end

def gem
  Dir['*.gem'].first
end

task :build do
	system "gem build #{gemspec}"
end

task :install => :build do
	system "gem install #{gem}"
end
