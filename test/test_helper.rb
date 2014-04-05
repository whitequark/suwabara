require 'tempfile'
require 'active_record'
require 'nulldb'

require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
end

require 'minitest/autorun'
require 'minitest/mock'

require 'suwabara'
