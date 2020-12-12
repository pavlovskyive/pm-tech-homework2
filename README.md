# Parimatch Tech Academy

## Homework 2

Student: **Vsevolod Pavlovskyi**

## Assignment

Implement a simple betting system with the following features:

- The system should provide a way to register a new user. Upon the registration, you should provide the user's role (admin or regular user), username, password.

- All usernames must be unique. Abort the registration if the chosen username is already busy. Print the reason why the registration failed.

- Users should be able to login/logout in/from the system.

- When authorized, a regular user should be able to place a new bet.

- A bet is a simple string which contains description of an event.

- An authorized user should be able to print a list of placed bets.

- An authorized admin user should be able to browse all registered regular users.

- An admin user should be able to ban a regular user.

- When the banned user tries to login, he should be rejected. Print the reason why the login failed.

## Tests output

```
---------------------------------
Register, login and logout tests:
---------------------------------

Successful registration of regular user:
📗: Registration completed. Try to login.

Successful registration of admin:
📗: Registration completed. Try to login.

Registration with error:
📕: Username is taken.

Login with error:
📕: Wrong username.
📕: Wrong password.

Successful login:
📗: Logged in successfully.

Successful logout:
📗: Logged out successfully.

Logout with error:
📕: Already logged out.


------------------------
Bets interactions tests:
------------------------

Place bet when unauthorized:
📕: Not logged in.

Login and place two bets:
📗: Logged in successfully.
📗: Bet placed successfully.
📗: Bet placed successfully.

List user's bets:
📗: OK
Na'Vi       - OG          20/12/2020 20:00    W1    30 UAH
Virtus Pro  - Vitality    20/12/2020 18:30    W2    60 UAH


-------------------------
Admin interactions tests:
-------------------------

Trying to list users without admin role:
📕: Access denied.

Login from another client as admin and list users:
📗: Logged in successfully.
📗: OK
[(username: "pavlovskyive", isBanned: false)]

Ban user:
📗: User is banned.

Logout from banned user and trying to login:
📗: Logged out successfully.
📕: Access denied: Current user is banned.
```
