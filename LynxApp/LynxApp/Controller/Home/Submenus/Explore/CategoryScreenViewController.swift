//
//  CategoryScreenViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 5/9/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class CategoryScreenViewController: UIViewController {

    
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StoryboardConstants.backgroundColor1
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBack))
        backLabel.isUserInteractionEnabled = true
        backLabel.addGestureRecognizer(tap)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let parentVC = self.parent as? ActiveEventsTableViewController {
            switch (parentVC.categoryName) {
            case "politics" :
                categoryTitleLabel.text = "Politics"
                subtitleLabel.text = "Find political events to wager on."
                break
            case "popculture" :
                categoryTitleLabel.text = "Pop Culture"
                subtitleLabel.text = "Find popular culture related events to wager on."
                break
            case "sports" :
                categoryTitleLabel.text = "Sports"
                subtitleLabel.text = "Find sports related events to wager on."
                break
            default:
                break
            }
        }
    }
    
    @objc func tapBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
