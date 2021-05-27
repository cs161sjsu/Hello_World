//
//  ShareTableViewCell.swift
//  KloutApp
//
//  Created by Kyle Burns on 3/2/21.
//

import UIKit

class ShareTableViewCell: UITableViewCell {

    @IBOutlet weak var socialImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
