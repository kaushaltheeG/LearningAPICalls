//
//  UsersViewModel.swift
//  LearningAPICalls
//
//  Created by Kaushal Kumbagowdana on 6/5/23.
//

import Foundation
import Combine



final class UsersViewModel: ObservableObject {
    
    @Published var users: [User] = [] // Observable in which the View listens to
    @Published var hasError: Bool = false
    @Published var error: UserError?
    @Published private(set) var isRefreshing = false; // only want VM to have access
    @Published var whichFetch: String = "Non-Combine Users"
    
    private var CancelableStore = Set<AnyCancellable>() // set is used unique Publishers in order to remove from memory when done
    
    func nonCombineUsersFetch() {
            
            isRefreshing = true
            hasError = false // init hasError at the start of the task
            whichFetch = "Non-Combine Users"
        
            let usersUrlString = "https://jsonplaceholder.typicode.com/users"
            // storing in URL object which allows for network requests
            if let url = URL(string: usersUrlString) {
                // preformance of the network request
                URLSession
                    .shared
                    .dataTask(with: url) { [weak self] data, response, error in // weak indicates memmory should be allocated if used
                        
                        // Test loading: asyncAfter(deadline: .now() + 1.5) -> delay on the call
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // preforms task on main async thread
                            // closure in order to handle the network response
                            if let error = error { // if not nil, then assign error to error var
                                self?.hasError = true
                                self?.error = UserError.custom(error: error)
                            } else {
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase // converts properities from snake to camal case
                                
                                if let data = data, let users = try? decoder.decode([User].self, from: data) { // decode the data into an array of User model
                                        self?.users = users
                                } else {
                                    self?.hasError = true
                                    self?.error = UserError.failedToDecode
                                }
                            }
                            
                            self?.isRefreshing = false
                        }
                    }.resume() // calls the function allowing use to execute code within the datTask closure
            }
        }
    
    func combineUsersFetch() {
        
        let usersUrlString = "https://jsonplaceholder.typicode.com/users"
        whichFetch = "Combine Users"
        
        if let url = URL(string: usersUrlString) {
            isRefreshing = true
            hasError = false
            // returns a Publisher in which we can listen and observe the changes duing an API request
            URLSession
                .shared
                .dataTaskPublisher(for: url) // creates Publisher
                .receive(on: DispatchQueue.main) // receive the response on the main thread
                .tryMap({ res in // tryMap allows for error handling while maping thru the response
                    
                    guard let response = res.response as? HTTPURLResponse,
                          response.statusCode >= 200 && response.statusCode <= 300 else {
                        throw UserError.invalidStatusCode
                    }
                    
                    let decoder = JSONDecoder()
                    // gaurd allows for if/else statement; will gaurd the operation if valid else will throw errow
                    guard let users = try? decoder.decode([User].self, from: res.data) else {
                        throw UserError.failedToDecode
                    }
                    return users
                })
                .delay(for: 1.5, scheduler: RunLoop.main)
                .sink { res in // the subscriber
                    // sets isRefreshing to false when completed
                    defer { self.isRefreshing = false }
                    // error handling case
                    switch res {
                    case .failure(let error):
                        self.hasError = true
                        self.error = UserError.custom(error: error)
                    default:
                        break
                    }
                    
                } receiveValue: { [weak self] users in
                    self?.users = users
                }
                .store(in: &CancelableStore) // stores the Publishers as cancels !!Very Important
        }
    }
}

extension UsersViewModel {
    // enum to handle the different errors
    enum UserError: LocalizedError {
        case custom(error: Error)
        case failedToDecode
        case invalidStatusCode
        
        var errorDescription: String? {
            switch self{
            case .failedToDecode:
                return "Failed to Decode"
            case .custom(let error):
                return error.localizedDescription
            case .invalidStatusCode:
                return "Request failed | Status Code Outside of Accepted Range "
            }
        }
    }
}
