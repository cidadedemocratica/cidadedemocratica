//Miscelanea...

// O modalbox nao permite que se coloque javascript
// na pagina. Entao, é preciso trazer pra cá...
function validarDenuncia(f) {
  var ok = true; //false
  //alert('x');
  if ($('denuncia[descricao]').value=='') {
    alert('Descreva sua reclamação ou denúncia.');
    ok = false;
  } 
  if ($('denuncia[nome]').value=='') {
    alert('Preencha seu nome.');
    ok = false;
  } 
  if ($('denuncia[email]').value=='') {
    alert('Preencha corretamente seu email.');
    ok = false;
  }
  return ok;
}
