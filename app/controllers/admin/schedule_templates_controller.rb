class Admin::ScheduleTemplatesController < ApplicationController
  def set_visibility
    @schedule_template = ScheduleTemplate.find params[:id]
    @schedule_template.visible = params[:visible]
    @schedule_template.save
    if params[:visible] != '2'
      User.update_all({:can_edit_schedule => 0}, :can_edit_schedule => params[:id])
      render(:update) do |page|
        messages = {"0" => 'The schedule is invisible now', "1" => 'The schedule is visible now'}
        message = "<div class='message notice'><p>#{messages[params[:visible]]}</p></div>"
        page['.flash'].parents(0).show
        page['.flash'].html message
      end
    else
      render :nothing => true
    end
  end

  def select_users
    @template = ScheduleTemplate.find_by_id params[:id]
    @users = User.order(:identifier).find_all_by_department_id_and_active @template.department_id, 1
    render :layout => false
  end

  def update_editable_users
    User.update_all({:can_edit_schedule => 0}, :can_edit_schedule => params[:id])
    html_message_users = []
    params[:users].each do |user_id|
      user = User.find_by_id(user_id)
      user.update_attribute(:can_edit_schedule, params[:id])
      html_message_users += [user.name]
      message = Schedule.send_invitation_to_user(user)
      message.deliver
    end if params[:users]
    render(:update) do |page|
      page["#overlay"].dialog("close")
      html_message = "<div class='message notice'><p>The schedule is available for editing now for the following users:<br/>#{html_message_users.join('<br/>')}</p></div>"
      page['.flash'].parents(0).show
      page['.flash'].html html_message
    end
  end

  def check_day
    @shift = ScheduleShift.find params[:id]
    @schedule_template = ScheduleTemplate.find @shift.schedule_template_id
    images = {
        '1' => 'error.png',
        '0' => 'accept.png',
        '-1' => 'cancel.png'
    }
    render(:update) do |page|
      id = "#day_#{params[:day]}"
      page[id].attr('src', '/images/web-app-theme/icons/' + images[(@schedule_template.check_day(params[:day])).to_s])
    end
  end

  def check_month
    @schedule_template = ScheduleTemplate.find params[:id]
    @days_in_month = Time.days_in_month(@schedule_template.month, @schedule_template.year)
    images = {
        '1' => 'error.png',
        '0' => 'accept.png',
        '-1' => 'cancel.png'
    }
    render(:update) do |page|
      @days_in_month.times do |day|
        id = "#day_#{day+1}"
        page[id].attr('src', '/images/web-app-theme/icons/' + images[(@schedule_template.check_day(day+1)).to_s])
      end
    end
  end

  def default_norms
    @template = ScheduleTemplate.find params[:id]
    @norms = Norm.norms_defaults(@template.year, @template.month)
    render :layout => false
  end

  def update_default_norms
    @template = ScheduleTemplate.find params[:id]
    @users = User.find_all_by_department_id_and_active @template.department_id, 1

    norm = Norm.new(params[:norm])
    month_days = Time.days_in_month(@template.month, @template.year)
    days = params[:norm][:weekend].to_i + params[:norm][:workdays].to_i

    if !norm.valid? || days != month_days
      if !norm.errors.full_messages.empty?
        message = '<p>' + norm.errors.full_messages.join('</p><p>') + '</p>'
      else
        message = '<p>' + 'There are '+month_days.to_s+ ' in this month' + '</p>'
      end
      render(:update) do |page|
        page['#norms_flash'].parents(0).show
        page['#norms_flash'].html message
      end
    else
      @users.each do |u|
        @norm = Norm.set_norms(u, @template, params[:norm])
      end
      render(:update) do |p|
        p.call 'app.show_users_admin'
      end
    end
  end

  def user_norms
    @user = User.find params[:id]
    @template = ScheduleTemplate.find params[:tmpl_id]
    @norms = Norm.find_by_user_id_and_year_and_month params[:id], @template.year, @template.month
    render :layout => false
  end

  def update_user_norms
    template = ScheduleTemplate.find params[:id]
    norm = Norm.find_by_user_id_and_year_and_month params[:norm][:user_id], template.year, template.month
    norm.update_attributes(params[:norm])
    month_days = Time.days_in_month(template.month, template.year)
    days = params[:norm][:weekend].to_i + params[:norm][:workdays].to_i

    if !norm.valid? || days != month_days
      if !norm.errors.full_messages.empty?
        message = '<p>' + norm.errors.full_messages.join('</p><p>') + '</p>'
      else
        message = '<p>' + 'There are '+month_days.to_s+ ' in this month' + '</p>'
      end
      render(:update) do |page|
        page['#norms_flash'].parents(0).show
        page['#norms_flash'].html message
      end
    else
      render(:update) do |p|
        p.call 'app.show_users_admin'
      end
    end
  end
end
