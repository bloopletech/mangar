document.observe("dom:loaded", function()
{
  function get_index()
  {
    var index = parseInt(location.hash.substr(1));    
    if(isNaN(index)) index = 0;
    return index;
  }

  function go_next_page()
  {
    var index = get_index();
    index += 1;

    if(index >= pages.length) index = pages.length - 1;
    location.hash = "#" + index;
  }

  window.onhashchange = function()
  {    
    var index = get_index();

    $("image").src = "/images/blank.png";
    window.scrollTo(0, 0);    
    $("image").src = pages[index];

    if((index + 1) < pages.length)
    {
      preload = new Image();
      preload.src = pages[index + 1];
    }
  }

  window.onkeydown = function(event)
  {
    if(event.keyCode == 32 && scrollDistanceFromBottom() == 0)
    {
      Event.stop(event);
      go_next_page();      
    }    
  };

  $("image").onclick = go_next_page;
  location.hash = "#0";
});