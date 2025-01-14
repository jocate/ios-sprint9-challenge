//
//  CaloriesTableViewController.swift
//  CalorieTraker
//
//  Created by Jocelyn Stuart on 3/15/19.
//  Copyright © 2019 JS. All rights reserved.
//

import UIKit
import CoreData
import SwiftChart

class CaloriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, ChartDelegate {
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    

    let calorieController = CalorieController()
    
    @IBOutlet weak var calorieChart: Chart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let chart = Chart(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        print(calorieController.calorieSeries)
        let series = ChartSeries(calorieController.calorieSeries)

        calorieChart.axesColor = .gray
        calorieChart.gridColor = .blue
        calorieChart.add(series)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        calorieChart.axesColor = .gray
        calorieChart.gridColor = .blue
        
        tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CaloriesCell", for: indexPath)

        let calorieCell = cell as! CaloriesTableViewCell
        
        let calorie = fetchedResultsController.object(at: indexPath)
        calorieCell.calorie = calorie
        calorieController.calorieSeries.append(fetchedResultsController.object(at: indexPath).amount)
    
        return calorieCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let calorie = fetchedResultsController.object(at: indexPath)
            calorieController.delete(calorie: calorie)
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case.move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func addCaloriesTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Calorie Intake", message: "Enter the amount of calories in the field", preferredStyle: .alert)
        
        var amountTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Calorie amount:"
            amountTextField = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            
            guard let amount = amountTextField?.text else { return }
            
            let amountNum = Double(Int(amount)!)
            
            self.calorieController.createCalorie(with: amountNum)
            let series = ChartSeries(self.calorieController.calorieSeries)
            self.calorieChart.add(series)
          //  self.calorieController.calorieSeries.append(amountNum)
            self.tableView.reloadData()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(submitAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Calorie> = {
        
        let fetchRequest: NSFetchRequest<Calorie> = Calorie.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "timestamp", ascending: true)
        ]
        
        let moc = CoreDataStack.shared.mainContext
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc,
                                             sectionNameKeyPath: "timestamp", cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        
        return frc
    }()
    
    

}
