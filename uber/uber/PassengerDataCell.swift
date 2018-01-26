//
//  PassengerDataCell.swift
//  
//
//  Created by SnoopyKing on 2017/11/9.
//

import UIKit

class PassengerDataCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    //設置單元格--作為外部調用,設置單元格內元素
    func configureCell(profileImage: UIImage,email: String, detail:String){
        self.profileImage.image = profileImage
        self.userEmail.text = email
        self.detailLabel.text = detail
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
