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
};

document.observe("dom:loaded", update_books);
/*
document.observe("dom:loaded", function()
{
  $("search_form").observe("submit", function(event)
  {
    event.preventDefault();
  });
});*/

document.observe('dom:loaded', function()
{
  var submit_func = function(element, value)
  {
   $('search_form').submit();
  };
  new Form.Element.Observer('sort', 1.0, submit_func);
  new Form.Element.Observer('sort_direction', 1.0, submit_func);
});