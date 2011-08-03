function ng(id) {
  $("." + id).animate({ opacity: "hide" }, "slow");
  if($.cookie == null)
    $.cookie('ng') = id
  else
    $.cookie('ng') = $.cookie('ng') + "," + id
}

function dong() {
}
