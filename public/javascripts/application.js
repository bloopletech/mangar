var update_books = function()
{
  $$("#books .tag_list").each(function(div)
  {
    div.observe("click", function(event)
    {
      div.next().show().down(".input").focus();
      div.hide();
    });

    div.next().hide();
  });
  /*
  $$("#books .delete").each(function(a)
  {
    a.observe("click", function(event)
    {
      if(
      event.stop();
    });
  });*/
};

document.observe("dom:loaded", update_books);

document.observe("dom:loaded", function()
{
  $("search_form").observe("submit", function(event)
  {
    event.preventDefault();
  });
});