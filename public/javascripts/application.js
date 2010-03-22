// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var update_books = function()
{
  $$("a.open").each(function(link)
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