/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A `SCNReferenceNode` subclass for virtual objects placed into the AR scene.
*/

import Foundation
import SceneKit
import ARKit

class VirtualObject: SCNNode {
    
    var referenceNode: SCNReferenceNode? {
        childNodes.first { $0 is SCNReferenceNode } as? SCNReferenceNode
    }

    var referenceURL: URL {
        referenceNode?.referenceURL ?? URL(string: "vobject://1")!
    }
    
    func load() {
        referenceNode?.load()
    }
    
    func unload() {
        referenceNode?.unload()
    }
    
    init?(url: URL) {
        guard let rn = SCNReferenceNode(url: url)
        else { return nil }
        modelName = rn.referenceURL.lastPathComponent
                .replacingOccurrences(of: ".scn", with: "")

        super.init()
        self.addChildNode(rn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        modelName = String(describing: Self.self)
        super.init()
    }

    init(name: String? = nil) {
        modelName = name ?? String(describing: Self.self)
        super.init()
    }
    
    var modelName: String
    // jmj END

    // jmj
    var selection_mark: SCNNode?
    
    var selected: Bool {
        get { selection_mark != nil }
        set {
            if newValue {
                let radius = CGFloat(self.boundingBox.max.z)
                let ring = VirtualObject.tube(innerRadius: radius, outerRadius: radius + 0.01, height: 0.02, content: UIColor.red.withAlphaComponent(0.8))
                selection_mark = ring
                self.addChildNode(ring)
            } else {
                selection_mark?.removeFromParentNode()
                selection_mark = nil
            }
        }
    }
    /// The model name derived from the `referenceURL`.
//    var modelName: String {
//        return referenceURL.lastPathComponent.replacingOccurrences(of: ".scn", with: "")
//    }
    
    /// The alignments that are allowed for a virtual object.
    var allowedAlignment: ARRaycastQuery.TargetAlignment {
        switch modelName {
        case "sticky note":
            return .any
        case "":
            return .any
        case "painting":
            return .vertical
        default:
            return .horizontal
        }
//        if modelName == "sticky note" {
//            return .any
//        } else if modelName == "painting" {
//            return .vertical
//        } else {
//            return .horizontal
//        }
    }
    
    /// Rotates the first child node of a virtual object.
    /// - Note: For correct rotation on horizontal and vertical surfaces, rotate around
    /// local y rather than world y.
    var objectRotation: Float {
        get {
            return childNodes.first?.eulerAngles.y ?? 0
        }
        set (newValue) {
            childNodes.first?.eulerAngles.y = newValue
        }
    }
    
    /// The object's corresponding ARAnchor.
    var anchor: ARAnchor?

    /// The raycast query used when placing this object.
    var raycastQuery: ARRaycastQuery?
    
    /// The associated tracked raycast used to place this object.
    var raycast: ARTrackedRaycast?
    
    /// The most recent raycast result used for determining the initial location
    /// of the object after placement.
    var mostRecentInitialPlacementResult: ARRaycastResult?
    
    /// Flag that indicates the associated anchor should be updated
    /// at the end of a pan gesture or when the object is repositioned.
    var shouldUpdateAnchor = false
    
    /// Stops tracking the object's position and orientation.
    /// - Tag: StopTrackedRaycasts
    func stopTrackedRaycast() {
        raycast?.stopTracking()
        raycast = nil
    }
}

extension VirtualObject {
    // MARK: Static Properties and Methods
    /// Loads all the model objects within `Models.scnassets`.
    static let availableObjects: [VirtualObject] = {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!

        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!

        var nobs: [VirtualObject] = fileEnumerator.compactMap { element in
            let url = element as! URL

            guard url.pathExtension == "scn" && !url.path.contains("lighting") else { return nil }

            return VirtualObject(url: url)
        }
        nobs.append(VirtualObject(name: "Steel Box", width: 0.2, height: 0.3, length: 0.5, content: UIColor.gray))
        return nobs
    }()
    
    /// Returns a `VirtualObject` if one exists as an ancestor to the provided node.
    static func existingObjectContainingNode(_ node: SCNNode) -> VirtualObject? {
        if let virtualObjectRoot = node as? VirtualObject {
            return virtualObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        // Recurse up to check if the parent is a `VirtualObject`.
        return existingObjectContainingNode(parent)
    }
}
