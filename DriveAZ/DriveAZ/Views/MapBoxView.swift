//
//  MapBoxView.swift
//  DriveAZ
//
//  Created by Ben on 3/18/25.
//

import SwiftUI
import MapKit
import CoreLocation
import B2VExtras
import B2VExtrasSwift
@_spi(Experimental) import MapboxMaps

struct OtherMapBoxView: View {
    // Initializes viewport state as styleDefault,
    // which will use the default camera for the current style.
    @State var viewport: Viewport = .followPuck(zoom: 16, bearing: .course ,pitch: 60)


    var body: some View {
        VStack {
            // Passes the viewport binding to the map.
            Map(viewport: $viewport)
        }
    }
    
    
    init() {
        let key = Bundle.main.object(forInfoDictionaryKey: "DAZ_MAPBOX_KEY") as? String
        MapboxOptions.accessToken = key!
        print("Mapbox key is", key)

    }
}
