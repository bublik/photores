$(document).ready(function(){
  $("#jsloading").bind("ajaxSend", function(){
    $(this).show();
    $('body').attr('style', 'cursor:progress');
  }).bind("ajaxComplete", function(){
    $(this).hide();
    $('body').attr('style', 'cursor:default');
    $('#flash').not(":empty").slideDown(2000).slideUp(3000, function(){
      $(this).empty()
    }); 
  });
  /*hide flash on load*/
  $('#flash').not(":empty").slideDown(2000).slideUp(3000, function(){
    $(this).empty()
  });
  $('#photo_row a.small').animate({
    "opacity": .5
  });
  $('#photo_row a.small').hover(function() {
    $(this).stop().animate({
      "opacity": 1
    });
  }, function() {
    $(this).stop().animate({
      "opacity": .5
    });
  });

  jQuery.fn.center = function (absolute) {
    return this.each(function () {
      var t = jQuery(this);
      t.css({
        position:    absolute ? 'absolute' : 'fixed',
        left:        '50%',
        top:        '50%',
        zIndex:        '99'
      }).css({
        marginLeft:    '-' + (t.outerWidth() / 2) + 'px',
        marginTop:    '-' + (t.outerHeight() / 2) + 'px'
      });

      if (absolute) {
        t.css({
          marginTop:    parseInt(t.css('marginTop'), 10) + jQuery(window).scrollTop(),
          marginLeft:    parseInt(t.css('marginLeft'), 10) + jQuery(window).scrollLeft()
        });
      }
    });
  };
  try {
    $("a.slide").overlay({
      // each trigger uses the same overlay with the id "gallery"
      target: '#gallery',
      // optional exposing effect
      expose: '#f1f1f1'
    // let the gallery plugin do its magic!
    }).gallery({
      // the plugin accepts its own set of configuration options
      speed: 800
    });
  } catch (exception) {};
  try {
    $(".main_image .desc").show(); //Show Banner
    $(".main_image .block").animate({
      opacity: 0.85
    }, 1 ); //Set Opacity
    $("a.collapse").click(function(){
      $(".main_image .block").slideToggle(); //Toggle the description (slide up and down)
      $("a.collapse").toggleClass("show"); //Toggle the class name of "show" (the hide/show tab)
    });
  } catch (exception) {};
});
