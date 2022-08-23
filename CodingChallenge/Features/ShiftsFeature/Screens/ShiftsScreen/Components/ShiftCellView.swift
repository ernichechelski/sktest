//
//  ShiftCellView.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import SwiftUI

/// Component for brief description of Shift. Used for cells.
struct ShiftCellView: View {
    
    struct ComponentModel: Equatable {
        /// Title on the top of the cell.
        let titleText: String
        /// Subtitle on the bottom of the cell.
        let subtitleText: String
        /// Icon on the right of the cell.
        let icon: Image
    }
    
    @Binding var componentModel: ComponentModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(componentModel.titleText).font(.title3)
                Text(componentModel.subtitleText).font(.subheadline)
            }
            Spacer()
            componentModel.icon
        }
    }
}

extension ShiftCellView.ComponentModel {
    
    /// Inits model from the `ShiftDisplayable`.
    init(viewModel: ShiftsScreenViewModel.ViewState.Ready.ShiftDisplayable) {
        titleText = viewModel.shiftKind
        subtitleText = "\(viewModel.timeText) \(viewModel.timezoneText)"
        icon = viewModel.isPremiumRate ? Image(systemName: "dollarsign.square") : Image(systemName: "figure.stand")
    }
}

