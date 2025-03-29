# Configuring auth0

## Setting up a post-login action

1. Create an action called, "Add roles to payload", then copy and paste the following code:

```js
/**
 * @param {Event} event - Details about the user and the context in which they are logging in.
 * @param {PostLoginAPI} api - Interface whose methods can be used to change the behavior of the login.
 */
exports.onExecutePostLogin = async (event, api) => {
  const namespace = "https://tesfafund-api.example.com";
  if (event.authorization) {
    api.idToken.setCustomClaim(`${namespace}/roles`, event.authorization.roles);
    api.accessToken.setCustomClaim(
      `${namespace}/roles`,
      event.authorization.roles,
    );
  }
};
```

2. Press 'Deploy' to save and deploy the action.
