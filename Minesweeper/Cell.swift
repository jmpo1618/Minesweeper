//
//  Cell.swift
//  Minesweeper
//
//  Created by Juan M Penaranda on 5/26/16.
//  Copyright © 2016 Juan M Penaranda. All rights reserved.
//

import UIKit

class Cell: UICollectionViewCell {
    
    // MARK: Properties
    @IBOutlet weak var label: UILabel!
    var row: Int?
    var col: Int?
    var mine: Bool?
    var tapped: Bool?
    var flagged: Bool?
    var neighborMines: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
