//
//  MainViewController.swift
//  My Place
//
//  Created by Владислав on 25.05.2023.
//

import UIKit       // (фреймворк) предоставляет классы и методы для создания пользовательского интерфейса
import RealmSwift  // библиотека для работы с базой данных Realm

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    var ascendingSorting = true
    var places: Results<Place>!                  // Представляет собой коллекцию объектов типа Place. Place является моделью данных
    
    override func viewDidLoad() {                // Функция вызывается, когда представление загружается в память
        super.viewDidLoad()
        
        places = realm.objects(Place.self)       // Коллекция places инициализируется, и возвращает все объекты типа Place из базы данных Realm.
        
    }
    
    // MARK: - Table view data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {              // Определяет количество строк в таблице
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {   // Определяет содержимое каждой ячейки
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]               // Из коллекции places извлекается объект Place по индексу, текущей ячейке
        
        // Значения текстовых меток и изображения в пользовательской ячейке (cell) устанавливаются на основе свойств объекта place
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData ?? Data())  // Изображение ячейки (cell.imageOfPlace.image) устанавливается с использованием                                        UIImage, создаваемого из place.imageData. Если place.imageData равно nil, то устанавливается пустое изображение
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2  // Скругление углов изображения ячейки, равным половине высоты изображения
        cell.imageOfPlace.clipsToBounds = true  // устанавливается в значение true, чтобы обрезать изображение по границам ячейки
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    // Метод определяет действие, выполняемое при свайпе вправо по ячейке. В данном случае, при свайпе вызывается действие удаления (deleteAction), которое удаляет объект Place из базы данных и удаляет соответствующую строку из таблицы.
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]   // Из коллекции places извлекается объект Place по индексу, соответствующему свайпаемой ячейке
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            
            // Создается действие deleteAction типа UIContextualAction. Действие будет отображаться при свайпе, имеет стиль .destructive, что указывает на опасное действие, такое как удаление. Заголовок действия установлен на "Delete".
            
            StorageManeger.deleteObject(place)   // В блоке действия вызывается метод StorageManager.deleteObject(place) для удаления объекта place
            tableView.deleteRows(at: [indexPath], with: .automatic) // метод для удаления соответствующей ячейки из таблицы с анимацией .automatic
            completionHandler(true) // вызывается для завершения выполнения действия с результатом true, указывающим, что действие завершилось успешно
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction]) // Создается объект configuration типа UISwipeActionsConfiguration, которому передается массив действий [deleteAction]
        
        return configuration // бъект configuration возвращается из метода, чтобы определить, какие действия должны быть доступны при свайпе ячейки вправо. В данном случае, доступно только одно действие - deleteAction
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue .identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    
    // Эта функция может быть использована, например, для обработки возврата с экрана создания нового места обратно к списку мест в главном экране приложения.
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {                                      // переход между view controller'ами.
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace()  //Если newPlaceVC содержит экземпляр NewPlaceViewController, вызывается метод saveNewPlace() для сохранения нового места
        tableView.reloadData()     //После сохранения нового места вызывается reloadData() на таблице (tableView), чтобы обновить ее и отразить изменения после                               сохранения нового места.
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
