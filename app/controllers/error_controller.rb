class ErrorController < ApplicationController
  skip_before_filter :login_required
  before_filter :check_params

  def check_params
    if params[:action]!='http'
      redirect_to :action => 'http', :id => 404
    end
  end
  
  def http
    begin
      render :action => 'http' + params[:id], :status => params[:id]
    rescue
      render :action => 'http404', :status => 404
    end
  end
end
