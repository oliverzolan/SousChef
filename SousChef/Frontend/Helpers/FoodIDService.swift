import Foundation

/// Service class to handle food ID lookups from the stored foodID.json file
class FoodIDService {
    static let shared = FoodIDService()
    
    private var idToNameMap: [String: String] = [:]
    private var nameToIdMap: [String: String] = [:]
    private var isLoaded = false
    
    // File path to the JSON file (will be populated in init)
    private var jsonFilePath: String?
    
    private init() {
        findJSONFilePath()
        loadFoodIDs()
    }
    
    /// Find the path to the foodID.json file
    private func findJSONFilePath() {
        // Get the main bundle path for debugging
        let mainBundlePath = Bundle.main.bundlePath
        print("Main bundle path: \(mainBundlePath)")
        
        // Try to find the file in various locations
        let fileManager = FileManager.default
        
        // Possible file paths to check
        let possiblePaths: [String?] = [
            // Direct app bundle paths
            Bundle.main.path(forResource: "foodID", ofType: "json"),
            Bundle.main.path(forResource: "foodID", ofType: "json", inDirectory: "Frontend/Helpers"),
            Bundle.main.path(forResource: "Frontend/Helpers/foodID", ofType: "json"),
            
            // Project directory paths
            "\(mainBundlePath)/Frontend/Helpers/foodID.json",
            "\(mainBundlePath)/../Frontend/Helpers/foodID.json",
            "\(mainBundlePath)/../../Frontend/Helpers/foodID.json",
            
            // Absolute paths
            "/Users/bennetrau/Documents/SousChef/SousChef/Frontend/Helpers/foodID.json",
            "/Users/bennetrau/Documents/SousChef/Frontend/Helpers/foodID.json",
            
            // Document directory path
            fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("foodID.json").path
        ]
        
        // Check each path
        for possiblePath in possiblePaths {
            if let path = possiblePath {
                if fileManager.fileExists(atPath: path) {
                    jsonFilePath = path
                    print("Found foodID.json at: \(path)")
                    return
                } else {
                    print("Checked path but file not found: \(path)")
                }
            }
        }
        
        // If we get here, we couldn't find the file
        print("Could not find foodID.json in any expected location")
    }
    
    /// Load the food IDs from the JSON file
    private func loadFoodIDs() {
        // If we found a path to the JSON file, try to load it
        if let path = jsonFilePath {
            if loadFromPath(path) {
                return
            }
        }
        
        // Try loading the embedded food ID data
        if loadFromEmbeddedData() {
            return
        }
        
        print("All file loading approaches failed. Loading hardcoded data.")
        loadHardcodedData()
    }
    
    private func loadFromPath(_ path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        return loadFromURL(url)
    }
    
