var utils = {};

utils.page = function(index, max) {
  if(arguments.length == 2) {
    if(isNaN(index) || index < 1) index = 1;
    if(index > max) index = max;
    location.hash = "#" + index;
  }
  else if(arguments.length == 1) {
    location.hash = "#" + index;
  }
  else {
    var index = parseInt(location.hash.substr(1));
    if(isNaN(index) || index < 1) index = 1;
    return index;
  }
}

utils.scrollDistanceFromBottom = function() {
  return utils.pageHeight() - (window.pageYOffset + self.innerHeight);
}

utils.pageHeight = function() {
  return $("body").height();
}

utils.nearBottomOfPage = function() {
  return utils.scrollDistanceFromBottom() < 250;
}