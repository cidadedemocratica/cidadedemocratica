//= require active_admin/base
//= require jquery_nested_form

//= require chosen-jquery
//= require jquery.ajaxChosen
//= require jquery.maskedinput

//= require jquery.active


/*
  Fix jQuery 1.9 support in checkbox toggler
  https://github.com/gregbell/active_admin/commit/efb8059ba5aafd3156c27a4ad62f48fc20714ba3
 */
jQuery.extend(window.AA.CheckboxToggler.prototype, {
  _didChangeToggleAllCheckbox: function () {
    if (this.toggle_all_checkbox.prop('checked')) {
      this._checkAllCheckboxes()
    } else {
      this._uncheckAllCheckboxes()
    }
  },
  _checkToggleAllCheckbox: function () {
    this.toggle_all_checkbox.prop('checked', true)
  },
  _checkAllCheckboxes: function () {
    var self = this
    this.checkboxes.each(function(index, el) {
      jQuery(el).prop("checked", true)
      self._didChangeCheckbox(el)
    })
  }
})

/*
  Bootstrap
 */
jQuery(document).ready(function ($) {
  $('.date_picker').mask('99/99/9999')

  $('.input_chosen_user').activeChosen({
    url: '/admin_new/users.json',
    jsonTermKey: 'q[dado_nome_contains]',
    valueKeys: ['user', 'id'],
    textKeys: ['user', 'nome']
  })

  $('.input_chosen_state').activeChosen({
    url: '/admin_new/estados.json',
    data: { order: 'nome_asc' },
    jsonTermKey: 'q[nome_contains]',
    valueKeys: ['estado', 'id'],
    textKeys: ['estado', 'nome'],
  })

  $('.input_chosen_city').activeChosen({
    url: '/admin_new/cidades.json',
    data: { order: 'nome_asc' },
    jsonTermKey: 'q[nome_contains]',
    valueKeys: ['cidade', 'id'],
    textKeys: ['cidade', 'full_name']
  })

  $('.input_chosen_tags').activeChosen({
    url: '/admin_new/tags.json',
    data: { order: 'name_asc' },
    jsonTermKey: 'q[name_contains]',
    valueKeys: ['tag', 'id'],
    textKeys: ['tag', 'name']
  })

  $('.active_tags').activeTags()

  $(document).activeCascadeLocals()
})
