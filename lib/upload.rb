class Upload < ApplicationController
=begin

 По умолчанию папка для загрузки
 public/uploads
#########Пример использования 
 def screen_save
    require 'upload'

    if params[:file][:name]==''
      flash[:notice]=TEXT[session[:lang]]['profile_file_incorrect']
      redirect_to(:action=>'index')
      return
    end

    #upload dir
    @group_dir='/images/screens/'+session[:site_id].to_s[0,1]

    @screen=Upload.new(params[:file][:name], 'public'+@group_dir, true)

    #clear old file
    if !@site.screenshot_name.empty? && @screen.exist?(@site.screenshot_name)
      unless @screen.destroy(@site.screenshot_name)
        redirect_to(:action=>'index')
        return
      end
    end

    @screen.allow_format('img')
    @screen.set_max_size(3072) #set 3 kb max size upload

    #Установим имя для файла
    unless @screen.write(@site.id)
      flash[:notice]=TEXT[session[:lang]]['profile_file_incorrect']
      redirect_to(:action=>'index')
      return
    end

    @file_path=@group_dir+'/'+@screen.file_name
    @site.screenshot_name=@file_path
    @site.save
    redirect_to(:action=>'index')
  end

###############################


=end

  @@location = 'public/uploads'
  
  def initialize(name, location, debug)
    @name = nil
    @file_name=nil
    @file_content_type=nil #all formats
    @bytes=nil #default lo limit size upload
    @name = name
    @@type=nil #all file extensions type
    @location=nil #default @@location
    
    debug.nil? ? @debug=nil : @debug = debug
    
    rails_dir="#{Rails.root}"
    logger.debug('PWD  '+rails_dir) if @debug
    if location.nil?
      @location =rails_dir+'/'+@@location+'/'
    else
      @location =rails_dir+'/'+location+'/'
    end
    
    #create directorys structure
    # if it is not exists
    FileUtils.mkdir_p @@location
  end

  def allow_format(type)
    #type =(img|doc|arh|all)
    if type=='img'
      @@type=['gif','jpg','jpeg','png']
    elsif type=='doc'
      @@type=['doc','xsl','txt','log','rtf','xml','html','htm','ini','pdf']
    elsif type=='arh'
      @@type=['zip','rar','tar','gz']
    elsif type.nil? ||type=='all'
      @@type=nil
    end
  end
    
  def write(new_name)
    @up_file = @name
    if  @debug
      logger.debug("Inspect upload file: "+ @up_file.inspect) 
      logger.debug("ORIGINAL FILE_NAME #{@up_file.original_filename}" )  
      logger.debug("File SIZE: #{@up_file.size}") 
      logger.debug("Content type:  "+  @up_file.content_type) 
      logger.debug("TO DIR: "+  @@location)
    end
    #Меняем имя файла если это необходимо
    if new_name.nil?
      @file_name = base_part_of(@up_file.original_filename)
    else
      ext=base_part_of(@up_file.original_filename).split('.')[-1]
      
      if @@type.nil? || @@type.include?(ext)
        @file_name ="#{new_name}.#{ext}"
      else
        flash[:notice] = 'Не верный формат файла!'
        return false
      end
    end
    #check file max-size
    unless @bytes.nil?
      if @up_file.size > @bytes
        return false
      end
    end
    
    
    @file_content_type = @up_file.content_type.chomp
    @local_file_name=@location+@file_name
    
    FileUtils.mkdir_p(@location)
    if @up_file.instance_of?(Tempfile)
      FileUtils.cp(@up_file.local_path, @local_file_name)
    else
      File.open(@local_file_name, "wb") { |f| f.write(@up_file.read)}
    end
    File.chmod(644, @local_file_name)
    return true
  end
  
=begin
return file name after write 
=end 
  def file_name
    @file_name
  end
  
  def set_max_size(bytes)
    unless bytes.nil?
      @bytes=bytes
    else
      @bytes=nil
    end
  end
  #get only file name
  def base_part_of(file_name)
    name = File.basename(file_name)
    name.gsub(/[^\w._-]/, '')
  end
  
  #chek esist file
  def exist?(file)
    file="#{Rails.root}"+'/public/'+file
    if File.exists?(file)
      return true
    else
      return false
    end
  end
  
  def self.destroy(file)
    remove_file="#{Rails.root}"+'/public/'+file
    logger.info("Inspect drop file: #{remove_file.inspect}")  if @debug
    
    if File.exists?(remove_file)
      begin
        File.delete(remove_file)
      rescue SystemCallError => e
        legger.debug("#{e.message}")
        return false
      end
    else
      logger.debug("File #{file} deleted!")
      return true
    end
    
  end
end
