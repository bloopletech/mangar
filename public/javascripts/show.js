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
    index += 2;

    if(index >= (pages.length - 2)) index = pages.length - 2;
    location.hash = "#" + index;
  }

  $(window).bind('hashchange', function()
  {
    var index = get_index();

    $("#image_left, #image_right").attr('src', "/images/blank.png");    
    window.scrollTo(0, 0);
    $("#image_left").attr('src', pages[index]);
    $("#image_right").attr('src', pages[index + 1]);

    if((index + 2) < pages.length)
    {
      var preload = new Image();
      preload.src = pages[index + 2];
    }
    if((index + 3) < pages.length)
    {
      var preload2 = new Image();
      preload2.src = pages[index + 3];
    }
      
  }).trigger('hashchange');

  $(window).keydown(function(event)
  {
    if(event.keyCode == 32)
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

  if(pages.length % 2 != 0) pages.push("/images/blank.png");

  $("body").click(go_next_page);  
});
