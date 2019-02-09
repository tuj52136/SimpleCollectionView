//
//  HeaderView.swift
//  SimpleCollectionView
//
//  Created by Leo Vergnetti on 1/30/19.
//  Copyright © 2019 Leo Vergnetti. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
        
    @IBOutlet weak var headerLabel: UILabel!
    
    func getHeaderPosition(for indexPath: IndexPath) -> CGRect{
        let headerLocation = CGRect(x: (CGFloat(Date.getFirstOfMonth(month: indexPath.section + 1) - 1) * self.frame.width / 7.0) + 5, y: self.frame.height - headerLabel.frame.height, width:headerLabel.frame.width, height: headerLabel.frame.height)
        return headerLocation
    }
}
