require 'active_sape'
module SapeHelper
  sape_options = YAML.load_file("#{RAILS_ROOT}/config/sape.yml")
  @@sape = {}

  sape_options.keys.each do |host|
    @@sape[host] = ActiveSape.new(sape_options[host])
  end
  

  def show_sape_links(count = 100)
    if @@sape[request.host]
      @offet ||= 0
      resp = @@sape[request.host].show_links(request, count, @offet)
      @offet += count
      resp
    end
  end
end

ActionView::Base.send(:include, SapeHelper)
