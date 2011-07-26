// Require jquery

function fixLinks() {
  var scheme = location.protocol;
  if (scheme=="http:" || scheme=="https:") return;
  var links = document.getElementsByTagName("a");
  for (var i = links.length; --i >= 0; ) {
    var link = links[i];
    var href = link.href;
    var hlen = href.length;
    if (hlen > 0 && link.protocol==scheme && href.charAt(hlen-1) == "/")
      links[i].href = href + "index.html";
  }
}

$(document).ready(fixLinks);

