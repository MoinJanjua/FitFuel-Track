//
//  SettingsViewController.swift
//  ShareWise Ease
//
//  Created by Maaz on 18/10/2024.
//

import UIKit

class SettingsViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

   
    @IBOutlet weak var SettingTB: UITableView!
    @IBOutlet weak var vesion_Label: UILabel!
    @IBOutlet weak var userView1: UIView!

    @IBOutlet weak var userBioLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var UserProfileShow: UIImageView!

    var user_Detail: [User] = []
    
    var settingList = [String]()
    var settingImgs = ["H","A","Remove","F","S","P"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDropShadow(to: userView1)
        
        settingList = ["Home","About Us","Clear All Data","Feedback","Share App","Privacy Notice"]
        SettingTB.delegate = self
        SettingTB.dataSource = self
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "N/A"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] ?? "N/A"
        vesion_Label.text = "Version \(version) (\(build))"
  
        makeImageViewCircular(imageView: UserProfileShow)
        
     
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // Display user details
     
        loadData()
        loadUserDetails()
        
    }
    func loadUserDetails() {
        // Load data from UserDefaults for user_Detail
        if let savedData = UserDefaults.standard.array(forKey: "userDataDetails") as? [Data] {
            let decoder = JSONDecoder()
            user_Detail = savedData.compactMap { data in
                do {
                    let user = try decoder.decode(User.self, from: data)
                    return user
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        if let firstUser = user_Detail.first {
            
            userNameLbl.text = "\(firstUser.username)"
        }
    }
    func makeImageViewCircular(imageView: UIImageView) {
           // Ensure the UIImageView is square
           imageView.layer.cornerRadius = imageView.frame.size.width / 2
           imageView.clipsToBounds = true
       }

    private func NavToWelcome() {
        // Implement your data clearing logic here
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeOneViewController") as! WelcomeOneViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
        private func clearUserData() {
            // Remove keys related to user data but not login information
            UserDefaults.standard.removeObject(forKey: "userDataDetails")
            UserDefaults.standard.removeObject(forKey: "currentWaterIntake")
            UserDefaults.standard.removeObject(forKey: "lastWaterResetDate")
            UserDefaults.standard.removeObject(forKey: "savedSteps")
            UserDefaults.standard.removeObject(forKey: "worksoutDataDetails")
            UserDefaults.standard.removeObject(forKey: "savedImage")
            UserDefaults.standard.removeObject(forKey: "description")
            NavToWelcome()

     }

        private func showResetConfirmation() {
            let confirmationAlert = UIAlertController(title: "Reset Complete", message: "Your data has been reset successfully.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            confirmationAlert.addAction(okAction)
            self.present(confirmationAlert, animated: true, completion: nil)
        }

    func loadData() {
//        // Load text fields
//        userNameLbl.text = UserDefaults.standard.string(forKey: "userDataDetails")
        
        // Load image
        if let imageData = UserDefaults.standard.data(forKey: "savedImage"), let image = UIImage(data: imageData) {
            UserProfileShow.image = image
        }
    }
    
    
    @IBAction func EditButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
     
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    

}
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SideMenuTableViewCell
        
       cell.sMenuImgs?.image = UIImage(named: settingImgs[indexPath.row])
        cell.sidemenu_label.text = settingList[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeOneViewController") as! WelcomeOneViewController
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
        }
        else if indexPath.item == 1 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "AboutusViewController") as! AboutusViewController
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
        }
        else if indexPath.item == 2 {
            let alert = UIAlertController(title: "Remove All Data", message: "You're sure you want to remove all the data.", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
                // Step 2: Clear user-specific data
                self.clearUserData()
                
                // Step 3: Optionally, refresh UI or notify the user that data has been reset
                self.showResetConfirmation()

                // Step 4: Navigate to WelcomeViewController after reset
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeOneViewController") as! WelcomeOneViewController
                newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                newViewController.modalTransitionStyle = .crossDissolve
                self.present(newViewController, animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
         
        }
        else if indexPath.item == 3 {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
     }
        else if indexPath.item == 4 {
            let appID = "FitFuelTrack" // Replace with your actual App ID
            let appURL = URL(string: "https://apps.apple.com/app/id\(appID)")!
            let activityViewController = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
       else if indexPath.item == 5 {
                // Open Privacy Policy Link
                if let url = URL(string: "https://jtechapps.pages.dev/privacy") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
          
        }
    }
