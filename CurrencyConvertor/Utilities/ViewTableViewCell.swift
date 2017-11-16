//
//  ViewTableViewCell.swift
//  CurrencyConvertor
//
//  Created by Syed Uzair Ahmed on 16/11/2017.
//  Copyright © 2017 Syed Uzair Ahmed. All rights reserved.
//

import UIKit

class ViewTableViewCell: UITableViewCell {

    @IBOutlet var lblValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
