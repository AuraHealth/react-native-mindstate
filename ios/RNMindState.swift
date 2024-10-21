import HealthKit

@objc(RNMindState)
class RNMindState: NSObject {
    
    private let healthStore = HKHealthStore()
    
    @objc
    func isAvailable(_ resolve: RCTPromiseResolveBlock,
                    rejecter reject: RCTPromiseRejectBlock) {
        if #available(iOS 17.0, *) {
            resolve(HKHealthStore.isHealthDataAvailable())
        } else {
            resolve(false)
        }
    }
    
    @objc
    func requestAuthorization(_ resolve: @escaping RCTPromiseResolveBlock,
                            rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 17.0, *) else {
            reject("ERROR", "iOS 17.0 or later required", nil)
            return
        }
        
        guard HKHealthStore.isHealthDataAvailable() else {
            reject("ERROR", "HealthKit is not available", nil)
            return
        }
        
        let mindStateType = HKObjectType.categoryType(forIdentifier: .mindfulState)!
        let typesToRead: Set<HKObjectType> = [mindStateType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                reject("ERROR", error.localizedDescription, error)
                return
            }
            resolve(success)
        }
    }
    
    @objc
    func queryMindStates(_ options: NSDictionary,
                        resolver resolve: @escaping RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard #available(iOS 17.0, *) else {
            reject("ERROR", "iOS 17.0 or later required", nil)
            return
        }
        
        guard let startDate = ISO8601DateFormatter().date(from: options["startDate"] as! String),
              let endDate = ISO8601DateFormatter().date(from: options["endDate"] as! String) else {
            reject("ERROR", "Invalid date format", nil)
            return
        }
        
        let mindStateType = HKObjectType.categoryType(forIdentifier: .mindfulState)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                   end: endDate,
                                                   options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: mindStateType,
                                predicate: predicate,
                                limit: options["limit"] as? Int ?? HKObjectQueryNoLimit,
                                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                                                ascending: false)]) { _, samples, error in
            if let error = error {
                reject("ERROR", error.localizedDescription, error)
                return
            }
            
            let results = samples?.map { sample -> [String: Any] in
                let categoryValue = (sample as! HKCategorySample).value
                return [
                    "date": ISO8601DateFormatter().string(from: sample.startDate),
                    "value": categoryValue,
                    "mood": self.getMoodString(from: categoryValue)
                ]
            }
            
            resolve(results ?? [])
        }
        
        healthStore.execute(query)
    }
    
    private func getMoodString(from value: Int) -> String {
        switch value {
        case 1: return "terrible"
        case 2: return "bad"
        case 3: return "neutral"
        case 4: return "good"
        case 5: return "great"
        default: return "unknown"
        }
    }
}