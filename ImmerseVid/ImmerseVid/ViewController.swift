///
//  ViewController.swift
//  ImmerseVid
//
//  Created by ShriGanesh K Purohit on 18/02/25.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // Dictionary mapping AR images to video filenames
    let videoMapping: [String: String] = [
           "page_1": "page_1",
           "page_2": "page_2",
           "marria":"marria",
           "page_3": "page_3",
           "page_4": "page_4",
           "page_5": "page_5",
           "page_8": "page_8",
           "page_9": "page_9",
           "page_20": "page_20",
           "page_22": "page_22",
           "page_24": "page_24",
           "page_25": "page_25",
           "page_26": "page_26",
           "page_28": "page_28",
           "page_31": "page_31",

        



       ]
    
    // Dictionary mapping AR images to specific video dimensions
    let videoDimensions: [String: CGSize] = [
        "marria": CGSize(width:  480, height: 580),
        "page_1": CGSize(width: 1012, height:850),
        "page_3": CGSize(width: 2479, height: 3590),
        "page_4": CGSize(width: 905, height: 540),
        "page_5": CGSize(width: 875, height: 499),
        "page_8": CGSize(width: 480, height: 711),
        "page_9": CGSize(width: 480, height: 711),
        "page_12": CGSize(width: 480, height: 711),
        "page_20": CGSize(width: 480, height: 711),
        "page_22": CGSize(width: 480, height: 711),
        "page_24": CGSize(width: 480, height: 711),
        "page_25": CGSize(width: 480, height: 711),
        "page_26": CGSize(width: 480, height: 711),
        "page_28": CGSize(width: 480, height: 711),
        "page_31": CGSize(width: 480, height: 711),
        "page_32": CGSize(width: 480, height: 711),
        "page_41": CGSize(width: 480, height: 711),
        "page_42": CGSize(width: 480, height: 711),
        "page_43": CGSize(width: 480, height: 711),
        "page_44": CGSize(width: 480, height: 711),
        "page_45": CGSize(width: 480, height: 711),
        
    ]
     
    var players: [String: AVPlayer] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "magzineImage", bundle: Bundle.main) {
            configuration.trackingImages = trackedImages
            configuration.maximumNumberOfTrackedImages = trackedImages.count
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let imageName = imageAnchor.referenceImage.name ?? ""
            
            if let videoFileName = videoMapping[imageName], let videoURL = Bundle.main.url(forResource: videoFileName, withExtension: "mp4") {
                let player: AVPlayer
                
                if let existingPlayer = players[imageName] {
                    player = existingPlayer
                } else {
                    player = AVPlayer(url: videoURL)
                    players[imageName] = player
                }
                
                let videoNode = SKVideoNode(avPlayer: player)
                
                player.actionAtItemEnd = .none
                
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                    player.seek(to: .zero)
                    player.play()
                }
                
                player.play()
                
                let videoSize = videoDimensions[imageName] ?? CGSize(width: 1000, height: 1000) // Default size
                
                let videoScene = SKScene(size: videoSize)
                videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
                videoNode.yScale = -1.0
                videoScene.addChild(videoNode)
                
                let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
                plane.firstMaterial?.diffuse.contents = videoScene
                
                let planeNode = SCNNode(geometry: plane)
                planeNode.eulerAngles.x = -.pi / 2
                node.addChildNode(planeNode)
            }
        }
        
        return node
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                let imageName = imageAnchor.referenceImage.name ?? ""
                if let player = players[imageName] {
                    if imageAnchor.isTracked {
                        player.play()
                    } else {
                        player.pause()
                    }
                }
            }
        }
    }
}
