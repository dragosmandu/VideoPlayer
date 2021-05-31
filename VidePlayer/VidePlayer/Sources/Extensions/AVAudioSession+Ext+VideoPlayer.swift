//
//
//  Workspace: VidePlayer
//  MacOS Version: 11.4
//			
//  File Name: AVAudioSession+Ext+VideoPlayer.swift
//  Creation: 5/31/21 9:07 PM
//
//  Author: Dragos-Costin Mandu
//
//
	

import AVFoundation
import os

public extension AVAudioSession
{
    static var s_LoggerCategory: String = "AVAudioSession"
    static let s_Logger: Logger = .init(subsystem: loggerSubsystem, category: s_LoggerCategory)
}

public extension AVAudioSession
{
    static func configureSharedAudioSessionForPlayback()
    {
        let audioSession = AVAudioSession.sharedInstance()
        
        do
        {
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
        }
        catch let error
        {
            s_Logger.error("Failed to configure audio session with error: '\(error.localizedDescription)'")
        }
    }
    
    static func activateSharedAudioSession()
    {
        let audioSession = AVAudioSession.sharedInstance()
        
        do
        {
            try audioSession.setActive(true)
        }
        catch let error
        {
            s_Logger.error("Failed to activate audio session with error: '\(error.localizedDescription)'")
        }
    }
    
    static func deactivateSharedAudioSession()
    {
        let audioSession = AVAudioSession.sharedInstance()
        
        do
        {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        catch let error
        {
            s_Logger.error("Failed to deactivate audio session with error: '\(error.localizedDescription)'")
        }
    }
}

