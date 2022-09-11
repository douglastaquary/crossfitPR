//
//  PRDetailView.swift
//  CrossfitPR
//
//  Created by Douglas Taquary on 04/04/22.
//

import SwiftUI
import SwiftUICharts
import CoreData

struct InsightsView: View {
    @State var showPROsubsciptionView = false
    @EnvironmentObject var store: InsightsStore

    var body: some View {
        if store.records.count > 8 {
            VStack {
                Form {
                    Section("insight.section.ranking.title") {
                        HorizontalBarChartView(dataPoints: [store.biggestPoint, store.evolutionPoint, store.lowPoint])
                    }
                    Section("insight.section.graph.title") {
                        if store.barPoints.isEmpty {
                            Text("insight.view.error.description")
                        } else {
                            BarChartView(dataPoints: store.barPoints, limit: store.limit)
                        }
                    }
                    Section("insight.section.information.title") {
                        let recordTypeName = store.biggestPR?.prName.rawValue ?? ""
                        if store.measureTrackingMode == .pounds {
                            HSubtitleView(
                                title: recordTypeName,
                                subtitle: "\(store.biggestPR?.poundValue ?? 0) lb"
                            )
                        } else {
                            HSubtitleView(
                                title: recordTypeName,
                                subtitle: "\(store.biggestPR?.kiloValue ?? 0) kg"
                            )
                        }
                        HSubtitleView(
                            title: "insight.view.intensity.title",
                            subtitle: "\(store.biggestPR?.percentage.clean ?? "") %"
                        )
                    }
                    
                    Button {
                        self.showPROsubsciptionView.toggle()
                    } label: {
                        CardGroupView(
                            cardTitle: "insight.view.card.pro.title",
                            cardDescript: "insight.view.card.pro.description",
                            buttonTitle: "insight.view.card.unlockprobutton.title",
                            iconSystemText: "chart.bar.fill"
                        )
                    }.sheet(isPresented: $showPROsubsciptionView) {
                        PurchaseView()
                    }.onAppear {
                        UINavigationBar.appearance().tintColor = .green
                    }
                }
            }
        } else {
            EmptyView(message: "Get started now\nby adding a new personal record.\n\nThe Powerful insights are generated from\nthe records you add. For better visualization, the minimum\nnumber of records\nto generate the graphs is ten.")
        }
        
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView().preferredColorScheme(.dark)
    }
}
