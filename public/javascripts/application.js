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

  $$("#books li").each(function(book)
  {
    book.select(".more_info").invoke('hide');
    book.observe("mouseenter", function(event)
    {
      this.select(".more_info").invoke('show');
    });
    book.observe("mouseleave", function(event)
    {
      this.select(".more_info").invoke('hide');
    });
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