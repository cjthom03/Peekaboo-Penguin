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
    
    var planeArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    //@IBOutlet weak var quit: UIBarButtonItem!
  
    @IBOutlet weak var quit: UIBarButtonItem!
    @IBAction func goBack(_ sender: Any) {
        
        let alert = UIAlertController(title: "I give up", message: "Are you sure you want to quit?", preferredStyle: .alert)
        //        let clearAction = UIAlertAction(title: "Clear", style: .default) { (alert: UIAlertAction!) -> Void in
        //        let clearAction = UIAlertAction(title: "Clear", style: .default, handler: { action in self.goBack(sender: <#UIBarButtonItem#>)})
        let clearAction = UIAlertAction(title: "Yes", style: .default, handler: {action in self.performSegue(withIdentifier: "title", sender: self)})
        
    
        //print("You pressed OK")
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
            //print("You pressed Cancel")
        }
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)
    }
 
    // @IBOutlet var sceneView: ARSCNView!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                let alert = UIAlertController(title: "Confirm?", message: "Add Plane at this point", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes",style: .default, handler: { action in self.addPlane(atLocation: hitResult)}))
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                self.present(alert,animated: true)
                
            }
        }
    }
    
    func addPlane(atLocation location: ARHitTestResult){
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        if let sceneNode = scene.rootNode.childNode(withName: "ship",recursively:true) {
            sceneNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y,
                z: location.worldTransform.columns.3.z
            )
            
            sceneNode.runAction(SCNAction.fadeOpacity(to: 0, duration: 5))
            
            planeArray.append(sceneNode)
            
            sceneView.scene.rootNode.addChildNode(sceneNode)
            delay(2, closure: playerTwo)
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
    
    @IBAction func removePlane(_ sender: Any) {
        if !planeArray.isEmpty{
            for plane in planeArray{
                plane.removeFromParentNode()
            }
        }
    }
    
    //MARK: - ARSCNViewDelegateMethods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
        
    }
    
    //MARK: - Plane Rendering Methods
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode{
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        planeNode.geometry = plane
        
        return planeNode
    }
    
    
}
