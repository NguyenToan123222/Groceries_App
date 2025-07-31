import SwiftUI
import SDWebImageSwiftUI

struct AdminView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var mainVM: MainViewModel
    @StateObject private var adminVM = AdminViewModel()
    @StateObject private var ordersVM = AdminOrdersViewModel()
    
    @State private var selectedTab = 0
    @State private var searchText = ""

    @State private var isShowingAddProduct = false
    @State private var isShowingAddExclusiveOffer = false
    @State private var isShowingAddNutrition = false
        
    @State private var selectedCategoryId: Int? = nil
    @State private var selectedBrandId: Int? = nil
    @State private var selectedOrderStatus: String? = nil
    
    @State private var editingProduct: ProductRequestModel?

    private let gridColumns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
            TabView(selection: $selectedTab) {
                // Tab 1: Products
                VStack(spacing: 0) {
                    headerView
                    searchAndFilterView
                    productListView
                }
                .tabItem {
                    Label("Products", systemImage: "cart")
                }
                .tag(0)

                // Tab 2: Exclusive Offers
                VStack(spacing: 0) {
                    exclusiveOffersView
                }
                .tabItem {
                    Label("Exclusive", systemImage: "tag")
                }
                .tag(1)

                // Tab 3: Orders
                VStack(spacing: 0) {
                    ordersView
                }
                .tabItem {
                    Label("Orders", systemImage: "list.bullet.rectangle")
                }
                .tag(2)

                // Tab 4: Accounts
                VStack(spacing: 0) {
                    accountsView
                }
                .tabItem {
                    Label("Accounts", systemImage: "person.2")
                }
                .tag(3)

                // Tab 5: Add Nutrition
                VStack(spacing: 0) {
                    AddNutritionView(adminVM: adminVM)
                }
                .tabItem {
                    Label("Add Nutrition", systemImage: "plus.circle")
                }
                .tag(4)

                // Tab 6: Logout
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
                .tag(5)
            }
            .accentColor(.blue)
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                print("Logged in user: \(mainVM.userObj.fullName), Role: \(mainVM.userObj.role ?? "N/A")")
                adminVM.fetchProducts()
                adminVM.fetchBestSelling()
                adminVM.fetchExclusiveOffers()
                adminVM.fetchCustomerAccounts() // Ensure this is called to load accounts
                ordersVM.refreshOrders()
            }
            .onChange(of: mainVM.navigateToLogin) { newValue in // Thêm logic theo dõi navigateToLogin
                if newValue {
                    dismiss() // Quay lại LoginView khi logout
                }
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
            .alert(isPresented: $ordersVM.showError) {
                Alert(
                    title: Text(Globs.AppName),
                    message: Text(ordersVM.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $ordersVM.showSuccess) {
                Alert(
                    title: Text(Globs.AppName),
                    message: Text(ordersVM.successMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $isShowingAddProduct) {
                AddProductView(
                    adminVM: adminVM,
                    product: .init(
                        id: nil,
                        name: "",
                        price: 0.0,
                        stock: 0,
                        unitName: "",
                        unitValue: "",
                        description: nil,
                        imageUrl: nil,
                        categoryId: nil,
                        brandId: nil,
                        offerPrice: nil,
                        avgRating: nil,
                        startDate: nil,
                        endDate: nil,
                        nutritionValues: nil
                    )
                )
            }
            .sheet(item: $editingProduct) { product in
                AddProductView(adminVM: adminVM, product: product)
            
        }
    }

    private var headerView: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Admin Dashboard")
                    .font(.customfont(.bold, fontSize: 26))
                    .foregroundColor(.primaryText)
                Spacer()
                if selectedTab == 0 {
                    Button(action: {
                        isShowingAddProduct = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }// HStack
            .padding(.horizontal, 20)

            Text("Welcome, \(mainVM.userObj.fullName)!")
                .font(.customfont(.medium, fontSize: 18))
                .foregroundColor(.secondaryText)
        }
    }
    // ------------------------------------------------------------------------------------------------------

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
                            categoryId: selectedCategoryId // sd bộ lọc hiện tại 
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
    // ------------------------------------------------------------------------------------------------------

    private var accountsView: some View {
        VStack(spacing: 0) { // Sử dụng VStack ngoài cùng để giữ tiêu đề cố định
            // Tiêu đề cố định
            Text("Customer Accounts")
                .font(.customfont(.bold, fontSize: 20))
                .foregroundColor(.primaryText)
                .padding(.horizontal, 20)
                .padding(.top, 5)
                .background(Color.white) // Đảm bảo nền không bị che khuất khi cuộn
                .frame(maxWidth: .infinity, alignment: .leading) // Đảm bảo tiêu đề chiếm toàn bộ chiều rộng
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    if adminVM.customerAccounts.isEmpty {
                        Text("No customer accounts available")
                            .font(.customfont(.medium, fontSize: 18))
                            .foregroundColor(.secondaryText)
                            .padding(.horizontal, 20)
                    } else {
                        ForEach(adminVM.customerAccounts) { user in
                            accountRowView(for: user)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                    }
                }
            } // Scroll
        } // Vstack
            .padding(.bottom, .bottomInsets + 20)
    }

    private func accountRowView(for user: UserModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(destination: AdminAccountDetailView(detailVM: AdminAccountDetailViewModel(userId: user.id))) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(user.fullName)
                        .font(.customfont(.semibold, fontSize: 16))
                        .foregroundColor(.primaryText)
                    
                    Text("Email: \(user.email)")
                        .font(.customfont(.regular, fontSize: 14))
                        .foregroundColor(.secondaryText)
                    
                    Text("Phone: \(user.phone)")
                        .font(.customfont(.regular, fontSize: 14))
                        .foregroundColor(.secondaryText)
                    
                    Text("Created: \(user.createdAt.displayDate(format: "yyyy-MM-dd"))")
                        .font(.customfont(.regular, fontSize: 14))
                        .foregroundColor(.secondaryText)
                }
            } // na
            .buttonStyle(PlainButtonStyle())

            // Delete Button
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        adminVM.deleteCustomerAccount(id: user.id) { success in
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
        } // Vstack
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    // ------------------------------------------------------------------------------------------------------

    private var productListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) {
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
                                        ForEach(productsInCategory.indices, id: \.self) { index in // [0, 1, 2...]
                                            let product = productsInCategory[index]
                                            productRowView(for: product, category: category.name)
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
                                        productRowView(for: product, category: "Uncategorized")
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
        /*
         let categories = [
             CategoryModel(id: 1, name: "Fruits"),
             CategoryModel(id: 2, name: "Vegetables")
         ]
         let productList = [
             ProductModel(id: 1, name: "Apple", category: "Fruits", brand: "Organic", price: 1.99, imageUrl: "https://example.com/apple.jpg"),
             ProductModel(id: 2, name: "Banana", category: "Fruits", brand: "Generic", price: 0.99, imageUrl: "https://example.com/banana.jpg"),
             ProductModel(id: 3, name: "Carrot", category: "Vegetables", brand: "Organic", price: 0.79, imageUrl: "https://example.com/carrot.jpg"),
             ProductModel(id: 4, name: "Orange", category: nil, brand: "Generic", price: 1.49, imageUrl: "https://example.com/orange.jpg")
         ]
         */
    // ------------------------------------------------------------------------------------------------------

    private var exclusiveOffersView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Exclusive Offers")
                            .font(.customfont(.bold, fontSize: 20))
                            .foregroundColor(.primaryText)
                        Spacer()
                        NavigationLink(
                            destination: AddExclusiveOfferView(adminVM: adminVM),
                            isActive: $isShowingAddExclusiveOffer
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
                    .padding(.top, 5)

                    if adminVM.exclusiveOfferList.isEmpty {
                        Text("No exclusive offers available")
                            .font(.customfont(.medium, fontSize: 18))
                            .foregroundColor(.secondaryText)
                            .padding(.horizontal, 20)
                    } else {
                        LazyVGrid(columns: gridColumns, spacing: 15) {
                            ForEach(adminVM.exclusiveOfferList, id: \.id) { product in
                                productRowView(for: product, category: "Exclusive Offers")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding(.bottom, .bottomInsets + 20)
        }
    }
    // ------------------------------------------------------------------------------------------------------

    private var ordersView: some View {
        VStack(spacing: 0) {
            ordersHeaderView // 2
            ordersListView
        }
    }
    private func orderHeaderView(for order: MyOrderModel) -> some View { // 1
        HStack {
            Text("Order Code: \(order.orderCode)")
                .font(.customfont(.bold, fontSize: 16))
                .foregroundColor(.primaryText)
            Spacer()
            Text(order.status)
                .font(.customfont(.bold, fontSize: 16))
                .foregroundColor(getOrderStatusColor(mObj: order))
        }
    }
    private var ordersListView: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                if ordersVM.orders.isEmpty {
                    Text("No orders found")
                        .font(.customfont(.medium, fontSize: 18))
                        .foregroundColor(.secondaryText)
                        .padding(.top, 20)
                } else {
                    ForEach(ordersVM.orders, id: \.id) { order in
                        NavigationLink {
                            AdminOrderDetailView(detailVM: AdminOrderDetailViewModel(prodObj: order))
                        } label: {
                            orderRowView(for: order)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            ordersVM.loadMoreIfNeeded(currentItem: order)
                        }
                    }
                }

                if ordersVM.isLoadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, .bottomInsets + 20)
        }
    }
    private func orderRowView(for order: MyOrderModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            orderHeaderView(for: order) // 1
            orderDetailsView(for: order)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
    private func orderDetailsView(for order: MyOrderModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(order.createdDate.displayDate(format: "yyyy-MM-dd hh:mm a"))
                .font(.customfont(.regular, fontSize: 12))
                .foregroundColor(.secondaryText)

            orderImageAndDetails(for: order)
        }
    }
    private func orderImageAndDetails(for order: MyOrderModel) -> some View {
        HStack {
            orderImageView(for: order)
            orderDetailsTextView(for: order)
        }
    }

    private func orderImageView(for order: MyOrderModel) -> some View {
        Group {
            if let firstItem = order.items.first, let imageUrl = firstItem.imageUrl, let url = URL(string: imageUrl) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }
        }
    }

    private func orderDetailsTextView(for order: MyOrderModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Items: \(order.items.map { $0.productName }.joined(separator: ", "))")
                .font(.customfont(.medium, fontSize: 14))
                .foregroundColor(.secondaryText)
                .lineLimit(1)

            Text("Payment: \(order.paymentMethod) (\(order.isPaid ? "Paid" : "Unpaid"))")
                .font(.customfont(.medium, fontSize: 14))
                .foregroundColor(order.isPaid ? .green : .red)

            Text("Total: $\(order.totalPrice, specifier: "%.2f")")
                .font(.customfont(.bold, fontSize: 14))
                .foregroundColor(.primaryText)
        }
    }
    // ------------------------------------------------------------------------------------------------------
    private var ordersHeaderView: some View { // 2
        VStack {
            ordersTitleView
            ordersFilterView
            ordersStatisticsView
        }
        .background(Color.white)
    }

    private var ordersTitleView: some View {
        HStack {
            Text("Order Management")
                .font(.customfont(.bold, fontSize: 26))
                .foregroundColor(.primaryText)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, .topInsets)
    }

    private var ordersFilterView: some View {
        Picker("Filter by Status", selection: $selectedOrderStatus) {
            Text("All Orders").tag(nil as String?)
            ForEach(ordersVM.statuses, id: \.self) { status in
                Text(status).tag(status as String?)
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
        .padding(.horizontal, 20)
        .onChange(of: selectedOrderStatus) { newValue in
            ordersVM.fetchOrders(status: newValue, isRefresh: true)
        }
    }

    private var ordersStatisticsView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            StatisticCard(title: "Total Orders", value: "\(ordersVM.statistics["totalOrders"] as? Int ?? 0)")
            StatisticCard(title: "Pending", value: "\(ordersVM.statistics["pendingOrders"] as? Int64 ?? 0)")
            StatisticCard(title: "Completed", value: "\(ordersVM.statistics["completedOrders"] as? Int64 ?? 0)")
            StatisticCard(title: "Revenue", value: String(format: "$%.2f", ordersVM.statistics["totalRevenue"] as? Double ?? 0.0))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }




    
    // ------------------------------------------------------------------------------------------------------

    private func productRowView(for product: ProductModel, category: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(destination: AdminProductDetailView(productId: product.id, adminVM: adminVM)) {
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
                }
            }
            .buttonStyle(PlainButtonStyle())

            productActionsView(for: product)
        }
        .frame(width: 120)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }

    private func productActionsView(for product: ProductModel) -> some View {
        HStack {
            Button(action: {
                editingProduct = ProductRequestModel(
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
                )
            }) {
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
    // ------------------------------------------------------------------------------------------------------

    private func getOrderStatusColor(mObj: MyOrderModel) -> Color {
        switch mObj.status {
        case "PENDING":
            return Color.blue
        case "COMPLETED":
            return Color.green
        case "CANCELLED":
            return Color.red
        case "AWAITING_PICKUP":
            return Color.orange
        default:
            return Color.gray
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.customfont(.medium, fontSize: 14))
                .foregroundColor(.secondaryText)
            Text(value)
                .font(.customfont(.bold, fontSize: 18))
                .foregroundColor(.primaryText)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}

#Preview {
    NavigationView {
        AdminView()
            .environmentObject(MainViewModel.shared)
    }
}
