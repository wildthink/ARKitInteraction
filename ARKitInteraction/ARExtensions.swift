//
//  ARExtensions.swift
//  ARKitInteraction
//
//  Created by Jason Jobe on 3/24/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import SceneKit

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


/* Reality Kit
import RealityKit

class CustomBox: Entity, HasModel, HasAnchoring, HasCollision {
    
    required init(color: UIColor) {
        super.init()
        self.components[ModelComponent] = ModelComponent(
            mesh: .generateBox(size: 0.1),
            materials: [SimpleMaterial(
                color: color,
                isMetallic: false)
            ]
        )
    }
    
    convenience init(color: UIColor, position: SIMD3<Float>) {
        self.init(color: color)
        self.position = position
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
*/


public extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
