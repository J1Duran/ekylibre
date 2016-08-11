#= require bootstrap/modal

((E, G, $) ->

  $(document).ajaxSend (e, xhr, options) ->
    token = $('meta[name=\'csrf-token\']').attr('content')
    xhr.setRequestHeader 'X-CSRF-Token', token
    return


  class golumn
    constructor: (id) ->
      @id = id

      @selectedItemsIndex = {}

      @groups = ko.observableArray []
      @containers = ko.observableArray []
      @animals = ko.observableArray []


      @enableDropZones = (state = false) =>
        ko.utils.arrayForEach @groups(), (group) =>
          group.droppable state
          ko.utils.arrayForEach group.containers(), (container) =>
            container.droppable state unless container.protect

      @moveAnimals = (container, group) =>

        params = {}
        params['container'] = container.id() unless container is undefined
        params['parameters'] = true

        # find if any group changed
        for id, item of @selectedItemsIndex
          if item.parent.parent.id != group.id and group isnt undefined
            params['group'] = group.id

        E.dialog.open @rebuildUrl(params),
          returns:
            success: (frame, data, status, request) =>
              Turbolinks.visit '#', action: 'replace'

              frame.dialog "close"
              return

            invalid: (frame, data, status, request) ->
              frame.html request.responseText
              return

      # by default, build url to move animals
      @rebuildUrl = =>
        options = Array.from(arguments).shift()
        options['animals_ids'] ||= Object.keys(@selectedItemsIndex)

        parameters = options['parameters'] || false
        base_url = options['base_url'] || $('a[data-target=animal_group_changing]').attr('href')

        delete options['base_url']
        delete options['parameters']

        base_url += "&#{$.param(options)}" if parameters

        base_url

      @impactOnSelection = =>

        count = Object.keys(@selectedItemsIndex).length
        $el = $('.interventions-accessor').find('[data-toggle=dropdown]')

        $el.data('name', $el.html()) unless $el.data('name')

        # TODO: set icon or text to explain counting.
        $el.html("#{$el.data('name')} (#{count})")


      @resetSelectedItems = =>
        for id, item  of @selectedItemsIndex
          item.checked(false)

        @selectedItemsIndex = {}


  @loadData = (golumn, element) =>
    $.ajax '/backend/animals/load_animals',
      type: 'GET'
      dataType: 'JSON'
      data:
        golumn_id: golumn
      beforeSend: () ->
        element.addClass("loading")
        return
      complete: () ->
        element.removeClass("loading")
        return
      success: (json_data) ->
        groups = ko.utils.arrayMap json_data.groups, (jGroup) =>

          group = new G.Group(jGroup.id, jGroup.name, [])

          group.containers ko.utils.arrayMap jGroup.places, (jPlace) =>

            container = new G.Container(jPlace.id, jPlace.name, [], group)

            container.items ko.utils.arrayMap jPlace.animals, (animal) =>
              new G.Item(animal.id, animal.name, animal.status, animal.sex, animal.show_path, container)

            container

          #items without place:
          if jGroup.without_place
            new_container = new G.Container(jGroup.without_place.id, jGroup.without_place.name, [], group)
            new_container.items ko.utils.arrayMap jGroup.without_place.animals, (animal) =>
              new G.Item(animal.id, animal.name, animal.status, animal.sex, animal.show_path, new_container)

            group.containers.push new_container

          group

        if json_data.without_group
          new_group = new G.Group(json_data.without_group.id, json_data.without_group.name, [])

          #items without place:
          if json_data.without_group.without_place
            new_container = new G.Container(json_data.without_group.without_place.id, json_data.without_group.without_place.name, [], new_group)
            new_container.items ko.utils.arrayMap json_data.without_group.without_place.animals, (animal) =>
              new G.Item(animal.id, animal.name, animal.status, animal.sex, animal.show_path, new_container)

            new_group.containers.push new_container

            groups.push new_group

        window.app.groups = ko.observableArray(groups)

        ko.applyBindings window.app

        return true

      error: (data) ->
        return false

    return

  $(document).on 'click', 'a[data-toggle=dialog]', (e) =>

    e.stopPropagation()
    
    E.dialog.open app.rebuildUrl({base_url: e.currentTarget.getAttribute('href'), parameters: $(e.currentTarget).data('parameters')}),
      returns:
        success: (frame, data, status, request) ->

          if $(e.currentTarget).data('refresh')
            Turbolinks.visit '', action: 'replace'

          frame.dialog "close"
          return

        invalid: (frame, data, status, request) ->
          frame.html request.responseText
          return
    false


  $(document).ready ->
    # $("*[data-golumns]").mousewheel (event, delta) ->
    #   if $(this).prop("wheelable") != "false"
    #     @scrollLeft -= (delta * 30)
    #     event.preventDefault()


    $("*[data-golumns='animal']").each ->
      golumn_id = $(this).data("golumns")
      window.app = new golumn(golumn_id)
      window.loadData(golumn_id, $(this))

) ekylibre, golumn, jQuery
