//
//  ProfileView.swift
//  tasked
//
//  Created by Darko Skerlevski on 3.1.23.
//

import SwiftUI
import FirebaseStorage
import AlertToast

struct ProfileView: View {
    @State var isPresented: Bool = false
    @State var showLogoutAlert: Bool = false
    @State var syncAlertPresented: Bool = false
    @AppStorage("offlineTasks") var offlineTasks: [CustomTask] = [CustomTask]()
    @AppStorage("offlineDeletedTasks") var offlineDeletedTasks: [CustomTask] = [CustomTask]()
    @ObservedObject var userManager: UserManager
    @ObservedObject var storageManager: StorageManager = StorageManager()
    
    var body: some View {
        NavigationView {
            VStack {
                if userManager.isLoggedIn {
                    VStack {
                        Header(storageManager: storageManager, userManager: userManager)
                        ProfileText(userManager: userManager)
                    }
                    .onAppear {
                        if !offlineTasks.isEmpty || !offlineDeletedTasks.isEmpty {
                            syncAlertPresented = true
                        }
                    }
                    .alert("Detected offline tasks, how would you like to proceed?", isPresented: $syncAlertPresented) {
                        Button("Sync with this account") {
                            userManager.syncTasks(firstTaskList: offlineTasks, secondTaskList: offlineDeletedTasks)
                            offlineTasks = []
                            offlineDeletedTasks = []
                        }
                        Button("Discard all offline tasks", role: .destructive) {
                            offlineTasks = []
                            offlineDeletedTasks = []
                        }
                        Button("Log out of the account", role: .cancel) {
                            userManager.logout()
                        }
                        
                    }
                    Spacer()
                    VStack {
                        Button(action: {
                            self.isPresented = true
                        }) {
                            
                            Text("Edit profile")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(.vertical)
                                .padding(.horizontal, 50)
                                .background(LinearGradient(colors: [.cyan, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Capsule())
                                .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5)
                                .foregroundColor(.red)
                        }
                        .offset(y: 25)
                        .padding(.bottom, 32)
                        .sheet(isPresented: $isPresented, content: {
                            SettingsView(storageManager: storageManager, userManager: userManager)
                        })
                        Button(action: {
                            showLogoutAlert.toggle()
                        }) {
                            Text("Logout")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(.vertical)
                                .padding(.horizontal, 50)
                                .background(LinearGradient(colors: [.red, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Capsule())
                                .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5)
                                .foregroundColor(.red)
                        }
                        .alert(isPresented: $showLogoutAlert) {
                            Alert(
                                title: Text("Logout?"),
                                message: Text("Are you sure you want to log out?"),
                                primaryButton: .destructive(Text("Logout"), action: { userManager.logout() }),
                                secondaryButton: .default(Text("Cancel"), action: { showLogoutAlert = false })
                            )
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.bottom, 5)
                } else {
                    LoginView(userManager: userManager)
                }
            }
        }
    }
}

struct LoginView : View {
    
    @ObservedObject var userManager: UserManager
    @State var email = ""
    @State var pass = ""
    
    var isSignInButtonDisabled: Bool {
        [email, pass].contains(where: \.isEmpty)
    }
    
    var body: some View{
        ZStack(alignment: .bottom) {
            VStack{
                HStack{
                    VStack(spacing: 10){
                        Image("logo")
                            .resizable()
                            .frame(width: 60, height: 60)
                        HStack {
                            Spacer()
                            Text("Sign in")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        Capsule()
                            .fill(Color.blue)
                            .frame(width: 100, height: 5)
                    }
                }
                .padding(.top, 30)// for top curve...
                VStack{
                    HStack(spacing: 15){
                        Image(systemName: "envelope.fill")
                        .foregroundColor(Color("Color1"))
                        TextField("Email Address", text: self.$email)
                            .keyboardType(.emailAddress)
                    }
                    
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 40)
                VStack{
                    HStack(spacing: 15){
                        Image(systemName: "eye.slash.fill")
                        .foregroundColor(Color("Color1"))
                        SecureField("Password", text: self.$pass)
                    }
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 30)
                HStack {
                    Spacer()
                    NavigationLink(destination: SignUpView(userManager: userManager)) {
                        Text("register here")
                            .font(.title3.smallCaps())
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 30)
            }
            .padding()
            .padding(.bottom, 65)
            .contentShape(CShape1())
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: -5)
            .cornerRadius(35)
            .padding(.horizontal,20)
            Button(action: {
                userManager.login(email: email, pass: pass)
            }) {
                
                Text("Sign in")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .padding(.horizontal, 50)
                    .background( isSignInButtonDisabled ? LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [.blue, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5)
                    .foregroundColor(.red)
            }
            .offset(y: 25)
            .disabled(isSignInButtonDisabled)
        }
        .toast(isPresenting: $userManager.showToast) {
            AlertToast(displayMode: .hud, type: .error(.red), title: "Login unsuccessful", subTitle: "Incorrect email or password!")
        }
    }
}

struct SignUpView : View {
    
    @ObservedObject var userManager: UserManager
    @State var email = ""
    @State var pass = ""
    @State var Repass = ""
    @State var name = ""
    @State var title = ""
    @Environment(\.dismiss) var dismiss
    
    var isSignUpButtonDisabled: Bool {
        [email, pass, Repass, name, title].contains(where: \.isEmpty)
    }
    
    var body: some View{
        ZStack(alignment: .bottom) {
            VStack{
                HStack{
                    VStack(spacing: 10){
                        Image("logo")
                            .resizable()
                            .frame(width: 60, height: 60)
                        HStack {
                            Spacer()
                            Text("Sign Up")
                                .background(Color(UIColor.systemBackground))
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        Capsule()
                            .fill(Color.blue)
                            .frame(width: 100, height: 5)
                    }
                }
                .padding(.top, 30)// for top curve...
                VStack{
                    HStack(spacing: 15){
                        Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(Color("Color1"))
                        TextField("Name", text: self.$name)
                    }
                    
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 40)
                VStack{
                    HStack(spacing: 15){
                        Image(systemName: "person.crop.square.fill")
                        .foregroundColor(Color("Color1"))
                        TextField("Title", text: self.$title)
                    }
                    
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 30)
                VStack{
                    HStack(spacing: 15){
                        Image(systemName: "envelope.fill")
                        .foregroundColor(Color("Color1"))
                        TextField("Email Address", text: self.$email)
                            .keyboardType(.emailAddress)
                    }
                    
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 30)
                VStack{
                    HStack(spacing: 15){
                        Image(systemName: "eye.slash.fill")
                        .foregroundColor(Color("Color1"))
                        SecureField("Password", text: self.$pass)
                    }
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 30)
                VStack{
                    HStack(spacing: 15){
                        Image(systemName: "eye.slash.fill")
                        .foregroundColor(Color("Color1"))
                        SecureField("Repeat Password", text: self.$Repass)
                    }
                    Divider().background(Color.white.opacity(0.5))
                }
                .padding(.horizontal)
                .padding(.top, 30)
            }
            .padding()
            .padding(.bottom, 65)
            .contentShape(CShape1())
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: -5)
            .cornerRadius(35)
            .padding(.horizontal,20)
            Button(action: {
                if pass == Repass {
                    userManager.register(email: email, pass: pass, name: name, title: title)
                } else {
                    userManager.showToast = true
                }
            }) {
                
                Text("SIGNUP")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .padding(.horizontal, 50)
                    .background( isSignUpButtonDisabled ? LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [.blue, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5)
                    .foregroundColor(.red)
            }
            .offset(y: 25)
            .disabled(isSignUpButtonDisabled)

        }
        .toast(isPresenting: $userManager.showToast) {
            AlertToast(displayMode: .hud, type: .error(.red), title: "Register failed", subTitle: "Passwords must match!")
        }
        .toast(isPresenting: $userManager.errorCreatingUser) {
            AlertToast(displayMode: .hud, type: .error(.red), title: "Error creating user", subTitle: "User with email already exists or password not strong enough")
        }
    }
}

struct Header: View {
    @AppStorage("rValue") var rValue = DefaultSettings.rValue
    @AppStorage("gValue") var gValue = DefaultSettings.gValue
    @AppStorage("bValue") var bValue = DefaultSettings.bValue
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var userManager: UserManager
    
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(Color(red: userManager.r, green: userManager.g, blue: userManager.b, opacity: 1.0))
                .edgesIgnoringSafeArea(.top)
                .frame(height: 100)
            if storageManager.imageReadyAfterUpload {
                ProfileURLImage()
            } else {
                Image(uiImage: (UIImage(systemName: "person.crop.circle.fill")?.scalePreservingAspectRatio(width: 200, height: 150))!)
            }
        }
    }
}

struct ProfileText: View {
//    @AppStorage("name") var name = DefaultSettings.name
//    @AppStorage("subtitle") var subtitle = DefaultSettings.subtitle
    @ObservedObject var userManager: UserManager
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 5) {
                Text(userManager.name)
                    .bold()
                    .font(.title)
                Text(userManager.title)
                    .font(.body)
                    .foregroundColor(.secondary)
            }.padding()
            Spacer()
        }
    }
}

struct CShape1 : Shape {
    
    func path(in rect: CGRect) -> Path {
        
        return Path{path in

            // left side curve...
            
            path.move(to: CGPoint(x: 0, y: 100))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userManager: UserManager())
    }
}
