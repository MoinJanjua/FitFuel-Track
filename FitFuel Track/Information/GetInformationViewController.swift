//
//  GetInformationViewController.swift
//  FitFuel Track
//
//  Created by Maaz on 29/10/2024.
//
import UIKit

class GetInformationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var genderDetailView: UIView!
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var maleView: UIView!
    @IBOutlet weak var femaleView: UIView!
    @IBOutlet weak var otheView: UIView!
    @IBOutlet weak var furtherView: UIView!
    @IBOutlet weak var AdditionalView: UIView!
    
    @IBOutlet weak var maleIV: UIImageView!
    @IBOutlet weak var otherIV: UIImageView!
    @IBOutlet weak var femaleIV: UIImageView!
    
    @IBOutlet weak var UserNameTF: UITextField!
    @IBOutlet weak var AgeTf: UITextField!
    @IBOutlet weak var DobTF: UITextField!
    @IBOutlet weak var workoutDurationTextField: UITextField!
        
    
    @IBOutlet weak var weightUnitTF: DropDown!
    @IBOutlet weak var heightUnitTF: DropDown!
    @IBOutlet weak var activityLevelDropdown: DropDown!
    @IBOutlet weak var workoutTypeDropdown: DropDown!
    @IBOutlet weak var workoutIntensityDropdown: DropDown!
    
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    
    @IBOutlet weak var adjustHeight: UISlider!
    @IBOutlet weak var adjustWeight: UISlider!
    
    var radioButtonTap = String()
    var selectedWeightUnit = "Kg" // Default weight unit

    override func viewDidLoad() {
        super.viewDidLoad()
        
        radioButtonTap = ""
        
        addDropShadow(to: genderDetailView)
        addDropShadow(to: maleView)
        addDropShadow(to: femaleView)
        addDropShadow(to: otheView)
        roundCorner(button: nextBtn)
        
        nextBtn.isHidden = true
        setupDatePicker(for: DobTF, target: self, doneAction: #selector(donePressed))

        // Configure weightUnitTF Dropdown
              weightUnitTF.optionArray = ["Kg", "Lbs"]
              weightUnitTF.didSelect { (selectedText, index, id) in
                  self.weightUnitTF.text = selectedText
                  self.updateWeightSliderUnit(selectedText)
              }
              weightUnitTF.delegate = self
        
        // Set minimum and maximum values for the weight slider
               adjustWeight.minimumValue = 20
               adjustWeight.maximumValue = 250
        
        // Set initial weight value
              adjustWeight.value = 65
              
              // Show the initial weight value in the weightLabel
              weightLabel.text = "\(Int(adjustWeight.value)) kg"
              
              // Add target action for slider value change
              adjustWeight.addTarget(self, action: #selector(weightSliderChanged(_:)), for: .valueChanged)
        
        // Configure heightUnitTF Dropdown
          heightUnitTF.optionArray = ["Centimeters", "Feet and inches"]
          heightUnitTF.didSelect { (selectedText, index, id) in
              self.heightUnitTF.text = selectedText
              self.updateHeightSliderUnit(selectedText)
          }
          heightUnitTF.delegate = self

          // Set default slider value and range for Centimeters
          adjustHeight.minimumValue = 100
          adjustHeight.maximumValue = 250
          adjustHeight.value = 170 // Default value (adjust as needed)
          heightLabel.text = "\(Int(adjustHeight.value)) cm" // Set initial label text
          
          // Add target for height slider value change
          adjustHeight.addTarget(self, action: #selector(heightSliderChanged), for: .valueChanged)

        // Setup Dropdown options
               activityLevelDropdown.optionArray = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active"]
               activityLevelDropdown.didSelect { (selectedText, index, id) in
               self.activityLevelDropdown.text = selectedText
                     }
              activityLevelDropdown.delegate = self
        
               workoutTypeDropdown.optionArray = ["Running", "Walking", "Cycling", "Swimming"]
               workoutTypeDropdown.didSelect { (selectedText, index, id) in
               self.workoutTypeDropdown.text = selectedText
                      }
               workoutTypeDropdown.delegate = self
        
               workoutIntensityDropdown.optionArray = ["Low", "Moderate", "High"]
                 workoutIntensityDropdown.didSelect { (selectedText, index, id) in
                self.workoutIntensityDropdown.text = selectedText
                     }
                 workoutIntensityDropdown.delegate = self
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
                tapGesture2.cancelsTouchesInView = false
                view.addGestureRecognizer(tapGesture2)
    }
    @objc func hideKeyboard() {
            view.endEditing(true)
        }
    @objc func donePressed() {
        // Get the date from the picker and set it to the text field
        if let datePicker = DobTF.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" // Same format as in convertStringToDate
            DobTF.text = dateFormatter.string(from: datePicker.date)
        }
        // Dismiss the keyboard
        DobTF.resignFirstResponder()
    }
    @objc func weightSliderChanged(_ sender: UISlider) {
           // Update the weightLabel when slider is moved based on selected unit
           let weight = Int(sender.value)
           if selectedWeightUnit == "Kg" {
               weightLabel.text = "\(weight) kg"
           } else if selectedWeightUnit == "Lbs" {
               weightLabel.text = "\(weight) lbs"
           }
       }

       // Update slider values based on selected weight unit
       func updateWeightSliderUnit(_ unit: String) {
           selectedWeightUnit = unit
           if unit == "Kg" {
               adjustWeight.minimumValue = 20
               adjustWeight.maximumValue = 250
               adjustWeight.value = 65 // Set default value for kg
               weightLabel.text = "\(Int(adjustWeight.value)) kg"
           } else if unit == "Lbs" {
               adjustWeight.minimumValue = 30 // Convert 20 kg to lbs
               adjustWeight.maximumValue = 550 // Convert 250 kg to lbs
               adjustWeight.value = 143 // Set default value for lbs (65 kg to lbs)
               weightLabel.text = "\(Int(adjustWeight.value)) lbs"
           }
       }
    // Action when the height slider is changed
    @objc func heightSliderChanged(_ sender: UISlider) {
        let heightValue = Int(sender.value)
        if heightUnitTF.text == "Centimeters" {
            heightLabel.text = "\(heightValue) cm"
        } else if heightUnitTF.text == "Feet and inches" {
            let feet = Int(sender.value) / 12
            let inches = Int(sender.value) % 12
            heightLabel.text = "\(feet) ft \(inches) in"
        }
    }

    // Function to update slider values based on selected height unit
    func updateHeightSliderUnit(_ unit: String) {
        if unit == "Centimeters" {
            adjustHeight.minimumValue = 100
            adjustHeight.maximumValue = 250
            adjustHeight.value = 170 // Set default value for centimeters
            heightLabel.text = "\(Int(adjustHeight.value)) cm"
        } else if unit == "Feet and inches" {
            adjustHeight.minimumValue = 36 // 3 feet (12 inches per foot)
            adjustHeight.maximumValue = 96 // 8 feet (12 inches per foot)
            adjustHeight.value = 66 // Set default value to 5 feet 6 inches (66 inches)
            let feet = Int(adjustHeight.value) / 12
            let inches = Int(adjustHeight.value) % 12
            heightLabel.text = "\(feet) ft \(inches) in"
        }
    }
    // Function to check if any button is selected
    func checkButtonSelection() {
        if radioButtonTap != "" {
            nextBtn.isHidden = false // Show the next button if any gender button is selected
        } else {
            nextBtn.isHidden = true // Hide it if none are selected
        }
    }
    // Function to update borders based on selection
    func updateBorders(selectedView: UIView, otherViews: [UIView]) {
        // Set border for the selected view
        selectedView.layer.borderColor = UIColor.systemBlue.cgColor
        selectedView.layer.borderWidth = 2.0
        
        // Reset borders for the other views
        for view in otherViews {
            view.layer.borderColor = UIColor.clear.cgColor
            view.layer.borderWidth = 0.0
        }
    }
    
    // Function to manage the visibility of image views
    func updateImageViews(selectedImageView: UIImageView, otherImageViews: [UIImageView]) {
        // Show the selected image view
        selectedImageView.isHidden = false
        
        // Hide the other image views
        for imageView in otherImageViews {
            imageView.isHidden = true
        }
    }
    
    @IBAction func nextButtonTap(_ sender: Any) {
         // Check if UserNameTF is empty
         if UserNameTF.text?.isEmpty ?? true {
             // Show an alert if the text field is empty
             showAlert(title:"Error", message: "Please enter your name")
         } else {
             // Proceed to the next step if the name is entered
             print("Proceeding with name: \(UserNameTF.text ?? "")")
             genderDetailView.isHidden = false
         }
        
     }
    @IBAction func maleButtonTap(_ sender: Any) {
        radioButtonTap = "Male"
        updateBorders(selectedView: maleView, otherViews: [femaleView, otheView])
        updateImageViews(selectedImageView: maleIV, otherImageViews: [femaleIV, otherIV])

        checkButtonSelection() // Check the condition after selection
        
    }
    
    @IBAction func femaleButtonTap(_ sender: Any) {
        radioButtonTap = "Female"
      
        updateBorders(selectedView: femaleView, otherViews: [maleView, otheView])
        updateImageViews(selectedImageView: femaleIV, otherImageViews: [maleIV, otherIV])

        checkButtonSelection() // Check the condition after selection
    }
    
    @IBAction func otherButtonTap(_ sender: Any) {
        radioButtonTap = "Other"
        updateBorders(selectedView: otheView, otherViews: [maleView, femaleView])
        updateImageViews(selectedImageView: otherIV, otherImageViews: [maleIV, femaleIV])

       checkButtonSelection() // Check the condition after selection
    }
    
    @IBAction func nextButton(_ sender: Any) {
        guard let ageText = AgeTf.text, let ageInt = Int(ageText), ageInt > 0 && ageInt <= 120 else
       {
            showAlert(title: "Error", message: "Please enter a valid age between 1 and 120")
            return
       }
        furtherView.isHidden = false
    }
    @IBAction func previous(_ sender: Any) {
        furtherView.isHidden = true

    }
    @IBAction func nextButtontwo(_ sender: Any) {
        let dateOfBirth = DobTF.text
        
       if dateOfBirth?.isEmpty ?? false
       {
           showAlert(title: "Error", message: "Please fill the field Date of birth")
           return
       }
        
        AdditionalView.isHidden = false
    }
    @IBAction func previousTwo(_ sender: Any) {
        AdditionalView.isHidden = true
    }
    
    
    func saveUsersData(_ sender: Any) {
        // Check if all mandatory fields are filled
        guard let userName = UserNameTF.text, !userName.isEmpty,
              let dateOfBirth = DobTF.text, !dateOfBirth.isEmpty,
//              let ageInt = AgeTf.text,!ageInt.isEmpty,
              !radioButtonTap.isEmpty  // Ensure a gender is selected
        else {
            let userName = UserNameTF.text
            let dateOfBirth = DobTF.text
            guard let ageText = AgeTf.text, let ageInt = Int(ageText), ageInt > 0 && ageInt <= 120 else 
            {
                 showAlert(title: "Error", message: "Please enter a valid age between 1 and 120")
                 return
            }
            
            if dateOfBirth?.isEmpty ?? false
            {
                showAlert(title: "Error", message: "Please fill in all required fields Date of birth")
                return
            }
            else if (userName?.isEmpty ?? false)
            {
                showAlert(title: "Error", message: "Please fill in all required fields userName")
                return
            }
            else
            {
                showAlert(title: "Error", message: "Please fill in all required fields")
                           return
            }
         
          
           
        }
        // Check for valid age
         guard let ageText = AgeTf.text, let ageInt = Int(ageText), ageInt > 0 && ageInt <= 120 else {
             showAlert(title: "Error", message: "Please enter a valid age between 1 and 120")
             return
         }
       
        let activityLevel = activityLevelDropdown.text?.isEmpty == false ? activityLevelDropdown.text! : "Nil"
        let workoutType = workoutTypeDropdown.text?.isEmpty == false ? workoutTypeDropdown.text! : "Nil"
        let workoutDurationDouble = Double(workoutDurationTextField.text ?? "") ?? 0.0
        let workoutIntensity = workoutIntensityDropdown.text?.isEmpty == false ? workoutIntensityDropdown.text! : "Nil"
        
        // Get the selected weight and height
        let weight = Int(adjustWeight.value)
        let height = Int(adjustHeight.value)
        
        // Prepare the weight and height strings based on the selected units
        let weightString = "\(weight) \(selectedWeightUnit)" // Example: "65 Kg" or "143 Lbs"
        let heightString: String
        if heightUnitTF.text == "Centimeters" {
            heightString = "\(height) cm"
        } else if heightUnitTF.text == "Feet and inches" {
            let feet = height / 12
            let inches = height % 12
            heightString = "\(feet) ft \(inches) in"
        } else {
            heightString = "\(height) cm" // Default fallback in case no unit is selected
        }

        // Create new user detail safely
        let randomCharacter = generateRandomCharacter()
        let newUser = User(
            id: "\(randomCharacter)",
            age: ageInt,
            username: userName,
            dateofbirth: convertStringToDate(dateOfBirth) ?? Date(),
            gender: radioButtonTap, // Save the selected gender
            weight: weightString, // Save the adjusted weight
            height: heightString,  // Save the adjusted height
            activityLevel: activityLevel,
            workoutType: workoutType,
            workoutDuration: workoutDurationDouble,
            workoutIntensity: workoutIntensity
        )
        
        saveUserInformation(newUser)
    }




  func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Corrected year format
        return dateFormatter.date(from: dateString)
    }
    
    func saveUserInformation(_ user: User) {
        var userData = UserDefaults.standard.object(forKey: "userDataDetails") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            userData.append(data)
            UserDefaults.standard.set(userData, forKey: "userDataDetails")
          // clearTextFields()
           
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        
    }
    @IBAction func DoneSaveButton(_ sender: Any) {
        saveUsersData(sender)
        
        // Show an alert indicating data was saved
        let alertController = UIAlertController(title: "Done", message: "User's Information Data Has Been Saved successfully.", preferredStyle: .alert)
        
        // Add an OK action to dismiss the alert and navigate to HomeViewController
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Ensure self is not nil
            guard let self = self else { return }
            
            // Navigate to HomeViewController after the alert is dismissed
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            if let homeViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
                homeViewController.modalPresentationStyle = .fullScreen
                homeViewController.modalTransitionStyle = .crossDissolve
                
                // Present the HomeViewController on the main thread
                DispatchQueue.main.async {
                    self.present(homeViewController, animated: true, completion: nil)
                }
            } else {
                print("HomeViewController could not be instantiated.")
            }
        }
        
        // Add the action to the alert controller
        alertController.addAction(okAction)
        
        // Present the alert
        present(alertController, animated: true, completion: nil)
    }

    
}
