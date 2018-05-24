//
//  TableSectionHeader.swift
//  LynxApp
//
//  Created by Bill Kwai on 5/24/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//
import UIKit

protocol StatusFilterDelegate: class {
    func didChangeSelection(value: Int)
}

class TableSectionHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var filterStatusSegment: UISegmentedControl!
    
    // 0 = active events. 1 = concluded events
    var selectedSegment: Int!
    
    weak var delegate: StatusFilterDelegate?
    
    @IBAction func indexChanged(_ sender: AnyObject) {
        if let segment = sender as? UISegmentedControl {
            selectedSegment = segment.selectedSegmentIndex
            delegate?.didChangeSelection(value: selectedSegment)
        }
    }
}
