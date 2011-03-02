# == Schema Information
#
# Table name: photo_profiles
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  camera_brand_id :integer
#  description     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  is_default      :boolean
#

require 'test_helper'

class PhotoProfileTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
