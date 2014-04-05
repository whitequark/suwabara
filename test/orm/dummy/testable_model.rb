class TestableModel < ActiveRecord::Base

  mount_storage :image, Suwabara::StoredImage

end
