//
//  MeasurmentsViewController.swift
//  FitFuel Track
//
//  Created by Maaz on 01/11/2024.
//

import UIKit
import CoreMotion

class MeasurmentsViewController: UIViewController {

    let pedometer = CMPedometer()
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stepsView: UIView!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    
    var stepGoal: Int = 10000 // Default daily step goal, initially set to 10,000 steps
    var userWeight: Double = 70.0 // Default weight in kg

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDropShadow(to: stepsView)
        roundCorner(button: startBtn)
    }
    
    func startPedometerUpdates() {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { data, error in
                guard let pedometerData = data, error == nil else {
                    print("Pedometer error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                DispatchQueue.main.async {
                    // Steps and distance
                    let steps = pedometerData.numberOfSteps.intValue
                    let distance = pedometerData.distance?.doubleValue ?? 0.0
                    
                    // Update labels
                    self.stepsLabel.text = "Steps: \(steps)"
                    self.distanceLabel.text = String(format: "Distance: %.2f meters", distance)
                    
                    // Calories burned calculation
                    let caloriesBurned = self.calculateCaloriesBurned(steps: steps)
                    self.caloriesLabel.text = String(format: "Calories: %.2f kcal", caloriesBurned)
                    
                    // Progress towards goal
                    let progress = min(1.0, Double(steps) / Double(self.stepGoal))
                    self.progressLabel.text = String(format: "Goal Progress: %.2f%%", progress * 100)
                }
            }
        }
    }
    
    func calculateCaloriesBurned(steps: Int) -> Double {
        // Calorie calculation using the user's weight
        return Double(steps) * userWeight * 0.035
    }

    func promptUserForGoalAndWeight() {
        let alert = UIAlertController(title: "Set Goals", message: "Enter your step goal and weight.", preferredStyle: .alert)
        
        // Step Goal input
        alert.addTextField { textField in
            textField.placeholder = "Step Goal (e.g., 10000)"
            textField.keyboardType = .numberPad
        }
        
        // Weight input
        alert.addTextField { textField in
            textField.placeholder = "Weight in kg (e.g., 70)"
            textField.keyboardType = .decimalPad
        }
        
        // Confirm button
        let confirmAction = UIAlertAction(title: "Start", style: .default) { _ in
            if let stepGoalText = alert.textFields?[0].text,
               let weightText = alert.textFields?[1].text,
               let stepGoal = Int(stepGoalText),
               let weight = Double(weightText) {
                
                // Set the step goal and user weight
                self.stepGoal = stepGoal
                self.userWeight = weight
                
                // Start updates
                self.startPedometerUpdates()
                self.startBtn.isHidden = true
            }
        }
        
        // Add actions and present alert
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func startButtonTap(_ sender: Any) {
        descriptionLabel.text = "Start running, walking, etc..."
        descriptionLabel.textColor = .systemRed

        promptUserForGoalAndWeight()
    }
    @IBAction func BackButton(_ sender: Any) {
        self.dismiss(animated: true)
 
    }
}
