//
//  ShapeNodes.swift
//  ARKitInteraction
//
//  Created by Jason Jobe on 3/25/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import SceneKit

public extension SCNNode {
    static var SelectionMarkerName = "selection_mark"
    
    static func tube(innerRadius: CGFloat, outerRadius: CGFloat, height: CGFloat, content: Any) -> Self {
        
        let tube = Self()
        tube.name = Self.SelectionMarkerName
        tube.geometry = SCNTube(innerRadius: innerRadius, outerRadius: outerRadius, height: height)
        
        tube.geometry?.firstMaterial = SCNMaterial(contents: content)
        return tube
    }
    
    static func beam(thickness: CGFloat, length: CGFloat, content: Any) -> Self {
        
        let beam = Self()
        beam.name = Self.SelectionMarkerName
        beam.geometry = SCNBox(width: thickness, height: thickness, length: length, chamferRadius: 0.0)
        beam.geometry?.firstMaterial = SCNMaterial(contents: content)
        return beam
    }

}

public extension SCNMaterial {
    convenience init (contents: Any) {
        self.init()
        self.diffuse.contents = contents
    }
}
