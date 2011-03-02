# == Schema Information
#
# Table name: bcomments
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  blog_id    :integer
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class BcommentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
