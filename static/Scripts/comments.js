// Require json2.js
// Require jquery 1.5

$(document).ready(function(){
  var api_url = "http://mildred817.free.fr/api/messages.php";
  //var api_url = "/api/messages";
  var main = $(".main");
  if(main && $("head meta[name=x-kind]").attr("content") == "article"){
    var permalink = $("head link[rel=canonical]").attr('href');
    var api_entry = api_url + '?' + escape(permalink);
    var comments = $('<div class="comments">').appendTo(main);
    $("<h2>Comments</h2>").appendTo(comments);
    var comments_container = $("<div>").appendTo(comments);
    
    if(! $.support.cors) {
      $("<p>")
        .text("Sorry, you don't have a browser with XmlHttpRequest enabled for "
        + "cross domain. The web site cannot fetch the comments on the remote "
        + "server.")
        .appendTo(comments_container);
    } else {

      function transform_text(str, parent){
        var str = str.replace("\r\n", "\n").replace("\r", "\n").replace(/\n\n+/, "\n\n");
        var arr = str.split("\n\n");
        for(var i = 0; i < arr.length; i++){
          $("<p>")
            .text(arr[i])
            .appendTo(parent);
        }
      };

      function add_comment(date, data){
        //console.log("Add comment", date, data);
        var comment = $('<div class="comment">').appendTo(comments_container);
        if(typeof data == 'string') {
          $('<p class="meta">')
            .text(date.toLocaleString())
            .appendTo(comment);
          transform_text(data, comment);
        } else {
          $('<p class="meta">')
            .append($("<strong>").text(data.author))
            .append(", " + date.toLocaleString())
            .appendTo(comment);
          transform_text(data.content, comment);
        }
      };
      
      function reload_comments(){
        comments_container.empty();
        $.ajax({type: 'GET', url: api_entry})
          .complete(function(obj){
            var data;
            try {
              data = JSON.parse(obj.responseText);
            } catch (err) {
              data = {status: false, data: err};
            }
            console.log("GET answer", data);
            if (!data.status) {
              $("<p>")
                .addClass("error")
                .text(data.data)
                .appendTo(comments);
            } else {
              for(var i = 0; i < data.data.length; i++){
                var dte = new Date (Date.parse(data.data[i].time));
                var dta = data.data[i].data;
                add_comment(dte, dta);
              }
            }
          });
      }
      
      $('<a href="" class="meta">Reload</a>')
        .appendTo(comments)
        .click(function(event){
          reload_comments();
          event.preventDefault();
        });
      
      reload_comments();
      var form = $('<h3>Reply</h3>'
        + '<form class="comment-reply">'
        +   '<label>Name: <input name="name" type="text" placeholder="Your Name"/></label>'
        +   '<br/>'
        +   '<textarea name="content"></textarea>'
        +   '<br/>'
        +   '<input type="submit" value="Reply"/>'
        + '</form>')
        .appendTo(comments)
        .submit(function(event){
          var i_name = form.find("[name=name]");
          var i_content = form.find("[name=content]");
          var sent_data = {
            'author':  i_name.val(),
            'content': i_content.val()
          };
          $.ajax({
            type:        'POST',
            url:         api_entry,
            data:        JSON.stringify(sent_data),
            contentType: 'application/json'})
            .complete(function(obj){
              var data;
              try {
                data = $.parseJSON(obj.responseText);
              } catch (err) {
                data = {status: false, data: err};
              }
              console.log("POST answer", data);
              if (!data.status) {
                alert(data.data);
              } else {
                add_comment(new Date, sent_data);
                i_content.val("");
              }
            });
          event.preventDefault();
        });
    }
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

