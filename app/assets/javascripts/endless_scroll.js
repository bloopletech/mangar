var scroll_lock = false;
var last_page = false;
var current_page = 1;

function checkScroll() {
  if(!last_page && !scroll_lock && utils.nearBottomOfPage()) {
    scroll_lock = true;

    current_page++;

    var url = new URI().removeQuery('page').addQuery('page', current_page).href();
    $.get(url, {}, function(data) {
      $("#items").append(data);
      scroll_lock = false;
    });
  }
}

$(function() {
  setInterval(checkScroll, 250);
});