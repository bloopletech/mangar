var update_items = function()
{
  $$("#items .tag_list").each(function(div)
  {
    div.observe("click", function(event)
    {
      div.next().show().down(".input").focus();
      div.hide();
    });

    div.next().hide();
  });
};

document.observe("dom:loaded", update_items);

document.observe('dom:loaded', function()
{
  var submit_func = function(element, value)
  {
   $('search_form').submit();
  };
  new Form.Element.Observer('sort', 1.0, submit_func);
  new Form.Element.Observer('sort_direction', 1.0, submit_func);

  $("tag_cloud_link").observe("click", function(event)
  {
    event.preventDefault();
  });
  
  $("tag_cloud_link").observe("mouseenter", function(event)
  {
    $("tag_cloud").show();
  });

  $("tag_cloud").observe("mouseleave", function(event)
  {
    $("tag_cloud").hide();
  });
});