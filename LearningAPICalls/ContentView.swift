//
//  ContentView.swift
//  LearningAPICalls
//
//  Created by Kaushal Kumbagowdana on 6/5/23.
//

import SwiftUI

/*
 Root UI Folder
*/

struct ContentView: View {
    
    @StateObject private var usersVM = UsersViewModel()

    var body: some View {
       
        NavigationView {
            VStack {
                
                if usersVM.isRefreshing {
                    // when loading data
                    ProgressView()
                } else {
                    List {
                        ForEach(usersVM.users, id: \.id) { user in
                            UsersView(user: user)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle(usersVM.whichFetch)
                }
            }
            .onAppear(perform: usersVM.nonCombineUsersFetch)
            .alert(isPresented: $usersVM.hasError, error: usersVM.error) { // whevere there is an issue, it will appear on ZStack
                Button(action: usersVM.combineUsersFetch) {
                    Text("Retry")
                }
            }
            .navigationBarItems(
                leading: Button(action: usersVM.combineUsersFetch){
                    Text("Combine")
                },trailing:
                    Button(action: usersVM.nonCombineUsersFetch){
                        Text("Non-Combine")
                    }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
