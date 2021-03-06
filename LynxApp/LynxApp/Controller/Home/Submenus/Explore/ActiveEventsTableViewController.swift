//
//  ActiveEventsTableViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ActiveEventsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    
    var fetchedResultsController: NSFetchedResultsController<Event>!
    var categoryName: String!
    var displayName: String!

    var categoryImageArray: [UIImage] = [
        UIImage (named: "politics")!,
        UIImage (named: "popculture")!,
        UIImage (named: "sports")!,
        ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension

        
        self.view.backgroundColor = StoryboardConstants.backgroundColor1

        self.title = displayName
        initializeFetchedResultsController()

    }
    

    
    func initializeFetchedResultsController() {
        
        var categoryDescriptor = ""
        switch  categoryName {
            case "politics" : categoryDescriptor = "POLITICS"
            break
            case "sports" : categoryDescriptor = "SPORTS"
            break
            case "popculture" : categoryDescriptor = "POP_CULTURE"
            break
        default:
            break
            
        }
        
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.predicate = NSPredicate(format: "expiresIn > 0 && pickedOutcomeId == 0 && categoryName == %@", categoryDescriptor)
        let timeSort = NSSortDescriptor(key: "expiresIn", ascending: false)
        request.sortDescriptors = [timeSort]
        let moc = SessionState.coreDataManager.persistentContainer.viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Delegation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentCell = tableView.cellForRow(at: indexPath) as? ActiveEventCell {
            // Track active event selection
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [AnalyticsParameterContentType: "new-active-event", AnalyticsParameterItemID: currentCell.eventTitleLabel.text!, AnalyticsParameterItemCategory: self.categoryName, AnalyticsParameterValue: currentCell.timeNumberLabel.text! + currentCell.timeUnitLabel.text!])
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    private func secondsToDaysHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int, Int) {
        return (seconds / 86400, (seconds % 86400) / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardConstants.ActiveEventCell, for: indexPath) as! ActiveEventCell
        let event = self.fetchedResultsController.object(at: indexPath)
        cell.eventTitleLabel.text = event.eventTitle
        let outcome1 = event.outcomes![0] as! Outcome
        let outcome2 = event.outcomes![1] as! Outcome
        cell.outcome1Label.text = outcome1.title
        cell.outcome2Label.text = outcome2.title
        
        cell.poolSizeLabel.text = "Pool Size: " + String(outcome1.pool + outcome2.pool)
        
        let title1 = (outcome1.title)!
        let title2 = (outcome2.title)!
        let poolTotal = Double((outcome1.pool) + (outcome2.pool))
        if (poolTotal > 0) {
            var percent1 = Double((outcome1.pool))/poolTotal * 100
            var percent2 = Double((outcome2.pool))/poolTotal * 100
            percent1.round()
            percent2.round()
            cell.poolSizeLabel.text = "\(Int(percent1))% \(title1) - \(Int(percent2))% \(title2)"
        } else {
            cell.poolSizeLabel.text = "50% \(title1) - 50% \(title2)"
        }
        
        switch (categoryName) {
        case "politics": cell.categoryImage.image = categoryImageArray[0]
        case "pop culture": cell.categoryImage.image = categoryImageArray[1]
        case "sports": cell.categoryImage.image = categoryImageArray[2]
        default: break
        }
        // Time labels
        let times = secondsToDaysHoursMinutesSeconds(seconds: Int(event.expiresIn))
        if (times.0 == 1) {
            cell.timeNumberLabel.text = "\(times.0)"
            cell.timeUnitLabel.text = "Day"
        } else if (times.0 > 0) {
            cell.timeNumberLabel.text = "\(times.0)"
            cell.timeUnitLabel.text = "Days"
        } else if (times.1 > 1) {
            cell.timeNumberLabel.text = "\(times.1)"
            cell.timeUnitLabel.text = "Hours"
        } else if (times.1 > 0) {
            cell.timeNumberLabel.text = "\(times.1)"
            cell.timeUnitLabel.text = "Hour"
        }
        else if (times.2 > 0) {
            cell.timeNumberLabel.text = "\(times.2)"
            cell.timeUnitLabel.text = "Mins"
        } else {
            cell.timeNumberLabel.text = "1"
            cell.timeUnitLabel.text = "Min"
        }
        
        cell.drawProgressLayer()
        // incremented is how much the progress bar shows based on outcome 1's pool size relative to the whole pool
        let odds = CGFloat((outcome1.pool))/CGFloat(outcome1.pool + outcome2.pool)
        cell.rectProgress(incremented: (odds * (cell.oddsBarView.bounds.width - 10)))
        cell.layer.borderWidth = 0.25
        cell.layer.borderColor = StoryboardConstants.tintColor.cgColor
        
        return cell
    }
 
    // alternate row colors
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = AppTheme.fadedPurple
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            break
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .move:
            break
            //tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - Navigation
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        if let destinationVC = segue.destination as? DetailedBetViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                switch self.categoryName {
                case "politics": destinationVC.categoryImage = categoryImageArray[0]
                case "popculture": destinationVC.categoryImage = categoryImageArray[1]
                case "sports": destinationVC.categoryImage = categoryImageArray[2]
                default: break
                }
                destinationVC.eventManagedId = self.fetchedResultsController.object(at: indexPath).objectID
            }
        }
        

    }
    
    


}
