//
//  UsersViewController.swift
//  ios-github-connector
//
//  Created by Liubov Fedorchuk on 12/1/18.
//  Copyright © 2018 Liubov Fedorchuk. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let limit = 30
    var usersList: [User]?
    let userManager = UserManager()
    let alertSetUp = AlertSetUp()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getAllUsers()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == usersList!.count - 1) {
            //todo
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell.")
        }
        
        let user = usersList?[indexPath.row]
        cell.usernameLabel.text = user!.username
        cell.userUrlLabel.text = user!.userUrl
        if (user!.avatarUrl != nil) {
            let avatarUrl = URL(string: user!.avatarUrl!)
            let data = try? Data(contentsOf: avatarUrl!)
            cell.imageView!.image = UIImage(data: data!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    private func getAllUsers() {
        userManager.getUsers(completionHandler: { user, status in
            if (user != nil && status == 200) {
                self.usersList = user!
                self.tableView.reloadData()
            } else {
                guard status != nil else {
                    let alert = self.alertSetUp.showAlert(alertTitle: "Unexpected error", alertMessage: "Please, try again later.")
                    self.present(alert, animated: true, completion: nil)
                    log.error("Unexpected error without status code.")
                    return
                }
                
                self.alertSetUp.showAlertAccordingToStatusCode(fromController: self, statusCode: status!)
            }
        })
    }
}

