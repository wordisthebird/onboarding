//
//  ViewController.swift
//  ios-onboarding
//
//  Created by Michael Christie on 26/06/2020.
//  Copyright © 2020 Michael Christie. All rights reserved.
//

import UIKit
import Lottie

struct Slide {
    let title : String
    
    let animationName: String
    let buttonColor: UIColor
    let buttonTitle : String
    
    static let collection: [Slide] = [
        .init(title: "Welcome to Space", animationName: "welcome2", buttonColor: .systemYellow, buttonTitle: "Start"),
        
        .init(title: "Select a restaurant from our map", animationName: "restaurant", buttonColor: .red, buttonTitle: "Next"),
        
        .init(title: "Choose what food you would like from the menu", animationName: "food2", buttonColor: .systemGreen, buttonTitle: "Next"),
        
        .init(title: "View the food in High Quality Augmented Reality", animationName: "viewFood", buttonColor: .systemGreen, buttonTitle: "Next"),
        
        .init(title: "Please enable your camera", animationName: "camera", buttonColor: .systemGreen, buttonTitle: "Enable Camera"),
        
        .init(title: "Lets get started", animationName: "getStarted2", buttonColor: .systemGreen, buttonTitle: "Get Started")
    ]
}

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    private let slides: [Slide] = Slide.collection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupPageControl()
    }
    
    private func setupPageControl(){
        pageControl.numberOfPages = slides.count
        let angle = CGFloat.pi/2
        pageControl.transform = CGAffineTransform(rotationAngle: angle)
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
            pageControl.currentPage = nextItem
        }
    }
    
    private func showMainApp(){
        let mainAppViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainAppViewController")
        
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(collectionView.contentOffset.y / scrollView.frame.size.height)
        pageControl.currentPage = index
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

