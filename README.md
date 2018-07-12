# Peekaboo Penguin

[Web Page](http://peekaboopenguin.com/)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![AppStoreLink](./PlanningDocs/AppStoreLink.png)

## Background and Overview

Peekaboo Penguin is a mobile application and hide-n-seek style game in which one player hides a small, digital 3D Penguin somewhere in augmented reality and another player must find that penguin within a given timeframe.

The penguin can be placed on a flat surface or simply anywhere in 3d space that the hiding player would like. The hiding player is also subject to a time constraint, to keep the game play fast paced and interesting.

The searching player will not be able to see the penguin unless they are within a certain distance, to avoid being able to detect the penguin through walls or other physical objects. If the searching player cannot find the penguin in the timeframe given, the searcher will have the option to make the penguin visible and grow in size - revealing its hiding spot to the player.


![demo](https://res.cloudinary.com/dchen3/image/upload/c_scale,h_529/v1530483601/penguin.gif)

Peekaboo Penguin was a 7 day project made from scratch. To see more details on how this project was planned, here is a link to the [proposal](https://github.com/cjthom03/Flex-Project/blob/Staging/PlanningDocs/plan.md).

***

## Technology

Peekaboo Penguin is built with...
  * Swift, using xCode 9.4 - Apple’s Model-View-Controller (MVC) framework and development environment.

  * ARKit, Apple’s developers toolkit for augmented reality apps.

  * SceneKit, Apple’s software for creating and using 3D models.

***

## Key Features
  * Users can scroll through direction pages to learn how to play the game
  * Users can go to the about us page to directly visit our website.
  * Users can click new game to begin a new game.
  * A timer runs to give users a limited time to either hide or find the penguin.
  * The game has button popups that will prompt or congratulate users upon interactions.
  * The hider will be able to hide the penguin in virtual space.
  * The hider can confirm or deny the penguin placement.
  * If the timer runs out of time for the hider, the penguin will be placed automatically in front of the user's current location.
  * The penguin will become hidden when the phone is 3m away from the penguin.
  * The penguin will become visible and provide audio feedback if it is less than 3m away from the phone.
  * If the seeker finds the penguin and taps the penguin, the penguin will spin upon winning.
  * If the timer runs out for the seeker or if they give up, the seeker will have an option to either return to the main page or have the penguin increase in size.

### Adding Penguin

We created two ways to add the penguin. The penguin will be added upon screen touch or if the user runs out of time.

```swift
func addPenquin(atLocation location: ARHitTestResult){
    let scene = SCNScene(named: "art.scnassets/tux.scn")!

    if let sceneNode = scene.rootNode.childNode(withName: "penguin", recursively:true) {
        sceneNode.position = SCNVector3(
            x: location.worldTransform.columns.3.x,
            y: location.worldTransform.columns.3.y + 0.022,
            z: location.worldTransform.columns.3.z
        )

        appendPenguinToScene(penguin: sceneNode)
    }
}

func addPenguin(matrix: float4x4) {
    let scene = SCNScene(named: "art.scnassets/tux.scn")!

    if let sceneNode = scene.rootNode.childNode(withName: "penguin", recursively:true) {
        let x = matrix.columns.3.x
        let y = matrix.columns.3.y
        let z = matrix.columns.3.z
        sceneNode.position = SCNVector3(x, y, z)

        appendPenguinToScene(penguin: sceneNode)
    }
}

```

In the first function, we pass in the location that the users touch on their screens. From that, we are able to set the penguin location using SCNVector3 and passing it those values. The y location has an offset of 0.022 to account for the height of the penguin, so it does not stay below a plane surface. The second function will only run if the timer has ran out for the seeker. The phone's current location when the timer runs out will be passed to the function. From that, we will place the penguin in virtual space in front of the screen automatically.

### Penguin Rotation

A challenge we had was making the penguin face and rotate from the center of the penguin. The penguin object we used in SceneKit had its pivot point on its left hand. To account for the pivot point, we had to adjust the penguin's pivot point like so :

```swift
func penguinPivot (penguin: SCNNode) {
    // change the pivot point of the penguin
    let box = penguin.boundingBox
    let x = (box.max.x - box.min.x) / 2
    let translationMatrix = SCNMatrix4Mult(SCNMatrix4MakeTranslation(-x, 0, 0), SCNMatrix4MakeRotation(Float(37 * Float.pi/180), 0, 1, 0))
    penguin.pivot = translationMatrix
}

func lookAtCamera(node penguin: SCNNode) {
    //force the penguin to face the camera
    let yaw = sceneView.session.currentFrame?.camera.eulerAngles.y
    penguin.eulerAngles.y = - yaw!
}

```

In penguinPivot, we manipulate the penguin's pivot point by finding the width of it using .boundingBox and finding the midpoint. Rotating our penguin by 37 degrees is the solution we found to make the penguin stand up straight when placed in virtual space. Since we only want to make the penguin spin, we just need to rotate it by the the new pivot point we found earlier. We then call in SCNNode's built in pivot function and pass it the matrix we created with the rotation points.


![spin](https://res.cloudinary.com/dchen3/image/upload/c_scale,h_541/v1530483031/spin.gif)

In lookAtCamera, we find the camera's current yaw angle: "yaw". The penguin's yaw, "y", is then set to -yaw:

![highschool geometry ftw](https://i.imgur.com/z91sbAB.png)

***

## Additional Resources
  To learn more about the technologies we used for this project....
  * [Swift](https://developer.apple.com/swift/)
  * [ARKit](https://developer.apple.com/arkit/)
  * [SceneKit](https://developer.apple.com/scenekit/)

## Future Features
  * Single player version
