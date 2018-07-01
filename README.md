# Peekaboo Penguin

[Web Page](http://peekaboopenguin.com/)

## Background and Overview
Peekaboo Penguin is a mobile application and hide-n-seek style game in which one player hides a small, digital 3D Penguin somewhere in augmented reality and another player must find that penguin within a given timeframe.

The penguin can be placed on a flat surface or simply anywhere in 3d space that the hiding player would like. The hiding player is also subject to a time constraint, to keep the game play fast paced and interesting.

The searching player will not be able to see the penguin unless they are within a certain distance, to avoid being able to detect the penguin through walls or other physical objects. If the searching player cannot find the penguin in the timeframe given, the penguin will become visible and will grow - revealing its hiding spot to the player.

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
    penguin.eulerAngles.y = (2 * Float.pi) - yaw!
}

```

In penguinPivot, we manipulate the penguin's pivot point by finding the width of it using .boundingBox and finding the midpoint. Rotating our penguin by 37 degrees is the solution we found to make the penguin stand up straight when placed in virtual space. Since we only want to make the penguin spin, we just need to rotate it by the 





## Documentation
- [ ] Full readme
- [ ] Demo Site
- [ ] App Store details

### Bonus Features
- [ ] Single player version
- [ ] Instructions and UI components rendered in AR

***

## Group Members and Responsibilities
The team includes 4 members: Charlie Thomas, Aakash Sarang, Nate Cunha, and Daniel Chen

Charlie’s primary responsibilities include:
* Managing Timeline
* Logic for object hit testing (user can tap on an object to end the game)
* Handling the game’s Win condition(s) and outcome
* Writing the game directions/rules to be displayed to the user
* Getting Application deployed on the app store

Aakash’s primary responsibilities include:
* Feature Manager - Game functions as planned
* Handles all button actions and transitions
* Logic for quit/lose conditions and game restart
* Writing the ‘About Us’ section of the app

Nate’s primary responsibilities include:
* UX Manager - The game runs smoothly and is fun to play
* Play testing manager - Gather playtest feedback to improve game
* Logic for calculating relative distances in 3D space
* Handles location-based events (e.g. to provide user with feedback)

Daniel’s primary responsibilities include:
* UI Manager - The game layout is intuitive and aesthetically pleasing
* Rendering and placement of objects in 3D space
* Styling ‘Directions’ & ‘About Us’ views
* Manage Demo Site setup (will be assisted by all)

***

## Schedule & Work Breakdown

Each day will begin with a Stand Up meeting at 9:05am to review the schedule and goals for the day, discuss roadblocks, and adjust the schedule and workload as needed. Each day will conclude with one person doing a code review for another on the team.

### Phase 1 - Basic Game Logic - (2.5 days)
* All UI components (unstyled) are in place (Daniel)
* 3D Object render in user designated placements (Daniel)
* Button actions are linked to View Controller and functional (Aakash)
* Transition between views are functional (Aakash)
* Object hitTesting is functional (Charlie)
* Basic Win conditions (Charlie)
* Basic Lose/Quit conditions (Aakash)
* Distance relative to origin / user is calculated (Nate)
* Object rendering distance events are functional (Nate)
* Game Directions are complete (Charlie)
* About Us section is complete (Aakash)


### Phase 2 - Polish and Playtest (1.5 days)
* PlayTest (All)
* Gather playtest feedback and provide adjustments needed (Nate)
* UX/UI adjustments based on playtest feedback (All)
* User feedback distance events are functional (Nate)
* Timer(s) are functional (Charlie)
* Timer events are functional (Nate)
* Finalize Plane detection logic (Daniel)
* UI components are styled appropriately (Daniel)
* Advanced win conditions are complete (Charlie)
* Advanced lose conditions are complete (Charlie)


### Phase 3 - Go Live - (1 day)
* Final styling/UI/UX adjustments (Aakash and Nate)
* Gather final assets and info needed to submit to App store (Aakash and Nate)
* Submit to the App Store for review (Charlie)
* Register Domain for Demo Site (Charlie)
* Build Demo Site (Daniel + All)

***

## Getting Users and Reviews
* Charlie will submit the app for review on the App store.
* All members will each share with at least 20 friends and family members.
* Soft launch with close friends.
