//
//  SettingsViewController.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 06/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var chargerTypes: [ChargerType] = []
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chargerTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        let chargerType = self.chargerTypes[indexPath.row]
        cell.textLabel?.text = chargerType.title
        cell.accessoryType = chargerType.isHidden ? .none : .checkmark
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chargerType = self.chargerTypes[indexPath.row]
        chargerType.isHidden = !chargerType.isHidden
        self.tableView.reloadData()
    }
    
    // MARK: - View cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
}
