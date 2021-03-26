//
//  LiveStreamViewerVC.swift
//  livestream
//
//  Created by DaoVanSon on 3/22/20.
//  Copyright © 2020 nguyen tung anh. All rights reserved.
//

import UIKit
import TwilioVideo
import TwilioChatClient
import IQKeyboardManagerSwift
import SwiftyJSON
import SwifterSwift

class LiveStreamViewerVC: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var remoteVideoView: UIView!
    @IBOutlet weak var hostInforView: UIView!
    @IBOutlet weak var roomNameLbl: UILabel!
    @IBOutlet weak var speckerButton: UIButton!
    @IBOutlet weak var likeAnimationView: LikeAnimationView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtPoint: UILabel!
    @IBOutlet weak var constraintBottomContentView: NSLayoutConstraint!
    @IBOutlet weak var tfInputText: UITextField!
    
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
    var remoteParticipant: RemoteParticipant?
    var remoteView: VideoView?
    var remoteAudioTrack: RemoteAudioTrack?
    var client: TwilioChatClient? = nil
    var delegate:ChannelManager?
    private var isLoudSpeaker: Bool = true
    let cellReuseIdentifier = "textChatCell"
    var textMsg: [[String:String]] = []
    private var _animationCurve: UIView.AnimationOptions = .curveEaseOut
    private var _animationDuration: TimeInterval = 0.25
    private var pointUser = 1000
    var _channel:TCHChannel!
    
    deinit {
        if let room = self.room {
            room.disconnect()
            self.room = nil
        }
    }
    
    static func create(tokenModel: TokenModel) -> LiveStreamViewerVC {
        let view: LiveStreamViewerVC = ViewUtil.loadStoryboardVC(storyboard: "LiveStreamViewer", identifier: "LiveStreamViewer")
        view.initialize(token: tokenModel)
        return view
    }
    
    private func initialize(token: TokenModel) {
        self.tokenModel = token
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtPoint.text = currencyFormat(input: self.pointUser)
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        displayInforHost()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tfInputText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        tfInputText.addTarget(self, action: #selector(onReturn(_:)), for: UIControl.Event.editingDidEndOnExit)
        
        let placeholder = tfInputText.placeholder ?? ""
        tfInputText.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : Color.white50])
        
        self.tableView.register(UINib(nibName: "TextChatCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        connect()
        initializeClientWithToken(token: tokenModel.token)
    }
    
    private func displayInforHost() {
        self.roomNameLbl.text = self.tokenModel.roomName
    }
    //MARK:- viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = true
        self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        super.viewDidAppear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillAppear(notification: NSNotification?) {
        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        //  Getting keyboard animation duration
        if let duration =  notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            if duration != 0 {
                _animationDuration = duration
            }
        }
        UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
            self.constraintBottomContentView.constant = keyboardHeight
        })
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification?) {
        UIView.animate(withDuration: _animationDuration, delay: 0, options: _animationCurve.union(.beginFromCurrentState), animations: { () -> Void in
            self.constraintBottomContentView.constant = 0.0
        })
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return self.room != nil
    }
    
    @IBAction func handleEndCall(_ sender: Any) {
        _channel.leave { result in
            if (result.isSuccessful()) {
                self.room!.disconnect()
                self.logout()
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text!
        if text.count != 0 {
            self.btnSend.isEnabled = true
        } else {
            self.btnSend.isEnabled = false
        }
    }
    
    @objc func onReturn(_ textField: UITextField) {
        tfInputText.resignFirstResponder()
        let msg = textField.text!
        self.tfInputText.text = ""
        if msg.count != 0 {
            self.sendMessage(type: .Message, value: msg)
        }
    }
    
    //MARK: Action
    @IBAction func handleLike(_ sender: Any) {
        self.sendMessage(type: .Like, value: "like")
    }
    
    @IBAction func handleSendMessage(_ sender: Any) {
        let msg = self.tfInputText.text!
        self.tfInputText.text = ""
        self.sendMessage(type: .Message, value: msg)
    }
    
    @IBAction func handleSpeaker(_ sender: Any) {
        self.isLoudSpeaker = !isLoudSpeaker
        let nameImage = isLoudSpeaker ? "btn_volume_on" : "btn_volume_off"
        self.speckerButton.setBackgroundImage(UIImage(named: nameImage)!, for: .normal)
        self.remoteAudioTrack?.isPlaybackEnabled = self.isLoudSpeaker
    }
    
    private func sendMessage(type: ChatType, value: String) {
        let dict = ["type": "\(type.rawValue)", "value": value]
        print("sendMessage \(dict)")
        if type == .Message {
            textFieldDidChange(self.tfInputText)
        }
        if let messages = self._channel.messages {
            let messageOptions = TCHMessageOptions().withBody(dict.jsonString()!)
            messages.sendMessage(with: messageOptions, completion: nil)
        }
    }
    
    private func sendPoint(point :pointNumber) {
        if self.pointUser - point.rawValue >= 0 {
            sendMessage(type: .Point, value: "\(point.rawValue)")
            updatePointUser(point: point.rawValue)
        }
    }
    
    @IBAction func pressButtonPoint(_ sender: UIButton) {
        switch sender.tag {
        case pointNumber.one.rawValue:
            sendPoint(point: .one)
            break
        case pointNumber.five.rawValue:
            sendPoint(point: .five)
            break
        case pointNumber.ten.rawValue:
            sendPoint(point: .ten)
            break
        case pointNumber.twenty.rawValue:
            sendPoint(point: .twenty)
            break
        default:
            break
        }
    }
    
    private func currencyFormat(input: Int) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .decimal
        return  currencyFormatter.string(from: NSNumber(value: input))!
    }
    
    private func updatePointUser(point: Int) {
        self.pointUser -= point
        txtPoint.text = currencyFormat(input: self.pointUser)
    }
    
    private func showAlertWithMessage(msg: String) {
        self.showAlert(title: "", message: msg, buttonTitles: ["OK"], highlightedButtonIndex:  nil) { (index) in
            if index == 0 {
                self.logout()
                self.room!.disconnect()
            }
        }
    }
    
    //MARK: Animation
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
    
    private func connect() {
        let connectOptions = ConnectOptions(token: tokenModel.token) { (builder) in
            builder.roomName = self.tokenModel.roomName
        }
        room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
    }
    
    private func renderRemoteParticipant(participant : RemoteParticipant) -> Bool {
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
    
    private func setupRemoteVideoView() {
        self.remoteView = VideoView(frame: CGRect.zero, delegate: self)
        self.remoteView!.contentMode = .scaleAspectFill;
        self.remoteVideoView.addXibView(view: self.remoteView!)
    }
}

// MARK:- TableViewDataSource
extension LiveStreamViewerVC : UITableViewDataSource {
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

// MARK:- VideoViewDelegate
extension LiveStreamViewerVC : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK:- RoomDelegate
extension LiveStreamViewerVC : RoomDelegate {
    func roomDidConnect(room: Room) {
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
        if participant.identity.contains("host_") {
            self.room!.disconnect()
        }
    }
}

// MARK:- RemoteParticipantDelegate
extension LiveStreamViewerVC : RemoteParticipantDelegate {
    
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
            //            cleanupRemoteParticipant()
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

// MARK: - TwilioChatClientDelegate
extension LiveStreamViewerVC : TwilioChatClientDelegate {
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
            ChannelManager.sharedManager.populateChannels()
            guard let channels = client.channelsList() else {
                return
            }
            channels.channel(withSidOrUniqueName: tokenModel.roomName) { result, channel in
                if result.isSuccessful() {
                    channel?.join(completion: { channelResult in
                        self.hideLoading()
                        if channelResult.isSuccessful() {
                            self._channel = channel
                            print("Channel joined.")
                        } else {
                            self.showAlertWithMessage(msg:"Channel NOT joined.")
                        }
                    })
                } else {
                    self.hideLoading()
                    self.showAlertWithMessage(msg: "Something wrong")
                }
            }
        }
        self.delegate?.chatClient(client, synchronizationStatusUpdated: status)
    }
}
// MARK: - TCHChannelDelegate
extension LiveStreamViewerVC: TCHChannelDelegate {
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageAdded message: TCHMessage) {
        print("aaaaaaaaa")
        if let msg: String = message.body, let author: String = message.author {
            let json = JSON(parseJSON: msg)
            let obj = ChatTextModel(json: json)
            if obj.type == .Message {
                let dict = ["name": "\(author)", "text": obj.message!]
                self.textMsg.append(dict)
            } else if obj.type == .Like {
                likeAnimationView.animate(icon: #imageLiteral(resourceName: "icon_like"))
            } else {
                let point = (Int(obj.message) ?? 1)
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


