//
//  PlayerPopupView.swift
//  groupstage-simulator
//
//  Created by Niels Beeuwkes on 25/11/2018.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

protocol PlayerPopupViewDelegate: class {
    func closeButtonPressed()
}

final class PlayerPopupView: View {
    
    private let contentView = UIView()
    
    private let padding: CGFloat = 10
    
    private let playerModel: PlayerModel
    
    weak var delegate: PlayerPopupViewDelegate?
    
    init(frame: CGRect, player: PlayerModel) {
        playerModel = player
        super.init(frame: frame)
        
        contentView.frame = CGRect(x: padding, y: frame.size.height * 0.325, width: frame.size.width - (padding*2), height: 50)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: -2.5, height: -2.5)
        contentView.layer.shadowOpacity = 0.3
        contentView.clipsToBounds = false
        addSubview(contentView)
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: 50))
        header.backgroundColor = Colors.blue.UI
        header.layer.cornerRadius = 4
        header.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.addSubview(header)
        
        let closeButton = UIButton(frame: CGRect(x: padding, y: padding, width: header.frame.size.height - (padding*2), height: header.frame.size.height - (padding*2)))
        closeButton.setImage(UIImage.coloredImage(named: "ic_close", color: Color(255)), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        contentView.addSubview(closeButton)
        
        let profilePic = UIImageView(frame: CGRect(x: padding, y: header.frame.size.height + padding, width: 100, height: 100))
        profilePic.image = UIImage.coloredImage(named: "ic_player", color: Color(0))
        profilePic.contentMode = .scaleAspectFit
        profilePic.layer.borderWidth = 1
        profilePic.layer.cornerRadius = 4
        profilePic.layer.borderColor = UIColor.black.cgColor
        contentView.addSubview(profilePic)
        
        let xPos = profilePic.frame.size.width + (padding*2)
        let contentWidth = contentView.frame.size.width - xPos - padding
        
        func createField(key: String, value: String, frame: CGRect) -> UIView {
            let view = UIView(frame: frame)
            
            let keyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width / 2, height: frame.size.height))
            keyLabel.text = key
            keyLabel.textColor = .black
            keyLabel.font = UIFont.boldSystemFont(ofSize: 14)
            keyLabel.numberOfLines = 2
            keyLabel.sizeToFit()
            keyLabel.frame.size.height = frame.size.height
            view.addSubview(keyLabel)
            
            let valueLabel = UILabel(frame: CGRect(x: frame.size.width / 2, y: 0, width: frame.size.width / 2, height: frame.size.height))
            valueLabel.text = value
            valueLabel.textColor = .black
            valueLabel.font = UIFont.systemFont(ofSize: 14)
            valueLabel.numberOfLines = 2
            valueLabel.sizeToFit()
            valueLabel.frame.size.height = frame.size.height
            view.addSubview(valueLabel)
            
            return view
        }
        
        var yPos = profilePic.frame.origin.y
        
        let firstName = createField(key: "First name:", value: player.firstName, frame: CGRect(x: xPos, y: yPos, width: contentWidth, height: 20))
        contentView.addSubview(firstName)
        yPos += firstName.frame.size.height
        
        let lastName = createField(key: "Last name:", value: player.lastName, frame: CGRect(x: xPos, y: yPos, width: contentWidth, height: 20))
        contentView.addSubview(lastName)
        yPos += lastName.frame.size.height + 10
        
        let age = createField(key: "Age:", value: "\(player.age)", frame: CGRect(x: xPos, y: yPos, width: contentWidth, height: 20))
        contentView.addSubview(age)
        yPos += age.frame.size.height
        
        let length = createField(key: "Length:", value: "\(player.length)m", frame: CGRect(x: xPos, y: yPos, width: contentWidth, height: 20))
        contentView.addSubview(length)
        yPos += length.frame.size.height + 10
        
        let score = createField(key: "Power:", value: "\(player.power)", frame: CGRect(x: xPos, y: yPos, width: contentWidth, height: 20))
        contentView.addSubview(score)
        yPos += score.frame.size.height
        
        let goals = createField(key: "Goals:", value: "\(player.goals)", frame: CGRect(x: xPos, y: yPos, width: contentWidth, height: 20))
        contentView.addSubview(goals)
        yPos += goals.frame.size.height
        
        contentView.frame.size.height = yPos + padding
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Targets
    @objc private func closeButtonPressed() {
        delegate?.closeButtonPressed()
    }
}
