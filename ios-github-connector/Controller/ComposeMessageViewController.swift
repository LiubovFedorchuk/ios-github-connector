//
//  ComposeMessageViewController.swift
//  ios-github-connector
//
//  Created by Liubov Fedorchuk on 12/15/18.
//  Copyright © 2018 Liubov Fedorchuk. All rights reserved.
//

import UIKit

class ComposeMessageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var sendTextToSelectedUsersButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noUsersSelecedLabel: UILabel!
    
    var selectedUsersList: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedUsersList.count == 0 {
            noUsersSelecedLabel.isHidden = false
            sendTextToSelectedUsersButton.isEnabled = false
        }
        return selectedUsersList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedUserCollectionViewCell", for: indexPath) as! SelectedUserCollectionViewCell
        let selectedUser = selectedUsersList[indexPath.row]
        noUsersSelecedLabel.isHidden = true
        cell.selectedUserLabel.text = selectedUser.username
        if(selectedUser.avatarUrl != nil) {
            cell.selectedUserImageView.setRounded()
            cell.selectedUserImageView!.image = stringUrlToImage(urlAsString: selectedUser.avatarUrl!)
        }
        cell.deleteSelectedUserButton.tag = indexPath.row
        cell.deleteSelectedUserButton.addTarget(self, action: #selector(deleteUserButtonClicked), for: .touchUpInside)
        return cell
    }
    
    @IBAction func deleteUserButtonClicked(sender: UIButton) -> Void {
        selectedUsersList.remove(at: sender.tag)
        self.collectionView.reloadData()
    }
    
    private func stringUrlToImage(urlAsString: String) -> UIImage {
        let url = URL(string: urlAsString)
        let data = try? Data(contentsOf: url!)
        let image = UIImage(data: data!)
        return image!
    }
}
