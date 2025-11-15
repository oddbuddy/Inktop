//
//  DrawingManager.swift
//  InkTop
//
//  Created by Sumit Kumar on 15/11/25.
//

import Cocoa

class DrawingManager {
    private(set) var strokes: [Stroke] = []
    private var undoneStrokes: [Stroke] = []
    
    var currentColor: NSColor = .red
    var currentWidth: CGFloat = 3.0
    var isEraserMode: Bool = false
    var eraserMode: EraserMode = .stroke
    var isPaused: Bool = false
    
    enum EraserMode {
        case stroke  // Erase entire strokes
        case pixel   // Erase by pixel
    }
    
    // Add a new stroke
    func addStroke(_ stroke: Stroke) {
        strokes.append(stroke)
        undoneStrokes.removeAll() // Clear redo stack when new action is performed
    }
    
    // Undo last stroke
    func undo() {
        guard let lastStroke = strokes.popLast() else { return }
        undoneStrokes.append(lastStroke)
    }
    
    // Redo last undone stroke
    func redo() {
        guard let lastUndone = undoneStrokes.popLast() else { return }
        strokes.append(lastUndone)
    }
    
    // Clear all strokes
    func clearAll() {
        strokes.removeAll()
        undoneStrokes.removeAll()
    }
    
    // Check if a point intersects with any stroke (for stroke eraser mode)
    func findStrokeAt(point: CGPoint, threshold: CGFloat = 10.0) -> Int? {
        for (index, stroke) in strokes.enumerated().reversed() {
            for strokePoint in stroke.points {
                let distance = hypot(point.x - strokePoint.x, point.y - strokePoint.y)
                if distance <= threshold {
                    return index
                }
            }
        }
        return nil
    }
    
    // Remove stroke at index
    func removeStroke(at index: Int) {
        guard index >= 0 && index < strokes.count else { return }
        strokes.remove(at: index)
    }
    
    // Create current stroke with current settings
    func createStroke(with points: [CGPoint]) -> Stroke {
        return Stroke(
            points: points,
            color: currentColor,
            width: isEraserMode ? currentWidth * 2 : currentWidth,
            isEraser: isEraserMode && eraserMode == .pixel
        )
    }
}
