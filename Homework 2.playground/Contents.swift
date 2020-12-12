import Foundation

// MARK: - Enums

// Role determines access level of user
enum Role {
    case admin, regular
}

// Errors holds all types of errors that server may throw
enum Errors: Error {
    case usernameIsTaken,
         wrongUsername,
         wrongPassword,
         notAuthorized,
         accessDenied
}

// MARK: - Betting System Implementation

// Betting system acts as server
class BettingSystem {
    
    // User struct stores all necessary information about user
    struct User {
        var username: String
        var password: String
        var role: Role
        var bets = [String]()
        var isBanned = false
        
        var token: UUID?
    }
    
    // users stores all registered users in betting system
    var users = [User]()
    
    // registerUser takes credentials with role to create a new user and add him to database
    func registerUser(username: String, password: String, role: Role = .regular) throws {
        
        // check if there is already a user with such username
        guard !users.map({ $0.username }).contains(username) else {
            throw Errors.usernameIsTaken
        }
        
        users.append(User(username: username, password: password, role: role))
    }
    
    // login takes credentials and returns token if credentials are correct
    func login(username: String, password: String) throws -> UUID {
        
        // check if there is a user with such username
        guard let index = users.firstIndex(where: { $0.username == username}) else {
            throw Errors.wrongUsername
        }
        
        // check if password is correct
        guard users[index].password == password else {
            throw Errors.wrongPassword
        }
        
        // check if user is not banned
        guard users[index].isBanned == false else {
            throw Errors.accessDenied
        }
        
        // generating token and adding it to current user
        let token = UUID()
        users[index].token = token
        
        // each time user will login from another client, session would be expired
        
        return token
    }
    
    // SIDENOTE:
    // Tokens here made with UUID, which means they won't expire until user logs out or logs in from different client (I know it's a bit stupid, because all another sessions would be dissmissed, but if we would change token on such occasions, there would be no need to request server for loggin out, client could just clear its token).
    // I'm fully aware that tokens should have information in it, expiration date and so on, but in case of this homework I decided to go with this plain method for the reason that I don't want to import any side frameworks and packages like JWS.
    // Also I could do authorization with checking username and password everytime request comes to server, but I wanted to implement token approach instead, because sending credentials everytime is not secure, and I'm trying to reach somewhat of a real-life solution, however it's very simplified.
    // SIDENOTE-END
    
    // logout clears token of user
    func logout(token: UUID) throws {
        
        // find user by token
        guard let index = users.firstIndex(where: { $0.token == token }) else {
            throw Errors.notAuthorized
        }
        
        // clear token
        users[index].token = nil
    }
    
    // placeBet takes token to determine which user is placing a bet and appends bet to this user
    func placeBet(bet: String, token: UUID) throws {
        
        // find user by token
        guard let index = users.firstIndex(where: { $0.token == token }) else {
            throw Errors.notAuthorized
        }
        
        // add bet to current user's bets
        users[index].bets.append(bet)
    }
    
    // listBets takes token to determine which user is requesting a list of his bets and returns an array them
    func listBets(token: UUID) throws -> [String] {
        
        // find user by token
        guard let index = users.firstIndex(where: { $0.token == token }) else {
            throw Errors.notAuthorized
        }
        
        return users[index].bets
    }
    
    // listUsers takes token to determine if user is admin and returns an array of all regular users
    func listUsers(token: UUID) throws -> [User] {
        
        // find user by token
        guard let index = users.firstIndex(where: { $0.token == token }) else {
            throw Errors.notAuthorized
        }
        
        // check if this user has admin access
        guard users[index].role == .admin else {
            throw Errors.accessDenied
        }
        
        // return list of only regular users
        return users.filter{ $0.role == .regular}
    }
    
    // banUser takes token to determine if user is admin and username of user to ban
    func banUser(username: String, token: UUID) throws {
        
        // find user(admin) by token
        guard let adminIndex = users.firstIndex(where: { $0.token == token }) else {
            throw Errors.notAuthorized
        }
        
        // check if this user has admin access
        guard users[adminIndex].role == .admin else {
            throw Errors.accessDenied
        }
        
        // find user to ban by token
        guard let userIndex = users.firstIndex(where: { $0.username == username}) else {
            throw Errors.wrongUsername
        }
        
        // check if this user is regular user, because admins can not ban admins
        guard users[userIndex].role == .regular else {
            throw Errors.accessDenied
        }
        
        // ban user
        users[userIndex].isBanned = true
    }
}

// MARK: - Client Implementation

// Creating an instance of Betting Sysytem
let system = BettingSystem()

// Client struct handles users' credentials (tokens) and interracts with server via requests and handles BettingSystem responses for convenient notifications
struct Client {
    
    // stores current user's token
    var token: UUID?
    
    // register takes credentials and requests BettingSystem to register such user
    func register(username: String, password: String, role: Role = .regular) {
        do {
            try system.registerUser(username: username, password: password, role: role)
            print("📗: Registration completed. Try to login.")
        } catch Errors.usernameIsTaken {
            print("📕: Username is taken.")
        } catch {
            print("📕: Unrecognized error.")
        }
    }
    
