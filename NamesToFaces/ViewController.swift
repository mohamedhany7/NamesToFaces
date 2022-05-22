//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Mohamed Hany on 25/04/2022.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
                    people = decodedPeople
                }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else{
            fatalError("Unable to dequeue PersonCell!")
        }
        
        let person = people[indexPath.item]
        cell.name.text = person.name
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    @objc func addNewPerson(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        let ac = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Take a photo", style: .default){[weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                picker.sourceType = .camera
            }
            self?.present(picker, animated: true)
        })
        ac.addAction(UIAlertAction(title: "From Camera Roll", style: .default){[weak self] _ in
            self?.present(picker, animated: true)
        })
        present(ac, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "unkown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory () -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ac = UIAlertController(title: "CHoose an action", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Rename", style: .default){ [weak self] _ in
            self?.rename(index: indexPath.item)
        })
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive){[weak self] _ in
            self?.people.remove(at: indexPath.item)
            self?.collectionView.reloadData()
        })
        present(ac, animated: true)
    }
    
    func rename(index: Int){
        let person = people[index]
        
        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default){ [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            self?.save()
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "CANCEL", style: .cancel))
        present(ac, animated: true)
    }
    
    func save(){
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        }
    }
}

