# == Schema Information
#
# Table name: photos
#
#  id               :integer         not null, primary key
#  title            :string(255)
#  user_id          :integer
#  parent_id        :integer
#  size             :integer
#  content_type     :string(255)
#  filename         :string(255)
#  height           :integer
#  width            :integer
#  thumbnail        :string(255)
#  registred        :boolean
#  auto_approve     :boolean         default(TRUE)
#  views            :integer         default(0)
#  complaint        :integer         default(0)
#  downloads        :integer         default(0)
#  comments_count   :integer         default(0)
#  comment_at       :date
#  show_at          :date
#  download_at      :date
#  created_at       :datetime
#  updated_at       :datetime
#  photo_profile_id :integer
#  contest_id       :integer
#  is_moderated     :boolean         default(TRUE)
#  exif             :text
#  want_critic      :boolean         default(TRUE)
#  lat              :decimal(15, 10)
#  lng              :decimal(15, 10)
#

require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
