//
//
//  Workspace: VidePlayer
//  MacOS Version: 11.4
//			
//  File Name: VideoPlayerTestViewController.swift
//  Creation: 5/31/21 8:51 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit
import VidePlayer

public class VideoPlayerTestViewController: UIViewController
{
    // MARK: - Initialization
    
    private let m_VideoUrl: URL = .init(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
}

public extension VideoPlayerTestViewController
{
    // MARK: - Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let videoPlayerController = VideoPlayerViewController(videoUrl: m_VideoUrl, isVideoGravityChangeable: true, defaultVideoGravity: .resizeAspectFill)
        
        addChild(videoPlayerController)
        view.addSubview(videoPlayerController.view)
        
        videoPlayerController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                videoPlayerController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
                videoPlayerController.view.heightAnchor.constraint(equalTo: view.heightAnchor),
                videoPlayerController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                videoPlayerController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
    }
}

