/**
 * RoomManager - Manages all game rooms
 */
class Room {
  constructor(code) {
    this.code = code;
    this.players = new Map(); // Map<name, { name, ws }>
    this.gameRunning = false;
    this.createdAt = Date.now();
    this.MAX_PLAYERS = 2;
  }

  /**
   * Add a player to the room
   */
  addPlayer(name, ws) {
    if (this.isFull()) {
      throw new Error('Room is full');
    }
    this.players.set(name, { name, ws });
  }

  /**
   * Remove a player from the room
   */
  removePlayer(name) {
    this.players.delete(name);
  }

  /**
   * Check if room is full
   */
  isFull() {
    return this.players.size >= this.MAX_PLAYERS;
  }

  /**
   * Check if room is empty
   */
  isEmpty() {
    return this.players.size === 0;
  }

  /**
   * Check if game can start (all players ready, 2 players)
   */
  canStart() {
    return this.players.size === this.MAX_PLAYERS;
  }

  /**
   * Start the game
   */
  startGame() {
    if (this.canStart()) {
      this.gameRunning = true;
    }
  }

  /**
   * End the game
   */
  endGame() {
    this.gameRunning = false;
  }

  /**
   * Get list of players for broadcasting
   */
  getPlayersList() {
    const players = [];
    let isFirst = true;
    for (const { name } of this.players.values()) {
      players.push({
        name,
        isHost: isFirst, // First player is considered "host"
      });
      isFirst = false;
    }
    return players;
  }

  /**
   * Broadcast message to all players in room
   */
  broadcast(message) {
    const data = JSON.stringify(message);
    for (const { ws } of this.players.values()) {
      if (ws.readyState === 1) { // WebSocket.OPEN = 1
        ws.send(data);
      }
    }
  }

  /**
   * Broadcast message to all players except sender
   */
  broadcastExcept(senderWs, message) {
    const data = JSON.stringify(message);
    for (const { ws } of this.players.values()) {
      if (ws !== senderWs && ws.readyState === 1) {
        ws.send(data);
      }
    }
  }

  /**
   * Send message to specific player
   */
  sendToPlayer(name, message) {
    const player = this.players.get(name);
    if (player && player.ws.readyState === 1) {
      player.ws.send(JSON.stringify(message));
    }
  }
}

export class RoomManager {
  constructor() {
    this.rooms = new Map(); // Map<code, Room>
  }

  /**
   * Generate random room code (4-6 alphanumeric characters)
   */
  generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 4; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    // Ensure uniqueness
    if (this.rooms.has(code)) {
      return this.generateRoomCode();
    }
    return code;
  }

  /**
   * Create a new room
   */
  createRoom(creatorName, creatorWs) {
    const code = this.generateRoomCode();
    const room = new Room(code);
    room.addPlayer(creatorName, creatorWs); // Creator joins with their WebSocket
    this.rooms.set(code, room);
    return room;
  }

  /**
   * Get an existing room
   */
  getRoom(code) {
    return this.rooms.get(code);
  }

  /**
   * Delete a room
   */
  deleteRoom(code) {
    this.rooms.delete(code);
  }

  /**
   * Get all active rooms (for monitoring/logging)
   */
  getAllRooms() {
    return Array.from(this.rooms.values());
  }

  /**
   * Clean up empty/old rooms (can be called periodically)
   */
  cleanup() {
    const now = Date.now();
    const oneHourMs = 60 * 60 * 1000;

    for (const [code, room] of this.rooms.entries()) {
      // Delete rooms that are empty OR inactive for 1+ hour
      if (room.isEmpty() || (now - room.createdAt > oneHourMs)) {
        this.rooms.delete(code);
        console.log(`Cleaned up room: ${code}`);
      }
    }
  }
}
