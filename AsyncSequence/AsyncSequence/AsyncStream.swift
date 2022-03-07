//
//  AsyncStream.swift
//  AsyncSequence
//
//  Created by satoutakeshi on 2022/03/06.
//

import SwiftUI
import CoreLocation

struct AsyncStreamView: View {
    @StateObject
    private var locationManager = LocationManager()

    var body: some View {
        VStack {
            Text("緯度:\(locationManager.coordinate.latitude)\n経度:\(locationManager.coordinate.longitude)")
                .font(.largeTitle)
            List {
                Button {
                    locationManager.startLocation()
                } label: {
                    Text("位置情報読み取り開始")
                }

                Button {
                    Task {
                        for await coordinate in locationManager.locations {
                            print(coordinate)
                        }
                    }
                } label: {
                    Text("AsyncStreamを使う")
                }

                Button {
                    Task {
                        do {
                            for try await coordinate in locationManager.locationsWithError {
                                print(coordinate)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } label: {
                    Text("AsyncThrowingStreamを使う")
                }
            }
        }
        .onAppear {
            locationManager.setup()
        }
        .alert(Text("位置情報を許可してください"),
               isPresented: $locationManager.showAuthorizationAlert) {
            Button("OK") {}
        }
    }
}

@MainActor
final class LocationManager: NSObject, ObservableObject {

    @Published
    var showAuthorizationAlert: Bool = false

    @Published
    var coordinate: CLLocationCoordinate2D = .init()

    private var continuation: AsyncStream<CLLocationCoordinate2D>.Continuation?

    private let locationManager = CLLocationManager()

    func setup() {
        locationManager.delegate = self

        switch locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                showAuthorizationAlert = true
            @unknown default:
                break
        }
    }

    func startLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopLocation() {
        locationManager.stopUpdatingHeading()
        continuation?.finish()
    }

    var locations: AsyncStream<CLLocationCoordinate2D> {
        AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }

    struct LocationError: Error {
        let message: String
    }

    var continuationWithError: AsyncThrowingStream<CLLocationCoordinate2D, Error>.Continuation?

    var locationsWithError: AsyncThrowingStream<CLLocationCoordinate2D, Error> {
        AsyncThrowingStream { [weak self] continuation in
            guard let self = self else { return }
            switch self.locationManager.authorizationStatus {
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                case .denied, .restricted:
                    continuation.finish(throwing: LocationError(message: "位置情報を許可してください"))
                default:
                    break
            }
            continuationWithError = continuation
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let lastLocation = locations.last else {
            return
        }
        coordinate = lastLocation.coordinate

        continuation?.yield(lastLocation.coordinate)
        continuation?.onTermination = { @Sendable [weak self]  _ in
            self?.locationManager.stopUpdatingLocation()
        }

        continuationWithError?.yield(lastLocation.coordinate)
        continuationWithError?.onTermination = { @Sendable [weak self] _ in
            self?.locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                showAuthorizationAlert = true
            default:
                break
        }
    }
}

struct AsyncStream_Previews: PreviewProvider {
    static var previews: some View {
        AsyncStreamView()
    }
}
