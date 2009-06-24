Gem::Specification.new do |s| 
  s.platform  =   Gem::Platform::RUBY
  s.name      =   "gemmer"
  s.version   =   "0.0.3"
  s.date      =   Date.today.strftime('%Y-%m-%d')
  s.author    =   "imedo GmbH"
  s.email     =   "entwicker@imedo.de"
  s.homepage  =   "http://www.imedo.de/"
  s.summary   =   "Internal distribution of gems"
  s.files     =   Dir.glob("{bin,src}/**/*")

  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  
  s.require_path = "src"
end
