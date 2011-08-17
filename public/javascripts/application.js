(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  this.app = {
    init: function() {
      return $(__bind(function() {
        this.flashFade();
        $('[data-load-user]').live('click', function() {
          $('#sidebar').load($(this).data('load-user'));
          return false;
        });
        _.each(['profile', 'address', 'contact'], function(data) {
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
          resizable: false
        });
        $("a.button.close").live('click', function() {
          return $("#overlay").dialog("close");
        });
        $('.modal_dialog').live('click', function() {
          $("#overlay .contentWrap").load($(this).attr("href"), function() {
            return $("#overlay").dialog("open");
          });
          return false;
        });
        $("#visible").click(function() {
          return $.post($(this).attr('href') + '?visible=' + $(this).attr('checked'));
        });
        $("#check_month").click(function() {
          $.get($(this).attr('href'));
          return false;
        });
        $("th.sortable").click(function() {
          $("#sort_by").val($(this).attr('sort'));
          return $("#find_form").submit();
        });
        $(".user_select").click(function() {
          var id;
          id = $(this).attr('id');
          $("td.modal_dialog.user_selected").removeClass('user_selected');
          return $("td.modal_dialog").each(function() {
            if ($.trim($(this).html()) === id) {
              return $(this).addClass('user_selected');
            }
          });
        });
        return $("#clear_selection").click(function() {
          return $("td.modal_dialog.user_selected").removeClass('user_selected');
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
    show_users_admin: function(template_id) {
      return $("#template_users").load('/admin/schedule/show_users/?id=' + template_id);
    }
  };
}).call(this);
