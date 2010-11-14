# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{waveforce}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["mapserver2007"]
  s.date = %q{2010-11-14}
  s.default_executable = %q{waveforce}
  s.description = %q{waveforce. notify matsuri for terrestrial broadcasting.}
  s.email = %q{mapserver2007@gmail.com}
  s.executables = ["waveforce"]
  s.extra_rdoc_files = ["README.rdoc", "ChangeLog"]
  s.files = ["README.rdoc", "ChangeLog", "Rakefile", "bin/waveforce", "spec/spec_config.yml", "spec/waveforce_helper.rb", "spec/waveforce_spec.rb", "lib/waveforce", "lib/waveforce/crawler.rb", "lib/waveforce/notify.rb", "lib/waveforce/store.rb", "lib/waveforce/utils.rb", "lib/waveforce.rb"]
  s.homepage = %q{http://github.com/mapserver2007/waveforce2}
  s.rdoc_options = ["--title", "waveforce documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README.rdoc", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{waveforce2}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{waveforce. notify matsuri for terrestrial broadcasting.}
  s.test_files = ["spec/waveforce_helper.rb", "spec/waveforce_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
