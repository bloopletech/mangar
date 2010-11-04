window.onkeydown = function()
{
  if(event.keyCode == 32 && scrollDistanceFromBottom() == 0) location.href = $$("a")[0].readAttribute('href');
};