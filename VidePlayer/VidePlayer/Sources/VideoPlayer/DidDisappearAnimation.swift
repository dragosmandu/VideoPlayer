//
//
//  Workspace: VidePlayer
//  MacOS Version: 11.4
//			
//  File Name: DidDisappearAnimation.swift
//  Creation: 5/31/21 9:05 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit

public class DidDisappearAnimation
{
    static var s_DidDisappearAnimationDuration: Double = 0.2
    static var s_DidDisappearAnimationDelay: Double = 0
    static var s_DidDisappearAnimationOption: UIView.AnimationOptions = .curveEaseInOut
    
    static func set(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil)
    {
        UIView.animate(withDuration: s_DidDisappearAnimationDuration, delay: s_DidDisappearAnimationDelay, options: s_DidDisappearAnimationOption)
        {
            animations()
        }
        completion:
        { finished in
            completion?(finished)
        }
    }
}

