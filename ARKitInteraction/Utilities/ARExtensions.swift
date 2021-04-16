//
//  ARExtensions.swift
//  ARKitInteraction
//
//  Created by Jason Jobe on 3/24/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import SceneKit

public enum CubeFace { case top, bottom, left, right, front, back }


public extension SCNNode {
    
    func visit<N: SCNNode> (type: N.Type, call: ((N)->Void)) {
        if let n = self as? N { call (n) }
        for c in childNodes {
            c.visit(type: type, call: call)
        }
    }
    
    func visit (call: ((SCNNode)->Void)) {
        visit(type: SCNNode.self, call: call)
    }

}

extension SCNVector3 {
    func distance(to vector: SCNVector3) -> Float {
        return simd_distance(simd_float3(self), simd_float3(vector))
    }
    
    func midpoint (to other: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: (x + other.x)/2, y: (y + other.y)/2, z: (z + other.z)/2)
    }

}

/*
 Example:
     let line = SCNGeometry.line(from: startPosition, to: endPosition)
     let lineNode = SCNNode(geometry: line)
     lineNode.position = SCNVector3Zero
     sceneView.scene.rootNode.addChildNode(lineNode)
 */
public extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}

class Connector: SCNNode {
    
    weak var source: SCNNode?
    weak var sink: SCNNode?
        
    required init(from src: SCNNode, to sink: SCNNode) {
        self.source = src
        self.sink = sink
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isValid: Bool {
        source?.parent != nil && sink?.parent != nil
    }
    
    func connects(_ e: SCNNode) -> Bool {
        e == source || e == sink
    }
    
    func layout(width: Float = 0.01, color: UIColor = .red) {
        
        guard let source = source, let sink = sink else { return }
//        self.geometry = SCNGeometry.line(from: source.position, to: sink.position)
//        position = SCNVector3Zero

        self.geometry = SCNGeometry.line(points: [
            source.position,
            sink.position
        ], radius: 0.01).0
        
        let material = SCNMaterial(color: .yellow, metalness: 0.5)
        self.geometry?.materials = [material]

    }
}

//extension Connector: CustomStringConvertible {
//    var description: String {
//        let src = source?.name ?? "<source>"
//        let snk = sink?.name ?? "<sink>"
//        return "\(src)::\(snk)"
//    }
//}

public extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
