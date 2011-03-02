class FgroupsController < ApplicationController
  before_filter  :check_admin 
  # GET /fgroups
  # GET /fgroups.xml
  def index
    @fgroups = Fgroup.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fgroups }
    end
  end

  # GET /fgroups/1
  # GET /fgroups/1.xml
  def show
    @fgroup = Fgroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fgroup }
    end
  end

  # GET /fgroups/new
  # GET /fgroups/new.xml
  def new
    @fgroup = Fgroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fgroup }
    end
  end

  # GET /fgroups/1/edit
  def edit
    @fgroup = Fgroup.find(params[:id])
  end

  # POST /fgroups
  # POST /fgroups.xml
  def create
    @fgroup = Fgroup.new(params[:fgroup])

    respond_to do |format|
      if @fgroup.save
        flash[:notice] = 'Fgroup was successfully created.'
        format.html { redirect_to(@fgroup) }
        format.xml  { render :xml => @fgroup, :status => :created, :location => @fgroup }
        redirect_to :controller => :forums, :action => :list
        return
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fgroup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /fgroups/1
  # PUT /fgroups/1.xml
  def update
    @fgroup = Fgroup.find(params[:id])

    respond_to do |format|
      if @fgroup.update_attributes(params[:fgroup])
        flash[:notice] = 'Fgroup was successfully updated.'
        format.html { redirect_to(@fgroup) }
        format.xml  { head :ok }
        redirect_to :controller => :forums, :action => :list
        return
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fgroup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fgroups/1
  # DELETE /fgroups/1.xml
  def destroy
    @fgroup = Fgroup.find(params[:id])
    @fgroup.destroy

    respond_to do |format|
      format.html { redirect_to(fgroups_url) }
      format.xml  { head :ok }
    end
  end
end
