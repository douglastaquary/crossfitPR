//
//  InsightsStore.swift
//  CrossfitPR
//
//  Created by Douglas Taquary on 25/04/22.
//

import Foundation
import SwiftUI
import Combine
import CoreData
import SwiftUICharts

final class InsightsStore: ObservableObject {
    @Published var biggestPoint: DataPoint = DataPoint.init(value: 0.0, label: "", legend: Legend(color: .green, label: "", order: 1))
    @Published var evolutionPoint: DataPoint = DataPoint.init(value: 0.0, label: "", legend: Legend(color: .yellow, label: "", order: 2))
    @Published var lowPoint: DataPoint = DataPoint.init(value: 0.0, label: "", legend: Legend(color: .gray, label: "", order: 3))
    
    @Published var limit: DataPoint = DataPoint(value: 0, label: "", legend: Legend(color: .clear, label: ""))
    @Published var barPoints: [DataPoint] = []
    @Published var biggestPRName: String = ""
    @Published var biggestPR: PersonalRecord?
    @Published private var dataManager: DataManager?
    
    // Barbell
    @Published var barbellBiggestPRName: String = ""
    @Published var barbellBiggestRecord: PersonalRecord?
    @Published var barbellRecords: [PersonalRecord] = []
    @Published var barbellBarPoints: [DataPoint] = []
    @Published var barbellBiggestPoint: DataPoint = DataPoint.init(value: 0.0, label: "", legend: Legend(color: .green, label: "", order: 1))
    @Published var barbellEvolutionPoint: DataPoint = DataPoint.init(value: 0.0, label: "", legend: Legend(color: .yellow, label: "", order: 2))
    @Published var barbellLowPoint: DataPoint = DataPoint.init(value: 0.0, label: "", legend: Legend(color: .gray, label: "", order: 3))
    
    // Gymnastic
    @Published var gymnasticRecords: [PersonalRecord] = []
    @Published var gymnasticBiggestPRName: String = ""
    @Published var gymnasticBiggestRecord: PersonalRecord?
    @Published var hangstandWalkPoint: DataPoint = DataPoint.init(value: 0.0, label: "", legend: Legend(color: .orange, label: "", order: 4))
    //@Published var barbellBarPoints: [DataPoint] = []
    @Published var gymnasticBiggestPoint: DataPoint = DataPoint.init(value: 0.0, label: "", legend: Legend(color: .green, label: "", order: 1))
    @Published var gymnasticEvolutionPoint: DataPoint = DataPoint.init(value: 0.0, label: "", legend: Legend(color: .yellow, label: "", order: 2))
    @Published var gymnasticLowPoint: DataPoint = DataPoint.init(value: 0.0, label: "", legend: Legend(color: .gray, label: "", order: 3))
    
    
    
    
    @Published var enduranceRecords: [PersonalRecord] = []
    
    
    
    private let defaults: UserDefaults
    let biggestPr = Legend(color: .green, label: "PR Biggest", order: 3)
    
    var anyCancellable: AnyCancellable? = nil
    var measureTrackingMode: MeasureTrackingMode {
        get {
            return defaults.string(forKey: SettingStoreKeys.measureTrackingMode)
                .flatMap { MeasureTrackingMode(rawValue: $0) } ?? .pounds
        }
    }
    
    var isPro: Bool {
        set { defaults.set(newValue, forKey: SettingStoreKeys.pro) }
        get { defaults.bool(forKey: SettingStoreKeys.pro) }
    }
    
    var records: [PersonalRecord] {
        if let records = dataManager?.recordsArray {
            return records
        }
        return []
    }
    
