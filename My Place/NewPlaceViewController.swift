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
        
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }
    
    // MARK: Table view delegate
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            let cameraIcon = UIImage(named: "camera_icon")
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photoIcon = UIImage(named: "photo_icon")
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
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
        guard let identifier = segue.identifier,
              let mapVC = segue.destination as? MapViewController // создаем экземпляр класса
              else { return }
        
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showPlace" {
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text!
            mapVC.place.type = placeType.text
            mapVC.place.imageData = placeImage.image?.pngData()
        }
    }
    
    func savePlace() {
                
        let image = imageIsChanged ? placeImage.image : UIImage(named: "imagePlaceholder")
        let imageData = image?.pngData()
        let newPlace = Place(name: placeName.text!,
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
                StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            
            setupNavigationBar()
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
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
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
      dismiss(animated: true)
    }
}

//MARK: Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {
    
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
    
    func chooseImagePicker (source: UIImagePickerController.SourceType) {
       
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
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

extension NewPlaceViewController: MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}



