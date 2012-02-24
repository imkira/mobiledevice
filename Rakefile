# encoding: utf-8

require 'rubygems'
require 'rake'

task :default => ['mobiledevice']

file 'mobiledevice' => ['mobiledevice.c', 'mobiledevice.h'] do |t|
  sh %Q[gcc -Wall -o "#{t.name}" -framework CoreFoundation -framework \
    MobileDevice -F/System/Library/PrivateFrameworks \
    "#{t.prerequisites.join('" "')}"]
end

task :clean do |t|
  sh 'rm -f mobiledevice'
end
