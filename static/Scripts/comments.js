

$(document).ready(function(){
  //var api_url = "http://mildred817.free.fr/api/messages.php";
  var api_url = "/api/messages";
  var main = $(".main");
  if(main.has(".article")){
    var permalink = $("head link[rel=canonical]").attr('href');
    var api_entry = api_url + '?' + escape(permalink);
    var comments = $("<div>")
      .addClass("comments")
      .appendTo(main);
    $("<h2>")
      .text("Comments")
      .appendTo(comments);
    var comments_container = $("<div>")
      .appendTo(comments);
    var add_comment = function(date, data){
      var comment = $("<div>")
        .addClass("comment")
        .appendTo(comments_container);
      $("<p>")
        .addClass("meta")
        .text(date.toLocaleString())
        .appendTo(comments_container);
      $("<p>")
        .text(data)
        .appendTo(comments_container);
    };
    $("<hr>").appendTo(comments);
    var form = $("<form>")
      .appendTo(comments);
    $("<textarea>").appendTo(form);
    $("<input>")
      .attr("type", "submit")
      .attr("value", "Reply")
      .appendTo(form);
    $.get(api_entry, function(data){
      console.log(data);
      if (!data.status) {
        $("<p>")
          .addClass("error")
          .text(data.data)
          .appendTo(comments);
      } else {
        for(var i = 0; i < data.data.length; i++){
          add_comment(Date.parse(dta.time), data.data[i]);
        }
      }
    }, "json");
    form.submit(function(event){
      var text = form.find("textarea").text();
      add_comment(new Date, text);
      $.post(api_entry, text, function(data){
        console.log(data);
        if (!data.status) {
          alert(data.data);
        }
      }, "json");
      event.preventDefault();
    });
  }
});

/**
 * Date.parse with progressive enhancement for ISO-8601, version 2
 * © 2010 Colin Snover <http://zetafleet.com>
 * Released under MIT license.
 * <http://zetafleet.com/blog/javascript-dateparse-for-iso-8601>
 */
(function () {
    var origParse = Date.parse;
    Date.parse = function (date) {
        var timestamp = origParse(date), minutesOffset = 0, struct;
        if (isNaN(timestamp) && (struct = /^(\d{4}|[+\-]\d{6})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{3,}))?)?(?:(Z)|([+\-])(\d{2})(?::?(\d{2}))?))?/.exec(date))) {
            if (struct[8] !== 'Z') {
                minutesOffset = +struct[10] * 60 + (+struct[11]);
                
                if (struct[9] === '+') {
                    minutesOffset = 0 - minutesOffset;
                }
            }
            
            timestamp = Date.UTC(+struct[1], +struct[2] - 1, +struct[3], +struct[4], +struct[5] + minutesOffset, +struct[6], +struct[7].substr(0, 3));
        }
        
        return timestamp;
    };
}());

