requirejs.config({
    basePath: './',
   
    paths: {
      'jquery': '../bower_components/jquery/jquery.min',
      'socketio': '/Socket.IO/Socket.IO',
      'mustache': '../bower_components/mustache/mustache'
    },
   
    shim: {
      mustache: {
        exports: 'Mustache'
      }
    }
  });
   
  require(['view'], function(view) {});
