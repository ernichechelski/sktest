//
//  ShiftsRepository.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Foundation
import Combine

protocol ShiftsDataSource {
    
    var currentValue: [Shift] { get }
    
    func shiftsSource() -> AnyPublisher<[Shift], Never>
    func fetchInitial() -> AnyPublisher<Void, Error>
    func fetchNext() -> AnyPublisher<Void, Error>
}


final class DefaultShiftsDataSource: ShiftsDataSource {
    
    enum DefaultShiftsDataSourceError: LocalizedError {
        case cannotCreateDates
    }
    
    var currentValue: [Shift] { value.value }
    
    private lazy var selectedDate: Date = timeManager.now
    
    private var timeManager: AppTimeManager = AppRealTimeManager()
    
    private var shiftsRepository: ShiftsRepository = ShiftsRepository()
    
    private var value = CurrentValueSubject<[Shift], Never>([])
    
    func shiftsSource() -> AnyPublisher<[Shift], Never> {
        value.eraseToAnyPublisher()
    }
    
    
    var currentStartDate: Date? {
        if timeManager.now.compare(selectedDate) == .orderedAscending {
            return timeManager.now
        } else {
            return selectedDate.startOfWeek(timeManager: timeManager)?.startOfDay(timeManager: timeManager)
        }
    }
    
    var currentEndDate: Date? {
        currentStartDate?.endOfWeek(timeManager: timeManager)?.endOfDay(timeManager: timeManager)
    }
    
    func fetchInitial() -> AnyPublisher<Void, Error> {
        selectedDate = timeManager.now
        return fetchWithSelectedDate()
    }
    
    func fetchWithSelectedDate() -> AnyPublisher<Void, Error> {
        guard
            let startDate = currentStartDate,
            let endDate = currentEndDate
        else {
            return Fail(outputType: Void.self, failure: DefaultShiftsDataSourceError.cannotCreateDates).eraseToAnyPublisher()
        }
        
        return shiftsRepository.fetchShifts(
            responseType: .week,
            start: startDate,
            end: endDate,
            address: "Dallas, TX",
            radius: nil
        )
        .handleEvents(
            receiveOutput: { [weak self] nextValue in
                guard let self = self else { return }
                self.value.send(nextValue + self.value.value)
            }
        )
        .eraseToAnyPublisher()
        .mapToVoid()
    }
    
    func fetchNext() -> AnyPublisher<Void, Error> {
        selectedDate = selectedDate.byAdding(value: 1, component: .weekOfYear, timeManager: timeManager)
        return fetchWithSelectedDate()
    }
}

/// Component conforming to this protocol should
/// return useful data about current time and place.
/// Because the user can change the timezone data provided from this
/// component should be processed at every request or display the data
/// (The timezone or locale cannot be cached somewhere).
protocol AppTimeManager {
    /// Returns computing timezone.
    var timezone: TimeZone { get set }
    /// Returns computing locale.
    var locale: Locale { get set }
    /// Returns computing current date.
    var now: Date { get }
    /// Returns current calendar domain
    var calendar: Calendar { get }
}


final class AppRealTimeManager: AppTimeManager {
    var timezone = TimeZone.autoupdatingCurrent
    var locale = Locale.autoupdatingCurrent
    var now: Date { Date() }
    private(set) var calendar: Calendar

    init() {
        var systemCalendar: Calendar = .autoupdatingCurrent
        systemCalendar.firstWeekday = 2
        calendar = systemCalendar
    }
}

final class AppPreviewTimeManager: AppTimeManager {
    var timezone = TimeZone.current
    var locale = Locale.current
    var now: Date {
        Date(timeIntervalSince1970: 1648807200) // First April 2022
    }

    private(set) var calendar: Calendar

    init() {
        var systemCalendar: Calendar = .current
        systemCalendar.firstWeekday = 2
        calendar = systemCalendar
    }
}


extension Date {
    
    /// Returns start of the week date.
    func startOfWeek(timeManager: AppTimeManager) -> Date? {
        let weekNumber = timeManager.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return timeManager.calendar.date(from: weekNumber)
    }

