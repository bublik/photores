# == Schema Information
#
# Table name: users
#
#  id               :integer         not null, primary key
#  login            :string(15)      not null
#  email            :string(50)      not null
#  first_name       :string(20)      not null
#  last_name        :string(20)      not null
#  description      :text            default("")
#  avatar           :string(50)      not null
#  privilegies      :integer         default(2)
#  raiting          :integer         default(0)
#  password         :string(32)      not null
#  crypt_password   :string(32)      not null
#  active           :boolean
#  code_activate    :string(32)
#  birth_day        :datetime        not null
#  icq_number       :integer
#  skype_name       :string(50)
#  aim_name         :string(50)
#  yahoo_handle     :string(50)
#  msn_handle       :string(50)
#  home_page        :string(100)
#  location         :string(100)
#  interests        :text
#  job              :text
#  posts            :integer         default(0)
#  created_at       :datetime
#  updated_at       :datetime
#  photos_count     :integer         default(0)
#  last_activity    :string(255)
#  last_activity_at :datetime
#  subscribed       :boolean         default(TRUE), not null
#  subdomain        :string(25)
#  promo            :text
#  blog_title       :string(255)
#

require File.dirname(__FILE__) + '/../test_helper'

class UsersTest < Test::Unit::TestCase
  fixtures :users

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
