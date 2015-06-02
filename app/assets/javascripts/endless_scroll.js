var scroll_lock = false;
var last_page = false;
var current_page = 1;

function checkScroll()
{
  if(!last_page && !scroll_lock && nearBottomOfPage())
  {
    scroll_lock = true;

    current_page++;

    var url = new URI().removeQuery('page').addQuery('page', current_page).href();
    $.get(url, {}, function(req)
    {
      scroll_lock = false;
    }, 'script');
  }
}

function nearBottomOfPage() {
  return scrollDistanceFromBottom() < 1000;
}

$(function() {
  setInterval(checkScroll, 250);
  console.log('checking');
});
console.log('executed');