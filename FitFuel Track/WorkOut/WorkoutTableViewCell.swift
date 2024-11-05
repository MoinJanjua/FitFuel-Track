//
//  WorkoutTableViewCell.swift
//  FitFuel Track
//
//  Created by Maaz on 30/10/2024.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {
    
    @IBOutlet weak var workOutnameLabel: UILabel!
    @IBOutlet weak var workoutTypeLbl: UILabel!
    @IBOutlet weak var setsLbl: UILabel!
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var mintsLbl: UILabel!
    @IBOutlet weak var daysLbl: UILabel!
    @IBOutlet weak var leftdaysLbl: UILabel!


    @IBOutlet weak var cornerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
      //  curveTopLeftCornersforView(of: cornerView, radius: 50)

        contentView.layer.cornerRadius = 12
        
        // Set up shadow properties
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 4.0
        contentView.layer.masksToBounds = false
        
        // Set background opacity
        contentView.alpha = 1.5 // Adjust opacity as needed
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
