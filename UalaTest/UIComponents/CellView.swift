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
        HStack {
            VStack(alignment: .leading) {
                Text(city)
                    .font(.headline)
                    .bold()

                Text(country)
                    .font(.subheadline)
                    .italic()
            }
            .padding()
            Spacer()
        }
    }
}
