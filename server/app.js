const app = require('express')();
const path = require('path');
app.all('/', (req, res) => {
	res.sendfile(path.resolve('../js/app.html'));
});
const server = require('http').createServer(app);
const io = require('socket.io')(server);
io.on('connection', (socket) => {
	console.log('connection', socket.id);
	socket.broadcast.emit('news', {type: 'new user connected!', id: socket.id});
	socket.on('msg', (data) => {
		console.log('msg', data);
		socket.broadcast.emit('news', {type: 'msg from another user', data, from: socket.id});
	});
});
// setInterval(() => {
// 	io.emit('news', {time: Date.now()});
// }, 6000);
server.listen(3000);