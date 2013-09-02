
jQuery.fn.activeChosen = (function ($) {
  function fetch(resource, keys) {
    $.each(keys, function(index, key) {
      resource = resource && resource[key]
    })
    return resource
  }

  function callback(options, data) {
    var results = []
    $.each(data, function(index, resource) {
      results.push({
        value: fetch(resource, options.valueKeys),
        text: fetch(resource, options.textKeys)
      })
    })
    return results
  }

  return function (options) {
    options = $.extend({
      dateType: 'json',
      keepTypingMsg: 'Continue digitando...',
      lookingForMsg: 'Procurando por',
      chosenOptions: {
        no_results_text: 'Nenhum registro encontrado para'
      }
    }, options)

    return this.ajaxChosen(options, $.proxy(callback, this, options), options.chosenOptions)
  }
})(jQuery)


jQuery.fn.activeCascadeLocals = (function ($) {

  var fields = [
    { name: 'estado_select_cascade', url: null },
    { name: 'cidade_select_cascade', url: '/locais/cidades_options_for_select?estado_id=:id&first_option=:first_option' },
    { name: 'bairro_select_cascade', url: '/locais/bairros_options_for_select?cidade_id=:id&first_option=:first_option' }
  ]

  function fieldsClassname () {
    var data = []
    $.each(fields, function (index, field) {
      data.push('.' + field.name)
    })
    return data.join(', ')
  }

  function getNextFields (current) {
    var nextFields = []
    $.each(fields, function (index, field) {
      if (current.hasClass(field.name)) {
        nextFields = fields.slice(index + 1)
        return false
      }
    })
    return nextFields
  }

  return function () {
    this.on('change', fieldsClassname(), function(event) {
      var current = $(event.currentTarget),
          container = current.closest('.cascade_container, form'),
          nextFields = getNextFields(current),
          nextField = nextFields.shift()

      if (nextField) {
        var field = container.find('.' + nextField.name)
        field.empty().load(
          nextField.url
            .replace(':id', current.val())
            .replace(':first_option', encodeURIComponent(field.data('first_option') || ''))
        )
      }

      $.each(nextFields, function (index, nextField) {
        container.find('.' + nextField.name).empty()
      })
    })
  }
})(jQuery)


jQuery.fn.activeTags = (function ($) {

  function ActiveTags(el) {
    this.el = el
    this.tags = el.find('.tags')
    this.tagsCount = el.find('.tags_count')

    this.eventListener()
  }

  ActiveTags.prototype.eventListener = function () {
    this.tags.on('change', $.proxy(this.tagsCountUpdate, this))

    this.el.find('.tags_select_all').on('click', $.proxy(this.changeAllTags, this, true))
    this.el.find('.tags_deselect_all').on('click', $.proxy(this.changeAllTags, this, false))

    this.el.find('.apply_macro_tags').on('click', $.proxy(this.applyMacroTags, this))
    this.el.find('.create_macro_tag').on('click', $.proxy(this.createMacroTags, this))

    $('.tags_refresh_button').on('click', $.proxy(this.refreshTags, this))

    $('.tags_refresh').on('change', $.proxy(this.refreshTags, this))
  }

  ActiveTags.prototype.refreshTags = function () {
    this.el.addClass('loading')
    $.ajax({
      url: '/admin_new/relatorios/tags.json',
      data: $('.tags_refresh').serialize(),
      dataType: 'json',
      success: $.proxy(function (data) {
        var values = this.tagsValues(),
            html = ''
        $.each(data, function (key, value) {
          if (values.indexOf(value) == -1) {
            html += '<option>' + value + '</option>'
          }
        })
        this.el.removeClass('loading')
        this.tags.find('option:not(:selected)').remove()
        this.tags.append(html)
      }, this)
    })
  }

  ActiveTags.prototype.tagsCountUpdate = function () {
    this.tagsCount.html(this.tagsValues().length + ' selecionado(s)')
  }

  ActiveTags.prototype.tagsValues = function () {
    return this.tags.val() || []
  }

  ActiveTags.prototype.changeAllTags = function (select) {
    this.tags.find('option').prop('selected', select)
    this.tagsCountUpdate()
  }

  ActiveTags.prototype.applyMacroTags = function (e) {
    var data = this.el.find('.macro_tags').val().split(',')
    this.tags.val(data.concat(this.tags.val()))
    this.tagsCountUpdate()
  }

  ActiveTags.prototype.createMacroTags = function (e) {
    e.preventDefault()
    if (!this.tags.val()) return alert('Você deve escolher pelo menos uma tag.')

    title = prompt('Nome da Macro Tag')
    if (!title) return alert('Você deve definir um nome.')

    $.ajax({
      type: 'post',
      url: '/admin/macro_tags',
      data: 'macro_tag[title]=' + title + '&macro_tag[tag_list]=' + this.tags.val().join(','),
      success: function() {
        alert('Macro Tag criada com sucesso!')
      }
    })
  }

  return function () {
    if (this.length) new ActiveTags(this)
    return this
  }
})(jQuery)
