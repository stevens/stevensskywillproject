class MatchActorsController < ApplicationController
  # GET /match_actors
  # GET /match_actors.xml
  def index
    @match_actors = MatchActor.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @match_actors }
    end
  end

  # GET /match_actors/1
  # GET /match_actors/1.xml
  def show
    @match_actor = MatchActor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @match_actor }
    end
  end

  # GET /match_actors/new
  # GET /match_actors/new.xml
  def new
    @match_actor = MatchActor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @match_actor }
    end
  end

  # GET /match_actors/1/edit
  def edit
    @match_actor = MatchActor.find(params[:id])
  end

  # POST /match_actors
  # POST /match_actors.xml
  def create
    @match_actor = MatchActor.new(params[:match_actor])

    respond_to do |format|
      if @match_actor.save
        flash[:notice] = 'MatchActor was successfully created.'
        format.html { redirect_to(@match_actor) }
        format.xml  { render :xml => @match_actor, :status => :created, :location => @match_actor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @match_actor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /match_actors/1
  # PUT /match_actors/1.xml
  def update
    @match_actor = MatchActor.find(params[:id])

    respond_to do |format|
      if @match_actor.update_attributes(params[:match_actor])
        flash[:notice] = 'MatchActor was successfully updated.'
        format.html { redirect_to(@match_actor) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @match_actor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /match_actors/1
  # DELETE /match_actors/1.xml
  def destroy
    @match_actor = MatchActor.find(params[:id])
    @match_actor.destroy

    respond_to do |format|
      format.html { redirect_to(match_actors_url) }
      format.xml  { head :ok }
    end
  end
end
