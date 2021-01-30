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

class VideoCallVC: BaseViewController {
    
    @IBOutlet weak var localVideoView: VideoView!
    @IBOutlet weak var remoteVideoView: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var speckerButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    
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
        if PlatformUtils.isSimulator {
            self.localVideoView.removeFromSuperview()
        } else {
            self.startLocalVideoView()
        }
        connect()
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
    @IBAction func handleEndCall(_ sender: Any) {
        self.room!.disconnect()
    }
    
    @IBAction func handleMic(_ sender: Any) {
        if (self.localAudioTrack != nil) {
            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
            if (self.localAudioTrack?.isEnabled == true) {
                self.micButton.setImage(UIImage(named: "btn_mic_on")!, for: .normal)
            } else {
                self.micButton.setImage(UIImage(named: "btn_mic_off")!, for: .normal)
            }
        }
    }
    
    @IBAction func handleSpeaker(_ sender: Any) {
        self.isLoudSpeaker = !isLoudSpeaker
        let nameImage = isLoudSpeaker ? "btn_volume_on" : "btn_volume_off"
        self.speckerButton.setImage(UIImage(named: nameImage)!, for: .normal)
        self.remoteAudioTrack?.isPlaybackEnabled = isLoudSpeaker
    }
    
    @IBAction func handleFlipCamera(_ sender: Any) {
        var newDevice: AVCaptureDevice?
        if let camera = self.camera, let captureDevice = camera.device {
            if captureDevice.position == .front {
                newDevice = CameraSource.captureDevice(position: .back)
            } else {
                newDevice = CameraSource.captureDevice(position: .front)
            }
            if let newDevice = newDevice {
                camera.selectCaptureDevice(newDevice) { (captureDevice, videoFormat, error) in
                    if let error = error {
                        print("Error selecting capture device.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                    } else {
                        self.localVideoView.shouldMirror = (captureDevice.position == .front)
                    }
                }
            }
        }
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
        // Create a video track which captures from the camera.
        if (localVideoTrack == nil) {
            self.startLocalVideoView()
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
    
    private func startLocalVideoView() {
        if PlatformUtils.isSimulator {
            return
        }
        let frontCamera = CameraSource.captureDevice(position: .front)
        let backCamera = CameraSource.captureDevice(position: .back)
        if (frontCamera != nil || backCamera != nil) {
            let options = CameraSourceOptions { (builder) in
                // To support building with Xcode 10.x.
                #if XCODE_1100
                if #available(iOS 13.0, *) {
                    // Track UIWindowScene events for the key window's scene.
                    // The example app disables multi-window support in the .plist (see UIApplicationSceneManifestKey).
                    builder.orientationTracker = UserInterfaceTracker(scene: UIApplication.shared.keyWindow!.windowScene!)
                }
                #endif
            }
            // Preview our local camera track in the local video preview view.
            camera = CameraSource(options: options, delegate: self)
            localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")
            
            if (frontCamera != nil && backCamera != nil) {
                self.flipCameraButton.isHidden = false
            }
            
            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(self.localVideoView)
            camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
                if let error = error {
                    self.showAlert(title: "Error", message: "Capture failed with error.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                } else {
                    self.localVideoView.shouldMirror = (captureDevice.position == .front)
                }
            }
        }
        else {
            self.showAlert(title: "", message: "No front or back capture device found!")
        }
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
    
    func roomIsReconnecting(room: Room, error: Error) {
        print("Reconnecting to room \(room.name), error = \(String(describing: error))")
    }
    
    func roomDidReconnect(room: Room) {
        print("Reconnected to room \(room.name)")
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
    
    func remoteParticipantDidPublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has offered to share the video Track.
        print("Participant \(participant.identity) published \(publication.trackName) video track")
    }
    
    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has stopped sharing the video Track.
        print("Participant \(participant.identity) unpublished \(publication.trackName) video track")
    }
    
    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has offered to share the audio Track.
        print("Participant \(participant.identity) published \(publication.trackName) audio track")
    }
    
    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has stopped sharing the audio Track.
        print("Participant \(participant.identity) unpublished \(publication.trackName) audio track")
    }
    
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
    
    func didUnsubscribeFromAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.
        print("Unsubscribed from \(publication.trackName) audio track for Participant \(participant.identity)")
    }
    
    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        print("Participant \(participant.identity) enabled \(publication.trackName) video track")
    }
    
    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        print("Participant \(participant.identity) disabled \(publication.trackName) video track")
    }
    
    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        print("Participant \(participant.identity) enabled \(publication.trackName) audio track")
    }
    
    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        print("Participant \(participant.identity) disabled \(publication.trackName) audio track")
    }
    
    func didFailToSubscribeToAudioTrack(publication: RemoteAudioTrackPublication, error: Error, participant: RemoteParticipant) {
        print("FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
    }
    
    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
        print("FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
    }
}

// MARK:- VideoViewDelegate
extension VideoCallVC : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}
