//
//  HamburgerViewController.swift
//  Menu
//
//  Created by Colin Dolese on 2/14/18.
//  Copyright © 2018 Colin Dolese. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var hamburgerTable: UITableView!
    
    var viewModel = HamburgerViewModel()
    var rows: [HamburgerLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rows = viewModel.allLayers()
        hamburgerTable.tableFooterView = UIView()
        
    }

    //MARK: Menu Actions
    
    func homeAction() {
    }
        
    
    
    func settingsAction() {
    }
    
    
    func contactUsAction() {
    }
    
    
    func helpAction() {
    }
    
    func logoutAction() {
        
    }
    
    
    
}

extension HamburgerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row: HamburgerLayer = rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.identifier, for: indexPath) as! HamburgerCell
        cell.lblTitle.text = row.name
        cell.icon.image = UIImage(named: row.iconName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let menuVC: MenuViewController = self.parent as? MenuViewController else { return }
        menuVC.hideMenu()
        
        let row = rows[indexPath.row]
        if row == .logout {
            let removed = KeychainWrapper.standard.removeAllKeys()
            if (removed) {
                let vc = storyboard?.instantiateViewController(withIdentifier: StoryboardConstants.LoginVC)
                present(vc!, animated: true, completion: nil )
            }

        } else if row != .home {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController")
            let navCont = UINavigationController(rootViewController: vc!)
            present(navCont, animated: true, completion: nil)
        }
        
        switch row {
        case .home: homeAction()
        case .settings: settingsAction()
        case .contactUs: contactUsAction()
        case .help: helpAction()
        case .logout: logoutAction()
        }
    }

}
