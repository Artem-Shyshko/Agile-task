//
//  AppIntent.swift
//  MasterTaskWidget
//
//  Created by Artur Korol on 11.12.2023.
//

import WidgetKit
import AppIntents

enum WidgetTheme: String, AppEnum {
    case aquamarine, day, night

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Refresh Interval"
    static var caseDisplayRepresentations: [WidgetTheme : DisplayRepresentation] = [
        .aquamarine: "Aquamarine",
        .day: "Day",
        .night: "Night",
    ]
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    @Parameter(title: "Theme", default: .aquamarine)
    var selectedTheme: WidgetTheme
}

