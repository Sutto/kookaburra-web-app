var last_message_id = 0;
var updateTimeout;

if(typeof(auto_update) == "undefined") auto_update = false;

$(function() {
  // Bind our event handler
  $("#status-update-field").keypress(updateCharactersTotal);
  $("#update-status-form").submit(statusSubmitHandler);
  $('a[rel*=facebox]').facebox();
  updateCharactersTotal();
  // Now, periodically check for updates.
  if(auto_update) updateTimeout = setTimeout(updateMessageList, 10000);
})

function updateCharactersTotal()
{
  var size = $("#status-update-field").val().length;
  $("#details-of-message").removeClass("normal middle high over").addClass(classForLength(size));
  $("#characters-used").text(size);
}

// normal middle high over
function classForLength(size) {
  if      (size <= 50)  return "normal";
  else if (size <= 100) return "middle";
  else if (size <= 140) return "high";
  else                  return "over";
}


function setReplyTo(username)
{
  var oldValue = $("#status-update-field").val();
  if(oldValue.indexOf("@" + username + " ") == -1)
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
    if(auto_update) {
      clearTimeout(updateTimeout);
      updateMessageList();
    }
    else window.location = window.location; // Manually refresh otherwise
  });
}

function cleanup()
{
  $("#status-update-field").val("").removeAttr("disabled");
  $("#status-update-field").val("");
  updateCharactersTotal();
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
  // Finally, schedule it to run again.
  updateTimeout = setTimeout(updateMessageList, 10000);
}