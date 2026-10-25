package com.doodleduel.websocket;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class GameEvent {

    private UUID eventId;
    private String eventType;
    private UUID roomId;
    private UUID matchId;
    private Integer roundNumber;
    private UUID senderId;
    private String senderName;
    private Instant serverTimestamp;
    private Object payload;

    public GameEvent() {
        this.eventId = UUID.randomUUID();
        this.serverTimestamp = Instant.now();
    }

    public GameEvent(String eventType, UUID roomId, UUID matchId, Integer roundNumber, UUID senderId, String senderName, Object payload) {
        this.eventId = UUID.randomUUID();
        this.eventType = eventType;
        this.roomId = roomId;
        this.matchId = matchId;
        this.roundNumber = roundNumber;
        this.senderId = senderId;
        this.senderName = senderName;
        this.serverTimestamp = Instant.now();
        this.payload = payload;
    }

    public UUID getEventId() {
        return eventId;
    }

    public void setEventId(UUID eventId) {
        this.eventId = eventId;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public UUID getRoomId() {
        return roomId;
    }

    public void setRoomId(UUID roomId) {
        this.roomId = roomId;
    }

    public UUID getMatchId() {
        return matchId;
    }

    public void setMatchId(UUID matchId) {
        this.matchId = matchId;
    }

    public Integer getRoundNumber() {
        return roundNumber;
    }

    public void setRoundNumber(Integer roundNumber) {
        this.roundNumber = roundNumber;
    }

    public UUID getSenderId() {
        return senderId;
    }

    public void setSenderId(UUID senderId) {
        this.senderId = senderId;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public Instant getServerTimestamp() {
        return serverTimestamp;
    }

    public void setServerTimestamp(Instant serverTimestamp) {
        this.serverTimestamp = serverTimestamp;
    }

    public Object getPayload() {
        return payload;
    }

    public void setPayload(Object payload) {
        this.payload = payload;
    }
}
