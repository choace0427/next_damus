//
//  Post.swift
//  damus
//
//  Created by William Casarin on 2022-04-03.
//

import SwiftUI

enum NostrPostResult {
    case post(NostrPost)
    case cancel
}

struct PostView: View {
    @State var post: String = ""
    @FocusState var focus: Bool
    let references: [ReferencedId]
    
    @Environment(\.presentationMode) var presentationMode

    enum FocusField: Hashable {
      case post
    }

    func cancel() {
        NotificationCenter.default.post(name: .post, object: NostrPostResult.cancel)
        dismiss()
    }
    
    func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    }

    func send_post() {
        let new_post = NostrPost(content: self.post, references: references)
        NotificationCenter.default.post(name: .post, object: NostrPostResult.post(new_post))
        dismiss()
    }

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    self.cancel()
                }
                .foregroundColor(.primary)

                Spacer()

                Button("Post") {
                    self.send_post()
                }
            }
            .padding([.top, .bottom], 4)

            HStack(alignment: .top) {
                ZStack(alignment: .leading) {
                    if self.post == "" {
                        VStack {
                            Text("What's happening?")
                                .foregroundColor(.gray)
                                .padding(6)
                            Spacer()
                        }
                    }
                    
                    TextEditor(text: $post)
                        .focused($focus)
                }


                Spacer()
            }

            Spacer()
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.focus = true
            }
        }
        .padding()
    }
}

