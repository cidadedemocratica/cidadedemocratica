// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require prototype
//= require prototype_ujs
//= require effects
//= require dragdrop
//= require controls
//= require livepipe-ui/src/livepipe
//= require livepipe-ui/src/tabs
//= require_self
//
// Interface de montagem do Relatorio //
/**************************************/

function selectOptions(options, selected) {
  for (var i = 0; i < options.length; i++) {
    options[i].selected = selected
  }
}

function refreshTotalSelected(total) {
  document.getElementById('selected_itens').innerHTML = total + " selecionados"
}

// Marca (ou desmarca) todos os OPTIONS de um dado SELECT
function selectAll(selectBox, selected) {
  // have we been passed an ID
  if (typeof selectBox == "string") {
    selectBox = document.getElementById(selectBox);
  }

  selectOptions(selectBox.options, selected)
  refreshTotalSelected(selectBox.selectedOptions.length)
}

// Marca os options de um dado SELECT de acordo com o seu valor
function selectOptionsByValues(selectBox, values) {
  if (typeof selectBox == "string") {
    selectBox = document.getElementById(selectBox)
  }

  values = values.split(',')
  var optionsToSelect = []

  for(var i = 0; i < values.length; i++) {
    for(var j = 0; j < selectBox.options.length; j++) {
      if (selectBox.options[j].value == values[i]) {
        optionsToSelect.push(selectBox.options[j])
      }
    }
  }
  selectOptions(optionsToSelect, true)
  refreshTotalSelected(selectBox.selectedOptions.length)
}


// Habilita um dado SELECT
function habilitar(selectBox) {
  // have we been passed an ID
  if (typeof selectBox == "string") {
    selectBox = document.getElementById(selectBox);
  }
  // is the element disabled?
  if (selectBox.disabled) {
    selectBox.disabled = false;
  }
}

// Habilita um dado SELECT
function desabilitar(selectBox) {
  // have we been passed an ID
  if (typeof selectBox == "string") {
    selectBox = document.getElementById(selectBox);
  }
  if (selectBox) {
    selectBox.disabled = true;
    selectBox.writeAttribute('disabled', 'disabled');
  }
}

// Mostra/Esconde um DIV de acordo com o select escolhido
function trocarTipoAviso() {
  $('aviso_texto_simples').hide();
  $('aviso_arquivo_personalizado').hide();
  //alert($('settings_aviso_geral_tipo').value);
  if($('settings_aviso_geral_tipo').value=="texto") {
    $('aviso_texto_simples').show();
  }
  if($('settings_aviso_geral_tipo').value=="arquivo") {
    $('aviso_arquivo_personalizado').show();
  }
}

// Criar MacroTag

function createMacroTag(selectBox) {
  if (typeof selectBox == "string") {
    selectBox = document.getElementById(selectBox)
  }

  var selectedOptions = selectBox.selectedOptions,
      tags  = []

  if (!selectedOptions.length) {
    return alert('Você deve escolher pelo menos uma tag.')
  }

  title = prompt('Nome da Macro Tag')
  if (!title) {
    return alert('Você deve definir um nome.')
  }

  for(var i = 0; i < selectedOptions.length; i++) {
    tagName = selectedOptions[i].text.replace(/ \([0-9]+\)/, '')
    tags.push(tagName)
  }

  params = 'macro_tag[title]=' + title
  params +='&macro_tag[tag_list]=' + tags.toString()

  new Ajax.Request('/admin/macro_tags', {
    method: 'post',
    parameters: params,
    onSuccess: function() {
      alert('Macro Tag criada com sucesso!')
    }
  })
}

