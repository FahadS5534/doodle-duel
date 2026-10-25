package com.doodleduel.drawing;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class DrawingStateServiceTest {

    private DrawingStateService drawingService;
    private UUID roomId;

    @BeforeEach
    void setUp() {
        drawingService = new DrawingStateService();
        roomId = UUID.randomUUID();
    }

    @Test
    void testRecordStrokeAndUndo() {
        DrawingStroke stroke1 = new DrawingStroke("s1", "#FF5733", 4.0, "PEN", List.of(new DrawingPoint(0.1, 0.2)), false);
        DrawingStroke stroke2 = new DrawingStroke("s2", "#2EC4B6", 6.0, "BRUSH", List.of(new DrawingPoint(0.5, 0.6)), true);

        drawingService.recordStroke(roomId, stroke1);
        drawingService.recordStroke(roomId, stroke2);

        List<DrawingStroke> snapshot = drawingService.getCanvasSnapshot(roomId);
        assertEquals(2, snapshot.size());

        // Undo
        boolean undone = drawingService.undoLastStroke(roomId);
        assertTrue(undone);
        assertEquals(1, drawingService.getCanvasSnapshot(roomId).size());
        assertEquals("s1", drawingService.getCanvasSnapshot(roomId).get(0).getStrokeId());

        // Clear
        drawingService.clearCanvas(roomId);
        assertTrue(drawingService.getCanvasSnapshot(roomId).isEmpty());
    }

    @Test
    void testAppendPointsToExistingStroke() {
        DrawingStroke initial = new DrawingStroke("s1", "#FF5733", 4.0, "PEN", List.of(new DrawingPoint(0.1, 0.1)), false);
        drawingService.recordStroke(roomId, initial);

        DrawingStroke chunk = new DrawingStroke("s1", "#FF5733", 4.0, "PEN", List.of(new DrawingPoint(0.2, 0.2)), true);
        drawingService.recordStroke(roomId, chunk);

        List<DrawingStroke> snapshot = drawingService.getCanvasSnapshot(roomId);
        assertEquals(1, snapshot.size());
        assertEquals(2, snapshot.get(0).getPoints().size());
        assertTrue(snapshot.get(0).isFinished());
    }
}
