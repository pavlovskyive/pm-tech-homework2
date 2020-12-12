# Parimatch Tech Academy

## Homework 2

Student: **Vsevolod Pavlovskyi**

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
