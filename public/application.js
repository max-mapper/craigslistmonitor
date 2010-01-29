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
  
  $.fn.placeholder = function(){

     // quit if there's support  for html5 placeholder
    if (this[0] && 'placeholder' in document.createElement('input')) return; 

    this.val( $(this).attr('placeholder'));

    return this
      .live('focusin',function(){

        if ($(this).val() === $(this).attr('placeholder')) {
          $(this).val('');
        }

      }).live('focusout',function(){

        if ($(this).val() === ''){
          $(this).val( $(this).attr('placeholder') );
        }
      });
  }
  
  $('.email[placeholder]').placeholder();
  $('.term[placeholder]').placeholder();
  
	function getSubscriptions() {
		$.getJSON("/manage",
      $(".form").serialize(),
      function(data) {
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
          $('#subscriptions').html('<ul></ul>').show();
          var remove_image = "<img class='subscription_remove' src='/delete.png'/>";
          $.each(data, function(subscription) {
            $('#subscriptions ul').append("<li>" + data[subscription]['subscription'] + remove_image);
          });
        }
    });
	};

  $(".manage").click(function(e) {
    e.preventDefault();
    if (emailIsValid()) {
      $('.hidden_email').val($('.email').val());
      $("#loading").show();
			getSubscriptions();
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
            $('.term').val("");
						getSubscriptions();
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
  
  $('.subscription_remove').live('click', function(e) {
    e.preventDefault();
    item = $(this).parents().filter(':first');
    $(item).hide();
    $('.hidden_term').val($(item).text());
    $.post("/destroy", $('.hidden_form').serialize(), function(data){});
  });
});