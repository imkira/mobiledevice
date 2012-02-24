# encoding: utf-8

require 'rubygems'
require 'rake'

task :default => 'mobiledevice'

desc 'Compile mobiledevice'
file 'mobiledevice' => ['mobiledevice.c', 'mobiletunnel.c', 'mobiledevice.h'] do |t|
  sh %Q[gcc -Wall -o "#{t.name}" -framework CoreFoundation -framework \
    MobileDevice -F/System/Library/PrivateFrameworks \
    "#{t.prerequisites.join('" "')}"]
end

desc 'Install mobiledevice on the system'
task :install => 'mobiledevice' do |t|
  sh %Q[/bin/cp -f "#{t.prerequisites.join('" "')}" /usr/local/bin/]
end

desc 'Cleanup'
task :clean do |t|
  sh 'rm -f mobiledevice'
end
