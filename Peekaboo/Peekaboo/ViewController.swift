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
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    var penguinToPOVDistance: Double = 0
    var penguinArray = [SCNNode]()
    
    var audioSource: SCNAudioSource?

    var winTimer: DispatchWorkItem?
    var winDistance: Float = 1
    var virtualText = SCNNode() // initialize as an empty scene node
    var textColor = UIColor.init(red: 0.467, green: 0.733, blue: 1.0, alpha: 1.0)
    var gaveUp = false


    var timer = Timer()
    var timerIsRunning = false
    var timeIsUp = false
    var seconds = 0 //default timer set to 0 - start times must be explicitly set
    var withinView = false
    var currentPlayer = 1
    var alert: UIAlertController = UIAlertController()
    
    @IBOutlet var sceneView: ARSCNView!
    //@IBOutlet weak var quit: UIBarButtonItem!
  
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var quit: UIBarButtonItem!
    @IBAction func goBack(_ sender: Any) {
        if timerIsRunning == true {
            toggleTimer()
            
        }
        var textforPlayer = ""
        let textforPlayer1 = "Are you sure you want to quit?"
        let textforPlayer2 = "Do you want to see where the penguin is hiding?"
        //Check which player it playing and change options of alert depending on that
        if currentPlayer == 1 {
            textforPlayer = textforPlayer1
        } else if currentPlayer == 2 {
            if gaveUp == true {
                quitGame()
            }
            textforPlayer = textforPlayer2
        }
        let alert = UIAlertController(title: "Give up?", message: textforPlayer, preferredStyle: .alert)
        let scaleObject = UIAlertAction(title: "Show me the penguin!", style: .default, handler: {action in self.biggerObject()})
        let clearAction = UIAlertAction(title: "Yes", style: .default, handler: {action in self.quitGame()})
        let pushQuit = UIAlertAction(title: "No, I'm good", style: .default, handler: {action in self.quitGame()})
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {action in self.cancelQuit()})
        // Add buttons to alert depending on currentPlayer
        if currentPlayer == 1 {
        alert.addAction(clearAction)
        } else if currentPlayer == 2 {
            
            if(gaveUp == false) { alert.addAction(scaleObject) }
            alert.addAction(pushQuit)
        }
        alert.addAction(cancelAction)
        if gaveUp == false {
            present(alert, animated: true, completion:nil)
        }
    }

    func cancelQuit() {
        toggleTimer()
    }
    
    func quitGame() {
        stopTimer()
        currentPlayer = 1
        self.performSegue(withIdentifier: "title", sender: self)
    }
    
    func biggerObject() {
        winDistance += 50
        animate()
    }
    
    func animate() {
        gaveUp = true
        stopTimer()
        let scale = 20
        SCNTransaction.animationDuration = 10.0
        let penguineNode = penguinArray.first
        let pinchScaleX = Float(scale) * (penguineNode?.scale.x)!
        let pinchScaleY = Float(scale) * (penguineNode?.scale.y)!
        let pinchScaleZ = Float(scale) * (penguineNode?.scale.z)!
        penguineNode?.scale = SCNVector3(pinchScaleX,pinchScaleY,pinchScaleZ)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        audioSource = SCNAudioSource(fileNamed: "/art.scnassets/duck.wav")!
        audioSource?.load()
        audioSource?.loops = true
        audioSource?.shouldStream = false
        let startText = "Hide the Penguin!"
        let startPos = SCNVector3(-0.45, 0, -1.5)
        virtualText = createText(text: startText, atPosition: startPos)
        
        setTimer(startTime: 15)
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // Allow rotation
    @objc func canRotate() -> Void {}
    
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
                if (!hitTest.isEmpty && currentPlayer == 2 && gaveUp == false && timeIsUp == false){
                   // If the penguin was tapped by player 2, the game is won!
                    if let nodeName = hitTest.first?.node.name {
                        if nodeName == "penguin" {
                            win()
                        }
                    }
                }
            }
         
        }
    }
    
    func deletePenquin() {
        for penquin in penguinArray {
            penquin.removeFromParentNode()
            penguinArray = [SCNNode]()
        }
    }
    
    func switchPlayers() {
        currentPlayer = 2
        //reset timeisUp
        timeIsUp = false
        // Stop the hide timer; Start the search timer
        stopTimer()
        playerDelay(0.3, closure: getPlayer2Ready)
    }

    func askConfirmation() {
        alert = UIAlertController(title: "Confirm?", message: "Hide Penguin here?", preferredStyle: .alert)
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
            
            sceneNode.name = "penguin"
            penguinArray.append(sceneNode)
            
            sceneView.scene.rootNode.addChildNode(sceneNode)
        }
    }
    
    func addPenguin(matrix: float4x4) {
        let scene = SCNScene(named: "art.scnassets/tux.scn")!
        
        if let sceneNode = scene.rootNode.childNode(withName: "penguin", recursively:true) {
            let x = matrix.columns.3.x
            let y = matrix.columns.3.y
            let z = matrix.columns.3.z
            sceneNode.position = SCNVector3(x, y, z)

            sceneNode.name = "penguin"
            penguinArray.append(sceneNode)
            
            sceneView.scene.rootNode.addChildNode(sceneNode)
        }
    }
    
    func getPlayer2Ready() {
        var title = "Ready?"
        if timeIsUp {
            title = "Time's Up!"
        }
        let alert = UIAlertController(title: title, message: "It's time to find the penguin, player 2 is on now!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go!", style: .default, handler: {action in self.readyPlayer2()}))
        self.present(alert,animated: true)
          currentPlayer = 2
    }
    

    func readyPlayer2() {
        setTimer(startTime: 30)
        updateText(textNode: virtualText, text: "FIND THE PENGUIN!!")
    }
    
    func playWithinRangeSound (){
         penguinArray[0].addAudioPlayer(SCNAudioPlayer(source: audioSource!))
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

            if (tempPenguinToPOVDistance <= winDistance && !withinView) {
                
                withinView = true
                penguinArray.first?.isHidden = false
                self.playWithinRangeSound()
                // play event
            } else if(withinView && tempPenguinToPOVDistance > winDistance){
                withinView = false

                if (currentPlayer == 2 ) { penguinArray.first?.isHidden = true }
            }
            penguinToPOVDistance = Double(tempPenguinToPOVDistance)
            
        }
        
    }
    
    func playerDelay(_ delay:Double, closure:@escaping ()->()) {
//        timer = Timer.scheduledTimer(timeInterval: 11, target: self, selector: #selector(closure), userInfo: nil, repeats: false)
        winTimer = DispatchWorkItem { closure() }
//        queue = DispatchQueue(label: "delayQueue")
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: winTimer!)

    }
    
    func playerTwo(){
        let changePlayers = UIAlertController(title: "Player2", message: "Ready to start?", preferredStyle: .alert)
        changePlayers.addAction(UIAlertAction(title: "Go!",style: .default, handler: nil))
        self.present(changePlayers,animated: true, completion: nil)
    }
    
    //MARK: - Text Functions
    //-------------------------------------------------------------
    
    func createText(text: String, atPosition position: SCNVector3) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = textColor
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = position
        textNode.scale = SCNVector3(0.0075, 0.0075, 0.0075)
        sceneView.scene.rootNode.addChildNode(textNode)
        return textNode
    }
    
    func updateText(textNode: SCNNode, text: String) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = textColor
        textNode.geometry = textGeometry
    }
    
    // MARK: - Timer Functions
    //-------------------------------------------------------------
    func setTimer(startTime: Int) {
        seconds = startTime
        timerLabel.isHidden = false
        runTimer()
    }
    
    func toggleTimer() {
        if timerIsRunning == true {
            timer.invalidate()
            timerIsRunning = false
        } else {
            runTimer()
        }
    }
    
    func stopTimer() {
        timer.invalidate()
        timerIsRunning = false
        timerLabel.text = ""
        timerLabel.isHidden = true
    }
    
    //------- PRIVATE TIMER FUNCTIONS - do not call directly ------
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        
        timerIsRunning = true
    }
    
    @objc func updateTimer() {
        if seconds >= 0 {
            timerLabel.text = "\(seconds)"
            seconds -= 1
        } else {
            stopTimer()
            // this is where we would put lose conditions / call other methods etc
            // depending on whoever is the current player
            if currentPlayer == 1 {
                // put the penguin somewhere
                if penguinArray.count == 0 {
                    guard let currentFrame = self.sceneView.session.currentFrame else {return}
                    let transform = currentFrame.camera.transform
                    var translateMatrix = matrix_identity_float4x4
                    translateMatrix.columns.3.z = -0.2
                    let modifiedMatrix = simd_mul(transform, translateMatrix)
                    addPenguin(matrix: modifiedMatrix)
                }
                
                //remove any alerts that are present
                alert.dismiss(animated: true, completion: nil)
                
                // trigger changing players
                timeIsUp = true
                switchPlayers()
                
            } else if currentPlayer == 2 {
                timeIsUp = true
                gameOver()
            }
        }
    }

    
    //MARK: - Game Over
    func gameOver() {
        let alert = UIAlertController(title: "Game over!", message: "Oh no! You could not find the penguin in time... wanna know where it was hiding?", preferredStyle: .alert)
        let scaleObject = UIAlertAction(title: "YES! Show me the penguin!", style: .default, handler: {action in self.biggerObject()})
        let pushQuit = UIAlertAction(title: "Nope", style: .default, handler: {action in self.quitGame()})
        alert.addAction(scaleObject)
        alert.addAction(pushQuit)
        present(alert, animated: true, completion:nil)
    }
    
    //MARK: - Win Logic
    func win() {
        penguinArray.first?.runAction(SCNAction.rotateBy(x: 0, y: CGFloat.pi * 4, z: 0, duration: 1), completionHandler: {
            self.winAlert()
            print(self)
        })
    }
    
    func winAlert() {
        let alert = UIAlertController(title: "You Win!", message: "You are awesome", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok!",style: .default, handler: {action in self.quitGame()} ))
        self.present(alert , animated: true)
    }

//    @IBAction func RemovePenquin(_ sender: Any) {
//        if !penguinArray.isEmpty{
//            for penquin in penguinArray{
//                penquin.removeFromParentNode()
//                penguinArray = [SCNNode]()
//            }
//        }
//    }
    
}
