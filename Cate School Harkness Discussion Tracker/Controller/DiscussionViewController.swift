//
//  DiscussionViewController.swift
//  Cate School Harkness Discussion Tracker
//
//  Created by cate on 4/20/19.
//  Copyright © 2019 cate. All rights reserved.
//


import UIKit
import CoreData
import MessageUI


class DiscussionViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    let discussionTracker = DiscussionTracker()
    let prettyDisplayStuff = PrettyDisplayStuff()
    //NOTES: ONLY WAY TO MOVE TO THE PREVIOUS PAGE IS TO TRIGGER THAT PROMPT that asks if you want to go to the previous page

    var chosenClassSection : ClassSection?
    
    var className = ""
    var students: [String] = []
    var starttime = Date()
    var currentTime: Double = 0

    let normalFont = UIFont(name: "Verdana-Regular", size: 17)
    let boldFont = UIFont(name: "Verdana-Bold", size: 17)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        finalPageOutlet.isHidden = true
        className = chosenClassSection!.nameOfSection!
        students = chosenClassSection!.studentNames!
        
        studentViews = studentViews.sorted(by: { $0.tag < $1.tag})
        studentLabels = studentLabels.sorted(by: { $0.tag < $1.tag})
        studentButtonOutletCollection = studentButtonOutletCollection.sorted(by: { $0.tag < $1.tag})
        
        //first hides alllll the student buttons to ensure a blank canvas
        for item in studentViews {
            item.isHidden = true
        }
        
        //show the student buttons for that class (just the number of students for the class selected)
        for i in 1 ... students.count {
            //show the student buttons for that class (just the number of students for the class selected)
            studentViews[i-1].isHidden = false
            
            //this ensures that you can't start the discussion without pressing the start button, as nothing will work until you press that STARTDONE BUTTON
            studentButtonOutletCollection[i-1].isEnabled = false
            
            //renames the labels of the buttons with First Names of the students
                var fullName = students[i-1].components(separatedBy: " ")
                studentLabels[i-1].text = fullName[0]
            
        }
        for item in discussionCommentOutletCollection {
            //this ensures that you can't start the discussion without pressing the start button, as nothing will work until you press that STARTDONE BUTTON
            item.isEnabled = false
        }
    }

    
    
    @IBOutlet weak var endDiscussionPrompt: UIView!
    @IBOutlet weak var finalPageOutlet: UIView!
    @IBOutlet weak var returnHomePrompt: UIView!
    @IBOutlet weak var startDoneButton: UIButton!
    
//transcripts
    @IBOutlet weak var liveTranscript: UITextView!
    
    @IBOutlet weak var finalTranscriptTextView: UITextView!
    
//outlet collection for the views
    @IBOutlet var studentViews: [UIView]!
    
//outlet collection for the labels
    @IBOutlet var studentLabels: [UILabel]!
    
//outlet collection for the buttons (I literally just need it to enable/disable the button when transcript isn't happening)
    @IBOutlet var studentButtonOutletCollection: [UIButton]!
    
    
//all the buttons
    @IBAction func studentButtons(_ sender: UIButton) {
        //basically it takes the tag of the button to establish which student is talking
        //this ensures that you get the number of the student and not their name, which is what Miss Fortner requested
        currentTime = abs(starttime.timeIntervalSinceNow)
        discussionTracker.discussionLog += prettyDisplayStuff.convertSecondsToReadableTime(timeInSeconds: currentTime) + " Student \(sender.tag) \n"
        liveTranscript.text = discussionTracker.discussionLog
        //this does an automatic scroll for the textview
        //https://stackoverflow.com/questions/16698638/scroll-uitextview-to-bottom
        let range = NSMakeRange(liveTranscript.text.count - 1, 1)
        liveTranscript.scrollRangeToVisible(range)
    }
    
