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
    
    convenience init(name: String, image: String? = nil, facing: CubeFace = .front,
                     width: CGFloat, height: CGFloat, depth: CGFloat, content: Any) {
        
        let beam = SCNNode()
        beam.name = Self.SelectionMarkerName
        let geom = SCNBox(width: width, height: height, length: depth, chamferRadius: 0.001)
        let material = SCNMaterial(color: .lightGray, metalness: 0.5)
//        material.transparency = 0.8
        geom.materials = [material]
        beam.geometry = geom
        self.init()
        modelName = name
        addChildNode(beam)
                
        guard let image = image,
              let img = UIImage(named: image) else { return }
        let plane: Plane
        
        switch facing {
        case .top:
            plane = Plane(width: width, height: depth, content: img, horizontal: true)
            plane.simdPosition = [0, Float(height/2) + 0.001, 0]
        case .bottom:
            plane = Plane(width: width, height: depth, content: img, horizontal: true)
            plane.simdPosition = [0, -Float(height/2) + 0.001, 0]
        case .left:
            plane = Plane(width: depth, height: height, content: img, horizontal: false)
            plane.simdPosition = [0, 0, Float(depth/2) + 0.001]
        case .right:
            plane = Plane(width: depth, height: height, content: img, horizontal: false)
            plane.simdPosition = [0, 0, Float(depth/2) + 0.001]
        case .front:
            plane = Plane(width: width, height: height, content: img, horizontal: false)
            plane.simdPosition = [0, 0, Float(depth/2) + 0.001]
        case .back:
            plane = Plane(width: width, height: height, content: img, horizontal: false)
            plane.simdPosition = [0, 0, -Float(depth/2) + 0.001]
        }
        beam.addChildNode(plane)
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

// https://www.blackmirrorz.tech/index.php/arkittutorials/scngeometry/scnplane
public class Plane: SCNNode {
    
    /// Creates An SCNPlane With A Single Colour Or Image For It's Material
    /// (Either A Colour Or UIImage Must Be Input)
    /// - Parameters:
    ///   - width: Optional CGFloat (Defaults To 60cm)
    ///   - height: Optional CGFloat (Defaults To 30cm)
    ///   - content: Any (UIColor Or UIImage)
    ///   - doubleSided: Bool
    ///   - horizontal: The Alignment Of The Plane
    
    public init(width: CGFloat, height: CGFloat, content: Any,
         doubleSided: Bool = false, horizontal: Bool = true) {
        
        super.init()
        
        self.geometry = SCNPlane(width: width, height: height)
        let material = SCNMaterial()
        material.diffuse.contents = content
        
         self.geometry?.firstMaterial = material
        
        material.isDoubleSided = doubleSided
      

        if horizontal {
            self.transform = SCNMatrix4MakeRotation((-Float.pi / 2), 1, 0, 0)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("Plane Node Coder Not Implemented") }
    
}


// https://stackoverflow.com/questions/51552293/show-bounding-box-while-detecting-object-using-arkit-2/51567573

public class BlackMirrorzBoundingBox: SCNNode {

    //-----------------------
    // MARK: - Initialization
    //-----------------------

    /// Creates A WireFrame Bounding Box From The Data Retrieved From The ARReferenceObject
    ///
    /// - Parameters:
    ///   - points: [float3]
    ///   - scale: CGFloat
    ///   - color: UIColor
    public init(points: [SIMD3<Float>], scale: CGFloat, color: UIColor = .cyan) {
        super.init()

        var localMin = SIMD3<Float>(repeating: Float.greatestFiniteMagnitude)
        var localMax = SIMD3<Float>(repeating: -Float.greatestFiniteMagnitude)

        for point in points {
            localMin = min(localMin, point)
            localMax = max(localMax, point)
        }

        self.simdPosition += (localMax + localMin) / 2
        let extent = localMax - localMin

        let wireFrame = SCNNode()
        let box = SCNBox(width: CGFloat(extent.x), height: CGFloat(extent.y), length: CGFloat(extent.z), chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = color
        box.firstMaterial?.isDoubleSided = true
        wireFrame.geometry = box
        setupShaderOnGeometry(box)
        self.addChildNode(wireFrame)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) Has Not Been Implemented") }

    //----------------
    // MARK: - Shaders
    //----------------

    /// Sets A Shader To Render The Cube As A Wireframe
    ///
    /// - Parameter geometry: SCNBox
    func setupShaderOnGeometry(_ geometry: SCNBox) {
        guard let path = Bundle.main.path(forResource: "wireframe_shader", ofType: "metal", inDirectory: "art.scnassets"),
            let shader = try? String(contentsOfFile: path, encoding: .utf8) else {

                return
        }
        geometry.firstMaterial?.shaderModifiers = [.surface: shader]
    }

}
