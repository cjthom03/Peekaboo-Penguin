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
import Foundation

class ViewController: UIViewController, ARSCNViewDelegate {
    var penguinToPOVDistance: Double = 0
    var penguinArray = [SCNNode]()
    var winDistance: Float = 1
    var timer = Timer()
    var seconds = 0 //default timer set to 0 - start times must be explicitly set
    var withinView = false
    var currentPlayer = 1
    
    @IBOutlet var sceneView: ARSCNView!
    //@IBOutlet weak var quit: UIBarButtonItem!
  
    @IBOutlet weak var quit: UIBarButtonItem!
    @IBAction func goBack(_ sender: Any) {
        
        let alert = UIAlertController(title: "Give up?", message: "Are you sure you want to quit?", preferredStyle: .alert)
        
        let clearAction = UIAlertAction(title: "Yes", style: .default, handler: {action in self.performSegue(withIdentifier: "title", sender: self)})

        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
        }
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)
    }
 
    // @IBOutlet var sceneView: ARSCNView!
    
    func HideObject() {
        if Float(penguinToPOVDistance) <= winDistance {
            penguinArray.first?.isHidden = false
        } else {
            penguinArray.first?.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
//        print(currentPlayer)
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
                   
//
                    addPenquin(atLocation: hitPlaneResult)
                    askConfirmation()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
//                        self.HideObject()
//                    })
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
//                        self.penguinToPOVDistance = 3.0
//                        self.HideObject()
//                    })
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
    
    func deletePenquin() {
        for penquin in penguinArray{
            penquin.removeFromParentNode()
            penguinArray = [SCNNode]()
        }
    }
    
    func switchPlayers() {
           delay(2, closure: getPlayer2Ready)
            currentPlayer = 2
//        print(currentPlayer)
    }

    func askConfirmation() {
        let alert = UIAlertController(title: "Confirm?", message: "Hide Penguin here?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in self.switchPlayers()}))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {action in self.deletePenquin()}))
        self.present(alert,animated: true)
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
            setTimer(startTime: 5)
            
            sceneView.scene.rootNode.addChildNode(sceneNode)
         
//            delay(3, closure: win )
        }
    }
    
    func getPlayer2Ready() {
        let alert = UIAlertController(title: "Ready?", message: "It's time to find pogo, player 2 is on now!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go!", style: .default, handler: nil))
        self.present(alert,animated: true)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval){
//      guard let currentFrame = self.sceneView.session.currentFrame else {return}
        
        if(!penguinArray.isEmpty){
            guard let pointOfView = self.sceneView.pointOfView else {return}
            let transform = pointOfView.transform
            let currentPosition = SCNVector3(transform.m41, transform.m42, transform.m43)
            let xDistance = currentPosition.x - penguinArray[0].position.x
            let yDistance = currentPosition.y - penguinArray[0].position.y
            let zDistance = currentPosition.z - penguinArray[0].position.z
            let tempPenguinToPOVDistance = sqrt(xDistance * xDistance + yDistance * yDistance + zDistance * zDistance)
//            print(tempPenguinToPOVDistance)
//            self.HideObject()
            if (tempPenguinToPOVDistance <= winDistance && !withinView) {
                withinView = true
                penguinArray.first?.isHidden = false
                // play event
            } else if(withinView && tempPenguinToPOVDistance > winDistance){
                withinView = false
                penguinArray.first?.isHidden = true
            }
            penguinToPOVDistance = Double(tempPenguinToPOVDistance)
            
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
    
    //TIMER FUNCTIONS -------------------------------------------------------------
    func setTimer(startTime: Int) {
        seconds = startTime
        runTimer()
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    //------- PRIVATE TIMER FUNCTIONS - do not call directly ------
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        
        if seconds >= 0 {
            seconds -= 1
            // labelName.text = "\(seconds)"
                //SET THE LABELTEXT TO WHATEVER TIMER LABEL WE END UP USING
        } else {
            stopTimer()
            // this is where we would put lose conditions / call other methods etc
            // depending on whoever is the current player
        }
    }
    
    // END OF TIMER FUNCTIONS ------------------------------------------------------------------
    
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
