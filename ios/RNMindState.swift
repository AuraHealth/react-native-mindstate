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
        
        // New Wellness API
        let mindStateType = HKObjectType.stateOfMindType()
        let gad7Type: HKObjectType = HKScoredAssessmentType(.GAD7)
        let phq9Type: HKObjectType = HKScoredAssessmentType(.PHQ9)
        
        var readPermissionList: Set<HKObjectType> = [
            mindStateType,
            phq9Type,
            gad7Type
        ]
        
        var writePermissionList: Set<HKSampleType> = []
        
        // Add existing APIs for react-native-health library
        
        if let mindfulSessionType = HKObjectType.categoryType(forIdentifier: .mindfulSession) {
            readPermissionList.insert(mindfulSessionType)
            writePermissionList.insert(mindfulSessionType)
        }
        
        if let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            readPermissionList.insert(sleepAnalysis)
        }
        
        if let sleepChanges = HKObjectType.categoryType(forIdentifier: .sleepChanges) {
            readPermissionList.insert(sleepChanges)
        }
        
        if let timeInDaylight = HKObjectType.quantityType(forIdentifier: .timeInDaylight) {
            readPermissionList.insert(timeInDaylight)
        }
    
        
        healthStore.requestAuthorization(toShare: writePermissionList, read: readPermissionList) { success, error in
            if let error = error {
                reject("ERROR", error.localizedDescription, error)
                return
            }
            resolve(success)
        }
    }
    
    @objc
    func queryTimeInDaylight(_ options: NSDictionary,
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
            
            
            guard let timeInDaylightType = HKObjectType.quantityType(forIdentifier: .timeInDaylight) else {
                reject("ERROR", "Failed to create timeInDaylight type.", nil)
                   return
               }
            
            
            // Create a query to fetch the data
                let query = HKSampleQuery(sampleType: timeInDaylightType, predicate: datePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                    if let error = error {
                        reject("Error", "Error fetching time in daylight: \(error.localizedDescription)", nil)
                        return
                    }
                    
                    guard let results = results as? [HKQuantitySample] else {
                        reject("Error", "No results found.", nil)
                        return
                    }
                    
                    var res: [[String: Any]] = []
                    
                    // Process the results
                    for sample in results {
                        let value = sample.quantity.doubleValue(for: HKUnit.minute())
                        let mappedValues: [String: Any] = [
                            "quantity": value,
                            "quantityType": sample.quantityType,
                            "uuid": sample.uuid,
                            "startDate": self.formatDate(sample.startDate),
                            "endDate": self.formatDate(sample.endDate)
                        ]
                        res.append(mappedValues)
                    }
                    
                    resolve(res)
                    
                }
                
                // Execute the query
                healthStore.execute(query)
            
        }
    }
    
    @objc
    func queryPhQ7Data(_ options: NSDictionary,
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
            
            
            let stateOfMindPredicate = HKSamplePredicate.phq9Assessment(compoundPredicate)
            
            
            let descriptor = HKSampleQueryDescriptor(predicates: [stateOfMindPredicate], sortDescriptors: [])
            
            var results: [HKPHQ9Assessment] = []
            
            
            do {
                results = try await descriptor.result(for: healthStore)
                
                var returnObj: [[String: Any]] = []
                
                results.forEach { result in
                    let answers: [Int] = result.answers.map {
                        $0.rawValue
                    }
                    
                    let risk = result.risk.rawValue
                    
                    let object: [String: Any] = [
                        "answers": answers,
                        "risk": risk,
                        "startDate": self.formatDate(result.startDate),
                        "endDate": self.formatDate(result.endDate)
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
    
    
    
    @objc
    func queryGad7Data(_ options: NSDictionary,
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
            
            
            let stateOfMindPredicate = HKSamplePredicate.gad7Assessment(compoundPredicate)
            
            
            let descriptor = HKSampleQueryDescriptor(predicates: [stateOfMindPredicate], sortDescriptors: [])
            
            var results: [HKGAD7Assessment] = []
            
            
            do {
                results = try await descriptor.result(for: healthStore)
                
                var returnObj: [[String: Any]] = []
                
                results.forEach { result in
                    let answers: [Int] = result.answers.map {
                        $0.rawValue
                    }
                    
                    let risk = result.risk.rawValue
                    
                    let object: [String: Any] = [
                        "answers": answers,
                        "risk": risk,
                        "startDate": self.formatDate(result.startDate),
                        "endDate": self.formatDate(result.endDate)
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
                    
                    
                    let object: [String: Any] = [
                        "associations": associations,
                        "kind": kind,
                        "labels": labels,
                        "valenceClassification": valienceClassifiction,
                        "startDate": self.formatDate(result.startDate),
                        "endDate": self.formatDate(result.endDate),
                        "valence": result.valence
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
    
    
    private func formatDate(_ date: Date) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoFormatter.string(from: date)
    }
    
    
}
