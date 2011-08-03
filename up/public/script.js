function ng(id) {
  hide = true;
  ngid = $.cookie('ng')

  if(ngid == null || ngid == '') {
    hide = true;
    $.cookie('ng', id, { path: '/' })
  } else {
    if(ngid.indexOf(id) == -1) {
      hide = true;
      $.cookie('ng', $.cookie('ng') + "," + id, { path: '/' })
    } else {
      hide = false;
      ngid = ngid.split(',' + id).join('').split(id + ',').join('')
      $.cookie('ng', ngid, { path: '/' })
    }
  }

  res =  $("." + id);
  if(hide) {
    $(".r", res).hide();
    $(".i .n", res).text("unNG");
  } else {
    $(".r", res).show();
    $(".i .n", res).text("NG");
  }
}

function nr() {
  ngid = $.cookie('ng')
  if(ngid != null && ngid != '') {
    selector = "." + $.cookie('ng').split(",").join(", .");
    $(".r", selector).hide();
    $(".i .n", selector).text("unNG");
  }
}

function clear_ng(){
  alert("clear " + $.cookie('ng'));
  $.cookie('ng', '', { path: '/' });
}
