//
//  ViewController.swift
//  DR Aid
//
//  Created by Greg Wu on 1/1/20.
//  Copyright © 2020 Greg Wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var behaviorLabel: UILabel!
    @IBOutlet var goalLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    
    // Set up User Defaults and property observers to store data for variables
    
    let defaults = UserDefaults.standard
    
    var behavior: String = "" {
        didSet {
            defaults.set(behavior, forKey: "Behavior")
        }
    }
    var goalType: String = "" {
        didSet {
            defaults.set(goalType, forKey: "GoalType")
        }
    }
    var goal: Int = 0 {
        didSet {
            defaults.set(goal, forKey: "Goal")
        }
    }
    var count: Int = 0 {
        didSet {
            defaults.set(count, forKey: "Count")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up navigation bar
        title = "DR Aid"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Create toolbar item objects
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)  // flexible spacer "spring"
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(reset))
        let reviseButton = UIBarButtonItem(title: "Revise Goal", style: .plain, target: self, action: #selector(reviseGoal))
        
        toolbarItems = [resetButton, spacer, reviseButton]  // Set toolbar items array property
        navigationController?.isToolbarHidden = false  // Show toolbar
        
        // Read User Defaults data for variables if it exists
        if let description = defaults.object(forKey: "Behavior") as? String {
            behavior = description
            goalType = defaults.object(forKey: "GoalType") as? String ?? ""
            goal = defaults.integer(forKey: "Goal")
            count = defaults.integer(forKey: "Count")
            
            // Set initial label text and/or color
            behaviorLabel.text = behavior
            goalLabel.text = "\(goal) \(goalType) times"
            countLabel.text = "\(count)"
            updateCountLabelColor()
        } else {
            setupBehavior()
        }
    }
    
    func setupBehavior() {
        // Create alert controller and Submit action
        let ac = UIAlertController(title: "Set Up Behavior", message: "What behavior do you want to track?", preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            guard let description = ac.textFields?[0].text else { return }  // Safely unwrap optional text field
            if description != "" {  // If text field was not an empty string:
                self.behavior = description
            } else {
                self.behavior = "(Behavior)"
            }
            self.setupGoalType()
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func setupGoalType() {
        let ac = UIAlertController(title: "Set Up Goal Type", message: "Do you want to increase or decrease this behavior?", preferredStyle: .alert)
        
        let increaseAction = UIAlertAction(title: "Increase", style: .default) { (action) in
            self.goalType = "or more"
            self.setupGoal()
        }
        let decreaseAction = UIAlertAction(title: "Decrease", style: .default) { (action) in
            self.goalType = "or less"
            self.setupGoal()
        }
        
        ac.addAction(increaseAction)
        ac.addAction(decreaseAction)
        present(ac, animated: true)
    }
    
    func setupGoal() {
        let ac = UIAlertController(title: "Set Up Goal", message: "What is your count goal?", preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.keyboardType = .numberPad
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            guard let description = ac.textFields?[0].text else { return }  // Safely unwrap optional text field
            self.goal = Int(description) ?? 0  // Assign default value if invalid input
            
            // Set initial label text
            self.behaviorLabel.text = self.behavior
            self.goalLabel.text = "\(self.goal) \(self.goalType) times"
            self.countLabel.text = "\(self.count)"
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    @IBAction func increaseCount(_ sender: UIButton) {
        count += 1
        countLabel.text = "\(count)"
        
        updateCountLabelColor()
    }
    
    @IBAction func decreaseCount(_ sender: UIButton) {
        if count > 0 {
            count -= 1
            countLabel.text = "\(count)"
        }
        
        updateCountLabelColor()
    }
    
    // Change color of count label in relation to goal
    func updateCountLabelColor() {
        if count < goal {
            countLabel.backgroundColor = UIColor(red: 23/255, green: 148/255, blue: 1, alpha: 1)
        } else if (goalType == "or more") && (count == goal) {
            countLabel.backgroundColor = .systemGreen
        } else if (goalType == "or less") && (count == goal) {
            countLabel.backgroundColor = .systemYellow
        } else if (goalType == "or less") && (count > goal) {
            countLabel.backgroundColor = .systemRed
        }
    }
    
    @objc func reset() {
        let ac = UIAlertController(title: "Reset", message: "Are you sure you want to start over?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { (action) in
            self.behavior = ""
            self.count = 0
            self.setupBehavior()
        }
        
        ac.addAction(cancelAction)
        ac.addAction(resetAction)
        present(ac, animated: true)
    }
    
    @objc func reviseGoal() {
        let ac = UIAlertController(title: "Revise Goal", message: "What is your new count goal?", preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let reviseAction = UIAlertAction(title: "Revise", style: .default) { (action) in
            guard let description = ac.textFields?[0].text else { return }  // Safely unwrap optional text field
            self.goal = Int(description) ?? 0  // Assign default value if invalid input
            self.count = 0
            
            self.goalLabel.text = "\(self.goal) \(self.goalType) times"
            self.countLabel.text = "\(self.count)"
        }
        
        ac.addAction(cancelAction)
        ac.addAction(reviseAction)
        present(ac, animated: true)
    }
    
}
