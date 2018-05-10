//
//  ExploreEventsCollectionViewController.swift
//  LynxApp
//
//  Created by Bill Kwai on 5/1/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class ExploreEventsCollectionViewController: UICollectionViewController {
    
    // MARK: - Variables
    var categoryImageArray: [UIImage] = [
        UIImage (named: "politics-category-button")!,
        UIImage (named: "pop-culture-category-button")!,
        UIImage (named: "sports-category-button")!,
        UIImage (named: "null-category-button")!,
        UIImage (named: "null-category-button")!,
        UIImage (named: "null-category-button")!
    ]
    
    var categoryNameArray: [String] = [
        "politics",
        "popculture",
        "sports",
        "locked",
        "locked",
        "locked"
    ]
    
    var displayNameDic = [
        "politics": "Politics",
        "popculture": "Pop Culture",
        "sports": "Sports"
    ]
    
    // MARK: - Properties
    fileprivate let reuseIdentifier = "exploreEventCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 25.0, left: 25.0, bottom: 25.0, right: 25.0)
    fileprivate let itemsPerRow: CGFloat = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        self.collectionView?.allowsSelection = true
        self.collectionView?.isUserInteractionEnabled = true
        self.collectionView?.backgroundColor = StoryboardConstants.backgroundColor1
        self.navigationController?.navigationBar.barTintColor = StoryboardConstants.backgroundColor1
        self.navigationController?.navigationBar.tintColor = StoryboardConstants.tintColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromCategorySegue" {
            guard let cell = sender as? ExploreEventCollectionViewCell else {
                assertionFailure("Failed to unwrap sender. Try to set a breakpoint here and check what sender is")
                return
            }
            let destinationVC = segue.destination as! ActiveEventsTableViewController
            guard let categoryName = cell.categoryName else {
                assertionFailure("The cell has no image in image view")
                return
            }
            destinationVC.categoryName = categoryName
            destinationVC.displayName = displayNameDic[categoryName]
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return categoryImageArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ExploreEventCollectionViewCell
        
        // Sets cell to correct icon
        cell.categoryImageView.image = categoryImageArray[indexPath.row]
        cell.categoryName = categoryNameArray[indexPath.row]
        cell.isUserInteractionEnabled = true
        cell.categoryImageView.isUserInteractionEnabled = false
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension ExploreEventsCollectionViewController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
