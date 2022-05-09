//
//  ProfilePicView.swift
//  damus
//
//  Created by William Casarin on 2022-04-16.
//

import SwiftUI

let PFP_SIZE: CGFloat? = 52.0
let CORNER_RADIUS: CGFloat = 32

func id_to_color(_ id: String) -> Color {
    return hex_to_rgb(id)
}

func highlight_color(_ h: Highlight) -> Color {
    switch h {
    case .main: return Color.red
    case .reply: return Color.black
    case .none: return Color.black
    case .custom(let c, _): return c
    }
}

func pfp_line_width(_ h: Highlight) -> CGFloat {
    switch h {
    case .reply: return 0
    case .none: return 0
    case .main: return 2
    case .custom(_, let lw): return CGFloat(lw)
    }
}

struct ProfilePicView: View {
    let pubkey: String
    let size: CGFloat
    let highlight: Highlight
    let image_cache: ImageCache
    let profiles: Profiles
    
    @State var picture: String? = nil
    @State var img: Image? = nil
    
    var PlaceholderColor: Color {
        return id_to_color(pubkey)
    }
    
    var Placeholder: some View {
        PlaceholderColor.opacity(0.5)
            .frame(width: size, height: size)
            .cornerRadius(CORNER_RADIUS)
            .overlay(Circle().stroke(highlight_color(highlight), lineWidth: pfp_line_width(highlight)))
            .padding(2)
    }
    
    func ProfilePic(_ url: URL) -> some View {
        let pub = load_image(cache: image_cache, from: url)
        return Group {
            if let img = self.img {
                img
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(highlight_color(highlight), lineWidth: pfp_line_width(highlight)))
                    .padding(2)
            } else {
                Placeholder
            }
        }
        .onReceive(pub) { mimg in
            if let img = mimg {
                self.img = Image(uiImage: img)
            }
        }
    }
    
    var MainContent: some View {
        Group {
            let picture = picture ?? profiles.lookup(id: pubkey)?.picture
            if let pic_url = picture.flatMap { URL(string: $0) } {
                ProfilePic(pic_url)
            } else {
                Placeholder
            }
        }
    }
    
    var body: some View {
        MainContent
            .onReceive(handle_notify(.profile_updated)) { notif in
                let updated = notif.object as! ProfileUpdate
                if updated.pubkey != pubkey {
                    return
                }
                
                if updated.profile.picture != picture {
                    picture = updated.profile.picture
                }
            }
    }
}

/*
struct ProfilePicView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePicView(picture: "http://cdn.jb55.com/img/red-me.jpg", size: 64, highlight: .none)
    }
}
 */
    

func hex_to_rgb(_ hex: String) -> Color {
    guard hex.count >= 6 else {
        return Color.black
    }
    
    let arr = Array(hex.utf8)
    var rgb: [UInt8] = []
    var i: Int = 0
    
    while i < 6 {
        let cs1 = arr[i]
        let cs2 = arr[i+1]
        
        guard let c1 = char_to_hex(cs1) else {
            return Color.black
        }

        guard let c2 = char_to_hex(cs2) else {
            return Color.black
        }
        
        rgb.append((c1 << 4) | c2)
        i += 2
    }

    return Color.init(
        .sRGB,
        red: Double(rgb[0]) / 255,
        green: Double(rgb[1]) / 255,
        blue:  Double(rgb[2]) / 255,
        opacity: 1
    )
}
