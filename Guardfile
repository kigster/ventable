#!/usr/bin/env ruby
# frozen_string_literal: true

# ^syntax detection

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec' do
  watch(/^ventable\.gemspec/) { "spec" }
  watch(%r{^lib/(.+)\.rb$}) { "spec" }

  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb') { "spec" }
  watch(%r{spec/support/.*}) { "spec" }
end
