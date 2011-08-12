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
        $("a.modal_dialog[rel]").overlay({
          onBeforeLoad: function() {
            var wrap;
            wrap = this.getOverlay().find(".contentWrap");
            return wrap.load(this.getTrigger().attr("href"));
          }
        });
        return $("a.button.close").live('click', function() {
          return $("a.modal_dialog[rel]").each(function() {
            return $(this).overlay().close();
          });
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
    }
  };
}).call(this);
