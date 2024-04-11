/**
 * NoobHub node.js server
 * Opensource multiplayer and network messaging for CoronaSDK, Moai, Gideros & LÖVE
 *
 * @usage
 * $ nodejs node.js
 *
 * @authors
 * Igor Korsakov
 * Sergii Tsegelnyk
 *
 * @license WTFPL
 *
 * https://github.com/Overtorment/NoobHub
 *
 **/

const net = require('net');

const cfg = {
  port: 1337,
  wsPort: 2337, // comment out if you don't need websocket bridge
  buffer_size: 1024 * 16, // buffer allocated per each socket client
  sendOwnMessagesBack: true, // if disabled, clients don't get their own messages back
  verbose: true // set to true to capture lots of debug info
};

let Games = {};

/*
    on first player connect, inject socket channel into payload?
    Games consists of:
    "socket_channel_id": {
        "lobby_id": 1234,
        "active": true/false,
        "players": [1, 2, 3, 4, 5, 6], # maybe store their sockets in this?
        "player_statuses": ["connected", "connected", "connecting", "connecting", "connected", "dropped],

    }
*/

// map of join code to channel ID
let socketIdToPlayerId_map = {};
const sockets = {}; // this is where we store all current client socket connections, map of channel ID to game
const suits = ['hearts', 'spades', 'diamonds', 'clubs'];
const ranks = ['2', '3', '4', '5', '6', '7', '9', '10', '11', '12', '13', '14'];
let cards = [];

for (let suit of suits) {
  for (let rank of ranks) {
    cards.push(suit + rank);
  }
}

function randomInt(max) {
  return Math.floor(Math.random() * max);
}

function shuffle(array) {
  let currentIndex = array.length;

  // While there remain elements to shuffle...
  while (currentIndex != 0) {
    // Pick a remaining element...
    let randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex--;

    // And swap it with the current element.
    [array[currentIndex], array[randomIndex]] = [
      array[randomIndex],
      array[currentIndex]
    ];
  }
}

shuffle(cards);

let sendAsWsMessage;

if (cfg.wsPort) {
  function sendAsTcpMessage(payload, channel) {
    const channelSockets = sockets[channel];
    if (!channelSockets) {
      return;
    }
    const subscribers = Object.values(channelSockets);
    for (let sub of subscribers) {
      sub.isConnected && sub.write(payload);
    }
  }

  sendAsWsMessage = require('./ws-server')({
    port: cfg.wsPort,
    verbose: cfg.verbose,
    sendAsTcpMessage,
    sendOwnMessagesBack: cfg.sendOwnMessagesBack
  });
}

const server = net.createServer();

function _log() {
  if (cfg.verbose) console.log.apply(console, arguments);
}

// black magic
process.on('uncaughtException', (err) => {
  _log('Exception: ' + err); // TODO: think we should terminate it on such exception
});

