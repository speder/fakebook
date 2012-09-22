(function( $ )  {
  var defaults = {};

  $.fn.showStatus = function( options ) {
    var opts = $.extend( {}, defaults, options );

    return this.each(function() {
      // if ( this.status ) { return false; }

      var $container = $( this );

      var self = {
        initialize: function() {
          $.getJSON(
            opts.url,
            function( json ) {
              $container.each(function() {
                var $modified = $( this ).show().find( 'ol:first' );

                $modified.slideUp().children().remove();
                $( json ).each( function( i, e ) {
                  $modified.append( '<li><a href="' + e[0] + '">'+ e[1] + '</a></li>' );
                });

                $modified.slideDown();
              });
            }
          );
        }
      };

      this.status = self;
      self.initialize();
    });
  };
})( jQuery );
