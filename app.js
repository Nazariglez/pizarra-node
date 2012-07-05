
//Inicializamos las variables necesarias.
var express = require('express'),
	app = express.createServer(),
	io = require('socket.io').listen(app);

app.listen(8080); //Establecemos el puerto 8080 en escucha.
io.set('log level',1); //Lo pongo a nivel uno para evitar demasiados logs ajenos a la aplicación.

app.configure(function(){

	//No uso layout en las vistas
	app.set('view options', {
	  layout: false
	});

	//Indicamos el directorio de acceso publico
    app.use(express.static('public'));

});

//Marco la ruta de acceso y la vista a mostrar
app.get('/', function(req, res){
    res.render('index.jade', { 
    	pageTitle: 'Pizarra'
    });
});

//Se ha establecido conexión
io.sockets.on('connection', function(socket) {

	/* Cuando un usuario realiza una acción en el cliente,
	   recibos los datos de la acción en concreto y 
	   envío a todos los demás las coordenadas */

	socket.on('startLine',function(e){
		console.log('Dibujando...');
		io.sockets.emit('down',e);
	});

	socket.on('closeLine',function(e){
		console.log('Trazo Terminado');
		io.sockets.emit('up',e);
	});

	socket.on('draw',function(e){
		io.sockets.emit('move',e);
	});

	socket.on('clean',function(){
		console.log('Pizarra Limpia');
		io.sockets.emit('clean',true);
	});

});