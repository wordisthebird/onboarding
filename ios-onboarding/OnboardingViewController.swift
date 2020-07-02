//
//  ViewController.swift
//  ios-onboarding
//
//  Created by Michael Christie on 26/06/2020.
//  Copyright © 2020 Michael Christie. All rights reserved.
//

import UIKit
import Lottie
import AVKit

struct Slide {
    let title : String
    
    let animationName: String
    let buttonColor: UIColor
    let buttonTitle : String
    
    static let collection: [Slide] = [
        .init(title: "Welcome to Space!", animationName: "rocket2",  buttonColor: .systemGreen, buttonTitle: "Start"),
        
        .init(title: "Choose a Restaurant", animationName: "map", buttonColor: .orange, buttonTitle: "Next"),
        
        .init(title: "Pick some food", animationName: "food2", buttonColor: .systemPurple, buttonTitle: "Next"),
        
        .init(title: "View the food in AR", animationName: "chef", buttonColor: .systemIndigo, buttonTitle: "Next"),
        
        .init(title: "Please enable your camera", animationName: "camera11", buttonColor: .systemTeal, buttonTitle: "Enable Camera"),
        
        .init(title: "Lets get started!", animationName: "getStarted2", buttonColor: .systemGreen, buttonTitle: "Get Started")
    ]
}

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let slides: [Slide] = Slide.collection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageName = "logo.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        
        imageView.frame.size.height = 30
        imageView.frame.size.width = 30
        
        imageView.frame.origin.y = 40.0 // 40 down from the top
        imageView.frame.origin.x = (self.view.bounds.size.width - imageView.frame.size.width) / 2.0 // centered left to right.
        
        view.addSubview(imageView)
        
        view.addSubview(imageView);
        
        setupCollectionView()
    }
    
    private func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
    }
    
    private func handleActionButtonTap(at indexPath: IndexPath){
        if indexPath.item == slides.count - 1{
            showMainApp()
        }
        else{
            let nextItem = indexPath.item + 1
            let nextIndexPath = IndexPath(item: nextItem, section: 0)
            collectionView.scrollToItem(at: nextIndexPath, at: .top, animated: true)
        }
    }
    
    private func showMainApp(){
        
        let mainAppViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondViewController")
        
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(true, forKey: "onboardingComplete")
        
        userDefaults.synchronize()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate,
            let window = sceneDelegate.window{
            
            window.rootViewController = mainAppViewController
            
            UIView.transition(with: window,
                              duration: 0.25,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Core.shared.isNewUser(){
            Core.shared.notNewUser()
            
            print("new")
            
            //dismiss(animated: true, completion: nil)
        }
        
        else{
            print("existing")
            
             let mainAppViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondViewController")
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let sceneDelegate = windowScene.delegate as? SceneDelegate,
                       let window = sceneDelegate.window{
                       
                       window.rootViewController = mainAppViewController
                       
                       UIView.transition(with: window,
                                         duration: 0.25,
                                         options: .transitionCrossDissolve,
                                         animations: nil,
                                         completion: nil)
                   }
        }
        
    }
}

extension OnboardingViewController: UICollectionViewDelegate,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! OnboardingCollectionViewCell
        
        let slide = slides[indexPath.row]
        cell.configure(with: slide)
        
        cell.actionButtonDidTap = { [weak self] in
            self?.handleActionButtonTap(at: indexPath)
            
            if indexPath.row == 4{
                //enable to camera settings
                
                print("Boom")
                
                
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                    if granted == true {
                        // User granted
                    } else {
                        // User rejected
                    }
                })
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = collectionView.bounds.width
        let itemHeight = collectionView.bounds.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var animationView: AnimationView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    
    
    var actionButtonDidTap: (() -> Void)?
    
    func configure(with slide: Slide){
        
        titleLabel.text = slide.title
        actionButton.backgroundColor = slide.buttonColor
        actionButton.setTitle(slide.buttonTitle, for: .normal)
        
        let animation = Animation.named(slide.animationName)
        
        animationView.animation = animation
        animationView.loopMode = .loop
        
        if !animationView.isAnimationPlaying{
            animationView.play()
        }
    }
    
    
    @IBAction func actionButtonTapped(){
        
        actionButtonDidTap?()
    }
}

class Core{
    
    static let shared = Core()
    
    func isNewUser() -> Bool{
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func notNewUser(){
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}



