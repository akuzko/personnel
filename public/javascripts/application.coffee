@app =
  init: ->
    $ =>
      @flashFade()
      $('[data-load-user]').live 'click', ->
        $('#sidebar').load $(this).data('load-user')
        no
      _.each ['profile', 'address', 'contact', 'permissions'], (data) ->
        $("[data-edit-#{data}]").live 'click', ->
          $("#sidebar_#{data}").append('<div/>')
          $("#sidebar_#{data}").children(':last').load $(this).data("edit-#{data}"), ->
            $("#sidebar_#{data}").children(':not(:last)').hide()
          no
        $("[data-cancel-#{data}]").live 'click', ->
          $("#sidebar_#{data}").children(':last').remove()
          $("#sidebar_#{data}").children().show()
          no
      $("[data-add-address]").live 'click', ->
        $("#sidebar_address").append('<div/>')
        $("#sidebar_address").children(':last').load $(this).data("add-address"), ->
          $("#sidebar_address").children(':not(:last)').hide()
        no
      $("#overlay").dialog
        autoOpen: false
        resizable: false
        modal: true
      $('#overlay').live 'keyup', (e) ->
        if e.keyCode == 13 && e.target.type != 'text'
          $(':button:contains("Save")').click()
      $("#batch_data").dialog
        autoOpen: false
        resizable: false
        modal: true
        width: 500
      $("a.#check_all").live 'click', ->
        $("#check_list :checkbox").each ->
          $(this).attr("checked", "checked")
        no
      $("a.#uncheck_all").live 'click', ->
        $("#check_list :checkbox").each ->
          $(this).attr("checked", "")
        no

      $("a.#check_all_users").live 'click', ->
        $("#users_check_list :checkbox").each ->
          $(this).attr("checked", "checked")
        no
      $("a.#uncheck_all_users").live 'click', ->
        $("#users_check_list :checkbox").each ->
          $(this).attr("checked", "")
        no

      $("#permissions_").live 'click', ->
        if $(this).attr("checked") == true
          $("#overlay .contentWrap").load "/admin/users/get_for_department?did="+$('#department_id').val()+"&pid="+$(this).val()+"&status="+$(this).attr("checked"), ->
            $("#overlay").dialog({ minWidth: 450, minHeight: 600 })
            $("#overlay").dialog("open")
      $(".button.check_users_submit").live 'click', ->
        $("#overlay, #batch_data").dialog("close")
        $('.modal_dialog').removeClass('ui-selected')

      $("a.button.close").live 'click', ->
        $("#overlay, #batch_data").dialog("close")
        $('.modal_dialog').removeClass('ui-selected')

      $('.schedule_editable li.cell').live 'click', ->
        regex = /cell_(\d+)_(\d+)_(\d+)/
        text = $(this).attr('id')
        match =text.match(regex)
        shift_id = match[1]
        line = match[2]
        day = match[3]
        $.post "/schedule/update_cell",
          {shift: shift_id, line: line, day: day}
        no

      $('.schedule_excludable li.cell').live 'click', ->
        match = $(this).attr('id').match(/cell_(\d+)_(\d+)_(\d+)/)
        shift_id = match[1]
        line = match[2]
        day = match[3]
        match = $(this).text().match(/[\d]+/)
        if current_user != '' and match != null and match[0] == current_user and confirm("Are you sure you want to toggle the delivery status?")
          $.post "/schedule/toggle_exclude",
            {shift: shift_id, line: line, day: day}
          no
#=====================================================
      $("#selectable").selectable({
        filter: 'li.cell',
        cancel: 'li.left_part.first'
      })

