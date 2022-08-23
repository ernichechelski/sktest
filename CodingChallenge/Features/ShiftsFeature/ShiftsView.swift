//
//  ShiftsView.swift
//  CodingChallenge
//
//  Created by Brady Miller on 4/7/21.
//

import SwiftUI

/// View containing `ShiftsFeature`.
struct ShiftsView: View {
    
    @StateObject var shiftsManager = ShiftsManager()
    
    var body: some View {
        NavigatorView(
            navigator: shiftsManager.navigator
        )
    }
}

struct ShiftsView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftsView()
    }
}
