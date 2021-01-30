//
//  LiveStreamHostVC.swift
//  livestream
//
//  Created by DaoVanSon on 3/22/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit
import TwilioVideo
import TwilioChatClient
import SwiftyJSON
import SwifterSwift

enum pointNumber: Int {
    case one = 1
    case five = 5
    case ten = 10
    case twenty = 20
}

class LiveStreamHostVC: BaseViewController {
    @IBOutlet weak var localVideoView: VideoView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var likeAnimationView: LikeAnimationView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtPoint: UILabel!
    @IBOutlet weak var txtLike: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var roomNameLbl: UILabel!
    @IBOutlet weak var inforView: UIView!
    
    @IBOutlet weak var onePointAnimationView: PointAnimationView!
    @IBOutlet weak var fivePointAnimationView: PointAnimationView!
    @IBOutlet weak var tenPointAnimationView: PointAnimationView!
    @IBOutlet weak var twentyPointAnimationView: PointAnimationView!
    
    override var existsNaviBar: Bool {
        return false
    }
    override var isEnableBack: Bool {
        return false
    }
    
    private var tokenModel: TokenModel!
    var room: Room?
    var camera: CameraSource?
    var localVideoTrack: LocalVideoTrack?
    var localAudioTrack: LocalAudioTrack?
    
    var channel: TCHChannel!
    var client: TwilioChatClient? = nil
    var delegate: ChannelManager?
    let cellReuseIdentifier = "textChatCell"
    var textMsg: [[String:String]] = []
    
    var totalPoint = 0
    var totalLike = 0
    
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
    
    static func create(tokenModel: TokenModel) -> LiveStreamHostVC {
        let view: LiveStreamHostVC = ViewUtil.loadStoryboardVC(storyboard: "LiveStreamHost", identifier: "LiveStreamHost")
        view.initialize(token: tokenModel)
        return view
    }
    
