(function( $ ) {
  var defaults = {};
  
  $.fn.pubsub = function( options ) {
    var opts = $.extend( {}, defaults, options );

    return this.each(function() {
      if ( this.pubsub ) { return false; }

      var $container = $( this ),
          source = new EventSource( opts.url ),
          $controls = $( opts.controls );

      var self = {
        initialize: function() {
          function add(data) {
            $( '<li>' + data + '</li>' ).appendTo( $container );
          }

          function replace(data) {
            $container.children( ':last' ).text( data );
          }

          function done() {
            source.close();
            $controls.show();
          }

          function log(str) {
            if ( window.console && window.console.log ) {
              window.console.log( str );
            }
          }

          source.addEventListener('open', function(e) {
            log('open');
            add('Start');
          }, false);

          source.addEventListener('add', function(e) {
            log('add ' + e.data);
            add(e.data);
          }, false);

          source.addEventListener('replace', function(e) {
            log('replace ' + e.data);
            replace(e.data);
          }, false);

          source.addEventListener('close', function(e) {
            log('close ' + e.data);
            add(e.data)
            done();
          }, false);

          source.addEventListener('error', function(e) {
            log('error');
            add('Error');
            if (e.readyState == EventSource.CLOSED) {
              log('closed');
              add('Closed from error');
              done();
            }
          }, false);
        }
      };

      this.pubsub = self;
      self.initialize();
    });
  };

})( jQuery );
