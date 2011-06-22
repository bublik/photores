class PhotoCategoriesPhoto < ActiveRecord::Base
  belongs_to :photo
  belongs_to :photo_category
end
