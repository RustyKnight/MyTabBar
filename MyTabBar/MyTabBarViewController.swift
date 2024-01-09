//
//  MyTabBarViewController.swift
//  MyTabBarViewController
//
//  Created by Shane Whitehead on 8/1/2024.
//

import Foundation
import UIKit
import SnapKit

class MyTabBarViewController: UIViewController, MyTabBarDelegate {
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        return view
    }()
    
    private lazy var tabBarView: MyTabBarView = {
        let view = MyTabBarView(delegate: self)
        return view
    }()
    
    private let iconConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .medium)
    
    var viewControllers: [UIViewController]? {
        didSet {
            viewControllersDidChange()
        }
    }
    
    private var selectedViewController: UIViewController?
    
    var selectedItem: UITabBarItem? {
        set { tabBarView.selectedItem = newValue }
        get { tabBarView.selectedItem }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        viewControllers = [
            makeHomeViewController(),
            makeCalendarViewController(),
            makeSpeakerViewController(),
            makeNotificationsViewController(),
            makeMoreViewController()
        ]
    }
    
    private func setupUI() {
        view.addSubview(contentView)
        view.addSubview(tabBarView)
        contentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(tabBarView.snp.top)
        }
        tabBarView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func viewControllerFor(item: UITabBarItem) -> UIViewController? {
        viewControllers?.first { $0.tabBarItem == item }
    }
    
    func tabBarDidSelectItem(item: UITabBarItem) {
        guard let nextViewController = viewControllerFor(item: item) else { return }
        
        selectedViewController?.willMove(toParent: nil)
        selectedViewController?.removeFromParent()
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
        
        nextViewController.willMove(toParent: self)
        addChild(nextViewController)
        contentView.addSubview(nextViewController.view)
        nextViewController.view.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        nextViewController.didMove(toParent: self)
        
        selectedViewController = nextViewController
    }
    
    private func viewControllersDidChange() {
        let tabBarItems = viewControllers?.compactMap( { $0.tabBarItem } ) ?? []
        tabBarView.set(items: tabBarItems)
    }
    
    private func makeHomeViewController() -> UIViewController {
        let item = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house", withConfiguration: iconConfig),
            selectedImage: UIImage(systemName: "house.fill", withConfiguration: iconConfig)
        )
        item.badgeValue = "99"
        return makeViewControllerFor(item: item)
    }
    
    private func makeCalendarViewController() -> UIViewController {
        let item = UITabBarItem(
            title: "Calendar",
            image: UIImage(systemName: "calendar", withConfiguration: iconConfig),
            tag: 0
        )
        
        return makeViewControllerFor(item: item)
    }
    
    private func makeSpeakerViewController() -> UIViewController {
        let item = UITabBarItem(
            title: "Channels with a long name",
            image: UIImage(systemName: "megaphone", withConfiguration: iconConfig),
            selectedImage: UIImage(systemName: "megaphone.fill", withConfiguration: iconConfig)
        )
        
        return makeViewControllerFor(item: item)
    }
    
    private func makeNotificationsViewController() -> UIViewController {
        let item = UITabBarItem(
            title: "Notifications",
            image: UIImage(systemName: "bell", withConfiguration: iconConfig),
            selectedImage: UIImage(systemName: "bell.fill", withConfiguration: iconConfig)
        )
        
        return makeViewControllerFor(item: item)
    }
    
    private func makeMoreViewController() -> UIViewController {
        let item = UITabBarItem(
            title: "More",
            image: UIImage(systemName: "line.3.horizontal", withConfiguration: iconConfig),
            tag: 1
        )
        
        return makeViewControllerFor(item: item)
    }

    private func makeViewControllerFor(item: UITabBarItem) -> UIViewController {
        return OtherViewController(tabBarItem: item)
    }
}

protocol MyTabBarDelegate: AnyObject {
    func tabBarDidSelectItem(item: UITabBarItem)
}

