class LensModelsController < ApplicationController
  # GET /lens_models
  # GET /lens_models.xml
  def index
    @lens_models = LensModel.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lens_models }
    end
  end

  # GET /lens_models/1
  # GET /lens_models/1.xml
  def show
    @lens_model = LensModel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lens_model }
    end
  end

  # GET /lens_models/new
  # GET /lens_models/new.xml
  def new
    @lens_model = LensModel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lens_model }
    end
  end

  # GET /lens_models/1/edit
  def edit
    @lens_model = LensModel.find(params[:id])
  end

  # POST /lens_models
  # POST /lens_models.xml
  def create
    @lens_model = LensModel.new(params[:lens_model])

    respond_to do |format|
      if @lens_model.save
        flash[:notice] = 'LensModel was successfully created.'
        format.html { redirect_to(@lens_model) }
        format.xml  { render :xml => @lens_model, :status => :created, :location => @lens_model }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lens_model.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lens_models/1
  # PUT /lens_models/1.xml
  def update
    @lens_model = LensModel.find(params[:id])

    respond_to do |format|
      if @lens_model.update_attributes(params[:lens_model])
        flash[:notice] = 'LensModel was successfully updated.'
        format.html { redirect_to(@lens_model) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lens_model.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lens_models/1
  # DELETE /lens_models/1.xml
  def destroy
    @lens_model = LensModel.find(params[:id])
    @lens_model.destroy

    respond_to do |format|
      format.html { redirect_to(lens_models_url) }
      format.xml  { head :ok }
    end
  end
end
