//
//  VideoCallVC.swift
//  livestream
//
//  Created by DaoVanSon on 3/19/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit
import TwilioVideo
import AVFoundation
import SwifterSwift
import SnapKit

class VideoCallVC: BaseViewController {
    
    @IBOutlet weak var constraintBottomListBackground: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomButtonViewContainer: NSLayoutConstraint!
    @IBOutlet weak var localVideoView: VideoView!
    @IBOutlet weak var remoteVideoView: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var mCollectionView: UICollectionView!

    let arrayBackgroundImage = ["none", "HangMa", "Moon", "sea","sakura_image"]
    var opencvCam: OpencvCamera!
    var webViewSource: CustomVideosource?
    
    private var tokenModel: TokenModel!
    var room: Room?
    var camera: CameraSource?
    var localVideoTrack: LocalVideoTrack?
    var localAudioTrack: LocalAudioTrack?
    var remoteParticipant: RemoteParticipant?
    var remoteAudioTrack: RemoteAudioTrack?
    var remoteView: VideoView?
    private var isLoudSpeaker: Bool = true
    override var existsNaviBar: Bool {return false}
    override var isEnableBack: Bool {return false}
    
    deinit {
        if let camera = self.camera {
            camera.stopCapture()
            self.camera = nil
        }
        if let room = self.room {
            room.disconnect()
            self.room = nil
        }
    }
    
    static func create(tokenModel: TokenModel) -> VideoCallVC {
        let view: VideoCallVC = ViewUtil.loadStoryboardVC(storyboard: "VideoCall", identifier: "VideoCall")
        view.initialize(token: tokenModel)
        return view
    }
    
    private func initialize(token: TokenModel) {
        self.tokenModel = token
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        opencvCam = OpencvCamera(controller: self)
        opencvCam.start()
        
        
        if PlatformUtils.isSimulator {
            self.localVideoView.removeFromSuperview()
        } else {
            self.setupLocalMedia()
        }
        
        mCollectionView.delegate = self
        mCollectionView.dataSource = self
        mCollectionView.register(UINib(nibName: "ImageViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageViewCell")
        
        
        connect()
    }
    
    func setupLocalMedia() {
        let source = CustomVideosource(aView: self.view)

        guard let videoTrack = LocalVideoTrack(source: source, enabled: true, name: "Screen") else {
            
            return
        }

        self.localVideoTrack = videoTrack
        webViewSource = source
        let localView = VideoView(frame: view.bounds)
        localView.contentMode = .scaleAspectFill
        localVideoTrack?.addRenderer(localView)
        localVideoView.addSubview(localView)

        localView.snp.makeConstraints({ make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        self.setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return self.room != nil
    }
    
    override func backEvent() -> Bool {
        self.room!.disconnect()
        return true
    }
    
    //MARK: Action
    @IBAction func showListBackground(_ sender: UIButton) {
        let isShowListBackground = constraintBottomListBackground.constant == 0
        sender.isEnabled = false
        
        UIView.animate(withDuration: 0.3) {
            self.constraintBottomButtonViewContainer.constant = isShowListBackground ? 0 : -110
            self.constraintBottomListBackground.constant = isShowListBackground ? -110 : 0
            self.view.layoutIfNeeded()
        } completion: { (_) in
            sender.isEnabled = true
        }


    }
    
    @IBAction func handleEndCall(_ sender: Any) {
        self.room!.disconnect()
    }
    
    @IBAction func handleMic(_ sender: Any) {
        if (self.localAudioTrack != nil) {
            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
            if (self.localAudioTrack?.isEnabled == true) {
                self.micButton.setImage(UIImage(named: "ic_micro_on")!, for: .normal)
            } else {
                self.micButton.setImage(UIImage(named: "ic_micro_off")!, for: .normal)
            }
        }
    }
    
    @IBAction func handleFlipCamera(_ sender: Any) {
        opencvCam.change()
    }
    
    private func connect() {
        // Prepare local media which we will share with Room Participants.
        self.prepareLocalMedia()
        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = ConnectOptions(token: tokenModel.token) { (builder) in
            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [LocalVideoTrack]()
            builder.roomName = self.tokenModel.roomName
        }
        // Connect to the Room using the options we provided.
        room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
    }
    
    private func prepareLocalMedia() {
        // We will share local audio and video when we connect to the Room.
        // Create an audio track.
        if (localAudioTrack == nil) {
            localAudioTrack = LocalAudioTrack(options: nil, enabled: true, name: "Microphone")
            if (localAudioTrack == nil) {
                showAlert(title: "", message: "Failed to create audio track")
            }
        }
    }
    
    private func renderRemoteParticipant(participant : RemoteParticipant) -> Bool {
        // This example renders the first subscribed RemoteVideoTrack from the RemoteParticipant.
        let videoPublications = participant.remoteVideoTracks
        for publication in videoPublications {
            if let subscribedVideoTrack = publication.remoteTrack,
                publication.isTrackSubscribed {
                setupRemoteVideoView()
                subscribedVideoTrack.addRenderer(self.remoteView!)
                self.remoteParticipant = participant
                return true
            }
        }
        return false
    }
    
    private func renderRemoteParticipants(participants : Array<RemoteParticipant>) {
        for participant in participants {
            // Find the first renderable track.
            if participant.remoteVideoTracks.count > 0,
                renderRemoteParticipant(participant: participant) {
                break
            }
        }
    }
    
    private func cleanupRemoteParticipant() {
        if self.remoteParticipant != nil {
            self.remoteVideoView?.removeFromSuperview()
            self.remoteVideoView = nil
            self.remoteParticipant = nil
        }
        self.popViewController()
    }
    
    func setupRemoteVideoView() {
        // Creating `VideoView` programmatically
        self.remoteView = VideoView(frame: CGRect.zero, delegate: self)
        // `VideoView` supports scaleToFill, scaleAspectFill and scaleAspectFit
        // scaleAspectFit is the default mode when you create `VideoView` programmatically.
        self.remoteView!.contentMode = .scaleAspectFit;
        self.remoteVideoView.addXibView(view: self.remoteView!)
    }
}

// MARK:- CameraSourceDelegate
extension VideoCallVC : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        self.showAlert(title: "", message: "Camera source failed with error: \(error.localizedDescription)")
    }
}

// MARK:- RoomDelegate
extension VideoCallVC : RoomDelegate {
    func roomDidConnect(room: Room) {
        // This example only renders 1 RemoteVideoTrack at a time. Listen for all events to decide which track to render.
        print("Connected to room \(room.name) as \(room.localParticipant?.identity ?? "") \n")
        for remoteParticipant in room.remoteParticipants {
            remoteParticipant.delegate = self
        }
    }
    
