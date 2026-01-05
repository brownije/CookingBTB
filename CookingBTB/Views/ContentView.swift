//
//  ContentView.swift
//  CookingBTB
//
//  Created by Joshua Browning on 11/2/25.
//

import SwiftUI

enum Status: String, CaseIterable, Identifiable {
    case progress = "New recipe"
    case shopping = "Shopping"
    case cooking = "Cooking"
    case eating = "Eating"
    
    var description: String {
        switch self {
        case .progress:
            return "You're starting a new recipe!"
        case .shopping:
            return "You're shopping for ingredients!"
        case .cooking:
            return "You're cooking your recipe!"
        case .eating:
            return "Enjoy the meal and note improvements for next time!"
        }
    }
    
    var id: String { rawValue }
}

struct ContentView: View {
    @State var selection: Status = .progress
    @State private var helpStatus: Status? = nil
    @State private var showPicker: Bool = false
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            NavigationStack {
                Group {
                    if showPicker {
                        VStack {
                            StatusGridView(selection: $selection)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .padding()
                    } else {
                        VStack(spacing: 12) {
                            Text("Welcome to CookingBTB!\n\n")
                                .font(.title)
                                .multilineTextAlignment(.center)
                            Text("Tap anywhere to begin")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture { showPicker = true }
                        .padding()
                    }
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [.blue, .gray]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                )
                .toolbarBackground(.clear, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .background(Color.clear)
            }
            .background(Color.clear)
            .environmentObject(locationManager)
        }
    }
}

struct StatusDetailView: View {
    let status: Status
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        Group {
            switch status {
            case .shopping:
                ShoppingMapView()
                    .onAppear {
                        locationManager.promptForLocationAccess()
                    }
            case .progress:
                CreateRecipeView()
            default:
                VStack(spacing: 16) {
                    Text(status.rawValue)
                        .font(.largeTitle)
                        .bold()
                    Text(status.description)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle(status.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatusGridView: View {
    @Binding var selection: Status
    @State private var navigateToDetail: Bool = false
    private let columns: [GridItem] = [GridItem(.flexible(), spacing: 16)]

    var body: some View {
        VStack {
            LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                ForEach(Status.allCases, id: \.self) { (status: Status) in
                    StatusTile(status: status)
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .onTapGesture {
                            selection = status
                            navigateToDetail = true
                        }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToDetail) {
            StatusDetailView(status: selection)
        }
        .frame(maxWidth: .infinity, maxHeight: .leastNormalMagnitude, alignment: .leading)
        .padding(16)
    }
}

struct StatusTile: View {
    let status: Status
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)

            VStack(spacing: 8) {
                Text(status.rawValue)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                Text(status.description)
                    .font(.footnote)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 8)
            }
            .padding(16)
        }
    }
}

struct StatusPickerSection: View {
    @Binding var selection: Status
    var body: some View {
        VStack {
            Text("Select your status:")
                .font(.largeTitle)
                .padding(.bottom, 12)

            Picker("Select your status", selection: $selection) {
                ForEach(Status.allCases, id: \.self) { (status: Status) in
                    Text(status.rawValue).tag(status)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}

