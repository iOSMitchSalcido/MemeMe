//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Online Training on 5/30/16.
//  Copyright © 2016 Mitch Salcido. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    var meme: Meme?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let meme = self.meme {
            imageView.image = meme.memedImage
        }
    }
}
