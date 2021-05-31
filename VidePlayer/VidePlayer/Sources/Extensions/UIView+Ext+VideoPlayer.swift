//
//
//  Workspace: VidePlayer
//  MacOS Version: 11.4
//			
//  File Name: UIView+Ext+VideoPlayer.swift
//  Creation: 5/31/21 8:57 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit

extension UIView
{
    // MARK: - Updates
    
    /// Adding a content mode toggler pinch gesture to current View.
    /// - Parameters:
    ///   - changeToAspectFitAction: Called when the content mode changes to fit.
    ///   - changeToAspectFillAction: Called when the content mode changes to fill.
    ///   - playHaptic: If true, will play a custom haptic feedback for current content mode change.
    @objc open func addContentModeChangeGesture(delegate: UIGestureRecognizerDelegate? = nil, changeToAspectFitAction: @escaping ((_ playHaptic: Bool) -> Void) -> Void, changeToAspectFillAction: @escaping ((_ playHaptic: Bool) -> Void) -> Void)
    {
        let changeContentModeGesture = ContentModeChangeGesture(changeToAspectFitAction: changeToAspectFitAction, changeToAspectFillAction: changeToAspectFillAction, delegate: delegate)
        
        addGestureRecognizer(changeContentModeGesture)
    }
    
    /// Adding a generic player state toggler long press gesture to current View.
    /// - Parameters:
    ///   - changePlayerStateAction: Called when the player state should toggle.
    @objc open func addPlayerStateToggleGesture(delegate: UIGestureRecognizerDelegate? = nil, changePlayerStateAction: @escaping () -> Void)
    {
        let togglePlayerStateGesture = PlayerStateToggleGesture(togglePlayerStateAction: changePlayerStateAction, delegate: delegate)
        
        addGestureRecognizer(togglePlayerStateGesture)
    }
}

