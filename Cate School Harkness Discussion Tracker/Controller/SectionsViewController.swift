//
//  ViewController.swift
//  Cate School Harkness Discussion Tracker
//
//  Created by cate on 4/20/19.
//  Copyright © 2019 cate. All rights reserved.
//

import UIKit
import CoreData

class SectionsViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    let classStudentSize = Array(1...16)
    var numberOfStudents = 1
    var classSections = [ClassSection]()
    var className: String = ""
    var studentNames: [String] = []
    var whichClass: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTapGesture()
        self.activeField = UITextField()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ClassSizePicker.delegate = self
        ClassSizePicker.dataSource = self
        AlreadyMadeGroups.delegate = self
        AlreadyMadeGroups.dataSource = self
        
        //keyboard stuff
        configureTextFields()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        let fetchRequest: NSFetchRequest<ClassSection> = ClassSection.fetchRequest()
        
        do {
            //This gets all the saved class sections so far
            let classSections = try PersistenceService.context.fetch(fetchRequest)
            self.classSections = classSections
            //this loads up the picker view with all the class sections saved so far
            self.AlreadyMadeGroups.reloadAllComponents()
            
        } catch {}
        
        print("Viewdidload: \(classSections)")
        print("Viewdidload: \(classSections.count)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //this link is for multiple pickerview, suggests the tag if else technique.
    //https://stackoverflow.com/questions/27642164/how-to-use-two-uipickerviews-in-one-view-controller
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        //this is alreadyMadeGroups pickerview
        if pickerView.tag == 1 {
            if classSections.count == 0 {
                return 1
            }
            else {
                return classSections.count
            }
            
        } else {
            //the pickerview to determine class size
            return classStudentSize.count
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if pickerView.tag == 1 {
            
            //this is to make sure that you know to add classes if you don't have classes saved
            if classSections.count == 0 {
                EditDelete.isEnabled = false
                StartDiscussion.isEnabled = false
                return "Add a Class"
            }
            else {
                //this fills the pickerview with the classes saved in the core data (classSections)
                EditDelete.isEnabled = true
                StartDiscussion.isEnabled = true
                
                return String(classSections[row].nameOfSection!)
            }
            
        } else {
            //this is for selecting the number of students to add when creating a new class/editing a class
            return String(classStudentSize[row])
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1{
            //alreadymadeclass
            
            //this variable later tells you which class has been selected, so you can call it when you're editing
            whichClass = row

        }
        else{
            numberOfStudents = classStudentSize[row]
            
        }
    }
    //All Outlets
    //the first thing you ssee
    
    //OKAY I KNOW WE DIDN'T CAMEL BUT THIS IS FAR TOO GONE TO FIX WITHOUT CAUSING A HEADACHE
    //if you want to fix this, future student, be my guest but I'm not gonna
    @IBOutlet weak var Return: UIButton!
    @IBOutlet weak var AddAClass: UIButton!
    @IBOutlet weak var AlreadyMadeGroups: UIPickerView!
    @IBOutlet weak var AddAClassView: UIView!
    
    //the part where you add/edit the class
    @IBOutlet weak var ClassNameLabel: UILabel!
    @IBOutlet weak var ClassNameTextField: UITextField!
    @IBOutlet weak var ClassSizePicker: UIPickerView!
    @IBOutlet weak var GoButton: UIButton!
    @IBOutlet var studentNameTextField: [UITextField]!
    
    //the view that contains all of the student input options
    @IBOutlet weak var studentNameView: UIView!
    @IBOutlet var studentNameList: [UIView]!
    
    @IBOutlet weak var Save: UIButton!
    
    @IBOutlet weak var Delete: UIButton!
    
    @IBOutlet weak var StartDiscussion: UIButton!
    
    @IBOutlet weak var EditDelete: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var throwAwayForAddOrEdit = 0
    
    @IBAction func AddAClassButton(_ sender: UIButton) {
        addingOrEditingNamePageTransition()
        throwAwayForAddOrEdit = 0
    }
    
    @IBAction func editDeleteButton(_ sender: UIButton) {
        //this sets up the AddAClass view, but it fills the textfields with the information from the selected class. Now, you can edit the info from that class, whether it is changing student name or class name, adding a student and stuff
        throwAwayForAddOrEdit = 1
        Delete.isEnabled = true
        
        addingOrEditingNamePageTransition()
        
        settingUpNameInput(numberOfStudents: classSections[whichClass].studentNames!.count)
        Delete.isHidden = false
        ClassNameTextField.text = String(classSections[whichClass].nameOfSection!)
        
        for i in 0...(classSections[whichClass].studentNames!.count - 1) {
            studentNameTextField[i].text = String(classSections[whichClass].studentNames![i])
        }
        
    }
    
    
    @IBAction func goButton(_ sender: UIButton) {
        //this happens when you establish how many students are in a class you're making
        settingUpNameInput(numberOfStudents: numberOfStudents)
    }
    
    
    //save button
    @IBAction func saveButton(_ sender: UIButton) {
        //sort the student name list by tage, then for each item save the text field stuff into an array
        studentNameTextField = studentNameTextField.sorted(by: { $0.tag < $1.tag})
        //FOR SAVING: you just save. ha.
        //FOR EDIT: you first delete the original core data, then re-add this data in there

    
        //general saving
        studentNames = []
        for i in 0...(numberOfStudents-1) {
            
            studentNames.append(studentNameTextField[i].text!)
        }
        //now send that name
        className = String(ClassNameTextField.text!)
        
        print(studentNames)
        print(className)
        
        //saves to core data
        let classSection = ClassSection(context: PersistenceService.context)
        classSection.nameOfSection = className
        classSection.studentNames = studentNames
        PersistenceService.saveContext()
        self.classSections.append(classSection)
        //saving doesn't depend on whichClass
        clearTextFields(numberOfTextFields: studentNames.count)
        
        //if throwAwayForAddorEdit is a 1, it means that this is in editing mode. The way we're editing is to just add a new class with the edited information, therefore we need to delete the old class
        if throwAwayForAddOrEdit == 1{
            deleteClass()
            backToStartAfterEditOrDelete()
        }
        //core data
        //https://www.youtube.com/watch?v=tP4OGvIRUC4
    }
    
    func deleteClass() {
        //deletes from core data
        let deleteThisClass = classSections[whichClass]
        //got the problem! for some reason the student names isn't saving as an array
        PersistenceService.context.delete(deleteThisClass)
        PersistenceService.saveContext()
        
        classSections.remove(at: whichClass)
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        //wipe the textfield
        print("which class is this?\(whichClass)")
        print(classSections[whichClass].studentNames!.count)
        clearTextFields(numberOfTextFields: classSections[whichClass].studentNames!.count)
        
        //then delete the class
        deleteClass()
        Delete.isEnabled = false
        backToStartAfterEditOrDelete()
        
        
    }
    
    //SEGUES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDiscussionPage" {
            let destinationVC = segue.destination as! DiscussionViewController
            destinationVC.chosenClassSection = classSections[whichClass]
        }
    }

    @IBAction func startDiscussionButton(_ sender: UIButton) {
        //SEGue to THE DISCUSSION BOARD
        performSegue(withIdentifier: "goToDiscussionPage", sender: self)
    }
    
    
    
    
    @IBAction func ReturnButton(_ sender: UIButton) {
        backToStartAfterEditOrDelete()
    }
    
    
    func backToStartAfterEditOrDelete() {
        self.AlreadyMadeGroups.reloadAllComponents()
        self.AlreadyMadeGroups.selectRow(0, inComponent: 0, animated: false)
        whichClass = 0
        
        Return.isHidden = true
        AddAClass.isHidden = false
        AlreadyMadeGroups.isHidden = false
        StartDiscussion.isHidden = false
        
        AddAClassView.isHidden = true
        ClassNameLabel.isHidden = true
        ClassNameTextField.isHidden = true
        ClassSizePicker.isHidden = true
        GoButton.isHidden = true
        studentNameView.isHidden = true
        
        Save.isHidden = true
        Delete.isHidden = true
        scrollView.isHidden = true
        
    }
    
    func addingOrEditingNamePageTransition() {
        Return.isHidden = false
        AddAClass.isHidden = true
        AlreadyMadeGroups.isHidden = true
        StartDiscussion.isHidden = true
        
        AddAClassView.isHidden = false
        ClassNameLabel.isHidden = false
        ClassNameTextField.isHidden = false
        ClassSizePicker.isHidden = false
        GoButton.isHidden = false
        Save.isHidden = false
        scrollView.isHidden = false
    }
    
    func clearTextFields(numberOfTextFields: Int) {
        //this clears the textfields of the student names and the class name so you can continue to add classes

        for i in 0...(numberOfTextFields-1) {
            studentNameTextField[i].text = ""
        }
        ClassNameTextField.text = ""
    }
    
    func settingUpNameInput(numberOfStudents: Int) {
        //this sets up the input textfields for adding the student names, establish their position on the view
        studentNameList = studentNameList.sorted(by: { $0.tag < $1.tag})
        studentNameView.isHidden = false
        for item in studentNameList {
            item.isHidden = true //resetting it
        }
        for i in 0...(numberOfStudents - 1) {
            
            studentNameList[i].isHidden = false
            //I don't know how to fix the i, try 7 if it doesn't work out
            if i < 8 {
                studentNameList[i].frame = CGRect(x: 8, y: ((50*(i)) + 8), width: 247, height: 50)
            }
            else {
                studentNameList[i].frame = CGRect(x: 277, y:((50*(i-8)) + 8), width: 247, height: 50)
            }
        }
    }
    
    //TEXTFIELD STUFF
    //all the scroll view stuff is from this https://www.youtube.com/watch?v=25lXM5G0iVY&app=desktop
    //This allows you to see the student name while you're typing it, the view automatically scrolls to show you the textfield
    var activeField : UITextField?
    private func configureTextFields(){
        for item in studentNameTextField{
            item.delegate = self
        }
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SectionsViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func handleTap() {
        view.endEditing(true )  //this leads to the extension below
    }
    
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardInfo = notification.userInfo else { return }
        if let keyboardSize = (keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            let keyboardHeight = keyboardSize.height
            let contentsInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            self.scrollView.contentInset = contentsInsets
            var viewRect = self.view.frame
            viewRect.size.height -= keyboardHeight + 10 //keep plus ten or no?
            guard let activeField = self.activeField else {return}
            if (!viewRect.contains(activeField.frame.origin)) {
                let scrollPoint = CGPoint(x:0, y:activeField.frame.origin.y - keyboardHeight)
                self.scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
        
    }
    @objc func keyboardWillHide(notification: Notification) {
        let contentsInset = UIEdgeInsets.zero
        self.scrollView.contentInset = contentsInset
    }
}

extension SectionsViewController: UITextFieldDelegate  {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.activeField = nil
        textField.resignFirstResponder()
        self.activeField = nil
        return true
    }
    
    
}
