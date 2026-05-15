import { WebSocketServer } from 'ws';
import { createServer } from 'http';
import { RoomManager } from './roomManager.js';

const PORT = process.env.PORT || 8080;
const server = createServer();
const wss = new WebSocketServer({ server, path: '/ws' });
const roomManager = new RoomManager();

console.log(`Starting Tetris Multiplayer Server on port ${PORT}`);

// Client connection handler
wss.on('connection', (ws) => {
  console.log('New client connected');
  let clientRoom = null;
  let clientName = null;

  // Send initial connection acknowledgment
  ws.send(JSON.stringify({ type: 'connected', message: 'Connected to server' }));

  // Message handler
  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data);
      console.log('Received message:', message.type, 'from', clientName);

      switch (message.type) {
        case 'create_room': {
          const { name } = message;
          clientName = name;
          const room = roomManager.createRoom(name, ws);
          clientRoom = room.code;

          // Send room created confirmation
          ws.send(JSON.stringify({
            type: 'room_created',
            roomCode: room.code,
            players: room.getPlayersList(),
          }));

          console.log(`Room created: ${clientRoom} by ${name}`);
          break;
        }

        case 'join': {
          const { roomCode, name } = message;
          clientName = name;
          const room = roomManager.getRoom(roomCode);

          if (!room) {
            ws.send(JSON.stringify({
              type: 'error',
              message: 'Room not found',
            }));
            break;
          }

          if (room.isFull()) {
            ws.send(JSON.stringify({
              type: 'error',
              message: 'Room is full',
            }));
            break;
          }

          clientRoom = roomCode;
          room.addPlayer(name, ws);

          // Broadcast updated player list to room
          room.broadcast({
            type: 'players_update',
            players: room.getPlayersList(),
          });

          console.log(`${name} joined room ${roomCode}`);
          break;
        }

        case 'start_game': {
          if (!clientRoom) {
            ws.send(JSON.stringify({ type: 'error', message: 'Not in a room' }));
            break;
          }

          const room = roomManager.getRoom(clientRoom);
          if (!room) break;

          room.broadcast({
            type: 'start_game',
          });

          room.startGame();
          console.log(`Game started in room ${clientRoom}`);
          break;
        }

        case 'board_update': {
          if (!clientRoom) break;

          const room = roomManager.getRoom(clientRoom);
          if (!room) break;

          // Broadcast board to opponent(s)
          room.broadcastExcept(ws, {
            type: 'board_update',
            board: message.board,
            playerName: clientName,
          });

          break;
        }

        case 'i_lost': {
          if (!clientRoom) break;

          const room = roomManager.getRoom(clientRoom);
          if (!room) break;

          // Notify opponent that current player lost
          room.broadcastExcept(ws, {
            type: 'you_win',
            reason: 'Opponent Lost!',
          });

          // End game for this room
          room.endGame();
          console.log(`${clientName} lost in room ${clientRoom}`);
          break;
        }

        default:
          console.log('Unknown message type:', message.type);
      }
    } catch (error) {
      console.error('Message handling error:', error);
    }
  });

  // Client disconnection handler
  ws.on('close', () => {
    console.log(`Client ${clientName} disconnected from room ${clientRoom}`);

    if (clientRoom) {
      const room = roomManager.getRoom(clientRoom);
      if (room) {
        room.removePlayer(clientName);

        // If room is empty, delete it
        if (room.isEmpty()) {
          roomManager.deleteRoom(clientRoom);
          console.log(`Room ${clientRoom} deleted (empty)`);
        } else {
          // Notify remaining players of disconnection
          room.broadcast({
            type: 'player_disconnected',
            playerName: clientName,
          });

          // If game was running, end it
          if (room.gameRunning) {
            room.endGame();
            room.broadcast({
              type: 'you_win',
              reason: 'Opponent Disconnected!',
            });
          }
        }
      }
    }
  });

  // Error handler
  ws.on('error', (error) => {
    console.error('WebSocket error:', error);
  });
});

// Start server
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server listening on ws://0.0.0.0:${PORT}/ws`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});