    /// Returns end of the week date.
    func endOfWeek(timeManager: AppTimeManager) -> Date? {
        guard let start = startOfWeek(timeManager: timeManager) else { return nil }
        return timeManager.calendar.date(byAdding: .day, value: 6, to: start)
    }

    /// Returns start of day date.
   func startOfDay(timeManager: AppTimeManager) -> Date {
       timeManager.calendar.startOfDay(for: self)
   }
    
    func byAdding(value: Int, component: Calendar.Component, timeManager: AppTimeManager) -> Date {
        timeManager.calendar.date(byAdding: component, value: value, to: self) ?? timeManager.now
    }


   /// Returns end of day date.
   func endOfDay(timeManager: AppTimeManager) -> Date {
       guard let nextDayDate = timeManager.calendar.date(
           byAdding: .day,
           value: 1,
           to: startOfDay(timeManager: timeManager)
       ) else {
           preconditionFailure("This should never fail")
       }
       return nextDayDate.addingTimeInterval(-1)
   }
}


final class ShiftsRepository {
    
    enum ResponseType: String {
        case week
        case fourDay = "4Day"
        case list
    }
    
    private let formatterISO8601 = ISO8601DateFormatter()
    
    private let dayMonthYearFormatter = with(DateFormatter()) {
        $0.dateFormat = "YYYY-MM-DD"
    }
    
    
    private let dayMonthDateTimeYearFormatter = with(DateFormatter()) {
        $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }

    
    /// Requests the API services for data about shifts.
    /// - Parameters:
    ///   - responseType: Response type.
    ///   - start: Etart date/datetime.
    ///   - end:  End date/datetime. Only applicable when type query param is list.
    ///   - address: Address to serve as the search location. Disregarded if lat and lng are provided. A 422 is returned if the address cannot be geo-coded.
    ///   - radius: Distance from lat/lng or address to be used in the shift search. Defaults to 150 if nil. Distance is in miles.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    func fetchShifts(
        responseType: ResponseType?,
        start: Date?,
        end: Date?,
        address: String,
        radius: Float?
    ) -> AnyPublisher<[Shift], Error> {
        shiftsData(
            responseType: responseType,
            start: start,
            end: end,
            address: address,
            radius: radius
        )
        .tryMap { [weak self] shiftsDaysResponse in
            guard let self = self else {
                throw AppError.arc
            }
            
            return try Array(shiftsDaysResponse.data.flatMap { shiftsDayResponse in
                try shiftsDayResponse.shifts.map { shiftResponse in
                    try self.map(shiftResponse: shiftResponse)
                }
            }.prefix(upTo: 15))
        }
        .eraseToAnyPublisher()
    }
}

private extension ShiftsRepository {
    
    enum ShiftsRepositoryError: LocalizedError {
        case wrongDateFormat(text: String)
    
        var errorDescription: String? {
            switch self {
            case let .wrongDateFormat(text): return "App could not load the data from external server \(text)" // TODO: - Place into localisables
            }
        }

        var recoverySuggestion: String? {
            "Contact support" // TODO: - Place into localisables
        }
    }
    
    struct ResponseContainer<T: Codable>: Codable {
        let data: T
    }
    
    struct ShiftsDay: Codable {
        let date: String
        let shifts: [ShiftResponse]
    }

    // MARK: - Shift
    struct ShiftResponse: Codable {
        let shiftID: Int
        let startTime: String
        let endTime: String
        let normalizedStartDateTime, normalizedEndDateTime, timezone: String
        let premiumRate, covid: Bool
        let shiftKind: String
        let withinDistance: Int?
        let facilityType, skill: FacilityTypeResponse
        let localizedSpecialty: LocalizedSpecialtyResponse

        enum CodingKeys: String, CodingKey {
            case shiftID = "shift_id"
            case startTime = "start_time"
            case endTime = "end_time"
            case normalizedStartDateTime = "normalized_start_date_time"
            case normalizedEndDateTime = "normalized_end_date_time"
            case timezone
            case premiumRate = "premium_rate"
            case covid
            case shiftKind = "shift_kind"
            case withinDistance = "within_distance"
            case facilityType = "facility_type"
            case skill
            case localizedSpecialty = "localized_specialty"
        }
    }

