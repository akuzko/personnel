@app =
  init: ->
    $ =>
      @flashFade()
      $('[data-load-user]').live 'click', ->
        $('#sidebar').load $(this).data('load-user')
        no
      _.each ['profile', 'address', 'contact'], (data) ->
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
      $("a.modal_dialog[rel]").overlay
        onBeforeLoad:() ->
          wrap = this.getOverlay().find(".contentWrap")
          wrap.load(this.getTrigger().attr("href"))
      $("a.button.close").live 'click', ->
        $("a.modal_dialog[rel]").each ->
          $(this).overlay().close()

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
