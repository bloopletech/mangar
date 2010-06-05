var scroll_lock = false;
var last_page = false;
var current_page = 1;

function checkScroll()
{
  if(!last_page && !scroll_lock && nearBottomOfPage())
  {
    scroll_lock = true;

    current_page++;

    var qs = $H(location.search.toQueryParams());
    qs.each(function(pair)
    {
      qs.set(pair.key, pair.value.replace("+", " "));
    });

    var url = location.pathname + "?" + qs.merge({ 'page' : current_page }).toQueryString();

    new Ajax.Request(url, { asynchronous: true, evalScripts: true, method: 'get', onSuccess: function(req)
    {
      setTimeout(function()
      {
        scroll_lock = false;
      }, 500);
    } });
  }
}

function nearBottomOfPage() {
  return scrollDistanceFromBottom() < 500;
}

function scrollDistanceFromBottom() {
  return pageHeight() - (window.pageYOffset + self.innerHeight);
}

function pageHeight() {
  return $$("body")[0].getHeight();
}

document.observe('dom:loaded', function()
{
  setInterval("checkScroll()", 250);
});