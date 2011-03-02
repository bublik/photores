class MessageObserver < ActiveRecord::Observer
  
  def after_create(record)
    #отсылаем письмо с уведомление о том что пользователь подписался на тему
    Mailer.deliver_notice(User.find(record.user_id), record) if record.described.eql?(1)
      
    #Отправка подписчикам писем о новом сообщении
    if record.parent_id
      # если родительский найти все дочерние и разослать всем подписчикам
      childs = Message.find( :all,
        :conditions => ['described = 1 AND (? IN (parent_id, id))',  record.parent_id])

      users = childs.collect{|m| m.user unless m.user == record.user}
      
      users.compact.detect do |u|
        next if u.nil?
        Mailer.deliver_new_post(u,record) if u.subscribed
      end
    end
  end

end
