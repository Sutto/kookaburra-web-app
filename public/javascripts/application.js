last_message_id = 0;

$(function() {
  // Bind our event handler
  $("#status-update-field").keypress(updateCharactersTotal);
  $("#update-status-form").submit(statusSubmitHandler);
  // Now, periodically check for updates.
  setInterval(updateMessageList, 30000);
})

function updateCharactersTotal()
{
  $("#characters-used").text($("#status-update-field").val().length);
}

function setReplyTo(username)
{
  var oldValue = $("#status-update-field").val();
  if(oldValue.indexOf("@") != 0)
  $("#status-update-field").val("@" + username.toString() + " " + oldValue).focus();
}

function statusSubmitHandler()
{
  var form  = $("#update-status-form");
  var text  = $("#status-update-field").val();
  var parts = text.split(" ");
  
  $("#status-update-field").attr("disabled", "disabled");
  if (parts.length > 1 && parts[0] == "/nick") {
   changeNickTo(parts[1]);
  } else {
   updateStatus(text); 
  }
  
  return false;
}

function changeNickTo(newNick)
{
  $.post("/update-nick", "nick=" + newNick.toString(), cleanup);
  $("#current-nick").text(newNick);
}

function updateStatus(text)
{
  $.post('/statuses/update', "status=" + encodeURIComponent(text), function() {
    cleanup();
    updateMessageList();
  });
}

function cleanup()
{
  $("#status-update-field").val("").removeAttr("disabled");
  $("#status-update-field").val("");
}

function updateMessageList()
{
  $.get('/statuses/messages_since', "since_id=" + last_message_id, function(data, status) {
    $("#messages").prepend(data);
    var offset = 0;
    var messages = $(".message");
    $.each(messages, function() {
      var current = $(this);
      var newClass = (offset++ % 2 == 0) ? "odd" : "even";
      current.removeClass("odd even").addClass(newClass);
    });
  });
}