    func roomDidDisconnect(room: Room, error: Error?) {
        print("disconnect room \(room.name)")
        self.cleanupRemoteParticipant()
        self.room = nil
    }
    
    func roomDidFailToConnect(room: Room, error: Error) {
        print("Failed to connect to room with error = \(String(describing: error))")
        self.cleanupRemoteParticipant()
        self.room = nil
    }
    
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        // Listen for events from all Participants to decide which RemoteVideoTrack to render.
        participant.delegate = self
        print("Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
    }
    
    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        print("Room \(room.name), Participant \(participant.identity) disconnected")
        self.room!.disconnect()
    }
}

// MARK:- RemoteParticipantDelegate
extension VideoCallVC : RemoteParticipantDelegate {
    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // The LocalParticipant is subscribed to the RemoteParticipant's video Track. Frames will begin to arrive now.
        print("Subscribed to \(publication.trackName) video track for Participant \(participant.identity)")
        
        if (self.remoteParticipant == nil) {
            _ = renderRemoteParticipant(participant: participant)
        }
    }
    
    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.
        print("Unsubscribed from \(publication.trackName) video track for Participant \(participant.identity)")
        
        if self.remoteParticipant == participant {
            cleanupRemoteParticipant()
            
            // Find another Participant video to render, if possible.
            if var remainingParticipants = room?.remoteParticipants,
                let index = remainingParticipants.firstIndex(of: participant) {
                remainingParticipants.remove(at: index)
                renderRemoteParticipants(participants: remainingParticipants)
            }
        }
    }
    
    func didSubscribeToAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's audio now.
        self.remoteAudioTrack = audioTrack
        print("Subscribed to \(publication.trackName) audio track for Participant \(participant.identity)")
    }
}

// MARK:- VideoViewDelegate
extension VideoCallVC : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

extension VideoCallVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayBackgroundImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as! ImageViewCell
        cell.bindData(arrayBackgroundImage[indexPath.row], indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = mCollectionView.frame.height - 20
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let imageName = arrayBackgroundImage[indexPath.row]
            let image = UIImage(named: imageName)!
            opencvCam.addBackground(image)
        } else {
            opencvCam.addBackground(nil)
        }
    }
}

extension VideoCallVC: OpencvCameraDelegate {
    func onAddBackground(_ resultImage: UIImage!) {
//        self.previewImage.image = resultImage
        
        webViewSource?.deliverCapturedImage(image: resultImage, orientation: .up, timestamp: CACurrentMediaTime())
    }
}
