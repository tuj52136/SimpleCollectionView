//
//  EventEditorViewController.swift
//  SimpleCollectionView
//
//  Created by Leo Vergnetti on 2/7/19.
//  Copyright © 2019 Leo Vergnetti. All rights reserved.
//

import UIKit

class EventEditorViewController : UIViewController{
    
    @IBOutlet weak var eventNameTextField: UITextField!
    
    @IBOutlet weak var eventDescriptionTextField: UITextView!

    @IBOutlet weak var addEventButton: UIBarButtonItem!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate : EventEditorDelegate?
    var dateBroughtForward : Date?
    override func viewDidLoad() {
        navigationController?.navigationBar.tintColor = UIColor.red
        if let date = dateBroughtForward {
            datePicker.setDate(date, animated: true)
        }
    }
//    @IBAction func addEventButtonPressed(_ sender: UIBarButtonItem) {
//    }
    @IBAction func addEventButtonPressed(_ sender: UIBarButtonItem) {
        if let setDelegate = delegate, let name = eventNameTextField.text{
            let date = datePicker.date
            let year = Calendar.current.component(.year, from: date)
            let month = Calendar.current.component(.month, from: date)
            let day = Calendar.current.component(.day, from: date)
            let formattedDate = Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
            setDelegate.updateEventDescription(eventName: name, date : formattedDate)
        }
        navigationController?.popViewController(animated: true)
    }
}
