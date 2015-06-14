$(function() {
  $("#search_form select").change(function(event) {
    $('#search_form').submit();
  });

  $("#tag_cloud_link").click(function(event)
  {
    event.preventDefault();
  });

  $("#tag_cloud_link").mouseenter(function(event)
  {
    $("#tag_cloud").show();
  });

  $("#tag_cloud").mouseleave(function(event)
  {
    $("#tag_cloud").hide();
  });

  $(document).on("click", "#items .title", function(event) {
    $(this).next().show().find("textarea").val($(this).text()).focus();
    $(this).hide();
  });

  $(document).on("keydown", "#items textarea", function(event) {
    var form = $(this).parents("form");
    if(event.keyCode == 13) {
      event.preventDefault();
      form.submit();
    }
    else if(event.keyCode == 27) {
      event.preventDefault();
      form.hide();
      form.prev().show();
      $(this).val(form.prev().text());
    }
  });
});
