(function() {
  var ctrlPressed, shiftPressed;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  ctrlPressed = false;
  shiftPressed = false;
  this.app = {
    init: function() {
      return $(__bind(function() {
        this.flashFade();
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
          return $('.modal_dialog').removeClass('selected');
        });
        $("a.button.close").live('click', function() {
          $("#overlay, #batch_data").dialog("close");
          return $('.modal_dialog').removeClass('selected');
        });
        $('.schedule_editable td').live('click', function() {
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
        $('.schedule_excludable td').live('click', function() {
          var day, line, match, regex, shift_id, text;
          regex = /cell_(\d+)_(\d+)_(\d+)/;
          text = $(this).attr('id');
          match = text.match(regex);
          shift_id = match[1];
          line = match[2];
          day = match[3];
          $.post("/schedule/toggle_exclude", {
            shift: shift_id,
            line: line,
            day: day
          });
          return false;
        });
        $("#selectable").selectable({
          filter: 'li.cells.selectable',
          cancel: 'li.shift-options'
        });
        $("#edit_cells").live('click', function() {
          $("#overlay .contentWrap").load($(this).attr("href"), function() {
            return $("#overlay").dialog("open");
          });
          return false;
        });
        $('#edit_cells').live('click', function() {
          $("#overlay .contentWrap").load($(this).attr("href"), function() {
            return $("#overlay").dialog("open");
          });
          false;
          $("#batch_data .contentWrap").load($(this).attr("batch"), function() {
            return $("#batch_data").dialog("open");
          });
          return false;
        });
        $('.modal_dialog').live('click', function() {
          if (ctrlPressed) {
            $(this).toggleClass('selected');
            return false;
          } else if (shiftPressed) {
            $(this).addClass('selected');
            $("#batch_data .contentWrap").load($(this).attr("batch"), function() {
              return $("#batch_data").dialog("open");
            });
            return false;
          } else {
            $(this).addClass('selected');
            $("#overlay .contentWrap").load($(this).attr("href"), function() {
              return $("#overlay").dialog("open");
            });
            return false;
          }
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
          $("td.cells.user_selected").removeClass('user_selected');
          return $("td.cells").each(function() {
            if ($.trim($(this).html()) === id) {
              return $(this).addClass('user_selected');
            }
          });
        });
        $("#clear_selection").live('click', function() {
          return $("td.cells.user_selected").removeClass('user_selected');
        });
        $("[name*='shiftdate']").change(function() {
          return app.reload_shift_numbers();
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
        $(window).keydown(function(evt) {
          if (evt.which === 17) {
            ctrlPressed = true;
          }
          if (evt.which === 16) {
            return shiftPressed = true;
          }
        });
        return $(window).keyup(function(evt) {
          if (evt.which === 17) {
            ctrlPressed = false;
          }
          if (evt.which === 16) {
            return shiftPressed = false;
          }
        });
      }, this));
    },
    flashFade: function() {
      return $('.flash-fade').children().each(function(i) {
        return setTimeout((__bind(function() {
          return $(this).fadeOut();
        }, this)), 250 + i * 1000);
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
      $("#template_users").load('/admin/schedule/show_users/?id=' + $("#schedule_template").attr('val'));
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
    mass_update: function(responsible, additional_attributes, user_id, is_modified) {
      var regex;
      regex = /cell_(\d+)_(\d+)_(\d+)/;
      $("li.cells.selectable.ui-selected").each(function() {
        var day, line, match, shift_id, text;
        text = $(this).attr('id');
        match = text.match(regex);
        shift_id = match[1];
        line = match[2];
        day = match[3];
        return $.post("/admin/schedule_cells", {
          shift: shift_id,
          line: line,
          day: day,
          'schedule_cell[responsible]': responsible,
          'schedule_cell[additional_attributes]': additional_attributes,
          'schedule_cell[user_id]': user_id,
          'schedule_cell[is_modified]': is_modified
        }, function() {
          return app.check_day(shift_id, day);
        });
      });
      false;
      $("li.cells.selectable.ui-selected").removeClass('ui-selected');
      app.show_users_admin();
      return $("#overlay").dialog("close");
    },
    check_department_for_identifier: function() {
      if ($("#user_department_id").val()) {
        return $.get('/shifts/' + $("#user_department_id").val() + '/check_department_for_identifier', function(data) {
          if (data === 'false') {
            return $("#user_identifier").parents("div.group").hide();
          } else {
            return $("#user_identifier").parents("div.group").show();
          }
        });
      }
    }
  };
}).call(this);
