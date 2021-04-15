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
    

    static func box(width: CGFloat, height: CGFloat, length: CGFloat, content: Any) -> Self {
        
        let beam = Self()
        beam.name = Self.SelectionMarkerName
        beam.geometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
        beam.geometry?.firstMaterial = SCNMaterial(contents: content)
        return beam
    }
}

extension VirtualObject {
    
    convenience init(name: String, width: CGFloat, height: CGFloat, length: CGFloat, content: Any) {
        
        let beam = SCNNode()
        beam.name = Self.SelectionMarkerName
        let geom = SCNBox(width: width, height: height, length: length, chamferRadius: 0.01)
        let material = SCNMaterial(color: .lightGray, metalness: 0.2)
        geom.materials = [material]
        beam.geometry = geom
        self.init()
        modelName = name
        addChildNode(beam)
    }
}

public extension SCNMaterial {
    
    convenience init (color: UIColor, metalness: CGFloat = 0.3, roughness: CGFloat = 0.1) {
        self.init()
        lightingModel = .physicallyBased
        diffuse.contents = color
        self.metalness.contents = metalness
        self.roughness.contents = roughness
    }

    convenience init (contents: Any) {
        self.init()
        self.diffuse.contents = contents
    }
}
