//
//
//  Workspace: VidePlayer
//  MacOS Version: 11.4
//			
//  File Name: VideoPlayerViewController.swift
//  Creation: 5/31/21 8:51 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit
import AVKit
import os

var loggerSubsystem: String = Bundle.main.bundleIdentifier!

public class VideoPlayerViewController: UIViewController
{
    // MARK: - Initialization
    
    public static var s_LoggerCategory: String = "VideoPlayerViewController"
    public static var s_Logger: Logger = .init(subsystem: loggerSubsystem, category: s_LoggerCategory)
    
    /// The number of seconds to skip when gesture recognized.
    public var skipGestureTimeSec: Double = 10
    
    /// The ratio between the minimum View length and an indicator (ex: play indicator).
    public var indicatorSizeRatio: CGFloat = 0.15
    
    public private(set) var currentVideoUrl: URL?
    
    private var m_PlayerLayer: AVPlayerLayer!
    private var m_ObservationKeys: [NSKeyValueObservation?] = []
    private var m_PlayIndicatorView: UIImageView!
    
    private let m_IsVideoGravityChangeable: Bool
    private let m_DefaultVideoGravity: AVLayerVideoGravity
    
    public init(videoUrl: URL?, isVideoGravityChangeable: Bool = true, defaultVideoGravity: AVLayerVideoGravity = .resizeAspectFill)
    {
        currentVideoUrl = videoUrl
        m_IsVideoGravityChangeable = isVideoGravityChangeable
        m_DefaultVideoGravity = defaultVideoGravity
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder)
    {
        m_IsVideoGravityChangeable = true
        m_DefaultVideoGravity = .resizeAspectFill
        
        super.init(coder: coder)
    }
    
    deinit
    {
        for observationKey in m_ObservationKeys
        {
            observationKey?.invalidate()
        }
    }
}

public extension VideoPlayerViewController
{
    // MARK: - Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configure()
        updateCurrentVideoWith(newVideoUrl: currentVideoUrl)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        m_PlayerLayer.player?.play()
    }
    
    override func viewWillDisappear(_ aniamted: Bool)
    {
        super.viewWillDisappear(aniamted)
        
        m_PlayerLayer.player?.pause()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        updatePlayerLayerFrame()
    }
}

public extension VideoPlayerViewController
{
    // MARK: - Updates
    
    func updateCurrentVideoWith(newVideoUrl: URL?)
    {
        VideoPlayerViewController.s_Logger.debug("Updating video with '\(newVideoUrl?.absoluteString ?? "")'.")
        
        if let newVideoUrl = newVideoUrl
        {
            let item = AVPlayerItem(url: newVideoUrl)
            
            m_PlayerLayer.player?.replaceCurrentItem(with: item)
            m_PlayerLayer.player?.currentItem?.preferredMaximumResolution = .zero
            
            currentVideoUrl = newVideoUrl
        }
    }
    
    func updateCurrentVideoWith(newPlayerItem: AVPlayerItem)
    {
        
        VideoPlayerViewController.s_Logger.debug("Updating video with new player item.")
        
        m_PlayerLayer.player?.replaceCurrentItem(with: newPlayerItem)
        m_PlayerLayer.player?.currentItem?.preferredMaximumResolution = .zero
    }
    
    func updateVideoGravityTo(newVideoGravity: AVLayerVideoGravity)
    {
        if m_IsVideoGravityChangeable
        {
            m_PlayerLayer.videoGravity = newVideoGravity
        }
    }
}

extension VideoPlayerViewController: UIGestureRecognizerDelegate
{
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if gestureRecognizer.name == PlayerStateToggleGesture.s_GestureName && otherGestureRecognizer.name == m_SkipToTimeGestureName
        {
            return true
        }
        
        return false
    }
}

private extension VideoPlayerViewController
{
    // MARK: - Configuration
    
    var m_SkipToTimeGestureName: String { "SkipToTimeGestureName" }
    
