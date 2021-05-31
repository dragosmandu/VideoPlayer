//
//
//  Workspace: VidePlayer
//  MacOS Version: 11.4
//			
//  File Name: PlayerStateToggleGesture.swift
//  Creation: 5/31/21 8:54 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit
import os

class PlayerStateToggleGesture: UITapGestureRecognizer
{
    public static var s_LoggerCategory: String = "PlayerStateToggleGesture"
    public static var s_Logger: Logger = .init(subsystem: loggerSubsystem, category: s_LoggerCategory)
    public static var s_GestureName: String = "PlayerStateToggleGestureName"
    
    private let m_TogglePlayerStateAction: () -> Void
    
    public init(togglePlayerStateAction: @escaping () -> Void, delegate: UIGestureRecognizerDelegate?)
    {
        m_TogglePlayerStateAction = togglePlayerStateAction
        
        super.init(target: nil, action: nil)
        
        self.numberOfTouchesRequired = 1
        self.numberOfTapsRequired = 1
        self.name = PlayerStateToggleGesture.s_GestureName
        self.delegate = delegate
        self.addTarget(self, action: #selector(didTogglePlayerState))
    }
}

private extension PlayerStateToggleGesture
{
    @objc private func didTogglePlayerState(_ gesture: UILongPressGestureRecognizer)
    {
        if gesture.state == .ended
        {
            PlayerStateToggleGesture.s_Logger.debug("Changing player state.")
            
            m_TogglePlayerStateAction()
        }
    }
}

