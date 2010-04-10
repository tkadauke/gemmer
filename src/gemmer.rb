require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'active_support'

# Deprecated. Don't use.
def gemmer(gem_name)
  puts "WARNING: the gemmer method is deprecated. Use Gemmer::Tasks.new(gem_name) instead"
  
  Gemmer::Tasks.new(gem_name)
end

module Gemmer #:nodoc:
  # Defines a couple of convenient tasks to build, install and release gems.
  #
  # Complete usage example:
  #
  #   Gemmer::Tasks.new('my_gem') do |t|
  #     t.gemspec_file = 'my_gem.gemspec' # <- this is the default
  #     t.gemspec_erb_file = 'my_gem.gemspec.erb' # <- this is the default
  #     t.package_path = 'pkg' # <- this is the default
  #
  #     t.release_via :rubygems
  #     t.release_via :ssh, :to => 'some_host', :username => 'me', :use_sudo => true
  #     t.release_via :ssh, :to => 'production', :host => 'some_other_hostname', :username => 'me', :use_sudo => false
  #     t.release_via :scatter, :to => 'my_host_group'
  #   end
  class Tasks
    attr_accessor_with_default(:gemspec_file) { "#{@gem_name}.gemspec" }
    attr_accessor_with_default(:gemspec_erb_file) { "#{gemspec_file}.erb" }
    attr_accessor_with_default :package_path, "pkg"
    
    # contains the Gem::Specification instance
    attr_reader :spec
    
    # Define gem tasks. The only argument is the name of the gem. Yields itself to a block
    # if given.
    #
    # The following writer methods are defined on the yielded object:
    #
    # gemspec_file:: relative path to the gemspec file. Defaults to <gem_name>.gemspec
    # gemspec_erb_file:: relative path of an erb template for generating the gemspec file. Use this only if you need to (e.g. Github did not allow Dir.glob in gemspec files, so a workaround was to use an erb file to glob for the files locally and generate the gemspec file from that.)
    # package_path:: relative path under which the built gem is stored. Defaults to pkg
    def initialize(gem_name)
      @gem_name = gem_name
      @release_destinations = {}
      yield self if block_given?
      define
    end
    
    # Add another release method. Available release methods are:
    #
    # - rubygems: Release the gem to rubygems.org
    # - ssh:      Release the gem to another computer via scp / ssh. Options are:
    #   - :to - Symbolic name and/or host name for the target machine. Required.
    #   - :host - Host name of the target machine. If not specified, the :to option is used.
    #   - :username - SSH user name
    #   - :use_sudo - Whether to use sudo for installing the gem on the remote machine.
    # - scatter:  Release the gem using scatter. Options are:
    #   - :to - Name of target host / group
    def release_via(release_method, options = nil)
      @release_destinations[release_method] = options
    end
    
  protected
    def define
      @spec = eval(File.read(gemspec_file))
      @file_name = "#{@gem_name}-#{@spec.version}.gem"
      @package = File.join(package_path, @file_name)
      
      define_gem_tasks
      define_install_tasks
      define_release_tasks
      define_rdoc_tasks
    end
    
    def define_gem_tasks
      Rake::GemPackageTask.new(@spec) do |pkg|
        pkg.need_tar = true
      end
      
      desc "Build gem"
      task :build => @package do
        puts "generated latest version"
      end

      desc "Generate .gemspec file from .gemspec.erb file"
      task :gemspec do
        require 'erb'
        File.open("#{gemspec_file}", 'w') do |file|
          file.puts ERB.new(File.read("#{gemspec_erb_file}")).result
        end
      end
    end
    
    def define_install_tasks
      desc "Install gem locally (use sudo rake install if you need privileges)"
      task :install => @package do
        system "gem install #{@package}"
      end

      desc "Uninstall gem (use sudo rake uninstall if you need privileges)"
      task :uninstall do
        system "gem uninstall #{@gem_name}"
      end

      desc "Reinstall gem (use sudo rake reinstall if you need privileges)"
      task :reinstall => [:uninstall, :install]
    end
    
    def define_rdoc_tasks
      desc "Generate documentation for #{@gem_name}."
      Rake::RDocTask.new(:rdoc) do |rdoc|
        rdoc.rdoc_dir = 'rdoc'
        rdoc.title    = @gem_name
        rdoc.options << '--line-numbers' << '--inline-source'
        rdoc.rdoc_files.include(spec.files.sort)
      end
    end
    
    def define_release_tasks
      task_names = @release_destinations.collect do |release_method, options|
        define_release_task(release_method, options)
      end
      
      unless task_names.empty?
        desc "Release #{@gem_name} to all destinations"
        task :release => task_names
      end
    end
    
    def define_release_task(release_method, options)
      case release_method.to_s.downcase
      when 'rubygems'
        define_rubygems_release_task
      when 'ssh'
        define_ssh_release_task(options)
      when 'scatter'
        define_scatter_release_task(options)
      else
        raise "Unknown release method #{release_method}"
      end
    end
    
    def define_rubygems_release_task
      namespace :release do
        desc "Release #{@gem_name} to rubygems.org"
        task :rubygems do
          sh "gem push #{@package}"
        end
      end
      
      "release:rubygems"
    end
    
    def define_ssh_release_task(options)
      namespace :release do
        desc "Release #{@gem_name} to #{options[:to]} via SSH"
        task options[:to] do
          ssh_string = "#{options[:username]}@#{options[:host] || options[:to]}"
          sh "scp #{@package} #{ssh_string}:/tmp/"
          sh "ssh #{ssh_string} #{options[:use_sudo]} gem install /tmp/#{@file_name}"
        end
      end
      
      "release:#{options[:to]}"
    end
    
    def define_scatter_release_task(options)
      namespace :release do
        desc "Release #{@gem_name} to #{options[:to]} via scatter"
        task options[:to] do
          sh "scatter push #{@package} #{options[:to]}"
        end
      end
      
      "release:#{options[:to]}"
    end
  end
end
