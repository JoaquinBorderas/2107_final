//
//  PKDrawing+Extensions.swift
//  CanvasConnect
//
//  Created by Joaquín Borderas Ochoa on 2023-08-07.
//
import PencilKit
import UIKit

extension PKDrawing {
    func toUIImage() -> UIImage {
        let drawingBounds = self.bounds
        
        let renderer = UIGraphicsImageRenderer(size: drawingBounds.size)
        return renderer.image { (context) in
            let rect = CGRect(origin: .zero, size: drawingBounds.size)
            let image = self.image(from: drawingBounds, scale: UIScreen.main.scale)
            image.draw(in: rect)
        }
    }
}
