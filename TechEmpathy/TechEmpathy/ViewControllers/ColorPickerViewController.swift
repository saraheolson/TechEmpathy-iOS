//
//  ColorPickerViewController.swift
//  TechEmpathy
//
//  Created by Sarah Olson on 4/14/17.
//  Copyright © 2017 SarahEOlson. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate {
    func colorPicked(viewController: UIViewController, color: UIColor)
}

class ColorPickerViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var colorPickerDelegate: ColorPickerDelegate? = nil
    var selectedColor: UIColor = UIColor.gray
    var datasource = [ UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple, UIColor.black]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
}
extension ColorPickerViewController: UICollectionViewDataSource {
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = datasource[indexPath.row]
        return cell
    }
}

extension ColorPickerViewController: UICollectionViewDelegate {

    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            self.colorPickerDelegate?.colorPicked(viewController: self, color: selectedCell.backgroundColor!)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
