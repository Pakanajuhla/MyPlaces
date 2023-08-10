//
//  NewPlaceViewController.swift
//  My Place
//
//  Created by Владислав on 27.05.2023.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChanged = false
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        
        tableView.tableFooterView = UIView()  // скрытие пустых строк в таблице
        saveButton.isEnabled = false          // отключение кнопки сохранения
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)  // установка целевого действия для текстового поля,
                                                                                              // чтобы отслеживать изменения в текстовом поле
        setupEditScreen()
    }
    
    // MARK: Table view delegate
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // метод который является методом делегата UITableViewDelegate и вызывается, когда пользователь выбирает определенную ячейку в таблице.
        
        if indexPath.row == 0 {  // Проверяется, если indexPath.row равно 0, то выполняются следующие действия
            
            let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            
            // Создается экземпляр UIAlertController с типом .actionSheet (это контроллер, который отображает список действий в виде всплывающего меню)
            
            let cameraIcon = UIImage(named: "camera_icon")                                // Изображение cameraIcon устанавливается для действия Camera
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(sourse: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photoIcon = UIImage(named: "photo_icon")
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(sourse: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
            
        } else {
            view.endEditing(true)
        }
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "showMap" {
            return
        }
        
        let mapVC = segue.destination as! MapViewController
        mapVC.place = currentPlace
    }
    
    
    func savePlace() {   // метод для сохранения нового места или объекта типа Place
                
        var image: UIImage?  // может содержать изображение или быть равным nil
        
        if imageIsChanged {             // указывает, было ли изменено изображение.
            image = placeImage.image    // если true то переменной image присваивается текущее изображение placeImage.image
        } else {
            image = UIImage(named: "imagePlaceholder") // иначе ей присваивается изображение с именем "imagePlaceholder"
        }
        
        let imageData = image?.pngData()               // Если image равно nil, то imageData также будет nil
        
        let newPlace = Place(name: placeName.text!,          // Создание нового объекта типа Place - Place - это пользовательский класс с различными свойствами
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData, rating: Double(ratingControl.rating))
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
              }
            } else {
                StorageManeger.saveObject(newPlace)// Сохранение объекта Place с помощью StorageManager.saveObject().Предположительно,здесь используется некоторый
        }                                                       // менеджер хранилища (StorageManager), который отвечает за сохранение объектов Place
         
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            
            setupNavigationBar()
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill     // .scaleAspectFill - это один из вариантов значения для свойства contentMode. Он определяет, что                                                                    изображение будет масштабировано по всему представлению, заполняя его полностью
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            
            ratingControl.rating = Int(currentPlace.rating)
        }
    }
    
    private func setupNavigationBar () {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil // убирает кнопку cancel
        title = currentPlace?.name // передает в заголовок текущее название заведения
        saveButton.isEnabled = true
    }
    
    // Это определение функции cancelAction(_:), которая принимает аргумент sender типа Any. В качестве аргумента, обычно передается объект, который инициировал вызов функции (например, кнопка)
    // аргумент sender не используется, и, так как действие dismiss(animated:) не зависит от конкретного объекта, который вызвал функцию
    @IBAction func cancelAction(_ sender: Any) {
        
      dismiss(animated: true)  // Это метод, который используется для закрытия текущего модульного представления (modal view controller) с анимацией
    }
    
}

//MARK: Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {
    
    // Скрываем клавиатуру по нажатию на Done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
            }
        }
    }

//MARK: Work with images

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker (sourse: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(sourse) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourse
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
        
    }
    
}




