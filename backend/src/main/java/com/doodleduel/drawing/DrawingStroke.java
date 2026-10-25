package com.doodleduel.drawing;

import java.util.ArrayList;
import java.util.List;

public class DrawingStroke {

    private String strokeId;
    private String color = "#FF5733";
    private double brushSize = 4.0;
    private String tool = "PEN"; // PEN, BRUSH, GLOW, FILL, ERASER
    private List<DrawingPoint> points = new ArrayList<>();
    private boolean isFinished = false;

    public DrawingStroke() {
    }

    public DrawingStroke(String strokeId, String color, double brushSize, String tool, List<DrawingPoint> points, boolean isFinished) {
        this.strokeId = strokeId;
        this.color = color;
        this.brushSize = brushSize;
        this.tool = tool;
        this.points = points != null ? points : new ArrayList<>();
        this.isFinished = isFinished;
    }

    public String getStrokeId() {
        return strokeId;
    }

    public void setStrokeId(String strokeId) {
        this.strokeId = strokeId;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public double getBrushSize() {
        return brushSize;
    }

    public void setBrushSize(double brushSize) {
        this.brushSize = brushSize;
    }

    public String getTool() {
        return tool;
    }

    public void setTool(String tool) {
        this.tool = tool;
    }

    public List<DrawingPoint> getPoints() {
        return points;
    }

    public void setPoints(List<DrawingPoint> points) {
        this.points = points;
    }

    public boolean isFinished() {
        return isFinished;
    }

    public void setFinished(boolean finished) {
        isFinished = finished;
    }
}
