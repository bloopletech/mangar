document.observe("dom:loaded", function()
{
  var index = -1;

  function next_page()
  {
    if((index + 1) == pages.length) return;

    index++;
    $("image").src = pages[index];

    window.scrollTo(0, 0);
  }

  function previous_page()
  {
    if(index == 0) return;

    index--;
    $("image").src = pages[index];
  }

  $("image").observe("click", next_page);

  $("previous_page_link").observe("click", function(event)
  {
    Event.stop(event);
    previous_page();
  });

  window.onkeydown = function()
  {
    if(event.keyCode == 32 && scrollDistanceFromBottom() == 0) next_page();
    else if(event.keyCode == 8) previous_page();
  };

  next_page();
});