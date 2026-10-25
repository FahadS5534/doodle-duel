package com.doodleduel.drawing;

import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class DrawingStateService {

    // Maps roomId -> List of completed and in-progress strokes
    private final Map<UUID, List<DrawingStroke>> roomCanvasMap = new ConcurrentHashMap<>();

    public synchronized void recordStroke(UUID roomId, DrawingStroke strokeChunk) {
        if (strokeChunk == null || strokeChunk.getStrokeId() == null) {
            return;
        }

        List<DrawingStroke> strokes = roomCanvasMap.computeIfAbsent(roomId, k -> Collections.synchronizedList(new ArrayList<>()));

        synchronized (strokes) {
            // Find existing stroke by strokeId
            Optional<DrawingStroke> existingOpt = strokes.stream()
                    .filter(s -> strokeChunk.getStrokeId().equals(s.getStrokeId()))
                    .findFirst();

            if (existingOpt.isPresent()) {
                DrawingStroke existing = existingOpt.get();
                if (strokeChunk.getPoints() != null && !strokeChunk.getPoints().isEmpty()) {
                    existing.getPoints().addAll(strokeChunk.getPoints());
                }
                existing.setFinished(strokeChunk.isFinished());
            } else {
                // New stroke
                DrawingStroke newStroke = new DrawingStroke(
                        strokeChunk.getStrokeId(),
                        strokeChunk.getColor(),
                        strokeChunk.getBrushSize(),
                        strokeChunk.getTool(),
                        new ArrayList<>(strokeChunk.getPoints() != null ? strokeChunk.getPoints() : Collections.emptyList()),
                        strokeChunk.isFinished()
                );
                strokes.add(newStroke);
            }
        }
    }

    public synchronized boolean undoLastStroke(UUID roomId) {
        List<DrawingStroke> strokes = roomCanvasMap.get(roomId);
        if (strokes != null && !strokes.isEmpty()) {
            synchronized (strokes) {
                if (!strokes.isEmpty()) {
                    strokes.remove(strokes.size() - 1);
                    return true;
                }
            }
        }
        return false;
    }

    public synchronized void clearCanvas(UUID roomId) {
        List<DrawingStroke> strokes = roomCanvasMap.get(roomId);
        if (strokes != null) {
            strokes.clear();
        }
    }

    public List<DrawingStroke> getCanvasSnapshot(UUID roomId) {
        List<DrawingStroke> strokes = roomCanvasMap.get(roomId);
        if (strokes == null) {
            return Collections.emptyList();
        }
        synchronized (strokes) {
            return new ArrayList<>(strokes);
        }
    }

    public void resetCanvas(UUID roomId) {
        roomCanvasMap.remove(roomId);
    }
}