//discussion comments
    //discussion views
    @IBOutlet var discussionCommentViews: [UIView]!
    
    //discussion comment label outlet collection
    
    @IBOutlet var discussionCommentLabels: [UILabel]!
    
    //discussionCommentButtonOutlet Collection
    @IBOutlet var discussionCommentOutletCollection: [UIButton]!
    
    
    //discussion action buttons
    @IBAction func discussionCommentButtons(_ sender: UIButton) {
        //sorts the labels and views
        currentTime = abs(starttime.timeIntervalSinceNow)
        discussionCommentLabels = discussionCommentLabels.sorted(by: { $0.tag < $1.tag})
        discussionTracker.discussionLog += prettyDisplayStuff.convertSecondsToReadableTime(timeInSeconds: currentTime) + " Contribution: \(discussionCommentLabels[sender.tag - 1].text!)\n"
        liveTranscript.text = discussionTracker.discussionLog
        
        //move to bottom of scroll, https://stackoverflow.com/questions/16698638/scroll-uitextview-to-bottom
        let range = NSMakeRange(liveTranscript.text.count - 1, 1)
        liveTranscript.scrollRangeToVisible(range)
    }
    
    
    @IBAction func startDoneButton(_ sender: UIButton) {
        currentTime = abs(starttime.timeIntervalSinceNow)
        //move to bottom of scroll
        let range = NSMakeRange(liveTranscript.text.count - 1, 1)
        liveTranscript.scrollRangeToVisible(range)
        
        if sender.currentTitle == "DONE" {
            //ending the recording
            startDoneButton.setTitle("START", for: .normal)
            print(prettyDisplayStuff.convertSecondsToReadableTime(timeInSeconds: currentTime))
            discussionTracker.discussionLog +=  prettyDisplayStuff.convertSecondsToReadableTime(timeInSeconds: currentTime) + " Done!"
            endDiscussionPrompt.isHidden = false
            finalTranscriptTextView.text = discussionTracker.discussionLog
            
        }
        else {
            //start the discussion and timer
            currentTime = 0
            startDoneButton.setTitle("DONE", for: .normal)
            discussionTracker.discussionLog += "\(className)\n"
            liveTranscript.text = discussionTracker.discussionLog
            
            //make sure that the student button is disabled until you press this
            //reenabling the student buttons
            for i in 1 ... students.count {
                studentButtonOutletCollection[i-1].isEnabled = true
            }
            for item in discussionCommentOutletCollection {
                item.isEnabled = true
            }
        }
        
    }
    
    //end discussion prompt leads you to the final page, where you can chose to email or send, then once you hit the home button it will warn you that it cannot save
    //first, you press done to trigger "end the discussion?", then if you press yes that leads you the the final page outlet, and there if you press home that leads you to the "WORK NOT SAVE" prompt, and there
    
    @IBAction func returnButton(_ sender: UIButton) {
        returnHomePrompt.isHidden = false
    }
    
    
    @IBAction func endDiscussionYes(_ sender: UIButton) {
        endDiscussionPrompt.isHidden = true
        for item in studentViews {
            item.isHidden = true
        }
        finalPageOutlet.isHidden = false
        returnHomePrompt.isHidden = true

    }
    
    @IBAction func endDiscussionNo(_ sender: UIButton) {
        endDiscussionPrompt.isHidden = true
        
        //gotta set the button title as Done again
        startDoneButton.setTitle("DONE", for: .normal)
    }
    
    @IBAction func returnHomeButton(_ sender: UIButton) {
        //finalPageOutlet.isHidden = false
        returnHomePrompt.isHidden = false
    }
    
    @IBAction func returnHomeYes(_ sender: UIButton) {
        //THE ONLY WAY TO GET OUT OF THIS VIEWCONTROLLER
        returnHomePrompt.isHidden = false
        liveTranscript.text = ""
        finalTranscriptTextView.text = ""
        finalPageOutlet.isHidden = false
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func returnHomeNo(_ sender: UIButton) {
        returnHomePrompt.isHidden = true
        finalPageOutlet.isHidden = true
    }
    
    
    //MAIL STUFF, CAROLINE DID THE STUFF BELOW
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setMessageBody(finalTranscriptTextView.text!, isHTML: false)
        return mailComposerVC
    }

    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    @IBAction func emailButton(_ sender: UIButton) {
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    
}
