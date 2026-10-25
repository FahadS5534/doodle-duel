import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

class StompService {
  static final StompService _instance = StompService._internal();
  factory StompService() => _instance;
  StompService._internal();

  StompClient? _client;
  final SecureStorageService _storage = SecureStorageService();

  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get isConnectedStream => _connectionStateController.stream;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Stream controllers for room channels
  final _lobbyEventsController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get lobbyEvents => _lobbyEventsController.stream;

  final _gameEventsController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get gameEvents => _gameEventsController.stream;

  final _drawingEventsController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get drawingEvents => _drawingEventsController.stream;

  final _scoreEventsController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get scoreEvents => _scoreEventsController.stream;

  final _privateNotificationsController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get privateNotifications => _privateNotificationsController.stream;

  final List<StompUnsubscribe> _activeSubscriptions = [];

  Future<void> connect() async {
    if (_client != null && _client!.connected) {
      return;
    }

    final token = await _storage.getToken() ?? '';

    _client = StompClient(
      config: StompConfig(
        url: AppConfig.wsUrl,
        onConnect: _onConnectCallback,
        beforeConnect: () async {
          debugPrint('STOMP: Connecting to ${AppConfig.wsUrl}...');
        },
        onWebSocketError: (dynamic error) {
          debugPrint('STOMP WebSocket Error: $error');
          _isConnected = false;
          _connectionStateController.add(false);
        },
        onStompError: (StompFrame frame) {
          debugPrint('STOMP Frame Error: ${frame.body}');
        },
        onDisconnect: (StompFrame frame) {
          debugPrint('STOMP Disconnected');
          _isConnected = false;
          _connectionStateController.add(false);
        },
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
          'token': token,
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    _client!.activate();
  }

  void _onConnectCallback(StompFrame frame) {
    debugPrint('STOMP Connected successfully!');
    _isConnected = true;
    _connectionStateController.add(true);

    // Subscribe to personal private notifications queue
    _client?.subscribe(
      destination: '/user/queue/notifications',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!) as Map<String, dynamic>;
            _privateNotificationsController.add(data);
          } catch (e) {
            debugPrint('Error parsing notification frame: $e');
          }
        }
      },
    );
  }

  void subscribeToRoom(String roomId) {
    if (_client == null || !_client!.connected) {
      connect().then((_) {
        _doSubscribeToRoom(roomId);
      });
    } else {
      _doSubscribeToRoom(roomId);
    }
  }

  void _doSubscribeToRoom(String roomId) {
    unsubscribeAll();

    // 0. Private user notifications queue (for secret word prompt & personal sync)
    final unsubNotif = _client?.subscribe(
      destination: '/user/queue/notifications',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!) as Map<String, dynamic>;
            _privateNotificationsController.add(data);
          } catch (e) {
            debugPrint('Error parsing notification frame: $e');
          }
        }
      },
    );
    if (unsubNotif != null) _activeSubscriptions.add(unsubNotif);

    // 1. Lobby topic
    final unsubLobby = _client?.subscribe(
      destination: '/topic/rooms/$roomId/lobby',
      callback: (frame) => _handleFrame(frame, _lobbyEventsController),
    );
    if (unsubLobby != null) _activeSubscriptions.add(unsubLobby);

    // 2. Game phase topic
    final unsubGame = _client?.subscribe(
      destination: '/topic/rooms/$roomId/game',
      callback: (frame) => _handleFrame(frame, _gameEventsController),
    );
    if (unsubGame != null) _activeSubscriptions.add(unsubGame);

    // 3. Drawing strokes topic
    final unsubDrawing = _client?.subscribe(
      destination: '/topic/rooms/$roomId/drawing',
      callback: (frame) => _handleFrame(frame, _drawingEventsController),
    );
    if (unsubDrawing != null) _activeSubscriptions.add(unsubDrawing);

    // 4. Scores & Guess feed topic
    final unsubScores = _client?.subscribe(
      destination: '/topic/rooms/$roomId/scores',
      callback: (frame) => _handleFrame(frame, _scoreEventsController),
    );
    if (unsubScores != null) _activeSubscriptions.add(unsubScores);

    // Request full sync
    requestSync(roomId);
  }

  void _handleFrame(StompFrame frame, StreamController<Map<String, dynamic>> controller) {
    if (frame.body != null) {
      try {
        final data = jsonDecode(frame.body!) as Map<String, dynamic>;
        controller.add(data);
      } catch (e) {
        debugPrint('Error decoding STOMP message: $e');
      }
    }
  }

  void sendReady(String roomId) {
    _send('/app/rooms/$roomId/ready', {});
  }

  void sendStart(String roomId) {
    _send('/app/rooms/$roomId/start', {});
  }

  void sendDrawingPoints(String roomId, Map<String, dynamic> strokeData) {
    _send('/app/rooms/$roomId/drawing', strokeData);
  }

  void sendDrawingUndo(String roomId) {
    _send('/app/rooms/$roomId/drawing/undo', {});
  }

  void sendDrawingClear(String roomId) {
    _send('/app/rooms/$roomId/drawing/clear', {});
  }

  void sendGuess(String roomId, String text) {
    _send('/app/rooms/$roomId/guess', {'text': text});
  }

  void sendReaction(String roomId, String emoji) {
    _send('/app/rooms/$roomId/reaction', {'emoji': emoji});
  }

  void requestSync(String roomId) {
    _send('/app/rooms/$roomId/sync', {});
  }

  void _send(String destination, Map<String, dynamic> body) {
    if (_client != null && _client!.connected) {
      _client!.send(
        destination: destination,
        body: jsonEncode(body),
      );
    } else {
      debugPrint('Cannot send STOMP message, client not connected: $destination');
    }
  }

  void unsubscribeAll() {
    for (var unsub in _activeSubscriptions) {
      try {
        unsub(unsubscribeHeaders: {});
      } catch (_) {}
    }
    _activeSubscriptions.clear();
  }

  void disconnect() {
    unsubscribeAll();
    _client?.deactivate();
    _client = null;
    _isConnected = false;
    _connectionStateController.add(false);
  }
}
