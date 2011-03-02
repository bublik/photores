# == Schema Information
#
# Table name: contests
#
#  id           :integer         not null, primary key
#  title        :string(255)     not null
#  description  :text            not null
#  prize        :string(255)
#  sponsor      :text
#  photo_id     :integer
#  date_from    :date
#  date_to      :date
#  is_completed :boolean
#  created_at   :datetime
#  updated_at   :datetime
#

class Contest < ActiveRecord::Base
  #Участники в конкурсе
  has_many :photos

  validates_presence_of :title, :description, :prize
  #Фильтр для выбора конкурсов при загрузки фото
  named_scope :current_konkurses, :conditions => ['date_from <= ?  AND ? <= date_to  AND is_completed != ?', Time.now , Time.now , true]


  def to_param
    "#{self.id}-#{self.title.gsub(/[\W]/,'-')}"
  end

  #The winner photo
  def photo
    Photo.find_by_id(self.photo_id)
  end
end
