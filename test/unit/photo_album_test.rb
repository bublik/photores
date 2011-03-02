# == Schema Information
#
# Table name: photo_albums
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  frendly    :boolean
#  user_id    :integer         not null
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class PhotoAlbumTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
