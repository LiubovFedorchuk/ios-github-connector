//
//  UsersViewController.swift
//  ios-github-connector
//
//  Created by Liubov Fedorchuk on 12/1/18.
//  Copyright © 2018 Liubov Fedorchuk. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noUsersSelecedLabel: UILabel!
    
    var limit = 10
    var isSelectedCell = false
    var usersList: [User]?
    var selectedUsersList: [User]?
    let userManager = UserManager()
    let alertSetUp = AlertSetUp()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isHidden = true
        noUsersSelecedLabel.isHidden = false
        getAllUsers()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell.")
        }
        
        let user = usersList?[indexPath.row]
        cell.usernameLabel.text = user!.username
        cell.userUrlLabel.text = user!.userUrl
        if (!isSelectedCell) {
            cell.userCheckmarkButton.setImage(UIImage(named : "unchecked"), for: .normal)
        }
        if (user!.avatarUrl != nil) {
            cell.userImageView.setRounded()
            cell.userImageView.image = stringUrlToImage(urlAsString: user!.avatarUrl!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isSelectedCell = true
        collectionView.isHidden = false
        let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        if (isSelectedCell) {
            let selectedUser = usersList?[indexPath.row]
            selectedUsersList?.append(selectedUser!)
            cell.userCheckmarkButton.setImage(UIImage(named : "checked"), for: .normal)
        }
        log.debug("selected \(self.usersList![indexPath.row])")
        isSelectedCell = false
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        isSelectedCell = false
        let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        if (!isSelectedCell) {
            cell.userCheckmarkButton.setImage(UIImage(named : "unchecked"), for: .normal)
        }
        log.debug("deselected \(self.usersList![indexPath.row])")
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(70)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsersList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.isHidden = false
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedUserCollectionViewCell", for: indexPath) as! SelectedUserCollectionViewCell
        let selectedUser = selectedUsersList?[indexPath.item]
        if (selectedUser == nil) {
            noUsersSelecedLabel.isHidden = false
        } else {
            noUsersSelecedLabel.isHidden = true
            cell.selectedUserLabel.text = selectedUser!.username
            if(selectedUser?.avatarUrl != nil) {
                cell.selectedUserImageView.setRounded()
                cell.selectedUserImageView!.image = stringUrlToImage(urlAsString: selectedUser!.avatarUrl!)
            }
        }
        return cell
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
    
    private func stringUrlToImage(urlAsString: String) -> UIImage {
        let url = URL(string: urlAsString)
        let data = try? Data(contentsOf: url!)
        let image = UIImage(data: data!)
        return image!
    }
}

