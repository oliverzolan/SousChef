import Foundation

class EnvFileManager {
    static let shared = EnvFileManager()
    
    private var environmentVariables: [String: String] = [:]
    private var isLoaded = false
    
    private init() {
        loadEnvironmentVariables()
    }
    
    private func loadEnvironmentVariables() {
        guard let path = Bundle.main.path(forResource: ".env", ofType: nil),
              let content = try? String(contentsOfFile: path) else {
            print("Error: Couldn't read .env file")
            return
        }
        
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let parts = line.components(separatedBy: "=")
            if parts.count >= 2 {
                let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = parts[1...].joined(separator: "=").trimmingCharacters(in: .whitespacesAndNewlines)
                environmentVariables[key] = value
            }
        }
        
        isLoaded = true
    }
    
    func getValue(forKey key: String) -> String? {
        if !isLoaded {
            loadEnvironmentVariables()
        }
        return environmentVariables[key]
    }
} 