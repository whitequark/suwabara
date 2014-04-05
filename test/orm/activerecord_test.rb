require_relative '../test_helper'
require_relative '../support/active_record'
require_relative 'dummy/testable_model.rb'

class ActiveRecordTest < Minitest::Test
  def setup
    @model = TestableModel.create

    @tempfile = Tempfile.new('ar_test')
    @tempfile.write('foobar')
    @tempfile.flush
    @tempfile.rewind

    @img = Suwabara::StoredFile.new(@model, 'file', @tempfile, 'ar_test.png')
  end

  def test_save_file_to_model
    @model.image = @img
    @model.save

    assert_equal @model.image.name, 'ar_test.png'
  end

  def test_dont_save_file_for_not_persisted_model
    @model1 = TestableModel.new
    @img = Suwabara::StoredFile.new(@model1, 'file', @tempfile, 'ar_test.png')
    @model1.image = @img

    assert_equal nil, @model1.image.storage
  end

  def test_save_file_for_persisted_model
    @model1 = TestableModel.new
    @img = Suwabara::StoredFile.new(@model1, 'file', @tempfile, 'ar_test.png')
    @model1.image = @img
    @model1.save

    assert_equal "000/000/00#{@model1.id}/ar_test.png", @model1.image.storage
    assert_equal 'foobar', File.read(@model1.image.full_path)
  end
end
