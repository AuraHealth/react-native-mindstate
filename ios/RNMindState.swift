import HealthKit
import React

@available(iOS 18.0, *)
@objc(RNMindState)
class RNMindState: NSObject {
    
    private let healthStore = HKHealthStore()
    
    @objc
    func isAvailable(_ resolve: RCTPromiseResolveBlock,
                    rejecter reject: RCTPromiseRejectBlock) {
        resolve(HKHealthStore.isHealthDataAvailable())
    }
    
    @objc
    func requestAuthorization(_ resolve: @escaping RCTPromiseResolveBlock,
                            rejecter reject: @escaping RCTPromiseRejectBlock) {
        
        
        guard HKHealthStore.isHealthDataAvailable() else {
            reject("ERROR", "HealthKit is not available", nil)
            return
        }
        
        let mindStateType = HKObjectType.stateOfMindType()
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
                         rejecter reject: @escaping RCTPromiseRejectBlock)  {
        Task {
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            guard let startDate = isoFormatter.date(from: options["startDate"] as! String),
                  let endDate = isoFormatter.date(from: options["endDate"] as! String) else {
                reject("ERROR", "Invalid date format", nil)
                return
            }
            
            let datePredicate = HKQuery.predicateForSamples(withStart: startDate,
                                                            end: endDate,
                                                            options: .strictEndDate)
            let compoundPredicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [datePredicate]
            )
            
            
            let stateOfMindPredicate = HKSamplePredicate.stateOfMind(compoundPredicate)
            
            let descriptor = HKSampleQueryDescriptor(predicates: [stateOfMindPredicate], sortDescriptors: [], limit: options["limit"] as? Int ?? HKObjectQueryNoLimit)
            
            var results: [HKStateOfMind] = []
            
            
            
            do {
                results = try await descriptor.result(for: healthStore)
                
                var returnObj: [[String: Any]] = []
                
                results.forEach { result in
                    let associations: [Int] = result.associations.map {
                        $0.rawValue
                    }
                    
                    let kind = result.kind.rawValue
                    
                    let labels: [Int] = result.labels.map {
                        $0.rawValue
                    }
                    
                    let valienceClassifiction = result.valenceClassification.rawValue
                    
                    // create an object
                    
                    let object: [String: Any] = [
                        "associations": associations,
                        "kind": kind,
                        "labels": labels,
                        "valence": valienceClassifiction
                    ]
                    
                    returnObj.append(object)
                    
                }
                
                resolve(returnObj)
            } catch {
                reject("ERROR", error.localizedDescription, nil)
                return
            }
            
        }
        
        
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
