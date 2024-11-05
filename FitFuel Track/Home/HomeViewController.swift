//
//  HomeViewController.swift
//  FitFuel Track
//
//  Created by Maaz on 30/10/2024.
//

import UIKit
import CoreMotion

// Protocol for updating user details
protocol UpdateUserDelegate: AnyObject {
    func didUpdateUser(_ user: User)
}

class HomeViewController: UIViewController, UpdateUserDelegate {
    
    let pedometer = CMPedometer()
    
    @IBOutlet weak var UserIV: UIImageView!
    @IBOutlet weak var heightView: UIView!
    @IBOutlet weak var weightView: UIView!
    @IBOutlet weak var caloriestView: UIView!
    @IBOutlet weak var stepsView: UIView!
    @IBOutlet weak var waterView: UIView!
    
    @IBOutlet weak var CalorieLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var yournameLabel: UILabel!
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var waterAddStepper: UIStepper!
    @IBOutlet weak var waterProgrssBar: UIProgressView!
    @IBOutlet weak var waterDrinkLabel: UILabel!
    @IBOutlet weak var remainingWaterDrinkLevelLabel: UILabel!
    
    var user_Detail: [User] = []
    var userWeight: Double = 0.0
    var stepGoal: Int = 100000
    var savedSteps: Int = 0
    let maxWaterIntake: Float = 2250.0
    var currentWaterIntake: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDropShadow(to: heightView)
        addDropShadow(to: weightView)
        addDropShadow(to: caloriestView)
        addDropShadow(to: stepsView)
        addDropShadow(to: waterView)
        makeImageViewCircular(imageView: UserIV)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserDetails()
        loadSavedSteps()
        startPedometerUpdates()
        loadSavedWaterIntake()
        setupWaterStepper()
        updateWaterUI()
        scheduleDailyReset()
        loadData()
        updateUI()
    }
    
    func loadData() {
        if let imageData = UserDefaults.standard.data(forKey: "savedImage"),
           let image = UIImage(data: imageData) {
            UserIV.image = image
        }
    }
    
    func loadUserDetails() {
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
    
    func updateUI() {
        guard let firstUser = user_Detail.first else {
            yournameLabel.text = "No user data available"
            return
        }
        
        yournameLabel.text = "Hi \(firstUser.username)!"
        heightLabel.text = firstUser.height
        weightLabel.text = firstUser.weight
        
        if let weightString = firstUser.weight?.split(separator: " ").first,
           let weight = Double(weightString) {
            userWeight = weight
        }
        
        let calories = calculateCalories(for: firstUser)
        CalorieLabel.text = "\(String(format: "%.2f", calories)) kcal"
    }
    
    func makeImageViewCircular(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }
    
    func loadSavedSteps() {
        savedSteps = UserDefaults.standard.integer(forKey: "savedSteps")
    }
    
    func startPedometerUpdates() {
        let lastRecordedDate = UserDefaults.standard.object(forKey: "lastRecordedDate") as? Date ?? Date()
        loadSavedSteps()
        
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: lastRecordedDate) { data, error in
                guard let pedometerData = data, error == nil else {
                    print("Pedometer error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                DispatchQueue.main.async {
                    let currentSteps = pedometerData.numberOfSteps.intValue
                    let totalSteps = self.savedSteps + currentSteps
                    let distance = pedometerData.distance?.doubleValue ?? 0.0
                    
                    self.stepsLabel.text = "\(totalSteps)"
                    self.distanceLabel.text = String(format: "Distance: %.2f meters", distance)
                    
                    let caloriesBurned = self.calculateCaloriesBurned(steps: totalSteps)
                    self.caloriesLabel.text = String(format: "Calories: %.2f kcal", caloriesBurned)
                    
                    let progress = min(1.0, Double(totalSteps) / Double(self.stepGoal))
                    self.progressLabel.text = String(format: "Goal Progress: %.2f%%", progress * 100)
                    
                    self.saveStepCount(totalSteps)
                }
            }
        }
    }
    
    func saveStepCount(_ totalSteps: Int) {
        UserDefaults.standard.set(totalSteps, forKey: "savedSteps")
        UserDefaults.standard.set(Date(), forKey: "lastRecordedDate")
    }
    
    func calculateCaloriesBurned(steps: Int) -> Double {
        return Double(steps) * userWeight * 0.035
    }
    
    func calculateCalories(for user: User) -> Double {
        guard let weightString = user.weight,
              let weightValue = Double(weightString.split(separator: " ")[0]),
              let heightString = user.height,
              let heightValue = Double(heightString.split(separator: " ")[0]) else {
            return 0.0
        }
        
        let bmr: Double
        if user.gender == "Male" {
            bmr = 88.362 + (13.397 * weightValue) + (4.799 * heightValue) - (5.677 * Double(user.age))
        } else {
            bmr = 447.593 + (9.247 * weightValue) + (3.098 * heightValue) - (4.330 * Double(user.age))
        }
        
        let activityMultiplier: Double
        switch user.activityLevel {
        case "Sedentary": activityMultiplier = 1.2
        case "Lightly Active": activityMultiplier = 1.375
        case "Moderately Active": activityMultiplier = 1.55
        case "Very Active": activityMultiplier = 1.725
        case "Super Active": activityMultiplier = 1.9
        default: activityMultiplier = 1.2
        }
        
        var totalCalories = bmr * activityMultiplier
        let workoutCalories: Double
        switch user.workoutIntensity {
        case "Low": workoutCalories = 4.0 * user.workoutDuration
        case "Moderate": workoutCalories = 6.0 * user.workoutDuration
        case "High": workoutCalories = 8.0 * user.workoutDuration
        default: workoutCalories = 4.0 * user.workoutDuration
        }
        
        totalCalories += workoutCalories
        return totalCalories
    }
    
    func setupWaterStepper() {
        waterAddStepper.minimumValue = 0
        waterAddStepper.maximumValue = Double(maxWaterIntake)
        waterAddStepper.stepValue = 250
        waterAddStepper.value = Double(currentWaterIntake)
    }
    
    func loadSavedWaterIntake() {
        currentWaterIntake = UserDefaults.standard.float(forKey: "currentWaterIntake")
    }
    
    func updateWaterUI() {
        waterDrinkLabel.text = "\(Int(currentWaterIntake)) ml"
        waterProgrssBar.progress = currentWaterIntake / maxWaterIntake
        
        let remainingPercentage = max(0, (1 - (currentWaterIntake / maxWaterIntake)) * 100)
        remainingWaterDrinkLevelLabel.text = String(format: "%.1f%% remaining", remainingPercentage)
        
        UserDefaults.standard.set(currentWaterIntake, forKey: "currentWaterIntake")
    }
    
    func scheduleDailyReset() {
        if let lastResetDate = UserDefaults.standard.object(forKey: "lastWaterResetDate") as? Date,
           Calendar.current.isDateInToday(lastResetDate) {
            return
        }
        resetWaterIntake()
        Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { _ in
            self.resetWaterIntake()
        }
    }
    
    func resetWaterIntake() {
        currentWaterIntake = 0.0
        waterAddStepper.value = 0
        updateWaterUI()
        UserDefaults.standard.set(Date(), forKey: "lastWaterResetDate")
    }
    
    @IBAction func weightEditTap(_ sender: Any) {
        navigateToUpdateViewController()
    }
    
    @IBAction func heightEditTap(_ sender: Any) {
        navigateToUpdateViewController()
    }
    
    @IBAction func EditButton(_ sender: Any) {
        navigateToUpdateViewController()
    }
    
    func navigateToUpdateViewController() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let updateVC = storyBoard.instantiateViewController(withIdentifier: "UpdateViewController") as? UpdateViewController{
            updateVC.delegate = self // Set the delegate
            updateVC.selectedData = user_Detail.first // Pass the first user details
            updateVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            updateVC.modalTransitionStyle = .crossDissolve
        self.present(updateVC, animated: true, completion: nil)
    }
}
    func didUpdateUser(_ user: User) {
        // Update the user details in the local array
        if let index = user_Detail.firstIndex(where: { $0.id == user.id }) {
            user_Detail[index] = user
        }
        updateUI() // Refresh the UI with the new data
    }
    @IBAction func CalorieCalculateButtonTap(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let newViewController = storyBoard.instantiateViewController(withIdentifier: "CaloriesCalculationViewController") as? CaloriesCalculationViewController {
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
        }
        

    }
    
    @IBAction func realTimeMeaureButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let newViewController = storyBoard.instantiateViewController(withIdentifier: "MeasurmentsViewController") as? MeasurmentsViewController {
            newViewController.modalPresentationStyle = .fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func waterStepperValueChanged(_ sender: UIStepper) {
        currentWaterIntake = Float(sender.value)
        updateWaterUI()
    }

}
