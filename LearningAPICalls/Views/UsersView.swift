//
//  UsersView.swift
//  LearningAPICalls
//
//  Created by Kaushal Kumbagowdana on 6/5/23.
//

import SwiftUI

struct UsersView: View {
    
    let user: User
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("**Name**: \(user.name)")
            Text("**Email**: \(user.email)")
            Divider()
            Text("**Company**: \(user.company.name)")
        }
        .frame(maxWidth: .infinity,
               alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 4)
    }
}

struct UsersView_Previews: PreviewProvider {
    static var previews: some View {
        // need to init UI component since it is expecting a user
        UsersView(user: .init(id: 0,
                              name: "Kzk",
                              email: "Kzk@gmail.com",
                              address: .init(street: "", suite: "", city: "", zipcode: "", geo: .init(lat: "", lng: "")),
                              phone: "",
                              website: "kzk.com",
                              company: .init(name: "Hehe",
                                            catchPhrase: "", bs: "")))
    }
}
