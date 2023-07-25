//
//  MainViewController.swift
//  My Place
//
//  Created by Владислав on 25.05.2023.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        
        if ascendingSorting {
            reversedSortingButton.image = UIImage(named: "ArrowUp")
        } else {
            reversedSortingButton.image = UIImage(named: "ArrowDown")
        }
        
        sorting()
        
        // Setup the search controller
        searchController.searchResultsUpdater = self // установка делегата (self) для searchController что бы реализовать протокол (UISearchResultsUpdating)
        // который будет отслеживать изменения в поисковой строке.
        searchController.obscuresBackgroundDuringPresentation = false // затемняет фон во время презентации, не будет затемнен, и содержимое видимое
        searchController.searchBar.placeholder = "Search"  // задается текст-подсказка для поисковой строки, которая отобразится, когда она пуста
        navigationItem.searchController = searchController // устанавливает поисковый контроллер searchController в качестве элемента поиска для navigationItem                                                                                                                           // вашего MainViewController
        definesPresentationContext = true  // определяет какой контент будет скрыт (true) чтобы предотвратить затемнение представления во время поиска
         
    }
    
    // MARK: - Table view data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {           // Определяет количество строк в таблице
       
        if isFiltering {
            return filteredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {            // Определяет содержимое каждой ячейки
         let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
        
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        // Значения текстовых меток и изображения в пользовательской ячейке (cell) устанавливаются на основе свойств объекта place
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData ?? Data())     
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        
        return cell
    }
    
    // MARK: - Table view delegate
    
       // Метод определяет действие, выполняемое при свайпе вправо по ячейке. В данном случае, при свайпе вызывается действие удаления (deleteAction), которое удаляет объект Place из базы данных и удаляет соответствующую строку из таблицы.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let place = places[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            
            StorageManeger.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction]) // Создается объект configuration типа UISwipeActionsConfiguration, которому                                                                                                              передается массив действий [deleteAction]
        
        return configuration // бъект configuration возвращается из метода, чтобы определить, какие действия должны быть доступны при свайпе ячейки вправо. В                                                                                            данном случае, доступно только одно действие - deleteAction
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // вызывается автоматически перед переходом на другой экран (View Controller) через(segue)
        if segue .identifier == "showDetail" {                                       // проверяет идентификатор перехода (segue.identifier)
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let place: Place
            
            if isFiltering {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place  
            
        }
    }
    

  // Эта функция может быть использована, например, для обработки возврата с экрана создания нового места обратно к списку мест в главном экране приложения
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {        // переход между view controller'ами.
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace()  //Если newPlaceVC содержит экземпляр NewPlaceViewController, вызывается метод saveNewPlace() для сохранения нового места
        tableView.reloadData()  //После сохранения нового места вызывается reloadData() на таблице (tableView), чтобы обновить ее и отразить изменения после                                                                                                                                сохранения нового места.
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reversedSortingButton.image = UIImage(named: "ArrowUp")
        } else {
            reversedSortingButton.image = UIImage(named: "ArrowDown")
        }
            sorting()
    }
    
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
    
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText (_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@" , searchText, searchText)
        tableView.reloadData()
    }
    
}
    
    