    // MARK: - FacilityType
    struct FacilityTypeResponse: Codable {
        let id: Int
        let name, color: String
        let abbreviation: String?
    }

    // MARK: - LocalizedSpecialty
    struct LocalizedSpecialtyResponse: Codable {
        let id, specialtyID, stateID: Int
        let name, abbreviation: String
        let specialty: FacilityTypeResponse

        enum CodingKeys: String, CodingKey {
            case id
            case specialtyID = "specialty_id"
            case stateID = "state_id"
            case name, abbreviation, specialty
        }
    }
    
    func map(shiftResponse: ShiftResponse) throws -> Shift {
        Shift(
            shiftID: shiftResponse.shiftID,
            startTime: try formatterISO8601
                .date(from: shiftResponse.startTime)
                .throwing(error: ShiftsRepositoryError.wrongDateFormat(text: shiftResponse.startTime)),
            endTime: try formatterISO8601
                .date(from: shiftResponse.endTime)
                .throwing(error: ShiftsRepositoryError.wrongDateFormat(text: shiftResponse.endTime)),
            normalizedStartDateTime: try dayMonthDateTimeYearFormatter
                .date(from: shiftResponse.normalizedStartDateTime)
                .throwing(error: ShiftsRepositoryError.wrongDateFormat(text: shiftResponse.normalizedStartDateTime)),
            normalizedEndDateTime: try dayMonthDateTimeYearFormatter
                .date(from: shiftResponse.normalizedEndDateTime)
                .throwing(error: ShiftsRepositoryError.wrongDateFormat(text: shiftResponse.normalizedEndDateTime)),
            timezone: shiftResponse.timezone,
            premiumRate: shiftResponse.premiumRate,
            covid: shiftResponse.covid,
            shiftKind: shiftResponse.shiftKind,
            withinDistance: shiftResponse.withinDistance,
            facilityType: map(facilityTypeResponse: shiftResponse.facilityType),
            skill: map(facilityTypeResponse: shiftResponse.skill),
            localizedSpecialty: map(localizedSpecialtyResponse: shiftResponse.localizedSpecialty)
        )
    }
    
    func map(facilityTypeResponse: FacilityTypeResponse) -> FacilityType {
        FacilityType(
            id: facilityTypeResponse.id,
            name: facilityTypeResponse.name,
            color: facilityTypeResponse.color,
            abbreviation: facilityTypeResponse.abbreviation
        )
    }
    
    func map(localizedSpecialtyResponse: LocalizedSpecialtyResponse) -> LocalizedSpecialty {
        LocalizedSpecialty(
            id: localizedSpecialtyResponse.id,
            specialtyID: localizedSpecialtyResponse.specialtyID,
            stateID: localizedSpecialtyResponse.stateID,
            name: localizedSpecialtyResponse.name,
            abbreviation: localizedSpecialtyResponse.abbreviation
        )
    }
    
    func shiftsData(
        responseType: ResponseType?,
        start: Date?,
        end: Date?,
        address: String,
        radius: Float?
    ) -> AnyPublisher<ResponseContainer<[ShiftsDay]>, Error> {
        
        let url = URL(string: "https://example.com/endpoint")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var urlComponents = URLComponents(
            string: "https://staging-app.shiftkey.com/api/v2/available_shifts"
        )!
        
        var queryItems = [URLQueryItem]()
        
        responseType.flatMap {
            queryItems.append(URLQueryItem(name: "type", value: $0.rawValue))
        }
        
        start.flatMap {
            queryItems.append(URLQueryItem(name: "start", value: formatterISO8601.string(from: $0)))
        }
        
        
        end.flatMap {
            queryItems.append(URLQueryItem(name: "end", value: formatterISO8601.string(from: $0)))
        }
        
        queryItems.append(URLQueryItem(name: "address", value: address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)))
        
        radius.flatMap {
            queryItems.append(URLQueryItem(name: "end", value: "\($0)"))
        }
        
        urlComponents.queryItems = queryItems
        
        request.url = urlComponents.url
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                return element.data
                }
            .decode(type: ResponseContainer<[ShiftsDay]>.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

