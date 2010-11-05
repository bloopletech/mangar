window.onkeydown = function()
{
  if(event.keyCode == 32 && scrollDistanceFromBottom() == 0) location.href = $("next_page_link").readAttribute('href');
  else if(event.keyCode == 8 && $("previous_page_link")) location.href = $("previous_page_link").readAttribute('href');
};