$( document ).ready(function() {
var nsub = $('#nivsub').text() * 4;
var nfav = $('#nivfav').text() * 0.4;
var ncom = $('#nivcom').text() * 0.8;
var nvot = $('#nivvot').text() * 0.4;
var nmet = $('#nivmet').text();
var nfor = $('#nivfor').text() * 0.8;
var suma = +nsub+ + +nfav+ +ncom+ + +nvot+ + +nmet+ + +nfor;
//NIVELES
if (suma <= 11) {
$('#nivel').text('Nivel 1');
$('#puntos').text(suma + '/12');
var pasento = (100 / 12) * suma;
$('#prog').css('width', pasento + '%');
}
else if (suma >= 12) {
$('#nivel').text('Nivel 2');
$('#puntos').text(suma + '/24');
var pasento = (100 / 24) * suma;
$('#prog').css('width', pasento + '%');
}
else if (suma >= 24) {
$('#nivel').text('Nivel 3');
$('#puntos').text(suma + '/44');
var pasento = (100 / 44) * suma;
$('#prog').css('width', pasento + '%');
}
else if (suma >= 44) {
$('#nivel').text('Nivel 4');
$('#puntos').text(suma + '/90');
var pasento = (100 / 90) * suma;
$('#prog').css('width', pasento + '%');
}
else if (suma >= 90) {
$('#nivel').text('Nivel 5');
$('#puntos').text(suma + '/180');
var pasento = (100 / 180) * suma;
$('#prog').css('width', pasento + '%');
}
else if (suma >= 180) {
$('#nivel').text('Nivel 6');
$('#puntos').text(suma + '/400');
var pasento = (100 / 400) * suma;
$('#prog').css('width', pasento + '%');
}
else if (suma >= 400) {
$('#nivel').text('Nivel 7');
$('#puntos').text(suma + '/800');
var pasento = (100 / 800) * suma;
$('#prog').css('width', pasento + '%');
}
else if (suma >= 800) {
$('#nivel').text('Nivel 8');
$('#puntos').text(suma + '/1600');
var pasento = (100 / 1600) * suma;
$('#prog').css('width', pasento + '%');
}
else if (suma >= 1600) {
$('#nivel').text('Nivel 9');
$('#puntos').text(suma + '/2500');
var pasento = (100 / 2500) * suma;
$('#prog').css('width', pasento + '%');
}

});
