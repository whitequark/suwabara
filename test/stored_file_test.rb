require_relative 'test_helper'

class StoredFileTest < Minitest::Test
  def setup
    @model = Object.new.tap { |o| def o.id; 42; end }

    @tempfile = Tempfile.new('test')
    @tempfile.write('foobar')
    @tempfile.flush
    @tempfile.rewind

    @file = Suwabara::StoredFile.new(@model, 'file', @tempfile, 'test.png')
  end

  def test_initialize_from_io
    assert_equal 'test.png', @file.name
  end

  def test_initialize_from_io_with_name
    file_gif = Suwabara::StoredFile.new(@model, 'file', @tempfile, 'test.gif')
    assert_equal 'test.gif', file_gif.name
  end

  def test_initialize_from_hash
    file_gif = Suwabara::StoredFile.new(@model, 'file',
                { 'name'    => 'test.gif',
                  'size'    => 6,
                  'storage' => @tempfile.path })

    assert_equal 'test.gif',     file_gif.name
    assert_equal 6,              file_gif.size
    assert_equal @tempfile.path, file_gif.storage
  end

  def test_content_type
    assert_equal 'image/png', @file.content_type
  end

  def test_read
    assert_equal 'foobar', @file.read
  end

  def test_rename
    file_gif = @file.rename('test.gif')

    assert_equal 'test.gif', file_gif.name
  end

  def test_url
    assert_equal '/000/000/042/test.png',
                 @file.url

    root_file = Class.new(Suwabara::StoredFile) do
      def url_for(path)
        URI.parse('http://assets.localhost').merge(path)
      end
    end.new(@model, 'file', @file.to_hash)

    assert_equal URI.parse('http://assets.localhost/000/000/042/test.png'),
                 root_file.url
  end

  def test_to_hash
    assert_equal({
      'name'    => 'test.png',
      'size'    => 6,
      'storage' => @file.storage,
    }, @file.to_hash)
  end

  def test_to_io
    assert_equal 'foobar', @file.to_io.read
  end

  def test_equals
    file2 = Suwabara::StoredFile.new(@warehouse, 'file', @file.to_hash)

    assert_equal @file, file2
  end
end
