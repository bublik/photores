# == Schema Information
#
# Table name: attachments
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  attachable_id   :integer
#  filename        :string(255)     not null
#  size            :integer         default(0), not null
#  content_type    :string(255)
#  height          :integer
#  width           :integer
#  parent_id       :integer
#  thumbnail       :string(255)
#  attachable_type :string(255)
#

require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < Test::Unit::TestCase
  fixtures :attachments

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
