//
//  titleViewController.swift
//  Peekaboo
//
//  Created by Daniel Chen on 6/24/18.
//  Copyright © 2018 Charles Thomas. All rights reserved.
//

import UIKit
import AVFoundation

var happyMusic: AVAudioPlayer?
var happyMusicPlaying: Bool = false

class titleViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
        //force orientation to portrait
        if (UIDevice.current.orientation != .portrait) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !happyMusicPlaying {
            let path = Bundle.main.path(forResource: "art.scnassets/happy.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            do {
                happyMusic = try AVAudioPlayer(contentsOf: url)
                happyMusic?.play()
                happyMusic?.numberOfLoops = -1
                happyMusic?.volume = 0.1
                happyMusicPlaying = true
            } catch {
                
            }
        }
       

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //change navbar color and font color
    override func viewDidAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
