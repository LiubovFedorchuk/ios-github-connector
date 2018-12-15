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
    
    var isSelectedCell = false
    var loadMore = false
    var usersList: [User]?
    var limitedUserList: [User] = []
    var selectedUsersList: [User] = []
    let userManager = UserManager()
    let alertSetUp = AlertSetUp()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNextBarButton()
        navigationItem.title = "Select Users"
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.setHidesBackButton(true, animated:true)
        noUsersSelecedLabel.isHidden = false
        getAllUsers()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setUpNextBarButton() {
        let nextBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(goNextByUserTapped))
        self.navigationItem.rightBarButtonItem  = nextBarButtonItem
    }
    
    @objc func goNextByUserTapped(sender: AnyObject) {
        performSegue(withIdentifier: "ComposeMessage", sender: sender)
        log.debug("Next button tapped.")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ComposeMessage":
            guard let composeMessageViewController = segue.destination as? ComposeMessageViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            composeMessageViewController.collectionView = self.collectionView
            composeMessageViewController.selectedUsersList = self.selectedUsersList
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return limitedUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell.")
        }
        
        let user = limitedUserList[indexPath.row]
        cell.usernameLabel.text = user.username
        cell.userUrlLabel.text = user.userUrl
        if (!isSelectedCell) {
            cell.userCheckmarkButton.setImage(UIImage(named : "unchecked"), for: .normal)
        }
        if (user.avatarUrl != nil) {
            cell.userImageView.setRounded()
            cell.userImageView.image = stringUrlToImage(urlAsString: user.avatarUrl!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isSelectedCell = true
        let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        if (isSelectedCell) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            let selectedUser = self.limitedUserList[indexPath.row]
            selectedUsersList.append(selectedUser)
            cell.userCheckmarkButton.setImage(UIImage(named : "checked"), for: .normal)
        }
        log.debug("selected \(self.limitedUserList[indexPath.row])")
        isSelectedCell = false
        collectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        if (!isSelectedCell) {
            tableView.deselectRow(at: indexPath, animated: true)
            cell.userCheckmarkButton.setImage(UIImage(named : "unchecked"), for: .normal)
            if (selectedUsersList.isEmpty) {
                noUsersSelecedLabel.isHidden = false
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                
            }
            collectionView.reloadData()
        }
        log.debug("deselected \(self.limitedUserList[indexPath.row])")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if (!loadMore && limitedUserList.count != usersList?.count) {
                loadMoreData(allUserList: usersList!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(70)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsersList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedUserCollectionViewCell", for: indexPath) as! SelectedUserCollectionViewCell
        let selectedUser = selectedUsersList[indexPath.row]
        if (selectedUsersList.isEmpty) {
            noUsersSelecedLabel.isHidden = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            noUsersSelecedLabel.isHidden = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            cell.selectedUserLabel.text = selectedUser.username
            if(selectedUser.avatarUrl != nil) {
                cell.selectedUserImageView.setRounded()
                cell.selectedUserImageView!.image = stringUrlToImage(urlAsString: selectedUser.avatarUrl!)
            }
            cell.deleteSelectedUserButton.tag = indexPath.row
            cell.deleteSelectedUserButton.addTarget(self, action: #selector(deleteUserButtonClicked), for: .touchUpInside)
        }
        return cell
    }
    
    @IBAction func deleteUserButtonClicked(sender: UIButton) -> Void {
        selectedUsersList.remove(at: sender.tag)
        let rowToSelect:IndexPath = IndexPath(row: sender.tag, section: 0)
        tableView(tableView, didDeselectRowAt: rowToSelect)
        collectionView.reloadData()
    }

    private func getAllUsers() {
        userManager.getUsers(completionHandler: { user, status in
            if (user != nil && status == 200) {
                self.usersList = user!
                self.limitedUserList = self.showFirst30Users(fullArray: user!)
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
    
    func showFirst30Users(fullArray: [User]) -> [User] {
        limitedUserList = Array(fullArray.prefix(30))
        log.debug(limitedUserList.count)
        return limitedUserList
    }
    
    func loadMoreData(allUserList: [User]) {
        loadMore = true
        let indexOfLimitedUserList = limitedUserList.count
        let indexOfAllUserList = allUserList.count
        let diff = indexOfAllUserList - indexOfLimitedUserList
        if (indexOfLimitedUserList != indexOfAllUserList && diff >= 30) {
            for i in indexOfLimitedUserList ..< indexOfLimitedUserList + 30 {
                limitedUserList.append(allUserList[i])
            }
            log.debug("More users have loaded.")
        } else if (indexOfLimitedUserList != indexOfAllUserList && diff > 0) {
            for i in indexOfLimitedUserList ..< indexOfLimitedUserList + diff {
                limitedUserList.append(allUserList[i])
            }
            log.debug("Last part of users have loaded.")
        }
        loadMore = false
        tableView.reloadData()
    }
    
    private func stringUrlToImage(urlAsString: String) -> UIImage {
        let url = URL(string: urlAsString)
        let data = try? Data(contentsOf: url!)
        let image = UIImage(data: data!)
        return image!
    }
}

