//
//  CaloriesCalculationViewController.swift
//  FitFuel Track
//
//  Created by Maaz on 31/10/2024.
//

import UIKit

class CaloriesCalculationViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var CalorieLabel: UILabel!
    @IBOutlet weak var CalorieView: UIView!

    // Outlets for Text Fields to take input from the user
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: DropDown!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var bodyFatPercentageTextField: UITextField! //
    @IBOutlet weak var activityLevelTextField: DropDown!
    @IBOutlet weak var workoutTypeTextField: DropDown!
    @IBOutlet weak var workoutFrequencyTextField: UITextField!
    @IBOutlet weak var workoutDurationTextField: UITextField!
    @IBOutlet weak var fitnessGoalTextField: DropDown!
    
   
        private var numberPicker = UIPickerView()
        private let numbers = Array(1...100) // Array of numbers from 1 to 100
    private var activeTextField: UITextField?

    
    override func viewDidLoad() {
        super.viewDidLoad()
  addDropShadow(to: CalorieView)
        // Setup Dropdown options
        genderTextField.optionArray = ["Male", "Female", "Other"]
        genderTextField.didSelect { (selectedText, index, id) in
        self.genderTextField.text = selectedText
              }
        genderTextField.delegate = self
        
        activityLevelTextField.optionArray = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active","Extremely Active"]
        activityLevelTextField.didSelect { (selectedText, index, id) in
               self.activityLevelTextField.text = selectedText
                     }
              activityLevelTextField.delegate = self

        workoutTypeTextField.optionArray = ["Cardio", "Strength","Flexibility","Mixed"]
        workoutTypeTextField.didSelect { (selectedText, index, id) in
               self.workoutTypeTextField.text = selectedText
                      }
               workoutTypeTextField.delegate = self
        
        fitnessGoalTextField.optionArray = ["Weight Loss","Weight Gain","Maintenance"]
        fitnessGoalTextField.didSelect { (selectedText, index, id) in
                self.fitnessGoalTextField.text = selectedText
                     }
        fitnessGoalTextField.delegate = self
        
        
        setupNumberPicker(for: bodyFatPercentageTextField)
             setupNumberPicker(for: workoutFrequencyTextField)
             setupNumberPicker(for: workoutDurationTextField)
           
         }
         
         func setupNumberPicker(for textField: UITextField) {
             // Set up the UIPickerView
             numberPicker.delegate = self
             numberPicker.dataSource = self
             
             // Assign the picker to the text field's input view
             textField.inputView = numberPicker
             
             // Add toolbar with "Done" button
             let toolbar = UIToolbar()
             toolbar.sizeToFit()
             let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
             toolbar.setItems([doneButton], animated: false)
             toolbar.isUserInteractionEnabled = true
             textField.inputAccessoryView = toolbar
             
             // Set text field delegate and track the active text field
             textField.delegate = self
         }
         
         @objc func donePressed() {
             // Get the selected number from the picker and set it to the active text field
             if let textField = activeTextField {
                 let selectedRow = numberPicker.selectedRow(inComponent: 0)
                 textField.text = "\(numbers[selectedRow])"
                 textField.resignFirstResponder()
             }
         }
         
         // MARK: - UITextField Delegate
         
         func textFieldDidBeginEditing(_ textField: UITextField) {
             activeTextField = textField
         }
         
         func textFieldDidEndEditing(_ textField: UITextField) {
             activeTextField = nil
         }
         
         // MARK: - UIPickerView Data Source and Delegate Methods
         
         func numberOfComponents(in pickerView: UIPickerView) -> Int {
             return 1
         }
         
         func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
             return numbers.count
         }
         
         func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
             return "\(numbers[row])"
         }
    func clearTextFields() {
        nameTextField.text = ""
        ageTextField.text = ""
        genderTextField.text = ""
        heightTextField.text = ""
        weightTextField.text = ""
        bodyFatPercentageTextField.text = ""
        activityLevelTextField.text = ""
        workoutTypeTextField.text = ""
        workoutFrequencyTextField.text = ""
        workoutDurationTextField.text = ""
        fitnessGoalTextField.text = ""
       
    }
    
    @IBAction func CalculateButton(_ sender: Any) {
        
        
        // Fetch and validate user input
        guard let name = nameTextField.text,
              let age = Int(ageTextField.text ?? ""),
              let height = Double(heightTextField.text ?? ""),
              let weight = Double(weightTextField.text ?? ""),
              let gender = Calories.Gender(rawValue: genderTextField.text ?? ""),
              let activityLevel = Calories.ActivityLevel(rawValue: activityLevelTextField.text ?? ""),
              let workoutType = Calories.WorkoutType(rawValue: workoutTypeTextField.text ?? ""),
              let workoutFrequency = Int(workoutFrequencyTextField.text ?? ""),
              let workoutDuration = Double(workoutDurationTextField.text ?? ""),
              let fitnessGoal = Calories.FitnessGoal(rawValue: fitnessGoalTextField.text ?? "") else {
            CalorieLabel.text = "Please enter all fields correctly."
            return
        }
        
        // Optional fields with default values
        let bodyFatPercentage = Double(bodyFatPercentageTextField.text ?? "")
        
        // Create the User instance
        let workoutPreferences = Calories.WorkoutPreferences(workoutType: workoutType,
                                                         workoutFrequency: workoutFrequency,
                                                         workoutDuration: workoutDuration)
        let user = Calories(
            name: name,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            bodyFatPercentage: bodyFatPercentage,
            activityLevel: activityLevel,
            workoutPreferences: workoutPreferences,
            fitnessGoal: fitnessGoal,
            dailyStepGoal: 10000, // Example default value
            dailyWaterIntakeGoal: 2.0, // Example default value in liters
            targetWeight: nil,
            goalTimelineInWeeks: nil,
            dietaryPreferences: .init(preferredMacros: .balanced, dietaryRestrictions: nil)
        )
        
        // Calculate BMR and TDEE
        let bmr = calculateBMR(for: user)
        let tdee = calculateTDEE(bmr: bmr, activityLevel: user.activityLevel)
        
        // Display the calculated calorie needs
        CalorieLabel.text = "Daily Calorie Needs: \(Int(tdee)) kcal"
        showAlert(title: "Success", message: "The calories daily you needs is \(Int(tdee))")
        clearTextFields()
    }
    
    // MARK: - BMR Calculation
    private func calculateBMR(for user: Calories) -> Double {
        // Harris-Benedict BMR formula based on gender
        switch user.gender {
        case .male:
            return 88.362 + (13.397 * user.weight) + (4.799 * user.height) - (5.677 * Double(user.age))
        case .female:
            return 447.593 + (9.247 * user.weight) + (3.098 * user.height) - (4.330 * Double(user.age))
        case .other:
            // Gender-neutral formula or based on user choice
            return 88.362 + (13.397 * user.weight) + (4.799 * user.height) - (5.677 * Double(user.age))
        }
    }
    
    // MARK: - TDEE Calculation
    private func calculateTDEE(bmr: Double, activityLevel: Calories.ActivityLevel) -> Double {
        // TDEE multipliers for activity levels
        switch activityLevel {
        case .sedentary:
            return bmr * 1.2
        case .lightlyActive:
            return bmr * 1.375
        case .moderatelyActive:
            return bmr * 1.55
        case .veryActive:
            return bmr * 1.725
        case .extremelyActive:
            return bmr * 1.9
        }
    }
    @IBAction func BackButton(_ sender: Any) {
        self.dismiss(animated: true)
  
    }
}