    var m_SkipToTimeGesture: UITapGestureRecognizer
    {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didSkipToTime))
        
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        gesture.name = m_SkipToTimeGestureName
        gesture.delegate = self
        
        return gesture
    }
    
    func configure()
    {
        VideoPlayerViewController.s_Logger.debug("Configuring video player.")
        
        configurePlayerLayer()
        addSubviews()
        setObservers()
        addGestures()
    }
    
    func configurePlayerLayer()
    {
        let player = getPlayer()
        m_PlayerLayer = .init(player: player)
        
        m_PlayerLayer.frame = view.frame
        m_PlayerLayer.videoGravity = m_DefaultVideoGravity
        m_PlayerLayer.speed = 999
        
        view.layer.addSublayer(m_PlayerLayer)
    }
    
    func getPlayer() -> AVPlayer
    {
        let player = AVPlayer()
        
        player.allowsExternalPlayback = true
        player.automaticallyWaitsToMinimizeStalling = true
        player.preventsDisplaySleepDuringVideoPlayback = true
        
        return player
    }
    
    func addSubviews()
    {
        addPlayIndicatorView()
    }
    
    func addPlayIndicatorView()
    {
        let minViewLength = min(view.frame.width, view.frame.height)
        let playIndicatorImageConfig = UIImage.SymbolConfiguration(pointSize: minViewLength * indicatorSizeRatio, weight: .black)
        let playIndicatorImage = UIImage(systemName: "play.fill", withConfiguration: playIndicatorImageConfig)
        m_PlayIndicatorView = .init(image: playIndicatorImage)
        
        m_PlayIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        m_PlayIndicatorView.tintColor = UIColor.white
        m_PlayIndicatorView.layer.opacity = 0
        m_PlayIndicatorView.layer.shadowColor = UIColor.black.cgColor
        m_PlayIndicatorView.layer.shadowRadius = 5
        m_PlayIndicatorView.layer.shadowOpacity = 0.15
        m_PlayIndicatorView.layer.shadowOffset = .zero
        
        view.addSubview(m_PlayIndicatorView)
        
        NSLayoutConstraint.activate(
            [
                m_PlayIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                m_PlayIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    func setObservers()
    {
        setPeriodicTimeObserver()
        setTimeControlObserver()
        setAppStateObservers()
    }
    
    func addGestures()
    {
        VideoPlayerViewController.s_Logger.debug("Setting control gestures.")
        
        addPlayPauseGesture()
        addContentModeChangeGesture()
        addSkipToTimeGesture()
    }
    
    func addPlayPauseGesture()
    {
        view.addPlayerStateToggleGesture(delegate: self)
        { [weak self] in
            if self?.m_PlayerLayer.player?.timeControlStatus == .playing
            {
                self?.m_PlayerLayer.player?.pause()
            }
            else if self?.m_PlayerLayer.player?.timeControlStatus == .paused
            {
                self?.m_PlayerLayer.player?.play()
            }
        }
    }
    
    func addContentModeChangeGesture()
    {
        view.addContentModeChangeGesture(delegate: self)
        { [weak self] completion in
            if self?.m_PlayerLayer.videoGravity != .resizeAspect
            {
                self?.updateVideoGravityTo(newVideoGravity: .resizeAspect)
                completion(true)
            }
            
            completion(false)
        } changeToAspectFillAction:
        { [weak self] completion in
            if self?.m_PlayerLayer.videoGravity != .resizeAspectFill
            {
                self?.updateVideoGravityTo(newVideoGravity: .resizeAspectFill)
                completion(true)
            }
            
            completion(false)
        }
        
    }
    
    func addSkipToTimeGesture()
    {
        view.addGestureRecognizer(m_SkipToTimeGesture)
    }
    
    func setPeriodicTimeObserver()
    {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        m_PlayerLayer.player?.addPeriodicTimeObserver(forInterval: interval, queue: nil)
        { [weak self] currentTime in
            self?.replayCurrentVideoWith(currentTime: currentTime)
        }
    }
    
    func setTimeControlObserver()
    {
        let timeControlStatusObservationKey = m_PlayerLayer.player?.observe(\.timeControlStatus)
        { [weak self] player, _ in
            if player.timeControlStatus == .paused
            {
                self?.onPauseAction()
            }
            else if player.timeControlStatus == .playing
            {
                self?.onPlayAction()
            }
        }
        
        m_ObservationKeys.append(timeControlStatusObservationKey)
    }
    
    func setAppStateObservers()
    {
        setMoveToBackgroundObserver()
        setMoveToForegroundObserver()
    }
    
    func setMoveToBackgroundObserver()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(didMoveToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    func setMoveToForegroundObserver()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(didMoveToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

private extension VideoPlayerViewController
{
    // MARK: - Updates
    
    func replayCurrentVideoWith(currentTime: CMTime)
    {
        guard let duration = m_PlayerLayer.player?.currentItem?.duration else { return }
        
        if currentTime >= duration
        {
            VideoPlayerViewController.s_Logger.debug("Replaying video.")
            
            m_PlayerLayer.player?.pause()
            m_PlayerLayer.player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            m_PlayerLayer.player?.play()
        }
    }
    
    func toggleVideoGravity()
    {
        if m_PlayerLayer.videoGravity == .resizeAspect
        {
            VideoPlayerViewController.s_Logger.debug("Toggle video gravity '.resizeAspectFill'.")
            
            updateVideoGravityTo(newVideoGravity: .resizeAspectFill)
        }
        else
        {
            VideoPlayerViewController.s_Logger.debug("Toggle video gravity '.resizeAspect'.")
            
            updateVideoGravityTo(newVideoGravity: .resizeAspect)
        }
    }
    
    func updatePlayerLayerFrame()
    {
        DispatchQueue.main.async
        {
            self.m_PlayerLayer.frame = self.view.frame
        }
    }
    
    func skipToTime(skipSign: Double)
    {
        guard let currentTime = m_PlayerLayer.player?.currentTime() else { return }
        guard let duration = m_PlayerLayer.player?.currentItem?.duration else { return }
        var skipToTime = CMTime(seconds: currentTime.seconds + skipGestureTimeSec * skipSign, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        if skipToTime >= duration
        {
            skipToTime = .zero
        }
        
        m_PlayerLayer.player?.currentItem?.preferredMaximumResolution = UIScreen.main.bounds.size // Speeds up the seek.
        m_PlayerLayer.player?.seek(to: skipToTime)
        { [weak self] _ in
            self?.m_PlayerLayer.player?.currentItem?.preferredMaximumResolution = .zero
        }
    }
    
    @objc func didMoveToBackground()
    {
        m_PlayerLayer.player?.pause()
    }
    
    @objc func didMoveToForeground()
    {
        m_PlayerLayer.player?.play()
    }
    
    @objc func didSkipToTime(_ gesture: UITapGestureRecognizer)
    {
        if gesture.state == .ended
        {
            var skipSign: Double = 1
            
            // Goes back when the touches were in the first mid of the view.
            if gesture.location(in: view).x < view.frame.midX
            {
                skipSign = -1
            }
            
            skipToTime(skipSign: skipSign)
        }
    }
    
    func onPauseAction()
    {
        DidAppearAnimation.set
        { [weak self] in
            self?.m_PlayIndicatorView.layer.opacity = 1
        }
        completion:
        { [weak self] finished in
            if !finished
            {
                self?.m_PlayIndicatorView.layer.opacity = 1
            }
        }
        
        AVAudioSession.deactivateSharedAudioSession()
    }
    
    func onPlayAction()
    {
        DidDisappearAnimation.set
        { [weak self] in
            self?.m_PlayIndicatorView.layer.opacity = 0
        }
        completion:
        { [weak self] finished in
            if !finished
            {
                self?.m_PlayIndicatorView.layer.opacity = 0
            }
        }
    }
}
