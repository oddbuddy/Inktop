//
//  Stroke.swift
//  InkTop
//
//  Created by Sumit Kumar on 15/11/25.
//

import Cocoa
import CoreGraphics

struct Stroke {
    var points: [CGPoint]
    var color: NSColor
    var width: CGFloat
    var isEraser: Bool = false
    
    init(points: [CGPoint] = [], color: NSColor, width: CGFloat, isEraser: Bool = false) {
        self.points = points
        self.color = color
        self.width = width
        self.isEraser = isEraser
    }
    
    func draw(in context: CGContext) {
        guard points.count > 1 else { return }
        
        context.saveGState()
        
        if isEraser {
            context.setBlendMode(.clear)
        } else {
            context.setBlendMode(.normal)
        }
        
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setShouldAntialias(true)
        context.setLineWidth(width)
        context.setStrokeColor(color.cgColor)
        
        let path = CGMutablePath()
        path.move(to: points[0])
        
        if points.count == 2 {
            path.addLine(to: points[1])
        } else {
            // Use quadratic curves for smooth drawing
            for i in 1..<points.count {
                let currentPoint = points[i]
                if i < points.count - 1 {
                    let nextPoint = points[i + 1]
                    let midPoint = CGPoint(
                        x: (currentPoint.x + nextPoint.x) / 2,
                        y: (currentPoint.y + nextPoint.y) / 2
                    )
                    path.addQuadCurve(to: midPoint, control: currentPoint)
                } else {
                    path.addLine(to: currentPoint)
                }
            }
        }
        
        context.addPath(path)
        context.strokePath()
        
        context.restoreGState()
    }
}
