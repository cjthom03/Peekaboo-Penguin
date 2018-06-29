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

//var highlitedColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)

var textColor = UIColor.init(red: 0.467, green: 0.733, blue: 1.0, alpha: 1.0)


extension UIButton {
    private func actionHandleBlock(action:(() -> Void)? = nil) {
        struct __ {
            static var action :(() -> Void)?
        }
        if action != nil {
            __.action = action
        } else {
            __.action?()
        }
        
    }
    
    @objc private func triggerActionHandleBlock() {
        self.actionHandleBlock()
    }
    
    func actionHandle(controlEvents control :UIControlEvents, ForAction action:@escaping () -> Void) {
        self.actionHandleBlock(action: action)
        self.addTarget(self, action: #selector(UIButton.triggerActionHandleBlock), for: control)
    }

//    override open var isHighlighted: Bool {
//        didSet {
//            if self.currentTitleColor != CGColorSpace.extendedGray {
//            backgroundColor = isHighlighted ? highlitedColor : UIColor.white
//            }
//        }
//    }
//
//    @IBAction func buttonReleased(sender: AnyObject) { //Touch Down action
//        print(sender.tag)
//    }
    
    
}

class ViewController: UIViewController, ARSCNViewDelegate {
    var penguinToPOVDistance: Double = 0
    var penguinArray = [SCNNode]()
    


    var subViewX: CGFloat = 1
    var subViewY: CGFloat = 1
   
    var audioSource: SCNAudioSource?

    @IBOutlet weak var readyLabel: UILabel!
    var popupOnScreen = false
    var winTimer: DispatchWorkItem?
    var winDistance: Float = 1
    var virtualText = SCNNode() // initialize as an empty scene node
    var textColor = UIColor.init(red: 0.467, green: 0.733, blue: 1.0, alpha: 1.0)
    var gaveUp = false
//            var cancelButton = UIButton(type: .system)
    var v = UIView()
    var savedView = UIView()
    var timer = Timer()
    var readyTimer = Timer()
    var readySeconds = 3
    var timerIsRunning = false
    var timeIsUp = false
    var seconds = 0 //default timer set to 0 - start times must be explicitly set
    var withinView = false
    var currentPlayer = 1
    var alert: UIAlertController = UIAlertController()
    var window = UIApplication.shared.keyWindow!
    @IBOutlet var sceneView: ARSCNView!
    //@IBOutlet weak var quit: UIBarButtonItem!
  

    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var instructionLabel: UILabel!
  
