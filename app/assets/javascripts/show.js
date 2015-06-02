$(function()
{
  $(window).bind('hashchange', function()
  {
    var index = utils.page();

    $("#image").attr('src', "/images/blank.png");
    window.scrollTo(0, 0);
    $("#image").attr('src', pages[index]);

    if((index + 1) < pages.length)
    {
      preload = new Image();
      preload.src = pages[index + 1];
    }

  }).trigger('hashchange');

  $("#page-back").click(function(e) {
    e.stopPropagation();
    utils.page(utils.page() - 1, pages.length - 1);
  });
  $("#page-back-10").click(function(e) {
    e.stopPropagation();
    utils.page(utils.page() - 10, pages.length - 1);
  });
  $("#page-next").click(function(e) {
    e.stopPropagation();
    utils.page(utils.page() + 1, pages.length - 1);
  });
  $("#page-next-10").click(function(e) {
    e.stopPropagation();
    utils.page(utils.page() + 10, pages.length - 1);
  });
  $("#page-home").click(function(e) {
    e.stopPropagation();
    window.close();
  });

  $(window).keydown(function(event) {
    if(event.keyCode == 39 || ((event.keyCode == 32 || event.keyCode == 13)
      && utils.scrollDistanceFromBottom() <= 0)) {
      event.preventDefault();
      utils.page(utils.page() + 1, pages.length);
    }
    else if(event.keyCode == 8 || event.keyCode == 37) {
      event.preventDefault();
      utils.page(utils.page() - 1, pages.length);
    }
  });
});
