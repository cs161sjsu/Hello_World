//
//  StatisticsTableViewCell.swift
//  KloutApp
//
//  Created by Kyle Burns on 3/2/21.
//

import UIKit

class StatisticsTableViewCell: UITableViewCell {

    @IBOutlet weak var socialImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var quantityLabel1: UILabel!
    @IBOutlet weak var quantityLabel2: UILabel!
    @IBOutlet weak var quantityLabel3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
