//
//import SwiftUI
//import CountryPicker
//
//
//struct SignInView: View {
//    @State var txtMobile: String = ""
//    @State var isShowPicker: Bool = false
//    @State var countryObj: Country? // maybe nill -> assign value for .onAppear
//
//    var body: some View {
//        ZStack {
//            
//            Image("bottom_bg")
//                .resizable()
//                .scaledToFill()
//                .frame(width: .screenWidth, height: .screenHeight)
//            
//            VStack {
//                Image("sign_in_top")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: .screenWidth, height: .screenHeight)
//                
//                Spacer()
//            }
//            
//            ScrollView {
//                
//                VStack(alignment: .leading) {
//                    Text ("Get your groceries\nwith nectar")
//                        .font(.customfont(.semibold, fontSize: 26))
//                        .foregroundColor(.primaryText)
//                        .multilineTextAlignment(.leading)
//                        .padding(.bottom, 25)
//                    
//                    HStack {
//                        Button {
//                            isShowPicker = true
//                        }label: {
//                            // Image("")
//                            if let countryObj = countryObj {
//                                
//                                Text("\(countryObj.isoCode.getFlag())")
//                                    .font(.customfont(.semibold, fontSize: 35))
//                                    .foregroundColor(.primaryText)
//                                
//                                Text("\(countryObj.phoneCode)")
//                                    .font(.customfont(.semibold, fontSize: 18))
//                                    .foregroundColor(.primaryText)
//                            }
//                            
//                        }
//                        TextField("Enter Mobile", text: $txtMobile)
//                            .frame(minWidth: 0, maxWidth: .infinity)
//                        
//                    }
//                    
//                    NavigationLink {
//                        LoginView()
//                    } label: {
//                        Text ("Continue with Email Sign In")
//                            .font(.customfont(.semibold, fontSize: 18))
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.center)
//                    }
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
//                    .background(Color(hex: "5383EC"))
//                    .cornerRadius(20)
//                    .padding(.bottom, 8)
//                    
//                    
//                    NavigationLink {
//                        SignUpView()
//                    } label: {
//                        Text ("Continue with Email Sign Up")
//                            .font(.customfont(.semibold, fontSize: 18))
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.center)
//                    }
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
//                    .background(Color.primaryApp)
//                    .cornerRadius(20)
//                    .padding(.bottom, 8)
//                    
//                    
//                    Divider ()
//                        .padding(.bottom, 25)
//                    
//                    Text ("Or connect with social media")
//                        .font(.customfont(.semibold, fontSize: 14))
//                        .foregroundColor(.textTitle)
//                        .multilineTextAlignment(.center)
//                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                        .padding(.bottom, 25)
//                    
//                    
//                    Button{
//                        
//                    } label: {
//                        Image("google_logo")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 20, height: 20)
//                        
//                        Text ("Continue with Google")
//                            .font(.customfont(.semibold, fontSize: 18))
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.center)
//                    }
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
//                    .background(Color(hex: "5383EC"))
//                    .cornerRadius(20)
//                    .padding(.bottom, 8)
//                    
//                    Button{
//                        
//                    } label: {
//                        
//                        Image("fb_logo")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 20, height: 20)
//                        Text ("Continue with Facebook")
//                            .font(.customfont(.semibold, fontSize: 18))
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.center)
//                    }
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
//                    .background(Color(hex: "4A66AC"))
//                    .cornerRadius(20)
//                    
//                }
//                // Vstack
//                .padding(.horizontal, 20)
//                .frame(width: .screenWidth, alignment: .leading)
//                .padding(.top, .topInsets + .screenWidth * 0.7)
//                
//                
//               
//            }
//        }
//        /*
//         - Nếu không có onAppear, countryObj ban đầu là nil, khiến nút chọn quốc gia không hiển thị gì cả.
//         - onAppear giúp đặt một giá trị mặc định ngay khi giao diện xuất hiện.
//         */
//        .onAppear {
//            self.countryObj = Country(phoneCode: "+1", isoCode: "US")
//        }
//        // choose country
//        .sheet(isPresented: $isShowPicker, content: {
//            CountryPickerUI(country: $countryObj)
//            // countryObj = Country(phoneCode: "+84", isoCode: "VN")
//        })
//        .navigationTitle("")
//        .navigationBarBackButtonHidden(true)
//        .navigationBarHidden(true)
//        .ignoresSafeArea()
//    }
//}
//
//#Preview {
//    NavigationView {
//        SignInView()
//    }
//}
//
