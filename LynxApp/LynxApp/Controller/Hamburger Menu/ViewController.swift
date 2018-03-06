//
//  ViewController.swift
//  Menu
//
//  Created by Colin Dolese on 2/14/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Another VC"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
    }

    func done() {
        dismiss(animated: true, completion: nil)
    }

}
