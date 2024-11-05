//
//  UpdateViewController.swift
//  FitFuel Track
//
//  Created by Maaz on 31/10/2024.
//

import UIKit

class UpdateViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var workintensityTF: DropDown!
    @IBOutlet weak var workoutDurationTF: UITextField!
    @IBOutlet weak var workoutTF: DropDown!
    @IBOutlet weak var activityLeveTF: DropDown!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var weightTF: UITextField!
    @IBOutlet weak var dateofbirthTF: UITextField!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!

    @IBOutlet weak var ageTF: UITextField!
    
    var selectedData: User?
    // Add this line to declare the delegate property
    var delegate: UpdateUserDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker(for: dateofbirthTF, target: self, doneAction: #selector(donePressed))

        if let userData = selectedData {
            ageTF.text = "\(userData.age)"
            userNameTF.text = userData.username
            genderTF.text = userData.gender
            // Format the date to a string before setting it to the text field
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium // Adjust date style as needed
            dateFormatter.timeStyle = .none
            
            if let dateOfBirth = userData.dateofbirth as? Date {
                dateofbirthTF.text = dateFormatter.string(from: dateOfBirth)
            } else if let dateOfBirthString = userData.dateofbirth as? String {
                // If dateofbirth is already a String, just assign it
                dateofbirthTF.text = dateOfBirthString
            }

            weightTF.text = userData.weight
            heightTF.text = userData.height
            activityLeveTF.text = userData.activityLevel
            workoutTF.text = userData.workoutType
            workoutDurationTF.text = "\(userData.workoutDuration)"
            workintensityTF.text = userData.workoutIntensity
        }


//        // Setup Dropdown options
        activityLeveTF.optionArray = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active"]
        activityLeveTF.didSelect { (selectedText, index, id) in
               self.activityLeveTF.text = selectedText
                     }
        activityLeveTF.delegate = self

        workoutTF.optionArray = ["Running", "Walking", "Cycling", "Swimming"]
        workoutTF.didSelect { (selectedText, index, id) in
               self.workoutTF.text = selectedText
                      }
        workoutTF.delegate = self

        workintensityTF.optionArray = ["Low", "Moderate", "High"]
        workintensityTF.didSelect { (selectedText, index, id) in
                self.workintensityTF.text = selectedText
                     }
        workintensityTF.delegate = self

        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
                tapGesture2.cancelsTouchesInView = false
                view.addGestureRecognizer(tapGesture2)
    }
    
    @objc func hideKeyboard() {
            view.endEditing(true)
        }
    
    @objc func donePressed() {
        // Get the date from the picker and set it to the text field
        if let datePicker = dateofbirthTF.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" // Same format as in convertStringToDate
            dateofbirthTF.text = dateFormatter.string(from: datePicker.date)
        }
        // Dismiss the keyboard
        dateofbirthTF.resignFirstResponder()
    }
 

    func saveUpdatedUser(_ user: User) {
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)
            UserDefaults.standard.set([userData], forKey: "userDataDetails")
            print("User data updated successfully.")
        } catch {
            print("Error saving updated user data: \(error)")
        }
        showAlert(title: "Updated", message: "Your data has been saved & updated successfully.")
    }
    
    @IBAction func UpdatedTheData(_ sender: Any) {
        // Ensure all fields have valid data
              guard let name = userNameTF.text,
                    let gender = genderTF.text,
                    let dob = dateofbirthTF.text,

                    let height = heightTF.text,
                    let weight = weightTF.text,
                    let activityLevel = activityLeveTF.text,
                    let workoutType = workoutTF.text,
                    let workoutIntensity = workintensityTF.text,
                    let ageText = ageTF.text, let age = Int(ageText),
                    let workoutDurationText = workoutDurationTF.text, 
                    let workoutDuration = Double(workoutDurationText)
              else {
                  // Show an error if fields are missing
                  print("Please fill all fields")
                  return
              }

              // Update the `User` object with new values
        let randomCharacter = generateRandomCharacter()
        let updatedUser = User(id: "\(randomCharacter)",age: age,
                               username: name,
                               dateofbirth: convertStringToDate(dob) ?? Date(),
                               gender:gender,
                               weight: weight,
                               height: height,
                              
                             activityLevel: activityLevel,
                               workoutType: workoutType,
                                workoutDuration: workoutDuration,
                               workoutIntensity: workoutIntensity)
              
              // Save to UserDefaults
              saveUpdatedUser(updatedUser)
        // Call the delegate method to notify the home view controller
               delegate?.didUpdateUser(updatedUser)

               // Dismiss the update view controller
               self.dismiss(animated: true)
    }
    
    func convertStringToDate(_ dateString: String) -> Date? {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "dd-MM-yyyy" // Corrected year format
          return dateFormatter.date(from: dateString)
      }

    @IBAction func BackButton(_ sender: Any) {
        self.dismiss(animated: true)
 
    }
    
}