    @IBOutlet weak var quit: UIBarButtonItem!
    

//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        if UIDevice.current.orientation.isLandscape {
//            let savedView = v
//            print(savedView.center)
//            self.removeSubView()
//            savedView.center = CGPoint(x: window.frame.width/2, y: window.frame.height/2)
//            print(savedView.center)
//            window.addSubview(savedView)
//            print("Landscape")
//        } else {
//            print("Portrait")
//            let savedView = v
////            v.center = window.convert(window.center, from: v)
//            self.removeSubView()
//            savedView.center = CGPoint(x: window.frame.height/2, y: window.frame.width/2)
//            window.addSubview(savedView)
//        }
//    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if popupOnScreen == true {
        self.removeSubView()
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            if UIDevice.current.orientation.isLandscape {
                            self.savedView.center = CGPoint(x: self.window.frame.width/2, y: self.window.frame.height/2)
                            self.window.addSubview(self.savedView)
                            self.popupOnScreen = true
                        }
            if UIDevice.current.orientation.isPortrait {
                self.savedView.center = CGPoint(x: self.window.frame.width/2, y: self.window.frame.height/2)
                self.window.addSubview(self.savedView)
                self.popupOnScreen = true
            }
 
        })
       }
    }

    
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
    
    @objc func quitGame() {
        removeSubView()
        stopTimer()
        currentPlayer = 1
        self.performSegue(withIdentifier: "title", sender: self)
    }
    
    @objc func biggerObject() {
        removeSubView()
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
//        if (UIDevice.current.orientation != .portrait) {
//            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
//        }
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        audioSource = SCNAudioSource(fileNamed: "/art.scnassets/duck.wav")!
        audioSource?.load()
        audioSource?.loops = true
        audioSource?.shouldStream = false
//        let startText = "Hide the Penguin!"
//        let startPos = SCNVector3(-0.45, 0, -1.5)
//        virtualText = createText(text: startText, atPosition: startPos)
        
        runReadyTimer()

        self.navigationItem.title = "Get Ready!"
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
        
        timer.invalidate()
        readyTimer.invalidate()
        
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
            if penguinArray.isEmpty && readySeconds < 0 {
                let planeResults = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane, .featurePoint])
        
                if let hitPlaneResult = planeResults.first {
                    addPenquin(atLocation: hitPlaneResult)
                         addCustomSubView("Hide Penguin here?","","Yes","Cancel", "HIDE")
                }else {
                    findPenguinLocation()
    addCustomSubView("Hide Penguin here?","","Yes","Cancel", "HIDE")
//                    askConfirmation()
                }
            } else {
                //penguin already on the screen? Test if the penguin was tapped
                let hitTest = sceneView.hitTest(touchLocation)
                if (!hitTest.isEmpty && currentPlayer == 2 && gaveUp == false && timeIsUp == false){
                   // If the penguin was tapped by player 2, the game is won!
                    if let nodeName = hitTest.first?.node.name {
                        if nodeName == "penguin" {
                            stopTimer()
//                            addCustomSubView("You Win!", "You're awesome", "", "Ok!", "GameWon")

                            win()

                        }
                    }
                }
            }
         
        }
    }
    
    @objc func deletePenquin() {
        removeSubView()
        for penquin in penguinArray {
            penquin.removeFromParentNode()
            penguinArray = [SCNNode]()
        }
    }
    
    @objc func switchPlayers() {
        removeSubView()
        //reset timeisUp
        timeIsUp = false
        if winDistance < Float(penguinToPOVDistance) { penguinArray.first?.isHidden = true }
        // Stop the hide timer; Start the search timer
        stopTimer()
        playerDelay(0.3, closure: getPlayer2Ready)
        self.navigationItem.title = ""
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
    
    //Add penguin in front of camera
    func findPenguinLocation(){
        guard let currentFrame = self.sceneView.session.currentFrame else {return}
        let transform = currentFrame.camera.transform
        var translateMatrix = matrix_identity_float4x4
        translateMatrix.columns.3.z = -0.2
        let modifiedMatrix = simd_mul(transform, translateMatrix)
        addPenguin(matrix: modifiedMatrix)
    }
    
    @objc func getPlayer2Ready() {
        var title = "Get Ready! "
        if timeIsUp {
            title = "Time's Up! "
        }
        addCustomSubView(title, "player 2 is on now!", "", "Go!", "GetPlayer2")
//          currentPlayer = 2
    }
    

    @objc func readyPlayer2() {
        removeSubView()
        setTimer(startTime: 60)
        instructionLabel.text = "Find Panguine!"
        instructionLabel.isHidden = false
//        updateText(textNode: virtualText, text: "FIND THE PENGUIN!!")
        self.navigationItem.title = "Player 2"
        currentPlayer = 2
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
        winTimer = DispatchWorkItem { closure() }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: winTimer!)

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
    
    
    // MARK: - READY TIMER
    
    func runReadyTimer(){
          instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        readyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateReadyTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateReadyTimer(){
        if readySeconds > 0 {
            readyLabel.text = "\(readySeconds)"
            readySeconds -= 1
        }else if(readySeconds == 0) {
            readyLabel.font = readyLabel.font.withSize(180)
            readyLabel.textColor = UIColor(displayP3Red: 255.0, green: 0.0, blue: 0.0, alpha: 1.0)
            readyLabel.text = "GO!"
            readySeconds -= 1
        }else{
            stopReadyTimer()
        }
    }
    
    func stopReadyTimer(){
        readyTimer.invalidate()
        readyLabel.text = ""
        readyLabel.isHidden = true
        setTimer(startTime: 10)
        self.navigationItem.title = "Player 1"
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
        instructionLabel.isHidden = true
    }
    
    //------- PRIVATE TIMER FUNCTIONS - do not call directly ------
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        
        timerIsRunning = true
    }
    
    //Function to add subview without acitons
    
    func addCustomSubView(_ titleString:String, _ textString:String, _ button1Text:String, _ button2Text:String, _ typeOfView:String){
        
//            self.removeSubView()
//        let window = UIApplication.shared.keyWindow!
//        if (UIDevice.current.orientation == .portrait) {
            subViewX = window.frame.width/2
            subViewY = window.frame.height/2
//        } else {
//            subViewX = window.frame.width/2
//            subViewY = window.frame.height/2
//        }
        navigationController?.navigationBar.isUserInteractionEnabled = false
        navigationController?.navigationBar.tintColor = UIColor.lightGray
        //Define subView
//        let window = UIApplication.shared.keyWindow!
        var popupWidth = window.frame.width/1.5
        if (UIDevice.current.orientation != .portrait) {
        popupWidth = window.frame.height/1.5
        }
        
        
        let titleFieldHeight: CGFloat = 40
        let titleFieldY: CGFloat = 10
        let buttonHeight: CGFloat = 45
        let textFieldY: CGFloat = titleFieldY + titleFieldHeight
        var textFieldHeight: CGFloat = 40
        if typeOfView == "gameOver" { textFieldHeight += 80 }
        let goButtonY: CGFloat = textFieldY + textFieldHeight
        var cancelButtonY: CGFloat = goButtonY
        let spaceBetweenButtons = 10
        if typeOfView == "HIDE" || typeOfView == "gameOver" {
            cancelButtonY = goButtonY + buttonHeight + CGFloat(spaceBetweenButtons)
        }
        let subViewHeight = cancelButtonY + buttonHeight + 20
        //Define height of frame depending on number of buttons needed

        v = UIView(frame: CGRect(x: 0, y: 0, width: popupWidth, height: subViewHeight))
        v.center = window.convert(window.center, from: v)
        v.backgroundColor = UIColor.white
        v.layer.borderWidth = 2
        
        //Add subView styling here
        
        let buttonWidth = v.frame.width/2
        
        //Define title field
        let titleField = UILabel(frame: CGRect(x: 0, y: titleFieldY, width: v.frame.width, height: titleFieldHeight))
        titleField.text = titleString
        titleField.textColor = UIColor.blue
        let fontSize: CGFloat = 20
        titleField.font = UIFont.boldSystemFont(ofSize: fontSize)
        titleField.textAlignment = NSTextAlignment.center
        //Add title field styling here
        
        
        //Define text field
        let textField = UILabel(frame: CGRect(x: 0, y: textFieldY, width: v.frame.width, height: textFieldHeight))
        textField.text = textString
        textField.textAlignment = NSTextAlignment.center
        if typeOfView == "gameOver" {
            textField.lineBreakMode = .byWordWrapping
            textField.numberOfLines = 3
        }
        //Add text field styling here
        
        //Define goButton
        let goButton = UIButton(type: .system)
        goButton.layer.borderWidth = 1
        goButton.backgroundColor = UIColor.white
        goButton.showsTouchWhenHighlighted = true
        goButton.setTitle(button1Text, for: UIControlState.normal)
        if typeOfView == "HIDE" {
        goButton.addTarget(self, action:#selector(switchPlayers), for: .touchUpInside)
        }
        else if typeOfView == "gameOver" {
        goButton.addTarget(self, action:#selector(biggerObject), for: .touchUpInside)
        }
        goButton.frame = CGRect(x: v.frame.width/2 - buttonWidth/2, y: goButtonY, width: buttonWidth - 10, height: buttonHeight)
        goButton.layer.cornerRadius = 20
        //Add goButton styling here

        //Define CancelButton
        let cancelButton = UIButton(type: .system)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderWidth = 1
        cancelButton.backgroundColor = UIColor.white
        cancelButton.showsTouchWhenHighlighted = true
        cancelButton.setTitle(button2Text, for: UIControlState.normal)
        //Add cancelbutton styling here
  
        if typeOfView == "GetPlayer2"
        {
            cancelButton.addTarget(self, action:#selector(readyPlayer2), for: .touchUpInside)
        }
        else if typeOfView == "GameWon" || typeOfView == "gameOver"
        {
            cancelButton.addTarget(self, action:#selector(quitGame), for: .touchUpInside)
            
        }
        else {
            cancelButton.addTarget(self, action:#selector(deletePenquin), for: .touchUpInside)
        }

        cancelButton.frame = CGRect(x: v.frame.width/2 - buttonWidth/2, y: cancelButtonY, width: buttonWidth - 10, height: buttonHeight)

        cancelButton.layer.cornerRadius = 20
        
        //Add all buttons and text to subView
        v.addSubview(titleField)
        if (typeOfView == "HIDE" || typeOfView == "gameOver") {
        v.addSubview(goButton)
        }
        v.addSubview(cancelButton)
        v.addSubview(textField)
        v.layer.cornerRadius = 20
        let backgroundColorUI = UIColor.init(red: 0.537, green: 0.776, blue: 1.0, alpha: 1.0)
        let background = backgroundColorUI.cgColor
        v.layer.backgroundColor = background
        savedView = v
        //Add subView to main view
        popupOnScreen = true
        UIView.animate(withDuration: 1.2, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 30.0, options: .curveEaseInOut, animations: { self.window.addSubview(self.v) })
    }

    //Function to remove subView
    
    func removeSubView() {
        popupOnScreen = false
        navigationController?.navigationBar.isUserInteractionEnabled = true
        navigationController?.navigationBar.tintColor = UIColor.white
        v.removeFromSuperview()
        savedView.removeFromSuperview()
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
                    findPenguinLocation()
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
        addCustomSubView("Game Over", "Oh no! You could not find the penguin in time... wanna know where it was hiding?", "Show me!", "Nope", "gameOver")
    }
    
    //MARK: - Win Logic
    func win() {
        penguinArray.first?.runAction(SCNAction.rotateBy(x: 0, y: CGFloat.pi * 4, z: 0, duration: 1), completionHandler: {
            DispatchQueue.main.async {
                self.winAlert()
            }
           
            
        })
    }
    
    func winAlert() {
         addCustomSubView("You Win!", "You're awesome", "", "Ok!", "GameWon")
    }
}

