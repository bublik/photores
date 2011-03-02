# == Schema Information
#
# Table name: comments
#
#  id               :integer         not null, primary key
#  title            :string(50)      default("")
#  comment          :text
#  is_approved      :boolean
#  commentable_id   :integer         default(0), not null
#  commentable_type :string(255)     default(""), not null
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
