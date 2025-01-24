//
//  CellView.swift
//  UalaTest
//
//  Created by David Figueroa on 23/01/25.
//

import SwiftUI

struct CellView: View {
    let city: String
    let country: String

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Divider()
                Text(city)
                    .font(.headline)
                    .bold()

                Text(country)
                    .font(.subheadline)
                    .italic()
            }
            Spacer()
        }
        .frame(width: 300, height: 60)
    }
}
