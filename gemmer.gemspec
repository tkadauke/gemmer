Gem::Specification.new do |s| 
  s.platform  =   Gem::Platform::RUBY
  s.name      =   "gemmer"
  s.version   =   "0.1.2"
  s.date      =   Date.today.strftime('%Y-%m-%d')
  s.author    =   "Thomas Kadauke"
  s.email     =   "tkadauke@imedo.de"
  s.homepage  =   "http://www.imedo.de/"
  s.summary   =   "Simple rake tasks for gems"
  s.files     =   Dir.glob("src/**/*")

  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  
  s.require_path = "src"
end
