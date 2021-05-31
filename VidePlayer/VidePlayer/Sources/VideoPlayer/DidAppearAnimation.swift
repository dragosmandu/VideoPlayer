//
//
//  Workspace: VidePlayer
//  MacOS Version: 11.4
//			
//  File Name: DidAppearAnimation.swift
//  Creation: 5/31/21 9:04 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit

public class DidAppearAnimation
{
    static var s_DidAppearAnimationDuration: Double = 0.3
    static var s_DidAppearAnimationDelay: Double = 0
    static var s_DidAppearAnimationOption: UIView.AnimationOptions = .curveEaseInOut
    
    static func set(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil)
    {
        UIView.animate(withDuration: s_DidAppearAnimationDuration, delay: s_DidAppearAnimationDelay, options: s_DidAppearAnimationOption)
        {
            animations()
        }
        completion:
        { finished in
            completion?(finished)
        }
    }
}
