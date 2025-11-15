//
//  OverlayView.swift
//  InkTop
//
//  Created by Sumit Kumar on 15/11/25.
//

import Cocoa
import CoreGraphics

class OverlayView: NSView {
    var drawingManager: DrawingManager
    var currentStrokePoints: [CGPoint] = []
    
    // Offscreen bitmap context for better performance
    private var drawingBitmap: CGContext?
    private var needsFullRedraw = true
    
    init(frame: NSRect, drawingManager: DrawingManager) {
        self.drawingManager = drawingManager
        super.init(frame: frame)
        setupView()
        createDrawingBitmap()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    private func createDrawingBitmap() {
        let scale = window?.backingScaleFactor ?? 2.0
        let pixelWidth = Int(bounds.width * scale)
        let pixelHeight = Int(bounds.height * scale)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        drawingBitmap = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: pixelWidth * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        
        drawingBitmap?.scaleBy(x: scale, y: scale)
        needsFullRedraw = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // Draw from bitmap
        if let bitmap = drawingBitmap, let image = bitmap.makeImage() {
            if needsFullRedraw {
                // Clear and redraw all strokes
                drawingBitmap?.clear(CGRect(origin: .zero, size: bounds.size))
                for stroke in drawingManager.strokes {
                    stroke.draw(in: bitmap)
                }
                needsFullRedraw = false
            }
            
            context.draw(image, in: bounds)
        }
        
        // Draw current stroke being drawn
        if !currentStrokePoints.isEmpty && !drawingManager.isPaused {
            let currentStroke = drawingManager.createStroke(with: currentStrokePoints)
            currentStroke.draw(in: context)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        guard !drawingManager.isPaused else { return }
        
        let location = convert(event.locationInWindow, from: nil)
        
        if drawingManager.isEraserMode && drawingManager.eraserMode == .stroke {
            // Stroke eraser mode - remove entire stroke
            if let strokeIndex = drawingManager.findStrokeAt(point: location) {
                drawingManager.removeStroke(at: strokeIndex)
                needsFullRedraw = true
                needsDisplay = true
            }
        } else {
            // Start new stroke
            currentStrokePoints = [location]
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard !drawingManager.isPaused else { return }
        
        let location = convert(event.locationInWindow, from: nil)
        
        if drawingManager.isEraserMode && drawingManager.eraserMode == .stroke {
            // Continue erasing strokes
            if let strokeIndex = drawingManager.findStrokeAt(point: location) {
                drawingManager.removeStroke(at: strokeIndex)
                needsFullRedraw = true
                needsDisplay = true
            }
        } else {
            // Add point to current stroke
            currentStrokePoints.append(location)
            needsDisplay = true
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        guard !drawingManager.isPaused else { return }
        
        if !currentStrokePoints.isEmpty && !(drawingManager.isEraserMode && drawingManager.eraserMode == .stroke) {
            // Finish current stroke
            let location = convert(event.locationInWindow, from: nil)
            currentStrokePoints.append(location)
            
            let stroke = drawingManager.createStroke(with: currentStrokePoints)
            drawingManager.addStroke(stroke)
            
            // Draw stroke to bitmap
            if let bitmap = drawingBitmap {
                stroke.draw(in: bitmap)
            }
            
            currentStrokePoints.removeAll()
            needsDisplay = true
        }
    }
    
    func refresh() {
        needsFullRedraw = true
        needsDisplay = true
    }
    
    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        createDrawingBitmap()
        refresh()
    }
}
