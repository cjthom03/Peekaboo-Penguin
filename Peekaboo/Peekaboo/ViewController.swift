//
//  ViewController.swift
//  test
//
//  Created by Daniel Chen on 6/23/18.
//  Copyright © 2018 Daniel Chen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var penguinArray = [SCNNode]()
    var penguinToPOVDistance = 5.0
    @IBOutlet var sceneView: ARSCNView!
    //@IBOutlet weak var quit: UIBarButtonItem!
  
    @IBOutlet weak var quit: UIBarButtonItem!
    @IBAction func goBack(_ sender: Any) {
        
        let alert = UIAlertController(title: "give up?", message: "Are you sure you want to quit?", preferredStyle: .alert)
        
        let clearAction = UIAlertAction(title: "Yes", style: .default, handler: {action in self.performSegue(withIdentifier: "title", sender: self)})

        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
        }
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)
    }
 
    // @IBOutlet var sceneView: ARSCNView!
    
    func HideObject() {
        if penguinToPOVDistance <= 4.0 {
            penguinArray.first?.isHidden = false
        } else {
            penguinArray.first?.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // called when a touch is detected in the view/window
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // ensure that a touch was detected
        if let touch = touches.first {
            // get the location of the touch event in the sceneview
            let touchLocation = touch.location(in: sceneView)
            //No penguin on the screen yet? Try to add one
            if penguinArray.isEmpty {
                let planeResults = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane, .featurePoint])
        
                if let hitPlaneResult = planeResults.first {
//                    let alert = UIAlertController(title: "Confirm?", message: "Hide Penguin here?", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Yes",style: .default, handler: { action in self.addPenquin(atLocation: hitPlaneResult)}))
//                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
//                    self.present(alert,animated: true)
                    addPenquin(atLocation: hitPlaneResult)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        self.HideObject()
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
                        self.penguinToPOVDistance = 3.0
                        self.HideObject()
                    })
                }
            } else {
                //penquin already on the screen? Test if the penguin was tapped
                let hitTest = sceneView.hitTest(touchLocation)
                if !hitTest.isEmpty{
                   // If the penguin was tapped by player 2, the game is won!
                    let alert = UIAlertController(title: "You Win!", message: "You are awesome", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok!",style: .default, handler: nil ))
                    self.present(alert,animated: true)
                }
            }
         
        }
    }

    func addPenquin(atLocation location: ARHitTestResult){
        let scene = SCNScene(named: "art.scnassets/tux.scn")!
        
        if let sceneNode = scene.rootNode.childNode(withName: "penguin", recursively:true) {
            sceneNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + 0.022,
                z: location.worldTransform.columns.3.z
            )
            
//            sceneNode.runAction(SCNAction.fadeOpacity(to: 0, duration: 5))
            
            penguinArray.append(sceneNode)
            
            sceneView.scene.rootNode.addChildNode(sceneNode)
//            delay(2, closure: playerTwo)
//            delay(3, closure: win )
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func playerTwo(){
        let changePlayers = UIAlertController(title: "Player2", message: "Ready to start?", preferredStyle: .alert)
        changePlayers.addAction(UIAlertAction(title: "Go!",style: .default, handler: nil))
        self.present(changePlayers,animated: true, completion: nil)
    }
    
    
    
    
    
    func win(){
        //    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "gameOver") as! gameOverViewController
        //
        //        self.present(nextViewController, animated: true,completion: nil)
    }
    

    @IBAction func RemovePenquin(_ sender: Any) {
        if !penguinArray.isEmpty{
            for penquin in penguinArray{
                penquin.removeFromParentNode()
                penguinArray = [SCNNode]()
            }
        }
    }
    
    //MARK: - ARSCNViewDelegateMethods

//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//
//        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
//
//        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
//
//        node.addChildNode(planeNode)
//
//    }
//
//    //MARK: - Plane Rendering Methods
//
//    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode{
//        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//        let gridMaterial = SCNMaterial()
//        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
//        plane.materials = [gridMaterial]
//        let planeNode = SCNNode()
//        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
//        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
//
//        planeNode.geometry = plane
//
//        return planeNode
//    }

}
