import SwiftUI

struct AdminView: View {
    @EnvironmentObject var mainVM: MainViewModel
    @StateObject private var adminVM = AdminViewModel()
    @State private var selectedTab = 0
    @State private var isShowingAddProduct = false
    @State private var searchText = ""
    @State private var selectedCategoryId: Int? = nil
    @State private var selectedBrandId: Int? = nil

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                VStack(spacing: 0) {
                    headerView
                    searchAndFilterView
                    productListView
                }
                .tabItem {
                    Label("Products", systemImage: "cart")
                }
                .tag(0)

                VStack {
                    Spacer()
                    Text("Are you sure you want to logout?")
                        .font(.customfont(.medium, fontSize: 20))
                        .foregroundColor(.primaryText)
                        .padding(.bottom, 20)
                    RoundButton(tittle: "Logout") {
                        withAnimation {
                            mainVM.logout()
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, .bottomInsets + 20)
                    Spacer()
                }
                .background(Color.white.edgesIgnoringSafeArea(.all))
                .tabItem {
                    Label("Logout", systemImage: "person.crop.circle.badge.minus")
                }
                .tag(1)
            }
            .accentColor(.blue)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                adminVM.fetchProducts()
                adminVM.fetchBestSelling()
                adminVM.fetchExclusiveOffers()
            }
            .alert(isPresented: $adminVM.showError) {
                Alert(
                    title: Text(Globs.AppName),
                    message: Text(adminVM.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $adminVM.showSuccess) {
                Alert(
                    title: Text(Globs.AppName),
                    message: Text(adminVM.successMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Admin Dashboard")
                    .font(.customfont(.bold, fontSize: 26))
                    .foregroundColor(.primaryText)
                Spacer()
                NavigationLink(
                    destination: AddProductView(
                        adminVM: adminVM,
                        product: .constant(ProductRequestModel(
                            name: "",
                            price: 0.0,
                            stock: 0,
                            unitName: "",
                            unitValue: ""
                        ))
                    ),
                    isActive: $isShowingAddProduct
                ) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)

            Text("Welcome, \(mainVM.userObj.fullName)!")
                .font(.customfont(.medium, fontSize: 18))
                .foregroundColor(.secondaryText)
        }
    }

    private var searchAndFilterView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search products by name", text: $searchText)
                    .font(.customfont(.regular, fontSize: 16))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 5)
                    .onChange(of: searchText) { newValue in
                        adminVM.searchProducts(
                            name: newValue.isEmpty ? nil : newValue,
                            brandId: selectedBrandId,
                            categoryId: selectedCategoryId
                        )
                    }

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        selectedCategoryId = nil
                        selectedBrandId = nil
                        adminVM.fetchProducts()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)

            HStack {
                Picker("Category", selection: $selectedCategoryId) {
                    Text("All Categories").tag(nil as Int?)
                    ForEach(adminVM.categories) { category in
                        Text(category.name).tag(category.id as Int?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(.black)
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
                .onChange(of: selectedCategoryId) { _ in
                    adminVM.searchProducts(
                        name: searchText.isEmpty ? nil : searchText,
                        brandId: selectedBrandId,
                        categoryId: selectedCategoryId
                    )
                }

                Picker("Brand", selection: $selectedBrandId) {
                    Text("All Brands").tag(nil as Int?)
                    ForEach(adminVM.brands) { brand in
                        Text(brand.name).tag(brand.id as Int?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(.black)
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
                .onChange(of: selectedBrandId) { _ in
                    adminVM.searchProducts(
                        name: searchText.isEmpty ? nil : searchText,
                        brandId: selectedBrandId,
                        categoryId: selectedCategoryId
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 8)
    }

    private var productListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) {
                // Section Exclusive Offers
                VStack(alignment: .leading) {
                    Text("Exclusive Offers")
                        .font(.customfont(.bold, fontSize: 20))
                        .foregroundColor(.primaryText)
                        .padding(.horizontal, 20)
                        .padding(.top, 5)

                    if adminVM.exclusiveOfferList.isEmpty {
                        Text("No exclusive offers available")
                            .font(.customfont(.medium, fontSize: 18))
                            .foregroundColor(.secondaryText)
                            .padding(.horizontal, 20)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 15) {
                                ForEach(adminVM.exclusiveOfferList, id: \.id) { product in
                                    NavigationLink(destination: ProductDetailView(productId: product.id)) {
                                        productRowView(for: product, category: "Exclusive Offers")
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                        }
                    }
                }

                // Section All Products
                if adminVM.productList.isEmpty {
                    Text("No products found")
                        .font(.customfont(.medium, fontSize: 18))
                        .foregroundColor(.secondaryText)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                } else {
                    ForEach(adminVM.categories, id: \.id) { category in
                        let productsInCategory = adminVM.productList.filter { $0.category == category.name }
                        if !productsInCategory.isEmpty {
                            VStack(alignment: .leading) {
                                Text(category.name)
                                    .font(.customfont(.bold, fontSize: 20))
                                    .foregroundColor(.primaryText)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 5)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 15) {
                                        ForEach(productsInCategory.indices, id: \.self) { index in
                                            let product = productsInCategory[index]
                                            NavigationLink(destination: ProductDetailView(productId: product.id)) {
                                                productRowView(for: product, category: category.name)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }

                    let uncategorizedProducts = adminVM.productList.filter { $0.category == nil || $0.category?.isEmpty == true }
                    if !uncategorizedProducts.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Uncategorized")
                                .font(.customfont(.bold, fontSize: 20))
                                .foregroundColor(.primaryText)
                                .padding(.horizontal, 20)
                                .padding(.top, 5)

                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 15) {
                                    ForEach(uncategorizedProducts.indices, id: \.self) { index in
                                        let product = uncategorizedProducts[index]
                                        NavigationLink(destination: ProductDetailView(productId: product.id)) {
                                            productRowView(for: product, category: "Uncategorized")
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, .bottomInsets + 20)
        }
    }

    private func productRowView(for product: ProductModel, category: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 5)
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Text(product.name)
                .font(.customfont(.semibold, fontSize: 16))
                .foregroundColor(.primaryText)
                .lineLimit(1)

            Text("Price: $\(String(format: "%.2f", product.price))")
                .font(.customfont(.regular, fontSize: 14))
                .foregroundColor(.secondaryText)

            if let offerPrice = product.offerPrice {
                Text("Offer Price: $\(String(format: "%.2f", offerPrice))")
                    .font(.customfont(.regular, fontSize: 14))
                    .foregroundColor(.green)
            }

            Text("Brand: \(product.brand ?? "N/A")")
                .font(.customfont(.regular, fontSize: 12))
                .foregroundColor(.gray)

            HStack {
                NavigationLink(destination: AddProductView(adminVM: adminVM, product: .constant(ProductRequestModel(
                    id: product.id,
                    name: product.name,
                    price: product.price,
                    stock: product.stock,
                    unitName: product.unitName,
                    unitValue: product.unitValue,
                    description: product.description,
                    imageUrl: product.imageUrl,
                    categoryId: adminVM.categories.first(where: { $0.name == product.category })?.id,
                    brandId: adminVM.brands.first(where: { $0.name == product.brand })?.id,
                    offerPrice: product.offerPrice,
                    avgRating: product.avgRating,
                    startDate: product.startDate ?? Date(),
                    endDate: product.endDate ?? Date(),
                    nutritionValues: product.nutritionValues.isEmpty ? nil : product.nutritionValues
                )))) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }

                Button(action: {
                    withAnimation {
                        adminVM.deleteProduct(id: product.id) { success in
                            if !success {
                                adminVM.showError = true
                            }
                        }
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .frame(width: 120)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    NavigationView {
        AdminView()
            .environmentObject(MainViewModel.shared)
    }
}
