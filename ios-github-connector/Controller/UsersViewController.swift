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
//        collectionView.isHidden = true
        noUsersSelecedLabel.isHidden = false
        getAllUsers()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
//    private func setUpImageView(imageView: UIImageView) -> UIImageView {
//        imageView.layer.cornerRadius = 100.0
//        imageView.layer.masksToBounds = true
//        return imageView
//    }
    
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
            let avatarUrl = URL(string: user!.avatarUrl!)
//            DispatchQueue.global().async {
                let data = try? Data(contentsOf: avatarUrl!)
//                if let data = data {
//                    let image =
//                    DispatchQueue.main.async {
            cell.imageView!.image = UIImage(data: data!)
//                    }
//                }
//            }
        }
        
//        cell.userCheckmarkButton.tag = indexPath.row
//        cell.userCheckmarkButton.setImage(UIImage(named : "unchecked"), for: .normal)
//        cell.userCheckmarkButton.setImage(UIImage(named : "checked"), for: .selected)
//        
//        cell.userCheckmarkButton.addTarget(self, action: #selector(userCheckmarkButtonClicked), for: .touchUpInside)
        return cell
    }
    
//    @objc func userCheckmarkButtonClicked(sender : UIButton) {
//        sender.isSelected = !sender.isSelected
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isSelectedCell = true
        let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        if (isSelectedCell) {
            cell.userCheckmarkButton.setImage(UIImage(named : "checked"), for: .normal)
        }
        log.debug("selected \(self.usersList![indexPath.row])")
        isSelectedCell = false
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedUserCollectionViewCell", for: indexPath) as! SelectedUserCollectionViewCell
        let selectedUser = selectedUsersList?[indexPath.item]
        if (selectedUser == nil) {
            noUsersSelecedLabel.isHidden = false
        } else {
            noUsersSelecedLabel.isHidden = true
            cell.selectedUserLabel.text = selectedUser!.username
            if(selectedUser?.avatarUrl != nil) {
                let avatarUrl = URL(string: selectedUser!.avatarUrl!)
                let data = try? Data(contentsOf: avatarUrl!)
                cell.selectedUserImageView!.image = UIImage(data: data!)
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
}

