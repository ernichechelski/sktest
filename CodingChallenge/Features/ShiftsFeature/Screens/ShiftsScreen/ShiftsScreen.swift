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
            case .loading:
                ProgressView("Loading")
            case let .error(text):
                Text(text).foregroundColor(.red)
            case let .ready(state):
                readyContents(ready: state)
            }
        }
        .navigationBarHidden(true)
        .navigationTitle("")
        .onAppear {
            viewModel.send(action: .viewDidAppear)
        }
    }
    
    @ViewBuilder func readyContents(ready state: ShiftsScreenViewModel.ViewState.Ready) -> some View{
        List {
            ForEach(state.shifts) { shift in
                Button {
                    viewModel.send(action: .itemSelected(item: shift))
                } label: {
                    ShiftCellView(
                        componentModel: .constant(
                            ShiftCellView.ComponentModel(viewModel: shift)
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
    }
}