    private func loadFromURL(_ url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            idToNameMap = try decoder.decode([String: String].self, from: data)
            
            // Create reverse mapping (name to ID)
            for (id, name) in idToNameMap {
                nameToIdMap[name.lowercased()] = id
            }
            
            isLoaded = true
            print("Successfully loaded \(idToNameMap.count) food IDs from \(url.path)")
            return true
        } catch {
            print("Error loading food IDs from \(url.path): \(error)")
            return false
        }
    }
    
    /// Load food IDs directly from a string of the JSON data
    private func loadFromEmbeddedData() -> Bool {
        let jsonString = """
        {
            "food_a1gb9ubb72c7snbuxr3weagwv0dd": "Coconut",
            "food_a6k79rrahp8fe2b26zussa3wtkqh": "Apple",
            "food_a6k79rrahp8fe2b26zussa3wtkqh": "Red Apple",
            "food_b6h499495fq11pbpwobfrabudls": "Tomato",
            "food_bct6jg3a3v2zd7ap8j5ulbxkjcv7": "Water",
            "food_bhpradua77pk16aipcvzeayg732r": "Egg",
            "food_b1d1icuad3iktrbqby0hiagfqnec": "Plain Flour",
            "food_a1vgrj1bs8rd1majvwhvzotrorn6": "Sugar",
            "food_b2vurdvawv27z0aspcbvhabee21c": "Salt",
            "food_bknby1la98smrsbwnthinbam42nj": "Chicken Breast",
            "food_bnbh4ycaqj9as0ay851ax9nyt6oj": "Chicken",
            "food_bpbsh28b3qr1ktaipp1mugbnbdkp": "Beef",
            "food_aofet7haluep5pb42cxz7axr9vn3": "Garlic",
            "food_avnda2yaoqydd7bbmuhyr2biwsqb": "Onion",
            "food_bjsfxtcaidvmhaa3afrbna43q3hu": "Butter",
            "food_bu6xjbhbda73htamoxcx2asc7sfo": "Milk",
            "food_ba5c5kmb2id3gaalk7zfraih8q0i": "White Bread",
            "food_akz5rvcaqtm5b4bvklr3ibmuz77g": "Pasta",
            "food_aqmrchnaxrhhq7bkbp23xamvshda": "Rice",
            "food_a1169saahtsefsaaith8wvk244ei": "Carrot"
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("⛔️ Failed to convert embedded JSON string to data")
            return false
        }
        
        do {
            let decodedData = try JSONDecoder().decode([String: String].self, from: jsonData)
            print("✅ Successfully loaded \(decodedData.count) food IDs from embedded data")
            
            // Store the decoded data
            for (id, name) in decodedData {
                idToNameMap[id] = name
                nameToIdMap[name.lowercased()] = id
            }
            
            return true
        } catch {
            print("⛔️ Error decoding embedded JSON data: \(error)")
            return false
        }
    }
    
    /// Fallback to load hardcoded data when file is not found
    private func loadHardcodedData() {
        // Add a few common items directly here as fallback
        idToNameMap = [
            "food_a1gb9ubb72c7snbuxr3weagwv0dd": "Apple",
            "food_a6k79rrahp8fe2b26zussa3wtkqh": "Tomato",
            "food_abiw5baauresjmb6xpap2bg3otzu": "Potato",
            "food_bhpradua77pk16aipcvzeayg732r": "Egg",
            "food_avtcmx6bgjv1jvay6s6stan8dnyp": "Garlic",
            "food_bmrvi4ob4binw9a5m7l07amlfcoy": "Onion",
            "food_aahw0jha9f8337ajbopx9aec6z7i": "Broccoli",
            "food_b49rs1kaw0jktabzkg2vvanvvsis": "Milk",
            "food_bhppgmha1u27voagb8eptbp9g376": "Cheese",
            "food_bjsfxtcaidvmhaa3afrbna43q3hu": "Banana"
        ]
        
        // Create reverse mapping
        for (id, name) in idToNameMap {
            nameToIdMap[name.lowercased()] = id
        }
        
        isLoaded = true
        print("Loaded \(idToNameMap.count) hardcoded food IDs as fallback")
    }
    
    /// Get the food name for a given ID
    /// - Parameter id: The Edamam food ID
    /// - Returns: The food name if available, nil otherwise
    func getFoodName(for id: String) -> String? {
        if !isLoaded {
            loadFoodIDs()
        }
        return idToNameMap[id]
    }
    
    /// Get the food ID for a given name
    /// - Parameter name: The food name
    /// - Returns: The Edamam food ID if available, nil otherwise
    func getFoodID(for name: String) -> String? {
        if !isLoaded {
            loadFoodIDs()
        }
        
        let searchName = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Special handling for a few common ingredients that might have database UUID issues
        if searchName == "egg" || searchName == "eggs" {
            return "food_bhpradua77pk16aipcvzeayg732r"
        }
        
        // Try direct match first
        if let id = nameToIdMap[searchName] {
            return id
        }
        
        // If not found, try checking if any food name contains this name
        // (e.g., "apple" should match "Apple Juice")
        for (foodName, id) in nameToIdMap {
            if foodName.contains(searchName) {
                return id
            }
        }
        
        return nil
    }
    
    /// Find similar food names that contain a given substring
    /// - Parameter substring: The substring to search for in food names
    /// - Returns: A dictionary of matching food names and their IDs
    func getSimilarNames(containing substring: String) -> [(name: String, id: String)] {
        if !isLoaded {
            loadFoodIDs()
        }
        
        let lowerSubstring = substring.lowercased()
        var matches: [(name: String, id: String)] = []
        
        for (name, id) in nameToIdMap {
            if name.contains(lowerSubstring) {
                matches.append((name: name, id: id))
            }
        }
        
        return matches
    }
    
    /// Check if we have an ID for a given food name
    /// - Parameter name: The food name
    /// - Returns: True if the ID exists, false otherwise
    func hasIDForName(_ name: String) -> Bool {
        if !isLoaded {
            loadFoodIDs()
        }
        
        // Special handling for common ingredients
        let searchName = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if searchName == "egg" || searchName == "eggs" {
            return true
        }
        
        return nameToIdMap[name.lowercased()] != nil
    }
    
    /// Debug method to verify if foodID.json can be found
    func debugFilePaths() -> [String: Bool] {
        let fileManager = FileManager.default
        var results: [String: Bool] = [:]
        
        let possiblePaths: [String: String] = [
            "Main Bundle Path": Bundle.main.bundlePath,
            "Direct foodID.json": Bundle.main.path(forResource: "foodID", ofType: "json") ?? "Not found",
            "Helpers subdirectory": Bundle.main.path(forResource: "foodID", ofType: "json", inDirectory: "Frontend/Helpers") ?? "Not found",
            "Absolute path": "/Users/bennetrau/Documents/SousChef/SousChef/Frontend/Helpers/foodID.json",
            "Current JSON path": jsonFilePath ?? "Not determined"
        ]
        
        for (description, path) in possiblePaths {
            results[description] = fileManager.fileExists(atPath: path)
        }
        
        return results
    }
    
    /// Get the number of food IDs that have been loaded
    func getLoadedCount() -> Int {
        return idToNameMap.count
    }
    
    /// Check if we're using hardcoded data or loaded from file
    func isUsingHardcodedData() -> Bool {
        return jsonFilePath == nil
    }
} 