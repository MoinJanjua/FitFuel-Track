//
//  WorkutDetailsViewController.swift
//  FitFuel Track
//
//  Created by Maaz on 04/11/2024.
//
import UIKit
import TYProgressBar

class WorkutDetailsViewController: UIViewController {
    
    @IBOutlet weak var typeTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var mintsTF: UITextField!
    @IBOutlet weak var setsTF: UITextField!
    @IBOutlet weak var startdateTF: UITextField!
    @IBOutlet weak var daysTF: UITextField!
    @IBOutlet weak var startBTn: UIButton!
    @IBOutlet weak var stopBTn: UIButton!
    @IBOutlet weak var resumeButton: UIButton! // Connect this button in storyboard
    @IBOutlet weak var ProgessBarView: UIView!

    @IBOutlet weak var tellinhMinutesLabel: UILabel!
    
    var selectedWorkouts: WorkOut?
    var selectedIndex: Int?
    let progressBar = TYProgressBar()
    var progressTimer: Timer?
    var savedProgress: CGFloat = 0.0 // To save progress when paused
    var totalDurationInSeconds: Double = 0 // Total workout duration in seconds
    var isPaused = false // To track the pause/resume state
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundCorner(button: startBTn)
        roundCorner(button: stopBTn)
        roundCorner(button: resumeButton)
        
        if let userData = selectedWorkouts {
            typeTF.text = userData.Types
            nameTF.text = userData.Name
            
            
            if let dailyMint = userData.DailyMint {
                mintsTF.text = "\(dailyMint)"
                tellinhMinutesLabel.text = "Your \(dailyMint) Minutes Counter Started"
            } else {
                mintsTF.text = "N/A"
                tellinhMinutesLabel.text = "N/A"
            }
            
            if let setCount = userData.SetCount {
                setsTF.text = "\(setCount)"
            } else {
                setsTF.text = "N/A"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            startdateTF.text = dateFormatter.string(from: userData.StartDate)
            
            if let totalDays = userData.TotalDays {
                daysTF.text = "\(totalDays)"
            } else {
                daysTF.text = "N/A"
            }
        }
        ProgessBarView.isHidden = true
        setupProgressBar()
    }
    
    func setupProgressBar() {
        progressBar.frame = CGRect(x: 0, y: 0, width: 220, height: 220)
        progressBar.center = self.view.center
        self.view.addSubview(progressBar)
        
        progressBar.trackColor = UIColor(white: 0.2, alpha: 0.5)
        progressBar.gradients = [UIColor.red, UIColor.yellow]
        progressBar.textColor = .orange
        progressBar.font = UIFont(name: "HelveticaNeue-Medium", size: 22)!
        progressBar.lineDashPattern = [10, 4]
        progressBar.lineHeight = 5
        progressBar.progress = 0
        progressBar.isHidden = true // Hide initially
    }
    
    @IBAction func StartButton(_ sender: Any) {
        // Stop any existing timer and reset progress
        progressTimer?.invalidate()
        savedProgress = 0.0
        progressBar.progress = 0
        progressBar.isHidden = false // Show progress bar
        ProgessBarView.isHidden = false
        isPaused = false
        resumeButton.setTitle("Pause", for: .normal)
        
        // Get the duration in minutes from mintsTF and convert to seconds
        guard let minutesText = mintsTF.text,
              let minutes = Int(minutesText),
              minutes > 0 else {
            showAlert(message: "Please enter a valid duration in minutes.")
            return
        }
        
        totalDurationInSeconds = Double(minutes * 60)
        startTimer(fromProgress: 0)
    }
    
    func startTimer(fromProgress progress: CGFloat) {
        let interval = 0.1
        let totalIntervals = totalDurationInSeconds / interval
        var currentInterval = Double(progress) * totalIntervals
        
        // Start a timer to update the progress
        progressTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            currentInterval += 1
            
            // Update the progress bar based on elapsed intervals
            self.progressBar.progress = CGFloat(currentInterval / totalIntervals)
            self.savedProgress = self.progressBar.progress
            
            if currentInterval >= totalIntervals {
                timer.invalidate()
                self.showAlert(message: "Workout complete!")
                self.progressBar.isHidden = true // Hide progress bar when complete
                self.resumeButton.setTitle("Continue", for: .normal)
            }
        }
    }

    @IBAction func resumeButton(_ sender: Any) {
        if isPaused {
            // Resume from the saved progress
            startTimer(fromProgress: savedProgress)
            resumeButton.setTitle("Pause", for: .normal)
        } else {
            // Pause the progress and save current progress
            progressTimer?.invalidate()
            resumeButton.setTitle("Continue", for: .normal)
        }
        isPaused.toggle()
    }
    
    @IBAction func StopButton(_ sender: Any) {
        progressTimer?.invalidate()
        progressBar.progress = 0
        savedProgress = 0.0
        progressBar.isHidden = true // Hide progress bar
        ProgessBarView.isHidden = true
        isPaused = false
        resumeButton.setTitle("Continue", for: .normal)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func BackButton(_ sender: Any) {
        progressTimer?.invalidate()
        progressBar.isHidden = true // Hide progress bar
        self.dismiss(animated: true)
    }
}

