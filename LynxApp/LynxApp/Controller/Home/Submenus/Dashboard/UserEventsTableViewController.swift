//
//  UserEventsTableViewController.swift
//  LynxApp
//
//  Created by Colin James Dolese on 2/16/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit
import CoreData

class UserEventsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var fetchedResultsController: NSFetchedResultsController<Event>!

    var categoryImageArray: [UIImage] = [
        UIImage (named: "politics")!,
        UIImage (named: "popculture")!,
        UIImage (named: "sports")!,
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.backgroundColor = StoryboardConstants.backgroundColor1
        initializeFetchedResultsController()
    }
    

    
    
    
    func initializeFetchedResultsController() {
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        
        //request.predicate = NSPredicate(format: "expiresIn > 0 && pickTimestamp == nil")
        request.predicate = NSPredicate(format: "pickedOutcomeId != 0")
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Adds a label when user has no picks and table is empty
        //            let emptyLabel = UILabel(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width, height:self.view.bounds.size.height))
        //            emptyLabel.text = "Swipe left to discover more events!"
        //            emptyLabel.textAlignment = NSTextAlignment.center
        //            self.tableView.backgroundView = emptyLabel
        //            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
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
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardConstants.UserEventCell, for: indexPath) as! UserEventCell
        let event = self.fetchedResultsController.object(at: indexPath)
        cell.eventTitleLabel.text = event.eventTitle
        let outcome1 = event.outcomes![0] as! Outcome
        let outcome2 = event.outcomes![1] as! Outcome
        cell.outcome1Label.text = outcome1.title
        cell.outcome2Label.text = outcome2.title
        if (event.pickedOutcomeId == outcome1.id) {
            cell.outcome1Label.textColor = UIColor.purple
            cell.outcome1Label.font = UIFont(name:"Futura-Bold", size: cell.outcome1Label.font.pointSize)

        } else {
            cell.outcome2Label.textColor = UIColor.purple
            cell.outcome2Label.font = UIFont(name:"Futura-Bold", size: cell.outcome2Label.font.pointSize)
        }
            
        
        cell.wagerLabel.text = "You wagered " + String(event.betSize) + " coins"
        cell.backgroundColor = StoryboardConstants.backgroundColor1

        
        switch (event.categoryName) {
        case "POLITICS": cell.categoryImage.image = categoryImageArray[0]
        case "POP CULTURE": cell.categoryImage.image = categoryImageArray[1]
        case "SPORTS": cell.categoryImage.image = categoryImageArray[2]
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
            if times.0 >= 1000 {
                cell.timeNumberLabel.font = cell.timeUnitLabel.font.withSize(14)
            }
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
        } else if (times.3 > 0) {
            cell.timeNumberLabel.text = "1"
            cell.timeUnitLabel.text = "Min"
        } else {
            cell.timeNumberLabel.font = cell.timeNumberLabel.font.withSize(10)
            cell.timeUnitLabel.text = ""
            // label and color based on whether pick was correct
            if (event.pickCorrect != -1) {
                if (event.pickedOutcomeId == outcome1.id) {
                    if (event.pickCorrect == 1) {
                        cell.timeNumberLabel.text = "Correct!"
                        cell.timeNumberLabel.textColor = UIColor.purple
                        cell.wagerLabel.text = "You won " + String(event.correctPayout) + " coins"
                    } else {
                        cell.timeNumberLabel.text = "Wrong!"
                        cell.timeNumberLabel.textColor = UIColor.red
                        cell.wagerLabel.text = "You lost " + String(event.betSize) + " coins"
                        cell.wagerLabel.textColor = UIColor.red

                    }
                } else {
                    if (event.pickCorrect == 1) {
                        cell.timeNumberLabel.text = "Correct!"
                        cell.timeNumberLabel.textColor = UIColor.purple
                        cell.wagerLabel.text = "You won " + String(event.correctPayout) + " coins"
                    } else {
                        cell.timeNumberLabel.text = "Wrong!"
                        cell.timeNumberLabel.textColor = UIColor.red
                        cell.wagerLabel.text = "You lost " + String(event.betSize) + " coins"
                        cell.wagerLabel.textColor = UIColor.red
                    }
                }
            } else {
                cell.timeNumberLabel.text = "Pending"
            }

        }
        
        cell.drawProgressLayer()
        // incremented is how much the progress bar shows based on team 1's pool size relative to the whole pool
        let odds = CGFloat((outcome1.pool))/CGFloat(outcome1.pool + outcome2.pool)
        cell.rectProgress(incremented: (odds * (cell.oddsBarView.bounds.width - 20)))
        cell.layer.borderWidth = 0.25
        cell.layer.borderColor = StoryboardConstants.tintColor.cgColor
        
        // makes cells unselectable until we implement functionality for this feature
        cell.isUserInteractionEnabled = false
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardConstants.UserEventsHeaderCell)
        cell?.contentView.backgroundColor = StoryboardConstants.backgroundColor1
        return cell?.contentView
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0,2:
            return 45
        default:
            return 60
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    


}
