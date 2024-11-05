//
//  AddWorkOutViewController.swift
//  FitFuel Track
//
//  Created by Maaz on 30/10/2024.
//

import UIKit

class AddWorkOutViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var typeTF: DropDown!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var mintsTF: UITextField!
    @IBOutlet weak var setsTF: UITextField!
    @IBOutlet weak var startdateTF: UITextField!
    @IBOutlet weak var daysTF: UITextField!
    
    @IBOutlet weak var mintsStepper: UIStepper!
    @IBOutlet weak var setsStepper: UIStepper!
    @IBOutlet weak var daysStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the initial value of the stepper and text field
        mintsStepper.value = 0
        mintsTF.text = "\(Int(mintsStepper.value))"
        // Add target for stepper value changes
        mintsStepper.addTarget(self, action: #selector(mintsStepperChanged), for: .valueChanged)
        
        setsStepper.value = 0
        setsTF.text = "\(Int(setsStepper.value))"
        // Add target for stepper value changes
        setsStepper.addTarget(self, action: #selector(setStepperChanged), for: .valueChanged)
        
        daysStepper.value = 0
        daysTF.text = "\(Int(daysStepper.value))"
        // Add target for stepper value changes
        daysStepper.addTarget(self, action: #selector(daysStepperChanged), for: .valueChanged)
        
        typeTF.optionArray = ["Exercise", "Workout"]
        typeTF.didSelect { (selectedText, index, id) in
            self.typeTF.text = selectedText
        }
        typeTF.delegate = self
        
        setupDatePicker(for: startdateTF, target: self, doneAction: #selector(donePressed))
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
                tapGesture2.cancelsTouchesInView = false
                view.addGestureRecognizer(tapGesture2)
    }
    @objc func hideKeyboard() {
            view.endEditing(true)
        }
    // Action method for stepper value change
    @objc func mintsStepperChanged(_ sender: UIStepper) {
        // Update the mintsTF with the new value of the stepper
        mintsTF.text = "\(Int(sender.value))"
    }
    @objc func setStepperChanged(_ sender: UIStepper) {
        // Update the mintsTF with the new value of the stepper
        setsTF.text = "\(Int(sender.value))"
    }
    @objc func daysStepperChanged(_ sender: UIStepper) {
        // Update the mintsTF with the new value of the stepper
        daysTF.text = "\(Int(sender.value))"
    }
    
    @objc func donePressed() {
        // Get the date from the picker and set it to the text field
        if let datePicker = startdateTF.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" // Same format as in convertStringToDate
            startdateTF.text = dateFormatter.string(from: datePicker.date)
        }
        // Dismiss the keyboard
        startdateTF.resignFirstResponder()
    }
    func clearTextFields() {
        typeTF.text = ""
        nameTF.text = ""
        mintsTF.text = ""
        setsTF.text = ""
        startdateTF.text = ""
        daysTF.text = ""
    }
    func saveWorkoutData(_ sender: Any) {
        // Check if all mandatory fields are filled
        guard let type = typeTF.text, !type.isEmpty,
              let name = nameTF.text, !name.isEmpty,
              let mints = mintsTF.text, !mints.isEmpty,
              let sets = setsTF.text, !sets.isEmpty,
              let startDate = startdateTF.text, !startDate.isEmpty,
              let days = daysTF.text, !days.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        // Convert string values to integers
        guard let dailyMintsInt = Int(mints),
              let setCountInt = Int(sets),
              let totalDaysInt = Int(days) else {
            showAlert(title: "Error", message: "Please enter valid numeric values for minutes, sets, and days.")
            return
        }

        // Create new workout entry
        let createNewWorkout = WorkOut(
            Types: type,
            Name: name,
            DailyMint: dailyMintsInt,
            SetCount: setCountInt,
            StartDate: convertStringToDate(startDate) ?? Date(),
            TotalDays: totalDaysInt
        )

        // Save the workout entry
        saveCreateSaleDetail(createNewWorkout)
    }

    
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Corrected year format
        return dateFormatter.date(from: dateString)
    }
    
    func saveCreateSaleDetail(_ work: WorkOut) {
        var works = UserDefaults.standard.object(forKey: "worksoutDataDetails") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(work)
            works.append(data)
            UserDefaults.standard.set(works, forKey: "worksoutDataDetails")
            clearTextFields()
           
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        showAlert(title: "Success", message: "WorkOut has been Saved successfully.")
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        saveWorkoutData(sender)
    }
    @IBAction func BackButton(_ sender: Any) {
        self.dismiss(animated: true)
  
    }
}













import UIKit

class NewViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var numberTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupDatePicker(for: numberTF, target: self, doneAction: #selector(donePressed))
        
        
    }
    
    
    @objc func donePressed() {
        // Get the date from the picker and set it to the text field
        if let datePicker = numberTF.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" // Same format as in convertStringToDate
            numberTF.text = dateFormatter.string(from: datePicker.date)
        }
        // Dismiss the keyboard
        numberTF.resignFirstResponder()
    }
}
