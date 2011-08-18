class Admin::EventsController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin'

  def index
    if params[:date_from]
      params[:date_from] =
          DateTime.parse(
              params[:date_from]["year"].to_s+
                  "-"+
                  params[:date_from]["month"].to_s+
                  "-"+
                  params[:date_from]["day"].to_s+
                  " "+
                  params[:date_from]["hour"].to_s+
                  ":"+
                  params[:date_from]["minute"].to_s
          )
    else
      params[:date_from] = DateTime.current - 2.hour
    end
    if params[:date_to]
      params[:date_to] =
          DateTime.parse(
              params[:date_to]["year"].to_s+
                  "-"+
                  params[:date_to]["month"].to_s+
                  "-"+
                  params[:date_to]["day"].to_s+
                  " "+
                  params[:date_to]["hour"].to_s+
                  ":"+
                  params[:date_to]["minute"].to_s
          )
    else
      params[:date_to] = DateTime.current
    end

    @events = Event.search(params, params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @events }
    end
  end

  def show

  end

  def new
    @event = Event.new
    render :layout => false
  end

  def edit
    @event = Event.find(params[:id])
    render :layout => false
  end

  def create
    @event = Event.new(params[:event])

    if @event.save
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @event.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#event_flash'].parents(0).show
        page['#event_flash'].html message
      end
    end

  end

  def update
    @event = Event.find(params[:id])

    if @event.update_attributes(params[:event])
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @event.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#event_flash'].parents(0).show
        page['#event_flash'].html message
      end
    end

  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(admin_events_url) }
      format.xml { head :ok }
    end
  end
end
