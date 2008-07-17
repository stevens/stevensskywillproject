class DataElementsController < ApplicationController
  # GET /data_elements
  # GET /data_elements.xml
  def index
    @data_elements = DataElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @data_elements }
    end
  end

  # GET /data_elements/1
  # GET /data_elements/1.xml
  def show
    @data_element = DataElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @data_element }
    end
  end

  # GET /data_elements/new
  # GET /data_elements/new.xml
  def new
    @data_element = DataElement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @data_element }
    end
  end

  # GET /data_elements/1/edit
  def edit
    @data_element = DataElement.find(params[:id])
  end

  # POST /data_elements
  # POST /data_elements.xml
  def create
    @data_element = DataElement.new(params[:data_element])

    respond_to do |format|
      if @data_element.save
        flash[:notice] = 'DataElement was successfully created.'
        format.html { redirect_to(@data_element) }
        format.xml  { render :xml => @data_element, :status => :created, :location => @data_element }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @data_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /data_elements/1
  # PUT /data_elements/1.xml
  def update
    @data_element = DataElement.find(params[:id])

    respond_to do |format|
      if @data_element.update_attributes(params[:data_element])
        flash[:notice] = 'DataElement was successfully updated.'
        format.html { redirect_to(@data_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @data_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /data_elements/1
  # DELETE /data_elements/1.xml
  def destroy
    @data_element = DataElement.find(params[:id])
    @data_element.destroy

    respond_to do |format|
      format.html { redirect_to(data_elements_url) }
      format.xml  { head :ok }
    end
  end
end
