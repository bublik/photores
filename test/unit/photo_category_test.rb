# == Schema Information
#
# Table name: photo_categories
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  identifier :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class PhotoCategoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
