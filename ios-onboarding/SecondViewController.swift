//
//  SecondViewController.swift
//  ios-onboarding
//
//  Created by Michael Christie on 27/06/2020.
//  Copyright © 2020 Michael Christie. All rights reserved.
//

import UIKit
import Lottie

class SecondViewController: UIViewController {
    

    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // Do any additional setup after loading the view.
    }
}

class OnboardingCollectionUView: UIView {
    
    @IBOutlet weak var animationView: AnimationView!
  
   
    
    func configure(with slide: Slide){
        let animation = Animation.named("food")
        
        animationView.animation = animation
        animationView.loopMode = .loop
        
        if !animationView.isAnimationPlaying{
            animationView.play()
        }
    }
}
