var scroll_lock = false;
var last_page = false;
var current_page = 1;

function checkScroll()
{
  if(!scroll_lock && nearBottomOfPage())
  {
    current_page++;

    var url = location.pathname + "?" + $H(location.search.toQueryParams()).merge({ 'page' : current_page }).toQueryString();

    scroll_lock = true;
    new Ajax.Request(url, { asynchronous: true, evalScripts: true, method: 'get', onSuccess: function(req)
    {
      if(!last_page) scroll_lock = false;
    } });
  }
}

function nearBottomOfPage() {
  return scrollDistanceFromBottom() < 150;
}

function scrollDistanceFromBottom() {
  return pageHeight() - (window.pageYOffset + self.innerHeight);
}

function pageHeight() {
  return Math.max(document.body.scrollHeight, document.body.offsetHeight);
}

document.observe('dom:loaded', function()
{
  setInterval("checkScroll()", 250);
});