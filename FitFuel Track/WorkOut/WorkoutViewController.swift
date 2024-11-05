//
//  WorkoutViewController.swift
//  FitFuel Track
//
//  Created by Maaz on 30/10/2024.
//

import UIKit
import PDFKit

class WorkoutViewController: UIViewController {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var createbtn: UIButton!

    var workout_Detail: [WorkOut] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDropShadowButtonOne(to: createbtn)
        roundCorner(button:createbtn)

        TableView.dataSource = self
        TableView.delegate = self
        noDataLabel.text = "There is no data in the table view. Please add a workout or exercise first" // Set the message


    }
    override func viewWillAppear(_ animated: Bool) {
        // Deselect the current tab
        if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? TabBarViewController {
            tabBarController.selectedIndex = NSNotFound // Set to an invalid index to deselect
        }
        // Retrieve stored medication records from UserDefaults
        if let savedData = UserDefaults.standard.array(forKey: "worksoutDataDetails") as? [Data] {
            let decoder = JSONDecoder()
            workout_Detail = savedData.compactMap { data in
                do {
                    let order = try decoder.decode(WorkOut.self, from: data)
                    return order
                } catch {
                    print("Error decoding medication: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        noDataLabel.text = "There is no data in the table view. Please add a workout or exercise first" // Set the message
        // Show or hide the table view and label based on data availability
               if workout_Detail.isEmpty {
                   TableView.isHidden = true
                   noDataLabel.isHidden = false  // Show the label when there's no data
               } else {
                   TableView.isHidden = false
                   noDataLabel.isHidden = true   // Hide the label when data is available
               }
     TableView.reloadData()
    
  
    }
    
    deinit {
        // Remove delegate when the view controller is deallocated
        if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
            tabBarController.delegate = nil
        }
    }
    func generatePDF() {
        let pdfDocument = PDFDocument()
        
        for (index, _) in workout_Detail.enumerated() {
            guard let cell = TableView.cellForRow(at: IndexPath(row: index, section: 0)) as? WorkoutTableViewCell else { continue }
            
            // Capture cell as image
            let cellImage = cellToImage(cell: cell)
            
            // Convert image to PDF page
            let pdfPage = PDFPage(image: cellImage)
            pdfDocument.insert(pdfPage!, at: index)
        }
        
        // Save PDF or share
        if let pdfData = pdfDocument.dataRepresentation() {
            savePDF(data: pdfData)
        }
    }
    
    func cellToImage(cell: UITableViewCell) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, UIScreen.main.scale)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func savePDF(data: Data) {
        // Save PDF file to the Documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfURL = documentsPath.appendingPathComponent("WorkoutDetails.pdf")
        
        do {
            try data.write(to: pdfURL)
            print("PDF saved at: \(pdfURL)")
            
            // Optionally present a share sheet
            let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
            present(activityVC, animated: true, completion: nil)
        } catch {
            print("Could not save PDF: \(error)")
        }
    }
    
    func showAlertForEmptyData() {
        let alertController = UIAlertController(
            title: "No Data Available",
            message: "There is no data in the table view. Please add a workout or exercise first.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func CaloriesCalculationButton(_ sender: Any) {
        
    }
    @IBAction func CreateWOButton(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddWorkOutViewController") as! AddWorkOutViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func PDFGeneratorButton(_ sender: Any) {
        if workout_Detail.isEmpty {
                 showAlertForEmptyData()
             } else {
                 generatePDF()
             }
    }
    
    
}
extension WorkoutViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workout_Detail.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath) as! WorkoutTableViewCell
        
        let workoutData = workout_Detail[indexPath.row]
        cell.workOutnameLabel?.text = workoutData.Name
        cell.workoutTypeLbl?.text = workoutData.Types
        
        // Convert Int? values to String, providing a default if nil
        cell.daysLbl?.text = workoutData.TotalDays != nil ? "\(workoutData.TotalDays!) Days" : "N/A"
        cell.setsLbl?.text = workoutData.SetCount != nil ? "\(workoutData.SetCount!) Sets" : "N/A"
        cell.mintsLbl?.text = workoutData.DailyMint != nil ? "\(workoutData.DailyMint!) Mints" : "N/A"
        
        // Format and display the start date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let startDate = workoutData.StartDate
        cell.startDateLbl.text = dateFormatter.string(from: startDate)
        
        // Calculate the end date based on StartDate and TotalDays
        if let totalDays = workoutData.TotalDays {
            if let endDate = Calendar.current.date(byAdding: .day, value: totalDays, to: startDate) {
                let currentDate = Date()
                let remainingTime = Calendar.current.dateComponents([.day], from: currentDate, to: endDate)
                
                if let daysRemaining = remainingTime.day {
                    if daysRemaining > 0 {
                        cell.leftdaysLbl.text = "\(daysRemaining) days left"
                    } else {
                        cell.leftdaysLbl.text = "Completed"
                    }
                }
            }
        } else {
            cell.leftdaysLbl.text = "N/A"  // Handle case if TotalDays is nil
        }
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            workout_Detail.remove(at: indexPath.row)
            
            let encoder = JSONEncoder()
            do {
                let encodedData = try workout_Detail.map { try encoder.encode($0) }
                UserDefaults.standard.set(encodedData, forKey: "worksoutDataDetails")
            } catch {
                print("Error encoding medications: \(error.localizedDescription)")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = workout_Detail[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let newViewController = storyBoard.instantiateViewController(withIdentifier: "WorkutDetailsViewController") as? WorkutDetailsViewController {
            newViewController.selectedWorkouts = selectedItem // Pass the selected translation
            newViewController.selectedIndex = indexPath.row // Pass the index for updating
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
            
        }
    }
}
extension WorkoutViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController,
           visibleViewController is WorkoutViewController {
            navigationController.popViewController(animated: false)
        }
    }
}



//        // Convert the Date object to a String
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        let dateString = "Start Date: \(dateFormatter.string(from: workoutData.StartDate)) "
//        //
//
//        // Assign the formatted date string to the label
//        cell.startDateLbl.text = dateString
