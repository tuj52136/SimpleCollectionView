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
    
    @IBOutlet weak var addEventButton: UIButton!
    
    
    var delegate : EventEditorDelegate?
    
    
    @IBAction func addEventButtonPressed(_ sender: UIButton) {
        if let setDelegate = delegate, let name = eventNameTextField.text{
            setDelegate.updateEventDescription(eventName: name)
        }
        self.dismiss(animated: true, completion: nil)
        }
    
//    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
//
//    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "Event Added" {
//            if let name = eventNameTextField.text, let setDelegate = delegate {
//                setDelegate.updateEventDescription(eventName: name)
//                print("Updated delegate with \(name)")
//            }
//        }
//    }
}