    private func initialize(token: TokenModel) {
        self.tokenModel = token
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if PlatformUtils.isSimulator {
//            self.localVideoView.removeFromSuperview()
//        } else {
            self.startLocalVideoView()
//        }
        self.tableView.register(UINib(nibName: "TextChatCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        connect()
        initializeClientWithToken(token: tokenModel.token)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = true
        self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        super.viewDidAppear(animated)
        displayUserInfor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideLoading()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return self.room != nil
    }
    
    //MARK: Action
    @IBAction func handleEndCall(_ sender: Any) {
        self.showLoading()
        self.channel.destroy(completion: { result in
            if result.isSuccessful() {
                self.logout()
                self.room!.disconnect()
            }
        })
    }
    
    @IBAction func handleMic(_ sender: Any) {
        if (self.localAudioTrack != nil) {
            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
            if (self.localAudioTrack?.isEnabled == true) {
                self.micButton.setBackgroundImage(UIImage(named: "btn_mic_on")!, for: .normal)
            } else {
                self.micButton.setBackgroundImage(UIImage(named: "btn_mic_off")!, for: .normal)
            }
        }
    }
    
    //    @IBAction func handleFlipCamera(_ sender: Any) {
    //        var newDevice: AVCaptureDevice?
    //        if let camera = self.camera, let captureDevice = camera.device {
    //            if captureDevice.position == .front {
    //                newDevice = CameraSource.captureDevice(position: .back)
    //            } else {
    //                newDevice = CameraSource.captureDevice(position: .front)
    //            }
    //            if let newDevice = newDevice {
    //                camera.selectCaptureDevice(newDevice) { (captureDevice, videoFormat, error) in
    //                    if let error = error {
    //                        print("Error selecting capture device.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
    //                    } else {
    //                        self.localVideoView.shouldMirror = (captureDevice.position == .front)
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    //MARK: Event
    private func displayUserInfor() {
        if let infor: UserInforModel = UserDefaults.standard.retrieve(object: UserInforModel.self, fromKey: AppConst.USER_INFOR_KEY){
            self.inforView.isHidden = false
            self.avatarImg.sd_setImage(with: URL(string: infor.avatarUrl), placeholderImage: UIImage(named: "avatar_default.png"))
        } else {
            self.inforView.isHidden = true
        }
        self.roomNameLbl.text = self.tokenModel.roomName
    }
    
    //MARK: TODO
    private func showAnimation(number: pointNumber) {
        switch number {
        case .one:
            onePointAnimationView.animate(icon: #imageLiteral(resourceName: "icon_gift01_large"))
        case .five:
            fivePointAnimationView.animate(icon: #imageLiteral(resourceName: "icon_gift02_large"))
        case .ten:
            tenPointAnimationView.animate(icon: #imageLiteral(resourceName: "icon_gift03_large"))
        case .twenty:
            twentyPointAnimationView.animate(icon: #imageLiteral(resourceName: "icon_gift04_large"))
        }
    }
    
    private func currencyFormat(input: Int) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .decimal
        return  currencyFormatter.string(from: NSNumber(value: input))!
    }
    
    private func updatePoint(point: Int) {
        self.totalPoint += point
        self.txtPoint.text = currencyFormat(input: self.totalPoint)
    }
    
    private func updateLike() {
        self.totalLike += 1
        self.txtLike.text = currencyFormat(input: self.totalLike)
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
    // MARK: Twilio Client
    func initializeClientWithToken(token: String) {
        self.showLoading()
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        TwilioChatClient.chatClient(withToken: token, properties: nil, delegate: self) { [weak self] result, chatClient in
            guard (result.isSuccessful()) else { return }
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self?.client = chatClient
        }
    }
    
    func loadGeneralChatRoomWithCompletion(completion:@escaping (Bool, NSError?) -> Void) {
        ChannelManager.sharedManager.joinGeneralChatRoomWithCompletion { succeeded in
            if succeeded {
                completion(succeeded, nil)
            }
            else {
                let error = self.errorWithDescription(description: "Could not join General channel", code: 300)
                completion(succeeded, error)
            }
        }
    }
    
    private func updateTableView() {
        self.tableView.reloadData()
        self.scrollToBottom()
    }
    
    func logout() {
        if let client = client {
            client.delegate = nil
            client.shutdown()
            self.client = nil
        }
    }
    
    func scrollToBottom(animated: Bool = true, delay: Double = 0.0) {
        let numberOfRows = tableView.numberOfRows(inSection: tableView.numberOfSections - 1) - 1
        guard numberOfRows > 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
            let indexPath = IndexPath(
                row: numberOfRows,
                section: self.tableView.numberOfSections - 1)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
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
                //                self.flipCameraButton.isHidden = false
            }
            self.localVideoView.contentMode = .scaleAspectFill
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

// MARK:- TableViewDataSource
extension LiveStreamHostVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textMsg.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! TextChatCell
        let data = self.textMsg[indexPath.row]
        cell.config(userName: data["name"]!, text: data["text"]!)
        return cell
    }
}

// MARK:- RoomDelegate
extension LiveStreamHostVC : RoomDelegate {
    func roomDidConnect(room: Room) {
        // This example only renders 1 RemoteVideoTrack at a time. Listen for all events to decide which track to render.
        print("Connected to room \(room.name) as \(room.localParticipant?.identity ?? "") \n")
    }
    
    func roomDidDisconnect(room: Room, error: Error?) {
        print("disconnect room \(room.name)")
        self.room = nil
        self.popViewController()
    }
    
    func roomDidFailToConnect(room: Room, error: Error) {
        print("Failed to connect to room with error = \(String(describing: error))")
        self.room = nil
        self.popViewController()
    }
    
    func roomIsReconnecting(room: Room, error: Error) {
        print("Reconnecting to room \(room.name), error = \(String(describing: error))")
    }
    
    func roomDidReconnect(room: Room) {
        print("Reconnected to room \(room.name)")
    }
    
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        // Listen for events from all Participants to decide which RemoteVideoTrack to render.
        print("Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
    }
    
    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        print("Room \(room.name), Participant \(participant.identity) disconnected")
    }
}

// MARK:- CameraSourceDelegate
extension LiveStreamHostVC : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        self.showAlert(title: "", message: "Camera source failed with error: \(error.localizedDescription)")
    }
}

// MARK: - TwilioChatClientDelegate
extension LiveStreamHostVC : TwilioChatClientDelegate {
    func chatClient(_ client: TwilioChatClient, channelAdded channel: TCHChannel) {
        self.delegate?.chatClient(client, channelAdded: channel)
    }
    
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, updated: TCHChannelUpdate) {
        self.delegate?.chatClient(client, channel: channel, updated: updated)
    }
    
    func chatClient(_ client: TwilioChatClient, channelDeleted channel: TCHChannel) {
        self.delegate?.chatClient(client, channelDeleted: channel)
    }
    
    func chatClient(_ client: TwilioChatClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        if status == .completed {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            ChannelManager.sharedManager.channelsList = client.channelsList()
            loadGeneralChatRoomWithCompletion { success, error in
                if success {
                    //create channel
                    ChannelManager.sharedManager.createChannelWithName(name: self.tokenModel.roomName, completion: { success, channel in
                        self.hideLoading()
                        ChannelManager.sharedManager.populateChannels()
                        if success {
                            self.channel = channel
                            self.channel.join(completion: { result in
                                print("Channel joined with result \(result.isSuccessful())")
                            })
                        } else {
                            self.showAlert(title: "", message: "Room chat already exists", buttonTitles: ["OK"], highlightedButtonIndex:  nil) { (index) in
                                if index == 0 {
                                    self.logout()
                                    self.room!.disconnect()
                                }
                            }
                        }
                    })
                } else {
                    self.showAlert(title: "", message: "\(error?.description ?? "Something wrong")")
                }
            }
        }
        self.delegate?.chatClient(client, synchronizationStatusUpdated: status)
    }
}

// MARK: - TCHChannelDelegate
extension LiveStreamHostVC: TCHChannelDelegate {
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageAdded message: TCHMessage) {
        if let msg: String = message.body, let author: String = message.author {
            let json = JSON(parseJSON: msg)
            let obj = ChatTextModel(json: json)
            if obj.type == .Message {
                let dict = ["name": "\(author)", "text": obj.message!]
                self.textMsg.append(dict)
            } else if obj.type == .Like {
                self.updateLike()
                likeAnimationView.animate(icon: #imageLiteral(resourceName: "icon_like"))
            } else {
                let point = Int(obj.message) ?? 1
                updatePoint(point: point)
                self.showAnimation(number: pointNumber.init(rawValue: point)!)
            }
        }
        self.tableView.reloadData()
        self.scrollToBottom()
    }
    
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberJoined member: TCHMember) {
        //            addMessages(newMessages: [StatusMessage(member:member, status:.Joined)])
    }
    
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberLeft member: TCHMember) {
        //            addMessages(newMessages: [StatusMessage(member:member, status:.Left)])
    }
    
    func chatClient(_ client: TwilioChatClient,
                    channel: TCHChannel,
                    synchronizationStatusUpdated status: TCHChannelSynchronizationStatus) {
    }
}
