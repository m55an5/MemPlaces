//
//  PlacesViewController.swift
//  MemPlaces
//
//  Created by Manjot S Sandhu on 17/4/20.
//  Copyright © 2020 Manjot S Sandhu. All rights reserved.
//

import UIKit
import CoreData

class PlacesViewController: UITableViewController, AddNewPlaceDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var places = [Places]()
    
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPlaces()
        table.reloadData()
    }
    
    func userEnteredAPlace(place: Places) {
        places.append(place)
        savePlaces()
    }
    
    func savePlaces(){
        do {
            try context.save()
        }catch {
            print("Error saving places, \(error)")
        }
        table.reloadData()
    }
    
    func loadPlaces(with request:NSFetchRequest<Places> = Places.fetchRequest()){
        
        do{
            places = try context.fetch(request)
        } catch {
            print("Error loading places, \(error)")
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "placesCell", for: indexPath)
        
        let place = places[indexPath.row].name
        
        cell.textLabel?.text = place
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        activePlace = indexPath.row
        performSegue(withIdentifier: "toMap", sender: nil)
        
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            places.remove(at: indexPath.row)
//            UserDefaults.standard.set(places, forKey: "places")
        }
        table.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ViewController
        
        if let indexPath = table.indexPathForSelectedRow {
            destinationVC.delegate = self;
            destinationVC.selectedPlace = places[indexPath.row]
        }
    }

}
