//
//  ViewController.swift
//  SimpleCollectionView
//
//  Created by Leo Vergnetti on 1/29/19.
//  Copyright © 2019 Leo Vergnetti. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, EventEditorDelegate{
    
    
    func updateEventDescription(eventName: String) {
           let date = getDateFromIndexPath(indexPath: indexPathCurrentlySelected!)
           addEvent(for: date, named: eventName)
           transitionBackToCalendarView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransitionToEventEditor" {
            let destinationVC = segue.destination as! EventEditorViewController
            destinationVC.delegate = self
        }
    }
    
    @IBOutlet weak var addEventButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet var backgroundView: UIView!
    
    let transLayer = UIView()
    let daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    let stringMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var eventsByDay = [Date : [Event]]()
    var indexPathCurrentlySelected : IndexPath?
    
    
    //MARK: DATASOURCE AND DELEGATE METHODS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ((daysInMonth[section] + Date.getFirstOfMonth(month: section + 1)) - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        print("Section number in header : \(indexPath)")
        headerView.headerLabel.textColor = UIColor.black
        if getDateFromSection(section: indexPath.section).isCurrentMonth(){
            headerView.headerLabel.textColor = UIColor(cgColor: getColorArray()[0])
        }
        headerView.headerLabel.text = stringMonths[indexPath.section]
        headerView.headerLabel.frame = headerView.getHeaderPosition(for: indexPath)
        return headerView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        removeSublayerFromViewByName(view: cell, name: "Disk Layer")
        let startDay = Date.getFirstOfMonth(month: indexPath.section + 1)
        cell.cellLabel.textColor = UIColor.black
        cell.cellLabel.font = UIFont.systemFont(ofSize: 16)
        if getDateFromIndexPath(indexPath: indexPath).isCurrentDay(){
            cell.cellLabel.textColor = UIColor(cgColor: getColorArray()[0])
            cell.cellLabel.font = UIFont.boldSystemFont(ofSize: 18)
        }
        if indexPath.item < startDay - 1 {
            cell.cellLabel.text = ""
            removeSublayerFromViewByName(view: cell, name: "")
        } else{
            drawTopLineOnCell(cell: cell)
            if let events = getEventsFromIndexPath(indexPath: indexPath){
                drawEventCircleOnCell(using: events, on: cell)
            }
            cell.cellLabel.text = "\((indexPath.item + 1) - startDay + 1)"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(eventsByDay)
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        indexPathCurrentlySelected = indexPath
        prepareToTransitionToDateScreen()
        //let button = UIButton(frame: collectionView.convert(cell.frame, to: backgroundView))
        let label = UILabel(frame: collectionView.convert(cell.frame, to: transLayer))
        //button.tintColor = UIColor.white
        //label.tintColor = UIColor.white
        label.textColor = UIColor.white
        //button.setTitle(cell.cellLabel.text, for: .normal)
        label.text = cell.cellLabel.text
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.frame = label.frame.offsetBy(dx: 0.0, dy: 1.0)
        
        transLayer.addSubview(label)
        cell.cellLabel.text = ""
        if let events = getEventsFromIndexPath(indexPath: indexPath){
            drawEventCircleOnCell(using: events, on: label)
            drawEventsToScreen(using: events, alignedWith: label)
        }
        backgroundView.addSubview(transLayer)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitionBackToCalendarView()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: UICollectionView.ScrollPosition.top, animated: true)
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        transitionBackToCalendarView()
    }
    
    
    //TODO: addEventButtonPressed segues to event screen
    @IBAction func addEventButtonPressed(_ sender: UIBarButtonItem) {
      performSegue(withIdentifier: "TransitionToEventEditor", sender: self)
    }

    func transitionBackToCalendarView(){
        indexPathCurrentlySelected = nil
        backgroundView.addSubview(navigationBar)
        for view in transLayer.subviews{
            view.removeFromSuperview()
        }
        navigationBar.isTranslucent = true
        navigationBar.barTintColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        transLayer.removeFromSuperview()
        navigationBar.setValue(true, forKey: "hidesShadow")
        collectionView.layer.borderColor = UIColor.lightGray.cgColor
        collectionView.layer.borderWidth = 0.5
        backButton.isEnabled = false
        backButton.tintColor = UIColor.white
        addEventButton.isEnabled = false
        addEventButton.tintColor = UIColor.white
        collectionView.reloadData()
    }
    
    func prepareToTransitionToDateScreen(){
        transLayer.frame = collectionView.frame
        transLayer.backgroundColor = UIColor.black
        transLayer.alpha = 0.75
        backButton.isEnabled = true
        backButton.tintColor = UIColor.red
        addEventButton.tintColor = UIColor.red
        addEventButton.isEnabled = true
        //navigationBar.isTranslucent = false
        //navigationBar.barTintColor = UIColor.black
        //transLayer.addSubview(navigationBar)
    }
    
    func drawEventsToScreen(using events: [Event], alignedWith button : UILabel){
        var labelY = CGFloat(0.0)
        var pm = 0
        if button.frame.maxY < collectionView.frame.midY {
            labelY = button.frame.maxY
            pm = 1
        }else{
            labelY = button.frame.minY - 30.0
            pm = -1
        }
        for i in events.enumerated(){
            let label = UILabel(frame: CGRect(x: button.frame.minX, y: labelY + (CGFloat(pm * i.offset) * 30.0),  width: 100, height: 30.0))
            label.textColor = UIColor(cgColor: getColorArray()[i.offset]).withAlphaComponent(1.0)
            label.font = UIFont(name: "Arial", size: 16)
            label.textAlignment = .center
            label.text = i.element.title
            transLayer.addSubview(label)
        }
    }
    
    //MARK: POTENTIAL MODEL METHODS
    func getEventsFromIndexPath(indexPath: IndexPath) -> [Event]?{
        var events : [Event]?
        if let newEvents = eventsByDay[getDateFromIndexPath(indexPath: indexPath)]{
            events = newEvents
        }
        return events
    }
    
    func addEvent(for date : Date, named title : String){
        var events = [Event]()
        if let oldEvents = eventsByDay[date] {
            events += oldEvents
        }
        let newEvent = Event(title: title)
        events += [newEvent]
        eventsByDay[date] = events
    }
    
    func getDateFromIndexPath(indexPath : IndexPath) -> Date{
        let startDay = Date.getFirstOfMonth(month: indexPath.section + 1)
        return Calendar.current.date(from: DateComponents(year: 2019, month: indexPath.section + 1, day:(indexPath.item + 1) - startDay + 1))!
    }
    
    func getDateFromSection(section : Int) -> Date{
        let startDay = Date.getFirstOfMonth(month: section + 1)
        return Calendar.current.date(from: DateComponents(year: 2019, month:section + 1, day: startDay))!
    }
    
    func removeSublayerFromViewByName(view : UIView, name : String){
        if let sublayers = view.layer.sublayers{
            for layer in sublayers{
                if layer.name == name{
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
    func drawTopLineOnCell(cell: UICollectionViewCell){
        let topLine = CALayer()
        topLine.frame = CGRect(x: 0.0, y: 0.0 + 4, width: cell.frame.width, height: 0.5)
        topLine.backgroundColor = UIColor.lightGray.cgColor
        topLine.name = ""
        cell.layer.addSublayer(topLine)
    }
    
    func drawEventCircleOnCell(using events : [Event], on view : UIView){
        for i in 1 ... events.count {
            let colors = getColorArray()
            let diskLayer = CAShapeLayer()
            let ovalPath = UIBezierPath(arcCenter: CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2),
                                        radius: view.frame.size.height * 5.0 / 16.0,
                                        startAngle: CGFloat(Double(i - 1) * 360.0 / Double(events.count) ).toRadians(),
                                        endAngle: CGFloat(Double(i) * 360.0 / Double(events.count)).toRadians(),
                                        clockwise: true)
            diskLayer.path = ovalPath.cgPath
            diskLayer.strokeColor = colors[i-1]
            diskLayer.lineWidth = 4.0
            diskLayer.fillColor = UIColor.clear.cgColor
            diskLayer.name = "Disk Layer"
            view.layer.addSublayer(diskLayer)
        }
    }
    
    
    func getColorArray() -> [CGColor]{
        let red = UIColor(red:0.84, green:0.19, blue:0.19, alpha:1.0)
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

extension Date{
    static func getFirstOfMonth(month : Int) -> Int{
        let date = Calendar.current.date(from: DateComponents(year: 2019, month: month, day: 1))
        let startDay = Calendar.current.component(.weekday, from: date!)
        return startDay
    }
    
    func isCurrentMonth() -> Bool{
        return Calendar.current.compare(Date(), to: self, toGranularity: .month) == ComparisonResult.orderedSame
    }
    
    func isCurrentDay() -> Bool{
        return Calendar.current.compare(Date(), to: self, toGranularity: .day) == ComparisonResult.orderedSame
    }
}
