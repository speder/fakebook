(function($) {
  /*
   * Enter here
   */
  $.fn.fakebook = function(options) {
    return $(this).each(function() {
      $(this).transpose().colorize().titleize();
    });
  };
  /*
   * Insert title into HEAD and BODY
   */
  $.fn.titleize = function(options) {
    return $(this).each(function() {
      var title = $(this).attr("data-title");
      $('head').prepend('<title>'+title+'</title>');
      $('body').prepend('<div id="title">'+title+'</div>');
    });
  };
  /*
   * Free the inner interior decorator
   */
  $.fn.colorize = function(options) {
    var colors = [
        "aliceblue",
        "antiquewhite",
        "aqua",
        "aquamarine",
        "azure",
        "beige",
        "bisque",
        "black",
        "blanchedalmond",
        "blue",
        "blueviolet",
        "brown",
        "burlywood",
        "cadetblue",
        "chartreuse",
        "chocolate",
        "coral",
        "cornflowerblue",
        "cornsilk",
        "crimson",
        "cyan",
        "darkblue",
        "darkcyan",
        "darkgoldenrod",
        "darkgray",
        "darkgreen",
        "darkkhaki",
        "darkmagenta",
        "darkolivegreen",
        "darkorange",
        "darkorchid",
        "darkred",
        "darksalmon",
        "darkseagreen",
        "darkslateblue",
        "darkslategray",
        "darkturquoise",
        "darkviolet",
        "deeppink",
        "deepskyblue",
        "dimgray",
        "dodgerblue",
        "firebrick",
        "floralwhite",
        "forestgreen",
        "fuchsia",
        "gainsboro",
        "ghostwhite",
        "gold",
        "goldenrod",
        "gray",
        "green",
        "greenyellow",
        "honeydew",
        "hotpink",
        "indianred",
        "indigo",
        "ivory",
        "khaki",
        "lavender",
        "lavenderblush",
        "lawngreen",
        "lemonchiffon",
        "lightblue",
        "lightcoral",
        "lightcyan",
        "lightgoldenrodyellow",
        "lightgray",
        "lightgreen",
        "lightpink",
        "lightsalmon",
        "lightseagreen",
        "lightskyblue",
        "lightslategray",
        "lightsteelblue",
        "lightyellow",
        "lime",
        "limegreen",
        "linen",
        "magenta",
        "maroon",
        "mediumaquamarine",
        "mediumblue",
        "mediumorchid",
        "mediumpurple",
        "mediumseagreen",
        "mediumslateblue",
        "mediumspringgreen",
        "mediumturquoise",
        "mediumvioletred",
        "midnightblue",
        "mintcream",
        "mistyrose",
        "moccasin",
        "navajowhite",
        "navy",
        "oldlace",
        "olive",
        "olivedrab",
        "orange",
        "orangered",
        "orchid",
        "palegoldenrod",
        "palegreen",
        "paleturquoise",
        "palevioletred",
        "papayawhip",
        "peachpuff",
        "peru",
        "pink",
        "plum",
        "powderblue",
        "purple",
        "red",
        "rosybrown",
        "royalblue",
        "saddlebrown",
        "salmon",
        "sandybrown",
        "seagreen",
        "seashell",
        "sienna",
        "silver",
        "skyblue",
        "slateblue",
        "slategray",
        "snow",
        "springgreen",
        "steelblue",
        "tan",
        "teal",
        "thistle",
        "tomato",
        "turquoise",
        "violet",
        "wheat",
        "white",
        "whitesmoke",
        "yellow",
        "yellowgreen"
    ];
    return $(this).each(function() {
      var colorSelects = '<div id="color"><select name="background"></select><select name="lyric"></select><select name="chord"></select></div>';
      $('body').append(colorSelects);
      $('#color select').each(function() {
	      var select = $(this);
	      for (i = 0; i < colors.length; i += 1) {
	        select.append('<option style="color:'+colors[i]+'">'+colors[i]+'</option>');
	      };
        switch(select.attr('name')) {
          case 'chord':
            select.val('royalblue'); 
            break;
          case 'lyric':
            select.val('black'); 
            break;
          default: // background
            select.val('white');
        }  
	      select.change(function() {
	        var color = $(this).val();
          switch($(this).attr('name')) {
            case 'chord':
              $('body span.c').css('color', color);
              break;
            case 'lyric':
              $('body span').not('.c').css('color', color);
              break;
            default: // background
              $('body').css('background-color', color);
          }  
	      });
      });
    });
  };
/*!
 * jQuery Chord Transposer plugin v1.0
 * http://codegavin.com/projects/transposer
 *
 * Copyright 2010, Jesse Gavin
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://codegavin.com/license
 *
 * Date: Sat Jun 26 21:27:00 2010 -0600
 */
  $.fn.transpose = function(options) {
    var opts = $.extend({}, $.fn.transpose.defaults, options);
    
    var currentKey = null;
    
    var keys = [
      { name: 'Ab',  value: 0,   type: 'F', rel: 'Fm',  menu: 1 },
      { name: 'A',   value: 1,   type: 'N', rel: 'F#m', menu: 1 },
      { name: 'A#',  value: 2,   type: 'S', rel: 'Gm',  menu: 0 },
      { name: 'Bb',  value: 2,   type: 'F', rel: 'Gm',  menu: 1 },
      { name: 'B',   value: 3,   type: 'N', rel: 'G#m', menu: 1 },
      { name: 'Cb',  value: 3,   type: 'F', rel: 'Abm', menu: 0 },
      { name: 'C',   value: 4,   type: 'N', rel: 'Am',  menu: 1 },
      { name: 'C#',  value: 5,   type: 'S', rel: 'A#m', menu: 0 },
      { name: 'Db',  value: 5,   type: 'F', rel: 'Bbm', menu: 1 },
      { name: 'D',   value: 6,   type: 'N', rel: 'Bm',  menu: 1 },
      { name: 'D#',  value: 7,   type: 'S', rel: 'B#m', menu: 0 },
      { name: 'Eb',  value: 7,   type: 'F', rel: 'Cm',  menu: 1 },
      { name: 'E',   value: 8,   type: 'N', rel: 'C#m', menu: 1 },
      { name: 'F',   value: 9,   type: 'N', rel: 'Dm',  menu: 1 },
      { name: 'F#',  value: 10,  type: 'S', rel: 'D#m', menu: 1 },
      { name: 'Gb',  value: 10,  type: 'F', rel: 'Ebm', menu: 0 },
      { name: 'G',   value: 11,  type: 'N', rel: 'Em',  menu: 1 },
      { name: 'G#',  value: 0,   type: 'S', rel: 'E#m', menu: 0 }
    ];
  
    var getKeyByName = function (name) {
        if (name.charAt(name.length-1) == "m") {
          name = name.substring(0, name.length-1);
        }
        for (var i = 0; i < keys.length; i++) {
            if (name == keys[i].name) {
                return keys[i];
            }
        }
    };

    var getChordRoot = function (input) {
        if (input.length > 1 && (input.charAt(1) == "b" || input.charAt(1) == "#"))
            return input.substr(0, 2);
        else
            return input.substr(0, 1);
    };

    var getNewKey = function (oldKey, delta, targetKey) {
        var keyValue = getKeyByName(oldKey).value + delta;

        if (keyValue > 11) {
            keyValue -= 12;
        } else if (keyValue < 0) {
            keyValue += 12;
        }
        
        var i=0;
        if (keyValue == 0 || keyValue == 2 || keyValue == 5 || keyValue == 7 || keyValue == 10) {
            // Return the Flat or Sharp Key
            switch(targetKey.name) {
              case "A":
              case "A#":
              case "B":
              case "C":
              case "C#":
              case "D":
              case "D#":
              case "E":
              case "F#":
              case "G":
              case "G#":
                  for (;i<keys.length;i++) {
                    if (keys[i].value == keyValue && keys[i].type == "S") {
                      return keys[i];
                    }
                  }
              default:
                  for (;i<keys.length;i++) {
                    if (keys[i].value == keyValue && keys[i].type == "F") {
                      return keys[i];
                    }
                  }
            }
        }
        else {
            // Return the Natural Key
            for (;i<keys.length;i++) {
              if (keys[i].value == keyValue) {
                return keys[i];
              }
            }
        }
    };

    var getChordType = function (key) {
        switch (key.charAt(key.length - 1)) {
            case "b":
                return "F";
            case "#":
                return "S";
            default:
              return "N";
        }
    };

    var getDelta = function (oldIndex, newIndex) {
        if (oldIndex > newIndex)
            return 0 - (oldIndex - newIndex);
        else if (oldIndex < newIndex)
            return 0 + (newIndex - oldIndex);
        else
            return 0;
    };

    var transposeSong = function (target, key) {
        var newKey = getKeyByName(key);

        if (currentKey.name == newKey.name) {
          return;
        }

        var delta = getDelta(currentKey.value, newKey.value);
        
        $("span.c", target).each(function (i, el) {
            transposeChord(el, delta, newKey);
        });
        
        currentKey = newKey;
    };

    var transposeChord = function (selector, delta, targetKey) {
        var el = $(selector);
        var oldChord = el.text();
        if (oldChord.match(/^\|(\d\/\d)?$/)) { return }
        var oldChordRoot = getChordRoot(oldChord);
        var newChordRoot = getNewKey(oldChordRoot, delta, targetKey);
        var newChord = newChordRoot.name + oldChord.substr(oldChordRoot.length);
        el.text(newChord);

        var sib = el[0].nextSibling;
        if (sib && sib.nodeType == 3 && sib.nodeValue.length > 0 && sib.nodeValue.charAt(0) != "/") {
            var wsLength = getNewWhiteSpaceLength(oldChord.length, newChord.length, sib.nodeValue.length);
            sib.nodeValue = makeString(" ", wsLength);
        }
    };

    var getNewWhiteSpaceLength = function (a, b, c) {
        if (a > b)
            return (c + (a - b));
        else if (a < b)
            return (c - (b - a));
        else
            return c;
    };

    var makeString = function (s, repeat) {
        var o = [];
        for (var i = 0; i < repeat; i++) o.push(s);
        return o.join("");
    }
    
    
    var isChordLine = function (input) {
        var tokens = input.replace(/\s+/, " ").split(" ");

        // Try to find tokens that aren't chords
        // if we find one we know that this line is not a 'chord' line.
        for (var i = 0; i < tokens.length; i++) {
            if (!$.trim(tokens[i]).length == 0 && !tokens[i].match(opts.chordRegex))
                return false;
        }
        return true;
    };
    
    var wrapChords = function (input) {
        return input.replace(opts.chordReplaceRegex, "<span class='c'>$1</span>");
    };
    
    
    return $(this).each(function() {
    
      var startKey = $(this).attr("data-key");
      if (!startKey || $.trim(startKey) == "") {
        startKey = opts.key;
      }

      if (!startKey || $.trim(startKey) == "") {
        throw("Starting key not defined.");
        return this;
      }
      
      currentKey = getKeyByName(startKey);

      // Build tranpose links ===========================================
      var keyLinks = [];
      $(keys).each(function(i, key) {
          if (key.menu == 1) {
              var key_pair = key.name + "<br />-<br />" + key.rel;
              if (currentKey.name == key.name)
                  keyLinks.push("<a href='#' class='selected'>" + key_pair + "</a>");
              else
                  keyLinks.push("<a href='#'>" + key_pair + "</a>");
          }
      });


      var $this = $(this);
      var keysHtml = $("<div class='transpose-keys'></div>");
      keysHtml.html(keyLinks.join(""));
      $("a", keysHtml).click(function(e) {
          e.preventDefault();
          var key = $(this).text().split('-')[0];
          transposeSong($this, key);
          $(".transpose-keys a").removeClass("selected");
          $(this).addClass("selected");
          return false;
      });
      
      $(this).after(keysHtml);

      var output = [];
      var lines = $(this).text().split("\n");
      var line, tmp = "";

      for (var i = 0; i < lines.length; i++) {
          line = lines[i];

          if (isChordLine(line))
              output.push("<span>" + wrapChords(line) + "</span>");
          else
              output.push("<span>" + line + "</span>");
      };

      $(this).html(output.join("\n"));
    });
  };

  $.fn.transpose.defaults = {
    chordRegex: /^([A-G\|](\d\/\d)?[b\#]?(maj|m|dim|aug|sus|\+|\-)?\d?(b|\#|\+|\-)?\d?)*(\/[A-G][b\#]*)*$/,
    chordReplaceRegex: re=/([A-G\|](\d\/\d)?[b\#]?(maj|m|dim|aug|sus|\+|\-)?\d?(b|\#|\+|\-)?\d?)/g
  };
})(jQuery);
