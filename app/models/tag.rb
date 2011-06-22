# == Schema Information
#
# Table name: tags
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  is_uploadet :boolean
#

class Tag < ActiveRecord::Base
   cattr_reader :per_page
  @@per_page = 10  
  @@delimiter = ' '

end
