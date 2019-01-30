//
//  ViewController.swift
//  SimpleCollectionView
//
//  Created by Leo Vergnetti on 1/29/19.
//  Copyright © 2019 Leo Vergnetti. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var janItems = Array(1 ... 31)
    var febItems = Array(1 ... 28)
    var marchItems = Array(1 ... 31)
    var aprilItems = Array(1 ... 30)
    var mayItems = Array(1 ... 31)
    
    var items = ["", ""]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        //cell.cellLabel = drawEventCircleOnLabel(events: [1, 2, 3], label: cell.cellLabel)
        cell.cellLabel.text = "\(items[indexPath.item])"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        items += ["Jan"] + getEmptyWeek() + janItems.map{ String($0) } + getEmptyWeek()
        items += ["Feb"] +  getEmptyWeek() + febItems.map{ String($0) } + getEmptyWeek()
        items += ["Mar"] +  getEmptyWeek() + marchItems.map{ String($0) } + getEmptyWeek()
        items += ["April"] +  getEmptyWeek() + aprilItems.map{ String($0) } + getEmptyWeek()
        items += ["May"] +  getEmptyWeek() + mayItems.map{ String($0) } + getEmptyWeek()
        
    }

    func getEmptyWeek() -> [String] {
        return ["", "", "", "", "", "", ""]
    }
    func drawEventCircleOnLabel(events : [Int], label : UILabel) -> UILabel {
        for i in 1 ... events.count {
            let colors = getColorArray()
            let diskLayer = CAShapeLayer()
            let ovalPath = UIBezierPath(arcCenter: CGPoint(x: label.frame.size.width/2, y: label.frame.size.height/2),
                                        radius: label.frame.size.height/3,
                                        startAngle: CGFloat(Double(i - 1) * 360.0 / Double(events.count) ).toRadians(),
                                        endAngle: CGFloat(Double(i) * 360.0 / Double(events.count)).toRadians(),
                                        clockwise: true)
            diskLayer.path = ovalPath.cgPath
            diskLayer.strokeColor = colors[i-1]
            diskLayer.lineWidth = 4.0
            diskLayer.fillColor = UIColor.clear.cgColor
            label.layer.addSublayer(diskLayer)
        }
        return label
    }
    
    
    func getColorArray() -> [CGColor]{
        let red = UIColor.init(red:0.84, green:0.19, blue:0.19, alpha:1.0)
        let green = UIColor(red:0.00, green:0.72, blue:0.58, alpha:1.0)
        let blue = UIColor(red:0.04, green:0.52, blue:0.89, alpha:1.0)
        let yellow = UIColor(red:1.00, green:0.92, blue:0.65, alpha:1.0)
        
        return [red.cgColor, green.cgColor, blue.cgColor, yellow.cgColor]
    }
    
    
}

extension CGFloat{
    func toRadians() -> CGFloat{
        return self * CGFloat.pi/180
    }
}
