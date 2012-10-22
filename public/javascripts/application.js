(function() {

  this.app = {
    init: function() {
      var _this = this;
      return $(function() {
        _this.flashFade();
        $('[data-load-user]').live('click', function() {
          $('#sidebar').load($(this).data('load-user'));
          return false;
        });
        _.each(['profile', 'address', 'contact', 'permissions'], function(data) {
          $("[data-edit-" + data + "]").live('click', function() {
            $("#sidebar_" + data).append('<div/>');
            $("#sidebar_" + data).children(':last').load($(this).data("edit-" + data), function() {
              return $("#sidebar_" + data).children(':not(:last)').hide();
            });
            return false;
          });
          return $("[data-cancel-" + data + "]").live('click', function() {
            $("#sidebar_" + data).children(':last').remove();
            $("#sidebar_" + data).children().show();
            return false;
          });
        });
        $("[data-add-address]").live('click', function() {
          $("#sidebar_address").append('<div/>');
          $("#sidebar_address").children(':last').load($(this).data("add-address"), function() {
            return $("#sidebar_address").children(':not(:last)').hide();
          });
          return false;
        });
        $("#overlay").dialog({
          autoOpen: false,
          resizable: false,
          modal: true
        });
        $('#overlay').live('keyup', function(e) {
          if (e.keyCode === 13 && e.target.type !== 'text') {
            return $(':button:contains("Save")').click();
          }
        });
        $("#batch_data").dialog({
          autoOpen: false,
          resizable: false,
          modal: true,
          width: 500
        });
        $("a.#check_all").live('click', function() {
          $("#check_list :checkbox").each(function() {
            return $(this).attr("checked", "checked");
          });
          return false;
        });
        $("a.#uncheck_all").live('click', function() {
          $("#check_list :checkbox").each(function() {
            return $(this).attr("checked", "");
          });
          return false;
        });
        $("a.#check_all_users").live('click', function() {
          $("#users_check_list :checkbox").each(function() {
            return $(this).attr("checked", "checked");
          });
          return false;
        });
        $("a.#uncheck_all_users").live('click', function() {
          $("#users_check_list :checkbox").each(function() {
            return $(this).attr("checked", "");
          });
          return false;
        });
        $("#permissions_").live('click', function() {
          if ($(this).attr("checked") === true) {
            return $("#overlay .contentWrap").load("/admin/users/get_for_department?did=" + $('#department_id').val() + "&pid=" + $(this).val() + "&status=" + $(this).attr("checked"), function() {
              $("#overlay").dialog({
                minWidth: 450,
                minHeight: 600
              });
              return $("#overlay").dialog("open");
            });
          }
        });
        $(".button.check_users_submit").live('click', function() {
          $("#overlay, #batch_data").dialog("close");
          return $('.modal_dialog').removeClass('ui-selected');
        });
        $("a.button.close").live('click', function() {
          $("#overlay, #batch_data").dialog("close");
          return $('.modal_dialog').removeClass('ui-selected');
        });
        $('.schedule_editable li.cell').live('click', function() {
          var day, line, match, regex, shift_id, text;
          regex = /cell_(\d+)_(\d+)_(\d+)/;
          text = $(this).attr('id');
          match = text.match(regex);
          shift_id = match[1];
          line = match[2];
          day = match[3];
          $.post("/schedule/update_cell", {
            shift: shift_id,
            line: line,
            day: day
          });
          return false;
        });
        $('.schedule_excludable li.cell').live('click', function() {
          var day, line, match, shift_id;
          match = $(this).attr('id').match(/cell_(\d+)_(\d+)_(\d+)/);
          shift_id = match[1];
          line = match[2];
          day = match[3];
          match = $(this).text().match(/[\d]+/);
          if (current_user !== '' && match !== null && match[0] === current_user && confirm("Are you sure you want to toggle the delivery status?")) {
            $.post("/schedule/toggle_exclude", {
              shift: shift_id,
              line: line,
              day: day
            });
            return false;
          }
        });
        $("#selectable").selectable({
          filter: 'li.cell',
          cancel: 'li.left_part.first'
        });
        $('li.cell').bind('contextmenu', function(e) {
          var cells;
          if ($('.ui-selected').attr('id') !== void 0) {
            cells = '';
            $(".ui-selected").each(function() {
              return cells += $(this).attr('id') + ',';
            });
            $("#overlay .contentWrap").load('/admin/schedule_cells/change?template_id=' + $("table.schedule_table.settings").attr('val') + '&cells=' + cells, function() {
              return $("#overlay").dialog("open");
            });
            false;
          }
          return false;
        });
        $('#excel_import').live('click', function() {
          if ($('.ui-selected').attr('id') !== void 0) {
            $("#batch_data .contentWrap").load($('.ui-selected').attr("batch"), function() {
              return $("#batch_data").dialog("open");
            });
            false;
          }
          return false;
        });
        $('.modal_dialog').live('click', function() {
          $("#overlay .contentWrap").load($(this).attr("href"), function() {
            return $("#overlay").dialog("open");
          });
          return false;
        });
        $("input.visible").click(function() {
          var href;
          href = $(this).attr("href");
          return $.post($(this).attr('action') + '?visible=' + $(this).val(), function() {
            return $("#overlay .contentWrap").load(href, function() {
              return $("#overlay").dialog("open");
            });
          });
        });
        $("#check_month").click(function() {
          $.get($(this).attr('href'));
          return false;
        });
        $("th.sortable").click(function() {
          if ($("#sort_by").val() === $(this).attr('sort')) {
            if ($("#sort_order").val() === 'ASC') {
              $("#sort_order").val('DESC');
            } else {
              $("#sort_order").val('ASC');
            }
          } else {
            $("#sort_order").val('ASC');
          }
          $("#sort_by").val($(this).attr('sort'));
          return $("#find_form").submit();
        });
        $(".user_select").live('click', function() {
          var id;
          id = $(this).attr('id');
          $("li.cell.user_selected").removeClass('user_selected');
          return $("li.cell").each(function() {
            if ($.trim($(this).html()) === id) {
              return $(this).addClass('user_selected');
            }
          });
        });
        $("#clear_selection").live('click', function() {
          return $("li.cell.user_selected").removeClass('user_selected');
        });
        $("[name*='shiftdate']").change(function() {
          return app.reload_shift_numbers();
        });
        $("#department_id").change(function() {
          return app.reload_users_by_department();
        });
        $(".datetime_select").datetimepicker({
          dateFormat: 'yy-mm-dd',
          changeMonth: true,
          changeYear: true
        });
        $(".date_select").datepicker({
          dateFormat: 'yy-mm-dd',
          changeMonth: true,
          changeYear: true
        });
        return $("#self_score_score").change(function() {
          $(".self_score").hide();
          if ($(this).val() > '') {
            $(".self_score.comment").show();
            if ($(this).val() > 3) {
              return $(".self_score.high").show();
            } else {
              return $(".self_score.low").show();
            }
          } else {
            return $(".self_score").hide();
          }
        });
      });
    },
    flashFade: function() {
      return $('.flash-fade').children().each(function(i) {
        var _this = this;
        return setTimeout((function() {
          return $(_this).fadeOut();
        }), 250 + i * 1000);
      });
    },
    reload: function() {
      return location.reload();
    },
    display_addresses: function(id) {
      $("#sidebar_address").load('/user/display_addresses', function() {
        return app.showAddTab(id);
      });
      return false;
    },
    display_addresses_admin: function(user_id, id) {
      $("#sidebar_address").load('/admin/users/' + user_id + '/display_addresses', function() {
        return app.showAddTab(id);
      });
      return false;
    },
    reload_section: function(section) {
      return $("#sidebar_" + section).load('/user/display_section?section=' + section);
    },
    reload_section_admin: function(user_id, section) {
      return $("#sidebar_" + section).load('/admin/users/' + user_id + '/display_section?section=' + section);
    },
    showAddTab: function(tab) {
      $("div[id^='sidebar_address_']").hide();
      $("#sidebar_address_" + tab).show();
      return false;
    },
    reload_shift_admin: function(shift) {
      return $("#shift_" + shift).load('/admin/schedule_shifts/' + shift, function() {
        return $("#overlay").dialog("close");
      });
    },
    check_day: function(template, day) {
      $.get('/admin/schedule_templates/' + template + '/check_day/?day=' + day);
      return false;
    },
    check_month: function(template) {
      $.get('/admin/schedule_templates/' + template + '/check_month/');
      return false;
    },
    show_users_admin: function() {
      $("#template_users").load('/admin/schedule/show_users/?id=' + $("table.schedule_table.settings").attr('val'));
      return $("#overlay").dialog("close");
    },
    reload_shift_numbers: function() {
      var dt;
      dt = $("#shift_shiftdate_1i").val() + '-' + $("#shift_shiftdate_2i").val() + '-' + $("#shift_shiftdate_3i").val();
      return $("#shift_numbers").load('/events/available_shift_numbers/?date=' + dt, function() {
        if ($("select#shift_number option").size() === 0) {
          return $("#new_shift .navform").hide();
        } else {
          return $("#new_shift .navform").show();
        }
      });
    },
    reload_shift_numbers_admin: function() {
      var dt;
      dt = $("#shift_shiftdate_1i").val() + '-' + $("#shift_shiftdate_2i").val() + '-' + $("#shift_shiftdate_3i").val();
      return $("#shift_numbers").load('/admin/shifts/available_shift_numbers/?date=' + dt + '&user_id=' + $("#shift_user_id").val(), function() {
        if ($("select#shift_number option").size() === 0) {
          return $("#new_shift .navform").hide();
        } else {
          return $("#new_shift .navform").show();
        }
      });
    },
    reload_users_by_department: function() {
      var dep_id;
      dep_id = $("#department_id").val();
      return $("#users_select").load('/users/by_department/?department_id=' + dep_id);
    },
    check_department_for_identifier: function() {
      if ($("#user_department_id").val()) {
        return $.get('/shifts/' + $("#user_department_id").val() + '/check_department_for_identifier', function(data) {
          if (data === 'false') {
            return $(".for_identified_only").hide();
          } else {
            return $(".for_identified_only").show();
          }
        });
      }
    },
    repaint_selected_cells: function(user_id, font_weight, font_color, color) {
      return $('.ui-selected').html(user_id).css("font-weight", font_weight).css("color", font_color).css("background-color", color).removeClass('ui-selected');
    },
    display_dialog: function(template) {
      $("#overlay .contentWrap").load(template);
      return $("#overlay").dialog("open");
    }
  };

}).call(this);