    mutating func login(username: String, password: String) {
        
        // if token is nil then user is already logged in
        guard token == nil else {
            print("📕: Already logged in. Logout first.")
            return
        }
        
        do {
            token = try system.login(username: username, password: password)
            print("📗: Logged in successfully.")
        } catch Errors.wrongUsername {
            print("📕: Wrong username.")
        } catch Errors.wrongPassword {
            print("📕: Wrong password.")
        } catch Errors.accessDenied {
            print("📕: Access denied: Current user is banned.")
        } catch {
            print("📕: Unrecognized error.")
        }
    }
    
    mutating func logout() {
        
        // if token is not nil then user is already logged out from client
        guard let token = token else {
            print("📕: Already logged out.")
            return
        }
        
        do {
            try system.logout(token: token)
            self.token = nil
            print("📗: Logged out successfully.")
        } catch Errors.notAuthorized {
            print("📕: Not authorized or already logged out.")
        } catch {
            print("📕: Unrecognized error.")
        }
    }
    
    func placeBet(bet: String) {
        
        // if token is nil then user is logged out from client
        guard let token = token else {
            print("📕: Not logged in.")
            return
        }
        
        do {
            try system.placeBet(bet: bet, token: token)
            print("📗: Bet placed successfully.")
        } catch Errors.notAuthorized {
            print("📕: Not authorized. Try to logout and login again.")
        } catch {
            print("📕: Unrecognized error.")
        }
    }
    
    func listBets() {
        
        // if token is nil then user is logged out from client
        guard let token = token else {
            print("📕: Not logged in.")
            return
        }
        
        do {
            let bets = try system.listBets(token: token)
            print("📗: OK")
            
            // print bets lists in convenient way
            print(bets.joined(separator: "\n"))
        } catch Errors.notAuthorized {
            print("📕: Not authorized. Try to logout and login again.")
        } catch {
            print("📕: Unrecognized error.")
        }
    }
    
    func listUsers() {
        
        // if token is nil then user is logged out from client
        guard let token = token else {
            print("📕: Not logged in.")
            return
        }
        
        do {
            let users = try system.listUsers(token: token)
            print("📗: OK")
            
            // print usernames and their banned status
            print(users.map{ (username: $0.username, isBanned: $0.isBanned) })
        } catch Errors.notAuthorized {
            print("📕: Not authorized. Try to logout and login again.")
        } catch Errors.accessDenied {
            print("📕: Access denied.")
        } catch {
            print("📕: Unrecognized error.")
        }
    }
    
    func banUser(_ username: String) {
        
        // if token is nil then user is logged out from client
        guard let token = token else {
            print("📕: Not logged in.")
            return
        }
        
        do {
            try system.banUser(username: username, token: token)
            print("📗: User is banned.")
        } catch Errors.notAuthorized {
            print("📕: Not authorized. Try to logout and login again.")
        } catch Errors.accessDenied {
            print("📕: Access denied.")
        } catch Errors.wrongUsername{
            print("📕: Wrong username.")
        } catch {
            print("📕: Unrecognized error.")
        }
    }
}

// MARK: - Testing

// Creating an instance of client
var client = Client()

print("---------------------------------")
print("Register, login and logout tests:")
print("---------------------------------")

print("\nSuccessful registration of regular user:")
client.register(username: "pavlovskyive", password: "12345678")

print("\nSuccessful registration of admin:")
client.register(username: "admin", password: "admin", role: .admin)

print("\nRegistration with error:")
client.register(username: "pavlovskyive", password: "12345678")

print("\nLogin with error:")
client.login(username: "pavlovskyi", password: "12345678")
client.login(username: "pavlovskyive", password: "1234567")

print("\nSuccessful login:")
client.login(username: "pavlovskyive", password: "12345678")

print("\nSuccessful logout:")
client.logout()

print("\nLogout with error:")
client.logout()

print("\n\n------------------------")
print("Bets interactions tests:")
print("------------------------")

print("\nPlace bet when unauthorized:")
client.placeBet(bet: "Na'Vi       - OG          20/12/2020 20:00    W1    30 UAH")

print("\nLogin and place two bets:")
client.login(username: "pavlovskyive", password: "12345678")
client.placeBet(bet: "Na'Vi       - OG          20/12/2020 20:00    W1    30 UAH")
client.placeBet(bet: "Virtus Pro  - Vitality    20/12/2020 18:30    W2    60 UAH")

print("\nList user's bets:")
client.listBets()

print("\n\n-------------------------")
print("Admin interactions tests:")
print("-------------------------")

print("\nTrying to list users without admin role:")
client.listUsers()

print("\nLogin from another client as admin and list users:")
var client1 = Client()
client1.login(username: "admin", password: "admin")
client1.listUsers()

print("\nBan user:")
client1.banUser("pavlovskyive")

print("\nLogout from banned user and trying to login:")
client.logout()
client.login(username: "pavlovskyive", password: "12345678")
