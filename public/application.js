$(document).ready(function() {
  
  function formIsValid() {
    if ($('.text').val() == "") { return false; }
    if (!emailIsValid()) { return false; }
    return true;
  };
  
  function emailIsValid() {
    if ($('.email').val().indexOf("@") < 0) { return false; }
    return true;
  };
  
  $(".manage").click(function(e) {
    e.preventDefault();
    if (emailIsValid()) {
      $(".manage").hide();
      $("#loading").show();
      $.getJSON("/manage",
        $(".form").serialize(),
        function(data){
          $("#loading").hide();
          if (data[0]['subscription'] == "none") {
            $("#messages").addClass('fail');
            $("#messages h1").text(data[0]['message']);
            $("#messages").fadeIn( function() {
              setTimeout( function() {
                $("#messages").fadeOut("fast");
              }, 2000);
            });
          }
          else {
            $('#subscriptions').append('<ul></ul>').show();
            $.each(data, function(subscription) {
              $('#subscriptions ul').append('<li>' + data[subscription]['subscription'] + '</li>');
            });
          }
      });
    } else {
      $("#messages").addClass('fail');
      $("#messages h1").text("Invalid Email. Please Try Again");
      $("#messages").fadeIn( function() {
        setTimeout( function() {
          $("#messages").fadeOut("fast");
        }, 2000);
      });
    }
  });
  
  $(".form").submit(function(e){ 
    e.preventDefault();
    if (formIsValid()) {
      $("#loading").show();
      $.post("/subscribe",
        $(".form").serialize(),
        function(data){
          $("#loading").hide();
          if (data.success) {
            $("#messages").addClass('success');
            $('.text').text("");
          }
          else {
            $("#messages").addClass('fail');
          }
        $("#messages h1").text(data.message);
        $("#messages").fadeIn( function() {
          setTimeout( function() {
            $("#messages").fadeOut("fast");
          }, 2000);
        });
        },
        "json"
      );
    }
    else {
      $("#messages").addClass('fail');
      $("#messages h1").text("Invalid Form. Please Try Again");
      $("#messages").fadeIn( function() {
        setTimeout( function() {
          $("#messages").fadeOut("fast");
        }, 2000);
      });
    }
  });
});