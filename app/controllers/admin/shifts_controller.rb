class Admin::ShiftsController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin'

  def index
    params[:date_from] = Date.current.to_formatted_s(:date_only)  if !params[:date_from]
    params[:date_to] = Date.current.to_formatted_s(:date_only)  if !params[:date_to]
    @shifts = Shift.joins('JOIN users ON shifts.user_id = users.id').search(params, params[:page], current_admin.id)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @shifts }
    end
  end

  def show

  end

  def new
    @shift = Shift.new
    render :layout => false
  end

  def edit
    @shift = Shift.find(params[:id])
    render :layout => false
  end

  def create
    @shift = Shift.new(params[:shift])

    if @shift.save
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @shift.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#shift_flash'].parents(0).show
        page['#shift_flash'].html message
      end
    end

  end

  def update
    @shift = Shift.find(params[:id])

    if @shift.update_attributes(params[:shift])
      render(:update) do |page|
        page["#overlay"].dialog("close")
        page.call 'app.reload'
      end
    else
      message = '<p>' + @shift.errors.full_messages.join('</p><p>') + '</p>'
      render(:update) do |page|
        page['#shift_flash'].parents(0).show
        page['#shift_flash'].html message
      end
    end

  end

  def destroy
    @shift = Shift.find(params[:id])
    @shift.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml { head :ok }
    end
  end
end
