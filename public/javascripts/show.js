$(function()
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

  $(window).bind('hashchange', function()
  {
    var index = get_index();

    $("#image").attr('src', "/images/blank.png");
    window.scrollTo(0, 0);    
    $("#image").attr('src', pages[index]);

    if((index + 1) < pages.length)
    {
      preload = new Image();
      preload.src = pages[index + 1];      
    }
    }).trigger('hashchange');

  $(window).keydown(function(event)
  {
    if(event.keyCode == 32 && scrollDistanceFromBottom() <= 0)
    {
      event.preventDefault();
      go_next_page();      
    }
    else if(event.keyCode == 8)
    {
      event.preventDefault();
      history.back();
    }
  });

  $("body").click(go_next_page);  
});