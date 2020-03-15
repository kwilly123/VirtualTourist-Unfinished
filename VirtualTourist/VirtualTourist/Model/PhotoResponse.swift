//
//  PhotoResponse.swift
//  VirtualTourist
//
//  Created by Kyle Wilson on 2020-03-13.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation

struct PhotoResponse: Codable {
    let photos: Photos
    let stat: String
}