class MyTabBarView: UIView, MyTabItemViewDelegate {
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .top
        //view.spacing = 2
        return view
    }()
    
    var selectedItem: UITabBarItem? {
        set { 
            guard let selectedItem = newValue else { return }
            select(item: selectedItem)
        }
        get { selectedView?.item }
    }
    
    private var selectedView: MyTabItemView?
    
    weak var delegate: MyTabBarDelegate?

    init(delegate: MyTabBarDelegate) {
        super.init(frame: .zero)
        self.delegate = delegate
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        stackView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(-safeAreaInsets.bottom)
        }
    }
    
    private func setupUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-safeAreaInsets.bottom)
        }
    }
    
    func set(items: [UITabBarItem]) {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
        }
        
        guard !items.isEmpty else { return }
        
        for item in items {
            stackView.addArrangedSubview(MyTabItemView(item: item, delegate: self))
        }
        
        let count = items.count
        for view in stackView.arrangedSubviews {
            view.snp.makeConstraints { make in
                make.width.equalToSuperview().dividedBy(count)
            }
        }
        
        selectedItem = items.first
    }
        
    private func viewFor(item: UITabBarItem) -> MyTabItemView? {
        for view in stackView.arrangedSubviews {
            guard let view = view as? MyTabItemView else { continue }
            guard view.item == item else { continue }
            return view
        }
        return nil
    }
    
    private func select(item: UITabBarItem) {
        guard let view = viewFor(item: item) else { return }
        selectedView?.isSelected = false
        view.isSelected = true
        selectedView = view
        
        delegate?.tabBarDidSelectItem(item: item)
    }
    
    func didTapTabItemView(view: MyTabItemView) {
        selectedItem = view.item
    }
}
protocol MyTabItemViewDelegate: AnyObject {
    func didTapTabItemView(view: MyTabItemView)
}

class MyTabItemView: UIView {
    private var normalImage: UIImageView = {
       let view = UIImageView()
        view.tintColor = .systemGray
        return view
    }()

    private var selectedImage: UIImageView = {
        let view = UIImageView()
        view.tintColor = .black
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var badgeView: BadgeView = {
       let view = BadgeView()
        view.badgeColor = .systemRed
        view.textColor = .white
        view.cornerRadius = 16
        view.font = UIFont.preferredFont(forTextStyle: .footnote)
        return view
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
        return tapGesture
    }()

    var isSelected: Bool {
        didSet {
            selectionDidChange()
        }
    }
    
    let item: UITabBarItem
    weak var delegate: MyTabItemViewDelegate?
    private var observer: NSKeyValueObservation?
    
    init(item: UITabBarItem, delegate: MyTabItemViewDelegate) {
        self.item = item
        self.delegate = delegate
        isSelected = false
        
        super.init(frame: .zero)
        
        observer = item.observe(\.badgeValue) { [weak self] item, change in
            print("[\(item.title)] badge value did change")
            self?.configureView()
        }

        addGestureRecognizer(tapGesture)

        setupUI()
        selectionDidChange()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemeted")
    }
    
    private func configureView() {
        normalImage.image = item.image
        selectedImage.image = item.selectedImage
        
        normalImage.isHidden = item.image == nil
        selectedImage.isHidden = true
        
        titleLabel.text = item.title
        
        titleLabel.textColor = isSelected ? .black : .systemGray
        normalImage.tintColor = isSelected ? .black : .systemGray
        selectedImage.tintColor = isSelected ? .black : .systemGray

        badgeView.text = item.badgeValue
        badgeView.isHidden = item.badgeValue == nil

        guard isSelected && selectedImage.image != nil else { return }
        normalImage.isHidden = isSelected
        selectedImage.isHidden = !isSelected
    }
    
    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.top.greaterThanOrEqualToSuperview()
            make.trailing.bottom.lessThanOrEqualToSuperview()
            make.centerX.centerY.equalToSuperview()
        }
        
        // What to do if there is no image...
        // Where should the badge counter go?!
        
        stack.addArrangedSubview(makeImageBadgeView())
        stack.addArrangedSubview(titleLabel)
    }
    
    private func makeImageBadgeView() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        
        stackView.addArrangedSubview(normalImage)
        stackView.addArrangedSubview(selectedImage)
        
        let view = UIView()
        view.addSubview(stackView)
        view.addSubview(badgeView)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        badgeView.snp.makeConstraints { make in
            make.leading.equalTo(stackView.snp.trailing).offset(-6)
            make.top.equalTo(stackView.snp.top).offset(-6)
        }

        return view
    }
    
    private func selectionDidChange() {
        configureView()
    }
    
    @objc
    private func didTap(gesture: UITapGestureRecognizer) {
        delegate?.didTapTabItemView(view: self)
    }
}