server.on('connection', (socket) => {
  socket.setNoDelay(true);
  socket.setKeepAlive(true, 300 * 1000);
  socket.isConnected = true;
  socket.connectionId = socket.remoteAddress + '-' + socket.remotePort; // unique, used to trim out from sockets hashmap when closing socket
  socket.buffer = Buffer.alloc(cfg.buffer_size);
  socket.buffer.len = 0; // due to Buffer's nature we have to keep track of buffer contents ourself

  _log('New client: ' + socket.remoteAddress + ':' + socket.remotePort);

  socket.on('data', (dataRaw) => {
    // dataRaw is an instance of Buffer as well
    if (dataRaw.length > cfg.buffer_size - socket.buffer.len) {
      _log(
        "Message doesn't fit the buffer. Adjust the buffer size in configuration"
      );
      socket.buffer.len = 0; // trimming buffer
      return false;
    }

    socket.buffer.len += dataRaw.copy(socket.buffer, socket.buffer.len); // keeping track of how much data we have in buffer

    let start;
    let end;
    let str = socket.buffer.slice(0, socket.buffer.len).toString();
    // PROCESS REGISTRATION 1ST
    if (
      (start = str.indexOf('__REGISTER__')) !== -1 &&
      (end = str.indexOf('__ENDREGISTER__')) !== -1
    ) {
      var new_chan = Math.random().toString(36).slice(2);
      while (Games[new_chan]) {
        new_chan = Math.random().toString(36).slice(2);
      }

      var all_cards_shuffled = [...cards];
      shuffle(all_cards_shuffled);
      socket.channel = new_chan;

      var player_hands = {
        1: all_cards_shuffled.slice(0, 8),
        2: all_cards_shuffled.slice(8, 16),
        3: all_cards_shuffled.slice(16, 24),
        4: all_cards_shuffled.slice(24, 32),
        5: all_cards_shuffled.slice(32, 40),
        6: all_cards_shuffled.slice(40, 48)
      };

      var player_id = 1;
      Games[socket.channel] = {
        active: true,
        player_ids: [player_id],
        active_player_id: player_id,
        stealing_from: -1,
        teams: { 0: [], 1: [] },
        player_hands: player_hands
      };

      var team = randomInt(2);
      if (Games[socket.channel].teams[team].length < 3)
        // should always be true when its a game host since new game is being registered
        Games[socket.channel].teams[team].push(player_id);
      socketIdToPlayerId_map[player_id] = socket.connectionId;
      str = str.substr(end + 16); // cut the message and remove the precedant part of the buffer since it can't be processed
      socket.buffer.len = socket.buffer.write(str, 0);
      sockets[socket.channel] = sockets[socket.channel] || {}; // hashmap of sockets  subscribed to the same channel
      sockets[socket.channel][socket.connectionId] = socket;
      _log(
        `Created game at channel ${socket.channel} by player with ID ${Games[socket.channel].active_player_id}`
      );

      console.log('Hand is:');
      console.log(Games[socket.channel].player_hands[player_id]);
      var payload = {
        status: 'ok',
        player_id: player_id,
        join_code: socket.channel,
        active_player_id: Games[socket.channel].active_player_id,
        team: team,
        opponent: team == 0 ? 1 : 0,
        hand: Games[socket.channel].player_hands[player_id]
      };
      socket.isConnected &&
        socket.write(
          '__JSON__START__' + JSON.stringify(payload) + '__JSON__END__'
        ) &&
        _log('Writing ' + JSON.stringify(payload) + 'to client socket');
    } else if (
      (start = str.indexOf('__SUBSCRIBE__')) !== -1 &&
      (end = str.indexOf('__ENDSUBSCRIBE__')) !== -1
    ) {
      socket.channel = str.substring(start + 13, end);
      socket.write('Hello. Noobhub online. \r\n');
      _log(
        `TCP Client ${socket.connectionId} subscribes for channel: ${socket.channel}`
      );

      if (Games[socket.channel].player_ids.length === 6) {
        socket.write('Lobby is full! \r\n');
        _log(`Lobby ${socket.channel} is full... Rejecting connection`);
        return;
      }
      Games[socket.channel].player_ids.sort();
      Games[socket.channel].player_ids.reverse();

      var assigned_player_id = Games[socket.channel].player_ids[0] + 1;
      socketIdToPlayerId_map[assigned_player_id] = socket.connectionId;
      Games[socket.channel].player_ids.reverse();
      Games[socket.channel].player_ids.push(assigned_player_id);

      var team = randomInt(2);
      while (Games[socket.channel].teams[team].length === 3) {
        team = randomInt(2);
      }
      Games[socket.channel].teams[team].push(assigned_player_id);

      str = str.substr(end + 16); // cut the message and remove the precedant part of the buffer since it can't be processed
      socket.buffer.len = socket.buffer.write(str, 0);
      sockets[socket.channel] = sockets[socket.channel] || {}; // hashmap of sockets  subscribed to the same channel
      sockets[socket.channel][socket.connectionId] = socket;

      var payload = {
        status: 'ok',
        player_id: assigned_player_id,
        join_code: socket.channel,
        active_player_id: Games[socket.channel].active_player_id,
        team: team,
        opponent: team == 0 ? 1 : 0,
        hand: Games[socket.channel].player_hands[assigned_player_id]
      };
      socket.isConnected &&
        socket.write(
          '__JSON__START__' + JSON.stringify(payload) + '__JSON__END__'
        ) &&
        _log('Writing ' + JSON.stringify(payload) + 'to client socket');

      if (Games[socket.channel].player_ids.length === 6) {
        // if we have all players, then let everyone know we're good to go
        payload = {
          status: 'begin_game',
          active_player_id: Games[socket.channel].active_player_id,
          // each player's hand
          teams: Games[socket.channel].teams
        };
        const channelSockets = sockets[socket.channel];
        if (channelSockets) {
          const subscribers = Object.values(channelSockets);
          for (let sub of subscribers) {
            if (!cfg.sendOwnMessagesBack && sub === socket) {
              continue;
            }
            sub.isConnected &&
              sub.write(
                '__JSON__START__' + JSON.stringify(payload) + '__JSON__END__'
              ) &&
              _log('Sending ' + JSON.stringify(payload));
          }
        }
      }
    } else if (
      (start = str.indexOf('__STEAL__')) !== -1 &&
      (end = str.indexOf('__ENDSTEAL__')) !== -1
    ) {
      let payload = str.substring(start + 9, end);
      let params = payload.split('&');
      if (params.length !== 3) {
        _log('FATAL: DID NOT RECEIVE 3 PARAMS FOR STEAL');
      }
      // param 0 - stealing player id
      // param 1 - stealing from player id
      // param 2 - card id being stolen
      let stealing_player_id = parseInt(params[0]);
      let stealing_from_player_id = parseInt(params[1]);
      let card_id = params[2];

      let card_idx =
        Games[socket.channel].player_hands[stealing_from_player_id].indexOf(
          card_id
        );

      payload = {
        status: 'steal'
      };
      if (card_idx !== -1) {
        Games[socket.channel].player_hands[stealing_from_player_id].splice(
          card_idx,
          1
        );
        Games[socket.channel].player_hands[stealing_player_id].push(card_id);

        payload['result'] = 'success';
        payload['stolen_card_id'] = card_id;
      } else {
        payload['result'] = 'fail';
        // guess failed, notify all players of active player change
        const channelSockets = sockets[socket.channel];
        if (channelSockets) {
          const subscribers = Object.values(channelSockets);
          for (let sub of subscribers) {
            if (!cfg.sendOwnMessagesBack && sub === socket) {
              continue;
            }
            sub.isConnected &&
              sub.write(
                '__JSON__START__' +
                  JSON.stringify({
                    status: 'switch',
                    active_player_id: stealing_from_player_id
                  }) +
                  '__JSON__END__'
              ) &&
              _log('Sending ' + JSON.stringify(payload));
          }
        }

        Games[socket.channel].active_player_id = stealing_from_player_id;
      }

      sockets[socket.channel][socketIdToPlayerId_map[stealing_player_id]]
        .isConnected &&
        sockets[socket.channel][
          socketIdToPlayerId_map[stealing_player_id]
        ].write(
          '__JSON__START__' + JSON.stringify(payload) + '__JSON__END__'
        ) &&
        _log(
          'wrote ' +
            JSON.stringify(payload) +
            ' to ' +
            stealing_player_id +
            "'s socket"
        );
    }

    let timeToExit = true;
    do {
      // this is for a case when several messages arrived in buffer
      // PROCESS JSON NEXT
      if (
        (start = str.indexOf('__JSON__START__')) !== -1 &&
        (end = str.indexOf('__JSON__END__')) !== -1
      ) {
        const json = str.substr(start + 15, end - (start + 15));
        _log(`TCP Client ${socket.connectionId} posts json: ${json}`);
        str = str.substr(end + 13); // cut the message and remove the precedant part of the buffer since it can't be processed
        socket.buffer.len = socket.buffer.write(str, 0);

        const payload = '__JSON__START__' + json + '__JSON__END__';

        sendAsWsMessage && sendAsWsMessage(payload, socket.channel);
        const channelSockets = sockets[socket.channel];
        if (channelSockets) {
          const subscribers = Object.values(channelSockets);
          for (let sub of subscribers) {
            if (!cfg.sendOwnMessagesBack && sub === socket) {
              continue;
            }
            sub.isConnected && sub.write(payload);
          }
        }
        timeToExit = false;
      } else {
        timeToExit = true;
      } // if no json data found in buffer - then it is time to exit this loop
    } while (!timeToExit);
  }); // end of  socket.on 'data'

  socket.on('error', () => {
    return _destroySocket(socket);
  });
  socket.on('close', () => {
    return _destroySocket(socket);
  });
}); //  end of server.on 'connection'

function _destroySocket(socket) {
  if (
    !socket.channel ||
    !sockets[socket.channel] ||
    !sockets[socket.channel][socket.connectionId]
  )
    return;
  sockets[socket.channel][socket.connectionId].isConnected = false;
  sockets[socket.channel][socket.connectionId].destroy();
  sockets[socket.channel][socket.connectionId].buffer = null;
  delete sockets[socket.channel][socket.connectionId].buffer;
  delete sockets[socket.channel][socket.connectionId];
  _log(
    `${socket.connectionId} has been disconnected from channel ${socket.channel}`
  );

  if (Object.keys(sockets[socket.channel]).length === 0) {
    delete sockets[socket.channel];
    _log('empty channel wasted');
  }
}

server.on('listening', () => {
  console.log(
    `NoobHub on ${server.address().address}:${server.address().port}`
  );
});

server.listen(cfg.port, '127.0.0.1');
