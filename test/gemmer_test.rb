require 'rubygems'
require 'test/unit'
require File.dirname(__FILE__) + '/../src/gemmer'

class GemmerTest < Test::Unit::TestCase
  def teardown
    Rake::Task.clear
  end
  
  def test_no_task_should_be_defined_by_default
    assert Rake::Task.tasks.empty?
  end
  
  def test_should_define_gem_related_tasks
    Gemmer::Tasks.new('my_gem') do |t|
      t.gemspec_file = File.dirname(__FILE__) + '/fixtures/my_gem.gemspec'
    end
    assert_tasks_defined :build, :gem, :clobber_package, :package, :repackage, :gemspec
  end
  
  def test_should_define_install_related_tasks
    Gemmer::Tasks.new('my_gem') do |t|
      t.gemspec_file = File.dirname(__FILE__) + '/fixtures/my_gem.gemspec'
    end
    assert_tasks_defined :install, :reinstall, :uninstall
  end
  
  def test_should_define_rdoc_related_tasks
    Gemmer::Tasks.new('my_gem') do |t|
      t.gemspec_file = File.dirname(__FILE__) + '/fixtures/my_gem.gemspec'
    end
    assert_tasks_defined :clobber_rdoc, :rdoc, :rerdoc
  end
  
  def test_should_not_define_release_related_tasks_without_explicit_specification
    Gemmer::Tasks.new('my_gem') do |t|
      t.gemspec_file = File.dirname(__FILE__) + '/fixtures/my_gem.gemspec'
    end
    assert_tasks_undefined :release
  end
  
  def test_should_define_rubygems_release_task
    Gemmer::Tasks.new('my_gem') do |t|
      t.gemspec_file = File.dirname(__FILE__) + '/fixtures/my_gem.gemspec'

      t.release_via :rubygems
    end
    assert_tasks_defined "release:rubygems"
  end

  def test_should_define_ssh_release_task
    Gemmer::Tasks.new('my_gem') do |t|
      t.gemspec_file = File.dirname(__FILE__) + '/fixtures/my_gem.gemspec'

      t.release_via :ssh, :to => 'my_host', :username => 'me'
    end
    assert_tasks_defined "release:my_host"
  end
  
  def test_should_define_scatter_release_task
    Gemmer::Tasks.new('my_gem') do |t|
      t.gemspec_file = File.dirname(__FILE__) + '/fixtures/my_gem.gemspec'

      t.release_via :scatter, :to => 'my_group_of_hosts'
    end
    assert_tasks_defined "release:my_group_of_hosts"
  end
  
  def test_should_allow_multiple_release_tasks
    Gemmer::Tasks.new('my_gem') do |t|
      t.gemspec_file = File.dirname(__FILE__) + '/fixtures/my_gem.gemspec'

      t.release_via :rubygems
      t.release_via :ssh, :to => 'my_host', :username => 'me'
    end
    assert_tasks_defined "release:rubygems", "release:my_host"
  end
  
  def test_should_define_general_release_task_when_at_least_one_release_method_is_specified
    Gemmer::Tasks.new('my_gem') do |t|
      t.gemspec_file = File.dirname(__FILE__) + '/fixtures/my_gem.gemspec'

      t.release_via :rubygems
    end
    assert_tasks_defined :release
  end
  
  def test_should_raise_exception_if_release_method_is_unknown
    assert_raise RuntimeError do
      Gemmer::Tasks.new('my_gem') do |t|
        t.gemspec_file = File.dirname(__FILE__) + '/fixtures/my_gem.gemspec'

        t.release_via :blah
      end
    end
  end
  
  def test_should_load_gemspec
    tasks = Gemmer::Tasks.new('my_gem') do |t|
      t.gemspec_file = File.dirname(__FILE__) + '/fixtures/my_gem.gemspec'
    end
    assert_equal 'my_gem', tasks.spec.name
  end
  
protected
  def assert_tasks_defined(*task_names)
    task_names.each do |task_name|
      assert Rake::Task.tasks.find { |task| task.name.to_s == task_name.to_s }
    end
  end

  def assert_tasks_undefined(*task_names)
    task_names.each do |task_name|
      assert ! Rake::Task.tasks.find { |task| task.name.to_s == task_name.to_s }
    end
  end
end
