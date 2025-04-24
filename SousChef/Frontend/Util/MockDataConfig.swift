import Foundation

// MARK: - Mock Data Configuration
struct MockDataConfig {
    // Enable this to use mock data when backend errors occur
    static var useMockData: Bool {
        #if DEBUG
        return true  // Set to true to enable mock data in DEBUG mode
        #else
        return false
        #endif
    }
    
    // Force mock data with environment variable
    static var forceMockData: Bool {
        ProcessInfo.processInfo.environment["USE_MOCK_DATA"] == "true"
    }
    
    // Whether to use mock data (either by default or forced)
    static var shouldUseMockData: Bool {
        useMockData || forceMockData
    }
} 