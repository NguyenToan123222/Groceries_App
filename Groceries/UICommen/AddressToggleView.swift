//
//  AddressToggleView.swift
//  Groceries
//
//  Created by Nguyễn Toàn on 30/5/25.
//

import SwiftUI

struct AddressToggleView: View {
    @State private var isHomeAddress: Bool = false
    
    var body: some View {
        VStack {
            Toggle("Use Home Address", isOn: $isHomeAddress)
                .padding()
            Text(isHomeAddress ? "Home Address Selected" : "Other Address")
        }
    }
}

struct AddressToggleView_Previews: PreviewProvider {
    static var previews: some View {
        AddressToggleView()
    }
}
// -----------------------------------------------------------------------
struct AddressFormView: View {
    @State private var street: String = ""
    
    var body: some View {
        VStack {
            Text("Street: \(street)")
            StreetInputView(street2: $street)
        }
    }
}

struct StreetInputView: View {
    @Binding var street2: String
    
    var body: some View {
        TextField("Enter street", text: $street2)
            .textFieldStyle(RoundedBorderTextFieldStyle()) // viền bo tròn
            .padding()
    }
}

struct AddressFormView_Previews: PreviewProvider {
    static var previews: some View {
        AddressFormView()
    }
}
// -----------------------------------------------------------------------

class LocationViewModel: ObservableObject {
    @Published var provinces: [String] = ["Hà Nội", "TP.HCM"]
}

struct ProvinceListView: View {
    @ObservedObject var locationVM: LocationViewModel
    
    var body: some View {
        List(locationVM.provinces, id: \.self) { province in
            Text(province)
        }
    }
}

struct ProvinceListView_Previews: PreviewProvider {
    static var previews: some View {
        ProvinceListView(locationVM: LocationViewModel())
    }
}


