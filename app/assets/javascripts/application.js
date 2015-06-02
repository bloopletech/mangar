//= require jquery
//= require jquery_ujs
//= require lib/URI.js

function scrollDistanceFromBottom() {
  return pageHeight() - (window.pageYOffset + self.innerHeight);
}

function pageHeight() {
  return $("body").height();
}


