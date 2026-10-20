# Payment credentials

This cleanup removes the identified embedded administrator, test-account and
wallet credentials from these inactive projects. Keep credentials outside version
control. Removing a value from source does not revoke it or erase Git history.

## Current behavior

- Removed dormant administrator-password fallbacks from SDK comments.
- Removed the example encryption key, embedded accounts/passwords and automatic demo network actions.
- The example's `configureDemo(account:adminName:adminPassword:)` accepts caller-supplied disposable test credentials. Call a demo action explicitly only after it returns true.
- Removed HTTP request-body/response logging, which could expose passwords and tokens.
- README snippets use a caller-provided `userPassword` variable instead of a shared password.

## Re-enabling development

Obtain fresh, narrowly scoped test credentials and provide them at runtime through
the existing SDK configuration APIs (or the example's explicit configuration
method, where provided). Do not restore the removed values from Git history or
commit replacement secrets in source, examples, resources or signing settings.
Production administrator access belongs behind a trusted service; packaging an
administrator password in a mobile application does not keep it secret.

The published historical credentials must be treated as exposed. Their owner
must revoke or rotate any values still accepted by the server before reuse of
these projects. This source cleanup does not change server accounts, remove old
tags/releases, rewrite history or automatically close secret-scanning alerts.
