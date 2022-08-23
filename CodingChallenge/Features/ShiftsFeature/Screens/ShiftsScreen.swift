//
//  ShiftsScreen.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 21/08/2022.
//

import SwiftUI

struct ShiftsScreen: View {
    @StateObject var viewModel: ShiftsScreenViewModel

    var body: some View {
        
        VStack {
            switch viewModel.viewState {
            case .loading: ProgressView("Loading")
            case let .error(text):
                Text(text).foregroundColor(.red)
            case let .ready(state):
                if #available(iOS 15.0, *) {
                    List {
                        ForEach(state.shifts) { shift in
                            Button {
                                viewModel.send(action: .itemSelected(item: shift))
                            } label: {
                                ShiftCell(
                                    componentModel: .constant(
                                        ShiftCell.ComponentModel(viewModel: shift)
                                    )
                                )
                            }
                                .onAppear {
                                    if shift == state.shifts.last { // 6
                                        viewModel.send(action: .listScrolledToBottom)
                                    }
                                }
                        }
                        if state.isLoadingMore { // 7
                            ProgressView().frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .refreshable {
                        viewModel.send(action: .viewDidAppear)
                    }
                } else {
                    List(state.shifts) { shift in
                        Text(shift.timeText)
                    }
                }
            }
        }
        .navigationTitle("Shifts")
        .onAppear {
            viewModel.send(action: .viewDidAppear)
        }
    }
}


struct ShiftCell: View {
    
    struct ComponentModel: Equatable {
        let titleText: String
        let subtitleText: String
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

extension ShiftCell.ComponentModel {
    init(viewModel: ShiftsScreenViewModel.ViewState.Ready.ShiftDisplayable) {
        titleText = viewModel.shiftKind
        subtitleText = "\(viewModel.timeText) \(viewModel.timezoneText)"
        icon = viewModel.isPremiumRate ? Image(systemName: "dollarsign.square") : Image(systemName: "figure.stand")
    }
}



struct ShiftDetailsView: View {
    
    struct ComponentModel: Equatable {
        let titleText: String
        let subtitleText: String
        
        let timeDescriptionText: String
        let normalizedTimeText: String
        
        let timezone: String
        let image: Image
        let shiftKind: String
        let withinDistance: String
        let facilityText: String
        let skillText: String
        let localizedSpecialtyText: String
    }
    
    @Binding var componentModel: ComponentModel
    
    var onEvent: ((ShiftsScreensFactoryEvents.DetailsEvent) -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(componentModel.titleText).font(.title)
                Text(componentModel.subtitleText).font(.subheadline)
                HStack {
                    Text("timeDescription").font(.body)
                    Text(componentModel.timeDescriptionText).font(.body)
                }
                HStack {
                    Text("normalizedTime").font(.body)
                    Text(componentModel.normalizedTimeText).font(.body)
                }
                HStack {
                    Text("skill").font(.body)
                    Text(componentModel.skillText).font(.body)
                }
                HStack {
                    Text("localizedSpecialty").font(.body)
                    Text(componentModel.localizedSpecialtyText).font(.body)
                }
            }
        }
        .navigationTitle("Shift Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            onEvent?(.onDismiss)
        }, label: {
            Image(systemName: "xmark")
        }))
    }
}

extension ShiftDetailsView.ComponentModel {
    
    init(shiftModel: Shift) {
        self.titleText = shiftModel.timezone
        self.subtitleText = shiftModel.timezone
        self.timeDescriptionText = shiftModel.startTime.description
        self.normalizedTimeText = ""
        self.timezone = shiftModel.timezone
        self.image = shiftModel.premiumRate ? Image(systemName: "dollarsign.square") : Image(systemName: "figure.stand")
        self.shiftKind = shiftModel.shiftKind
        self.withinDistance = shiftModel.withinDistance.flatMap { "\($0)" } ?? ""
        self.facilityText = shiftModel.facilityType.name
        self.skillText = shiftModel.skill.name
        self.localizedSpecialtyText = shiftModel.localizedSpecialty.name
    }
}
