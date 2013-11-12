$(document).ready(function() {
  // A logo a day
  var day         = $('.right-col h1').text().split(' ');
  var current_day = 'logo-' + day[0].toLowerCase();
  $('a.logo').removeClass().addClass('logo ' + current_day);
});