#      $("#edit_selected").live 'click', ->
#        if $('.ui-selected').attr('id') != undefined
#          $("#overlay .contentWrap").load $(this).attr("href"), ->
#            $("#overlay").dialog("open")
#          no
#        no

      $('li.cell').bind 'contextmenu', (e) ->
        if $('.ui-selected').attr('id') != undefined
          cells = ''
          $(".ui-selected").each ->
            cells += $(this).attr('id') + ','
          $("#overlay .contentWrap").load '/admin/schedule_cells/change?template_id='+$("table.schedule_table.settings").attr('val')+'&cells='+cells, ->
            $("#overlay").dialog("open")
          no
        no

      $('#excel_import').live 'click', ->
        if $('.ui-selected').attr('id') != undefined
          $("#batch_data .contentWrap").load $('.ui-selected').attr("batch"), ->
            $("#batch_data").dialog("open")
          no
        no

      $('.modal_dialog').live 'click', ->
        $("#overlay .contentWrap").load $(this).attr("href"), ->
          $("#overlay").dialog("open")
        no

      $("input.visible").click ->
        href = $(this).attr("href")
        $.post $(this).attr('action')+'?visible='+$(this).val(), ->
          $("#overlay .contentWrap").load href, ->
            $("#overlay").dialog("open")

      $("#check_month").click ->
        $.get $(this).attr('href')
        no

      $("th.sortable").click ->
        if $("#sort_by").val() == $(this).attr('sort')
          if $("#sort_order").val() == 'ASC'
            $("#sort_order").val('DESC')
          else
            $("#sort_order").val('ASC')
        else
          $("#sort_order").val('ASC')
        $("#sort_by").val($(this).attr('sort'))
        $("#find_form").submit()

      $(".user_select").live 'click', ->
        id = $(this).attr('id')
        $("li.cell.user_selected").removeClass('user_selected')
        $("li.cell").each ->
          if $.trim($(this).html())==id
            $(this).addClass('user_selected')

      $("#clear_selection").live 'click', ->
        $("li.cell.user_selected").removeClass('user_selected')

      $("[name*='shiftdate']").change ->
        app.reload_shift_numbers()

      $("#department_id").change ->
        app.reload_users_by_department()

      $(".datetime_select").datetimepicker
        dateFormat: 'yy-mm-dd'
        changeMonth: true
        changeYear: true

      $(".date_select").datepicker
        dateFormat: 'yy-mm-dd'
        changeMonth: true
        changeYear: true

      $("#self_score_score").change ->
        $(".self_score").hide()
        if $(this).val() > ''
          $(".self_score.comment").show()
          if $(this).val() > 3
            $(".self_score.high").show()
          else
            $(".self_score.low").show()
        else
          $(".self_score").hide()

  flashFade: ->
    $('.flash-fade').children().each (i) ->
      setTimeout((=> $(this).fadeOut()), 250 + i * 1000)

  reload: -> location.reload()

  display_addresses: (id) ->
    $("#sidebar_address").load '/user/display_addresses', ->
      app.showAddTab(id)
    no

  display_addresses_admin: (user_id, id) ->
    $("#sidebar_address").load '/admin/users/'+user_id+'/display_addresses', ->
      app.showAddTab(id)
    no

  reload_section: ( section) ->
    $("#sidebar_"+section).load '/user/display_section?section='+section

  reload_section_admin: (user_id, section) ->
    $("#sidebar_"+section).load '/admin/users/'+user_id+'/display_section?section='+section

  showAddTab: (tab) ->
    $("div[id^='sidebar_address_']").hide()
    $("#sidebar_address_"+tab).show()
    no
  reload_shift_admin: ( shift) ->
    $("#shift_"+shift).load '/admin/schedule_shifts/'+shift, ->
      $("#overlay").dialog("close")
  check_day: (template, day) ->
    $.get '/admin/schedule_templates/'+template+'/check_day/?day='+day
    no
  check_month: (template) ->
    $.get '/admin/schedule_templates/'+template+'/check_month/'
    no

  show_users_admin: ->
    $("#template_users").load '/admin/schedule/show_users/?id='+$("table.schedule_table.settings").attr('val')
    $("#overlay").dialog("close")

  reload_shift_numbers: ->
    dt = $("#shift_shiftdate_1i").val()+'-'+$("#shift_shiftdate_2i").val()+'-'+$("#shift_shiftdate_3i").val()
    $("#shift_numbers").load '/events/available_shift_numbers/?date='+dt, ->
      if $("select#shift_number option").size() == 0
        $("#new_shift .navform").hide()
      else
        $("#new_shift .navform").show()

  reload_shift_numbers_admin: ->
    dt = $("#shift_shiftdate_1i").val()+'-'+$("#shift_shiftdate_2i").val()+'-'+$("#shift_shiftdate_3i").val()
    $("#shift_numbers").load '/admin/shifts/available_shift_numbers/?date='+dt+'&user_id='+$("#shift_user_id").val(), ->
      if $("select#shift_number option").size() == 0
        $("#new_shift .navform").hide()
      else
        $("#new_shift .navform").show()

  reload_users_by_department: ->
    dep_id = $("#department_id").val()
    $("#users_select").load '/users/by_department/?department_id='+dep_id

  check_department_for_identifier: (show_alert = false) ->
    alert("After save all user's permissions will be copied to the new department") if show_alert
    if $("#user_department_id").val()
      $.get '/shifts/'+$("#user_department_id").val()+'/check_department_for_identifier', (data) ->
        if data == 'false'
          $(".for_identified_only").hide()
        else
          $(".for_identified_only").show()

  repaint_selected_cells: (user_id, font_weight, font_color, color) ->
    $('.ui-selected').html(user_id).css("font-weight", font_weight).css("color", font_color).css("background-color", color).removeClass('ui-selected')

  display_dialog: (template) ->
    $("#overlay .contentWrap").load template
#    $("#overlay").dialog({ minWidth: 450, minHeight: 600 })
    $("#overlay").dialog("open")