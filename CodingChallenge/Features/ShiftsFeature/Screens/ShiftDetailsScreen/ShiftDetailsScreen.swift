//
//  ShiftDetailsScreen.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import SwiftUI

/// Screen containing detailed description of Shift.
/// This is an example how simpler components/screens can look like.
// TODO: - Complete documentation for this component.
// TODO: - Localise text.
// TODO: - Update UI to be more nice.
struct ShiftDetailsScreen: View {
    struct ComponentModel: Equatable {
        let titleText: String
        let subtitleText: String

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
            VStack(alignment: .leading, spacing: Constants.detailsSpacing) {
                Text(componentModel.subtitleText).font(.subheadline)
                VStack(alignment: .leading, spacing: Constants.innerSpacing) {
                    Text("Time description").font(.body).fontWeight(.bold)
                    Text(componentModel.normalizedTimeText).font(.body)
                }
                VStack(alignment: .leading, spacing: Constants.innerSpacing) {
                    Text("Normalized time").font(.body).fontWeight(.bold)
                    Text(componentModel.normalizedTimeText).font(.body)
                }
                VStack(alignment: .leading, spacing: Constants.innerSpacing) {
                    Text("Skill").font(.body).fontWeight(.bold)
                    Text(componentModel.skillText).font(.body)
                }
                VStack(alignment: .leading, spacing: Constants.innerSpacing) {
                    Text("Localized specialty").font(.body).fontWeight(.bold)
                    Text(componentModel.localizedSpecialtyText).font(.body)
                }
            }
            .multilineTextAlignment(.leading)
        }
        .navigationTitle(componentModel.titleText)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button(
                action: {
                    onEvent?(.onDismiss)
                },
                label: {
                    Image(systemName: "xmark")
                }
            )
        )
    }
}

private extension ShiftDetailsScreen {
    enum Constants {
        static let detailsSpacing: CGFloat = 10
        static let innerSpacing: CGFloat = 5
    }
}

// MARK: Component model mappings.

extension ShiftDetailsScreen.ComponentModel {
    /// Inits the model from the `Shift` model.
    init(shiftModel: Shift, timeManager _: AppTimeManager) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        titleText = "Shift \(shiftModel.shiftID)"
        subtitleText = "\(dateFormatter.string(from: shiftModel.startTime))-\(dateFormatter.string(from: shiftModel.endTime))"

        normalizedTimeText = "\(dateFormatter.string(from: shiftModel.normalizedStartDateTime))-\(dateFormatter.string(from: shiftModel.normalizedEndDateTime))"
        timezone = shiftModel.timezone

        image = shiftModel.premiumRate ? Image(systemName: "dollarsign.square") : Image(systemName: "figure.stand")
        shiftKind = shiftModel.shiftKind
        withinDistance = shiftModel.withinDistance.flatMap { "\($0)" } ?? ""
        facilityText = shiftModel.facilityType.name
        skillText = shiftModel.skill.name
        localizedSpecialtyText = shiftModel.localizedSpecialty.name
    }
}