    init(dataManager: DataManager = DataManager.shared, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.dataManager = dataManager

        anyCancellable = dataManager.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
            
        }
        loadBarbellRecords()
        loadBabellHorizontalBar()
        loadGymnasticRecords()
        //loadPRInfos()
    }
    
    // Barbell methods
    
    func loadBarbellRecords() {
        barbellRecords = getAllRecordsFor(recordGroup: .barbell)
//        if measureTrackingMode == .pounds {
//            let max: Int = barbellRecords.map { $0.poundValue }.max() ?? 0
//            barbellBarPoints = barbellRecords.map { pr in
//                if pr.poundValue == max {
//                    self.limit = DataPoint(value: Double(max) , label: "\(pr.prName)", legend: biggestPr)
//                }
//                return DataPoint.init(value: Double(pr.poundValue), label: "", legend: validateCategoryInformationPounds(pr))
//            }
//        } else {
//            let max: Int = barbellRecords.map { $0.kiloValue }.max() ?? 0
//            barbellBarPoints = barbellRecords.map { pr in
//                if pr.kiloValue == max {
//                    self.limit = DataPoint(value: Double(max) , label: "\(pr.prName)", legend: biggestPr)
//                }
//                return DataPoint.init(value: Double(pr.kiloValue), label: "", legend: validateCategoryInformationKilos(pr))
//            }
//        }
    }
    
    private func loadBabellHorizontalBar() {
        if measureTrackingMode == .pounds {
            let max: Int = barbellRecords.map { $0.poundValue }.max() ?? 0
            let min: Int = barbellRecords.map { $0.poundValue }.min() ?? 0
            let evolutionPRselected = barbellRecords.filter { pr in
                return pr.poundValue < max && pr.poundValue > min && pr.prName != biggestPRName
            }.sorted {
                $0.poundValue > $1.poundValue
            }.first
            
            barbellEvolutionPoint = DataPoint.init(
                value: Double(evolutionPRselected?.poundValue ?? 0),
                label: "\(evolutionPRselected?.poundValue ?? 0) lb",
                legend: Legend(color: .yellow, label: "\(evolutionPRselected?.prName ?? "")", order: 2)
            )
            for pr in barbellRecords {
                if pr.poundValue == max {
                    barbellBiggestPoint = DataPoint.init(
                        value: Double(pr.poundValue),
                        label: "\(pr.poundValue) lb",
                        legend: Legend(color: .green, label: "\(pr.prName)", order: 1)
                    )
                    barbellBiggestPRName = pr.prName
                    barbellBiggestRecord = pr
                } else if pr.poundValue == min {
                    barbellLowPoint = DataPoint.init(
                        value: Double(pr.poundValue),
                        label: "\(pr.poundValue) lb",
                        legend: Legend(color: .gray, label: "\(pr.prName)", order: 3)
                    )
                }
            }
        } else {
            let max: Int = barbellRecords.map { $0.kiloValue }.max() ?? 0
            let min: Int = barbellRecords.map { $0.kiloValue }.min() ?? 0
            let evolutionPRselected = barbellRecords.filter { pr in
                return pr.kiloValue < max && pr.kiloValue > min && pr.prName != biggestPRName
            }.sorted {
                $0.kiloValue > $1.kiloValue
            }.first
            
            evolutionPoint = DataPoint.init(
                value: Double(evolutionPRselected?.kiloValue ?? 0),
                label: "\(evolutionPRselected?.kiloValue ?? 0) kg",
                legend: Legend(color: .yellow, label: "\(evolutionPRselected?.prName ?? "")", order: 2)
            )
            for pr in barbellRecords {
                if pr.kiloValue == max {
                    biggestPoint = DataPoint.init(
                        value: Double(pr.kiloValue),
                        label: "\(pr.kiloValue) kg",
                        legend: Legend(color: .green, label: "\(pr.prName)", order: 1)
                    )
                    barbellBiggestPRName = pr.prName
                    barbellBiggestRecord = pr
                } else if pr.kiloValue == min {
                    lowPoint = DataPoint.init(
                        value: Double(pr.kiloValue),
                        label: "\(pr.kiloValue) kg",
                        legend: Legend(color: .gray, label: "\(pr.prName)", order: 3)
                    )
                }
            }
        }
    }
    
    // Gymnastic methods
    
    func loadGymnasticRecords() {
        gymnasticRecords = getAllRecordsFor(recordGroup: .gymnastic)
        let maxRepsRecords = gymnasticRecords.filter { record in
            if let recordMode = record.recordMode {
                return recordMode.rawValue.contains(RecordMode.maxRepetition.rawValue)
            }
            return false
        }
        let maxGymnastic: Int = maxRepsRecords.map { $0.maxReps }.max() ?? 0
        let minGymnastic: Int = maxRepsRecords.map { $0.maxReps }.min() ?? 0
        let handstandWalk = gymnasticRecords.filter { record in
            if let recordMode = record.recordMode {
                return recordMode.rawValue.contains(RecordMode.maxDistance.rawValue)
            }
            return false
        }.first ?? PersonalRecord()
        
        hangstandWalkPoint = DataPoint.init(
            value: Double(handstandWalk.distance),
            label: "\(handstandWalk.distance) km",
            legend: Legend(color: .yellow, label: "\(handstandWalk.prName)", order: 4)
        )
        
        let maxRepEvolution = maxRepsRecords.filter { pr in
            return pr.maxReps < maxGymnastic && pr.maxReps > minGymnastic //&& pr.prName != biggestPRName
        }.sorted {
            $0.maxReps > $1.maxReps
        }.first

        gymnasticEvolutionPoint = DataPoint.init(
            value: Double(maxRepEvolution?.maxReps ?? 0),
            label: "\(maxRepEvolution?.maxReps ?? 0) reps",
            legend: Legend(color: .yellow, label: "\(maxRepEvolution?.prName ?? "")", order: 2)
        )
        for pr in maxRepsRecords {
            if pr.maxReps == maxGymnastic {
                gymnasticBiggestPoint = DataPoint.init(
                    value: Double(pr.maxReps),
                    label: "\(pr.maxReps) reps",
                    legend: Legend(color: .green, label: "\(pr.prName)", order: 1)
                )
                barbellBiggestPRName = pr.prName
                barbellBiggestRecord = pr
            } else if pr.maxReps == minGymnastic {
                gymnasticLowPoint = DataPoint.init(
                    value: Double(pr.maxReps),
                    label: "\(pr.maxReps) reps",
                    legend: Legend(color: .gray, label: "\(pr.prName)", order: 3)
                )
            }
        }
        
    }
    
    func loadGymnasticHorizontalBars() {
        let max: Int = gymnasticRecords.map { $0.poundValue }.max() ?? 0
        let min: Int = barbellRecords.map { $0.poundValue }.min() ?? 0
        let evolutionPRselected = barbellRecords.filter { pr in
            return pr.poundValue < max && pr.poundValue > min && pr.prName != biggestPRName
        }.sorted {
            $0.poundValue > $1.poundValue
        }.first
        
        barbellEvolutionPoint = DataPoint.init(
            value: Double(evolutionPRselected?.poundValue ?? 0),
            label: "\(evolutionPRselected?.poundValue ?? 0) lb",
            legend: Legend(color: .yellow, label: "\(evolutionPRselected?.prName ?? "")", order: 2)
        )
        for pr in barbellRecords {
            if pr.poundValue == max {
                barbellBiggestPoint = DataPoint.init(
                    value: Double(pr.poundValue),
                    label: "\(pr.poundValue) lb",
                    legend: Legend(color: .green, label: "\(pr.prName)", order: 1)
                )
                barbellBiggestPRName = pr.prName
                barbellBiggestRecord = pr
            } else if pr.poundValue == min {
                barbellLowPoint = DataPoint.init(
                    value: Double(pr.poundValue),
                    label: "\(pr.poundValue) lb",
                    legend: Legend(color: .gray, label: "\(pr.prName)", order: 3)
                )
            }
        }
    }
    
    
    // Endurance methods
    func loadEnduranceRecords() {
        enduranceRecords = getAllRecordsFor(recordGroup: .endurance)
    }
    
    private func getAllRecordsFor(recordGroup: RecordGroup) -> [PersonalRecord] {
        let groupRecords = self.records.filter { record in
            if let group = record.group {
                return group.rawValue.contains(recordGroup.rawValue)
            }
            return false
        }
        let records = groupRecords.sorted(by: {$0.recordDate?.compare($1.recordDate ?? Date()) == .orderedAscending })
        return records
    }

    private func loadBarbellGraph() {
        if measureTrackingMode == .pounds {
            let max: Int = records.map { $0.poundValue }.max() ?? 0
            barPoints = records.map { pr in
                if pr.poundValue == max {
                    self.limit = DataPoint(value: Double(max) , label: "\(pr.prName)", legend: biggestPr)
                }
                return DataPoint.init(value: Double(pr.poundValue), label: "", legend: validateCategoryInformationPounds(pr))
            }
        } else {
            let max: Int = records.map { $0.kiloValue }.max() ?? 0
            barPoints = records.map { pr in
                if pr.kiloValue == max {
                    self.limit = DataPoint(value: Double(max) , label: "\(pr.prName)", legend: biggestPr)
                }
                return DataPoint.init(value: Double(pr.kiloValue), label: "", legend: validateCategoryInformationKilos(pr))
            }
        }

    }
    
    func loadPRInfos() {
        //loadGraph()
        if measureTrackingMode == .pounds {
            let max: Int = records.map { $0.poundValue }.max() ?? 0
            let min: Int = records.map { $0.poundValue }.min() ?? 0
            let evolutionPRselected = records.filter { pr in
                return pr.poundValue < max && pr.poundValue > min && pr.prName != biggestPRName
            }.sorted {
                $0.poundValue > $1.poundValue
            }.first
            
            evolutionPoint = DataPoint.init(
                value: Double(evolutionPRselected?.poundValue ?? 0),
                label: "\(evolutionPRselected?.poundValue ?? 0) lb",
                legend: Legend(color: .yellow, label: "\(evolutionPRselected?.prName ?? "")", order: 2)
            )
            for pr in records {
                if pr.poundValue == max {
                    biggestPoint = DataPoint.init(
                        value: Double(pr.poundValue),
                        label: "\(pr.poundValue) lb",
                        legend: Legend(color: .green, label: "\(pr.prName)", order: 1)
                    )
                    biggestPRName = pr.prName
                    biggestPR = pr
                } else if pr.poundValue == min {
                    lowPoint = DataPoint.init(
                        value: Double(pr.poundValue),
                        label: "\(pr.poundValue) lb",
                        legend: Legend(color: .gray, label: "\(pr.prName)", order: 3)
                    )
                }
            }
        } else {
            let max: Int = records.map { $0.kiloValue }.max() ?? 0
            let min: Int = records.map { $0.kiloValue }.min() ?? 0
            let evolutionPRselected = records.filter { pr in
                return pr.kiloValue < max && pr.kiloValue > min && pr.prName != biggestPRName
            }.sorted {
                $0.kiloValue > $1.kiloValue
            }.first
            
            evolutionPoint = DataPoint.init(
                value: Double(evolutionPRselected?.kiloValue ?? 0),
                label: "\(evolutionPRselected?.kiloValue ?? 0) kg",
                legend: Legend(color: .yellow, label: "\(evolutionPRselected?.prName ?? "")", order: 2)
            )
            for pr in records {
                if pr.kiloValue == max {
                    biggestPoint = DataPoint.init(
                        value: Double(pr.kiloValue),
                        label: "\(pr.kiloValue) kg",
                        legend: Legend(color: .green, label: "\(pr.prName)", order: 1)
                    )
                    biggestPRName = pr.prName
                    biggestPR = pr
                } else if pr.kiloValue == min {
                    lowPoint = DataPoint.init(
                        value: Double(pr.kiloValue),
                        label: "\(pr.kiloValue) kg",
                        legend: Legend(color: .gray, label: "\(pr.prName)", order: 3)
                    )
                }
            }
        }
    }
    
    private func validateCategoryInformationPounds(_ pr: PersonalRecord) -> Legend {
        let max: Int = records.map { $0.poundValue }.max() ?? 0
        let min: Int = records.map { $0.poundValue }.min() ?? 0
        let biggestPr = Legend(color: .green, label: "PR Biggest", order: 3)
        let evolutionPr = Legend(color: .yellow, label: "PR Evolution", order: 2)
        let lowestRecord = Legend(color: .gray, label: "PR Lowest", order: 1)
        if pr.poundValue >= max {
            return biggestPr
        } else if pr.poundValue == min {
            return lowestRecord
        } else {
            return evolutionPr
        }
    }
    
    private func validateCategoryInformationKilos(_ pr: PersonalRecord) -> Legend {
        let max: Int = records.map { $0.kiloValue }.max() ?? 0
        let min: Int = records.map { $0.kiloValue }.min() ?? 0
        let biggestPr = Legend(color: .green, label: "PR Biggest", order: 3)
        let evolutionPr = Legend(color: .yellow, label: "PR Evolution", order: 2)
        let lowestRecord = Legend(color: .gray, label: "PR Lowest", order: 1)
        if pr.kiloValue >= max {
            return biggestPr
        } else if pr.kiloValue == min {
            return lowestRecord
        } else {
            return evolutionPr
        }
    }
}

extension InsightsStore {
    func unlockPro() {
        // You can do your in-app transactions here
        isPro = true
    }

    func restorePurchase() {
        // You can do you in-app purchase restore here
        isPro = false
    }
}
