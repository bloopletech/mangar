var update_books = function()
{
  $$("a.open, #import_and_update > a").each(function(link)
  {
    link.observe("click", function(event)
    {
      event.preventDefault();
      new Ajax.Request(link.getAttribute("href"), { method: "get" });
    })
  });

  $$("#books .tag_list").each(function(div)
  {
    div.observe("click", function(event)
    {
      div.next().show().down(".input").focus();
      div.hide();
    });

    div.next().hide();
  });
};

document.observe("dom:loaded", update_books);

document.observe("dom:loaded", function()
{
  $("search_form").observe("submit", function(event)
  {
    event.preventDefault();
  });
});