//
//  ViewController.swift
//  SimpleCollectionView
//
//  Created by Leo Vergnetti on 1/29/19.
//  Copyright © 2019 Leo Vergnetti. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var addEventButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet var backgroundView: UIView!
    
    let transLayer = UIView()
    let stringMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    //var earliestDateCurrentlyLoaded : Date?
    var eventsByDay = [Date : [Event]]() {
        didSet {
            collectionView.reloadData()
        }
    }
    var indexPathCurrentlySelected : IndexPath?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request : NSFetchRequest<Event> = Event.fetchRequest()
        do{
            let events = try context.fetch(request)
            for event in events{
                addEventToEventsByDayDictionary(add: event)
            }
        }catch{
            print("Error fetching data from context: \(error)")
        }
        //collectionView.reloadData()
        transitionBackToCalendarView()
        collectionView.scrollToItem(at: IndexPath(item: 13, section: 0), at: UICollectionView.ScrollPosition.top, animated: true)
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        transitionBackToCalendarView()
    }
    
    
    
    @IBAction func addEventButtonPressed(_ sender: UIBarButtonItem) {
      performSegue(withIdentifier: "TransitionToEventEditor", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransitionToEventEditor" {
            let destinationVC = segue.destination as! EventEditorViewController
            if let indexPath = indexPathCurrentlySelected{
                destinationVC.dateBroughtForward = getDateFromIndexPath(indexPath: indexPath)
            }
            destinationVC.delegate = self
        }
    }
    
    func transitionBackToCalendarView(){
        indexPathCurrentlySelected = nil
        for view in transLayer.subviews{
            view.removeFromSuperview()
        }
        transLayer.removeFromSuperview()
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        collectionView.layer.borderColor = UIColor.lightGray.cgColor
        collectionView.layer.borderWidth = 0.5
        backButton.isEnabled = false
        backButton.tintColor = UIColor.white
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
        let newEvent = Event(context: context)
        newEvent.title = title
        newEvent.date = date
        addEventToEventsByDayDictionary(add: newEvent)
        do{
            try context.save()
        }catch{
            print("Error Saving Context: \(error)")
        }
    }
    
    func addEventToEventsByDayDictionary(add event : Event){
        var events = [Event]()
        if let oldEvents = eventsByDay[event.date!] {
            events += oldEvents
        }
        events += [event]
        eventsByDay[event.date!] = events
    }
    func getDateFromIndexPath(indexPath : IndexPath) -> Date{
        let startDay = Date.getFirstOfMonth(month: indexPath.section + 1)
        return Calendar.current.date(from: DateComponents(year: 2019, month: indexPath.section + 1, day:(indexPath.item + 1) - startDay + 1))!
        
    }
    
    func getDateFromSection(section : Int) -> Date{
        let startDay = Date.getFirstOfMonth(month: section + 1)
        return Calendar.current.date(from: DateComponents(year: 2019, month:section + 1, day: startDay))!
    }
    
    //MARK: DRAW FUNCTIONS
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


extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    //MARK: DATASOURCE AND DELEGATE METHODS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getDateFromSection(section: section).getNumberOfDaysInMonth() + Date.getFirstOfMonth(month: section + 1) - 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
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
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        indexPathCurrentlySelected = indexPath
        prepareToTransitionToDateScreen()
        let label = UILabel(frame: collectionView.convert(cell.frame, to: transLayer))
        label.textColor = UIColor.white
        label.text = cell.cellLabel.text
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.frame = label.frame.offsetBy(dx: 0.0, dy: 1.0)
        transLayer.addSubview(label)
        //cell.cellLabel.text = ""
        if let events = getEventsFromIndexPath(indexPath: indexPath){
            drawEventCircleOnCell(using: events, on: label)
            drawEventsToScreen(using: events, alignedWith: label)
        }
        backgroundView.addSubview(transLayer)
    }
    
    
}

extension ViewController : EventEditorDelegate {
    
    func updateEventDescription(eventName: String, date: Date) {
        addEvent(for: date, named: eventName)
        transitionBackToCalendarView()
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
        //let date = Calendar.current.date(byAdding: Calendar.Component, value: <#T##Int#>, to: <#T##Date#>)
        let startDay = Calendar.current.component(.weekday, from: date!)
        return startDay
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    func getNumberOfDaysInMonth() -> Int{
         return Calendar.current.component(.day, from: Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!) //Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    func isCurrentMonth() -> Bool{
        return Calendar.current.compare(Date(), to: self, toGranularity: .month) == ComparisonResult.orderedSame
    }
    
    func isCurrentDay() -> Bool{
        return Calendar.current.compare(Date(), to: self, toGranularity: .day) == ComparisonResult.orderedSame
    }
}

