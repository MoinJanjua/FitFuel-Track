//
//  WelcomeOneViewController.swift
//  NameSpectrum Hub
//
//  Created by Maaz on 03/10/2024.
//

import UIKit

class WelcomeOneViewController: UIViewController {
    
    var user_Detail: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load data from UserDefaults for Users_Detail
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
       
    }

    @IBAction func nextButton(_ sender: Any) {
        // Check if there is any user data available
                if !user_Detail.isEmpty {
                    // If user data is available, go to TabBarViewController
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tabBarVC = storyBoard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
                        tabBarVC.modalPresentationStyle = .fullScreen
                        tabBarVC.modalTransitionStyle = .crossDissolve
                        self.present(tabBarVC, animated: true, completion: nil)
                    }
                } else {
                    // If no user data is available, go to GetInformationViewController
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    if let getInfoVC = storyBoard.instantiateViewController(withIdentifier: "GetInformationViewController") as? GetInformationViewController {
                        getInfoVC.modalPresentationStyle = .fullScreen
                        getInfoVC.modalTransitionStyle = .crossDissolve
                        self.present(getInfoVC, animated: true, completion: nil)
                    }
                }
    }

}
