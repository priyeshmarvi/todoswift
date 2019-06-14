//
//  DisplayCell.swift
//  TODOAPP
//
//  Created by icanstudioz on 13/06/19.
//  Copyright © 2019 icanstudioz.com. All rights reserved.
//

import UIKit

class DisplayCell: UITableViewCell {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_description: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
