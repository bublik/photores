# == Schema Information
#
# Table name: fgroups
#
#  id         :integer         not null, primary key
#  name       :string(255)     default("new group")
#  is_visible :boolean
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class FgroupTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
