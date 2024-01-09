//
//  OtherViewController.swift
//  MyTabBar
//
//  Created by Shane Whitehead on 9/1/2024.
//

import Foundation
import UIKit
import SnapKit

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

class OtherViewController: UIViewController {
    private var count = 0
    
    init(tabBarItem: UITabBarItem) {
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = tabBarItem
        view.backgroundColor = .random
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        super.viewDidLoad()
        
        guard let tabBarItem = tabBarItem else { return }
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.top.greaterThanOrEqualToSuperview()
            make.trailing.bottom.lessThanOrEqualToSuperview()
            make.centerX.centerY.equalToSuperview()
        }
        
        
        let label = UILabel()
        label.text = tabBarItem.title
        label.textColor = .black
        
        let image = UIImageView(image: tabBarItem.image)
        image.tintColor = .black

        stack.addArrangedSubview(image)
        stack.addArrangedSubview(label)
        
        let button = UIButton()
        button.setTitle("Counter", for: [])
        button.addTarget(self, action: #selector(didTapCounter), for: .touchUpInside)
        
        stack.addArrangedSubview(button)
    }
    
    @objc func didTapCounter() {
        guard let item = tabBarItem else { return }
        count += 1
        item.badgeValue = "\(count)"
    }
}
