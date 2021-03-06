/*
 * Copyright @ 2018-present Atlassian Pty Ltd
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import AVKit
import CallKit
import Foundation

internal final class JMCallKitEmitter: NSObject, CXProviderDelegate {

    private let listeners = NSMutableArray()

    internal override init() {}

    // MARK: - Add/remove listeners

    func addListener(_ listener: JMCallKitListener) {
        if (!listeners.contains(listener)) {
            listeners.add(listener)
        }
    }

    func removeListener(_ listener: JMCallKitListener) {
        listeners.remove(listener)
    }

    // MARK: - CXProviderDelegate

    func providerDidReset(_ provider: CXProvider) {
        listeners.forEach {
            let listener = $0 as! JMCallKitListener
            listener.providerDidReset?()
        }
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        listeners.forEach {
            let listener = $0 as! JMCallKitListener
            listener.performAnswerCall?(UUID: action.callUUID)
        }

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        listeners.forEach {
            let listener = $0 as! JMCallKitListener
            listener.performEndCall?(UUID: action.callUUID)
        }

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        listeners.forEach {
            let listener = $0 as! JMCallKitListener
            listener.performSetMutedCall?(UUID: action.callUUID, isMuted: action.isMuted)
        }

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        listeners.forEach {
            let listener = $0 as! JMCallKitListener
            listener.performStartCall?(UUID: action.callUUID, isVideo: action.isVideo)
        }

        action.fulfill()
    }

    func provider(_ provider: CXProvider,
                  didActivate audioSession: AVAudioSession) {
        listeners.forEach {
            let listener = $0 as! JMCallKitListener
            listener.providerDidActivateAudioSession?(session: audioSession)
        }
    }

    func provider(_ provider: CXProvider,
                  didDeactivate audioSession: AVAudioSession) {
        listeners.forEach {
            let listener = $0 as! JMCallKitListener
            listener.providerDidDeactivateAudioSession?(session: audioSession)
        }
    }
}
