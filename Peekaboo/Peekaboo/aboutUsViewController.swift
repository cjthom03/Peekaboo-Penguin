//
//  aboutUsViewController.swift
//  Peekaboo
//
//  Created by Daniel Chen on 6/24/18.
//  Copyright © 2018 Charles Thomas. All rights reserved.
//

import UIKit

class aboutUsViewController: UIViewController {
    
    @IBAction func websiteLink(_ sender: Any) {
        UIApplication.shared.open(URL(string: "http://peekaboopenguin.com/")! as URL, options: [:], completionHandler: nil)
    }
    
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //align text to top of page
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(.zero, animated: false)
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
