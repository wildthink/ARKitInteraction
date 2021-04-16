/*
See LICENSE folder for this sample’s licensing information.

Abstract:
ARSCNViewDelegate interactions for `ViewController`.
*/

import ARKit

extension ARKViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        let isAnyObjectInView = virtualObjectLoader.loadedObjects.contains { object in
            return sceneView.isNode(object, insideFrustumOf: sceneView.pointOfView!)
        }
        
        DispatchQueue.main.async {
            self.updateFocusSquare(isObjectVisible: isAnyObjectInView)
            
            // If the object selection menu is open, update availability of items
            if self.objectsViewController?.viewIfLoaded?.window != nil {
                self.objectsViewController?.updateObjectAvailability()
            }
            
            // jmj
            var invalid = [Connector]()
            self.sceneView.scene.rootNode.enumerateChildNodes { node, flag in
                guard let con = node as? Connector else { return }
                if !con.isValid {
                    invalid.append(con)
                } else {
                    con.layout()
                }
                for c in invalid { c.removeFromParentNode() }
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        
        //1. Check We Have A Valid ARObject Anchor
//        guard let objectAnchor = anchor as? ARObjectAnchor else { return }

        //2. Create A Bounding Box Around Our Object
//        let scale = CGFloat(objectAnchor.referenceObject.scale.x)
//        let boundingBoxNode = BlackMirrorzBoundingBox(points: objectAnchor.referenceObject.rawFeaturePoints.points, scale: scale)
//        node.addChildNode(boundingBoxNode)

        DispatchQueue.main.async {
            self.statusViewController.cancelScheduledMessage(for: .planeEstimation)
            self.statusViewController.showMessage("SURFACE DETECTED")
            if self.virtualObjectLoader.loadedObjects.isEmpty {
                self.statusViewController.scheduleMessage("TAP + TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .contentPlacement)
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        updateQueue.async {
            if let objectAtAnchor = self.virtualObjectLoader.loadedObjects.first(where: { $0.anchor == anchor }) {
                objectAtAnchor.simdPosition = anchor.transform.translation
                objectAtAnchor.anchor = anchor
            }
        }
    }
    
    /// - Tag: ShowVirtualContent
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusViewController.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        switch camera.trackingState {
        case .notAvailable, .limited:
            statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
            showVirtualContent()
        }
    }

    func showVirtualContent() {
        virtualObjectLoader.loadedObjects.forEach { $0.isHidden = false }
    }

    public func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Hide content before going into the background.
        hideVirtualContent()
    }
    
    /// - Tag: HideVirtualContent
    func hideVirtualContent() {
        virtualObjectLoader.loadedObjects.forEach { $0.isHidden = true }
    }

    /*
     Allow the session to attempt to resume after an interruption.
     This process may not succeed, so the app must be prepared
     to reset the session if the relocalizing status continues
     for a long time -- see `escalateFeedback` in `StatusViewController`.
     */
    /// - Tag: Relocalization
    public func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
}
