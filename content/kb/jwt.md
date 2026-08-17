---
layout: kb
title:  "JWT"
category: Technologies
---

**JSON Web Token** is an Internet standard for creating JSON-based
authentication tokens. They are generally used to assert some number
of claims.  The server will provide the client a JWT in which the
client will use in subsequent requests. To ensure authenticity and integrity,
the token is signed by the server's private key before sending it to the client.
The client can then verify using the server's public key (usually hosted in a JWKS).

### Structure
There are three main parts to a JWT: **header**, **payload**, and
**signature**. The header identifies which algorithm is used to
generate the signature. The payload contains the set of claims. The
signature validates the token using cryptographic technologies. It
is calculated by base64url encoding the header and payload and
concatenating the two with a `.`, followed by the cryptographic
algorithm specified in the header.

```
# header
{
 "alg" : "HS256",
 "typ" : "JWT"
}

# payload
{
 "loggedInAs" : "admin",
 "iat" : 1573492539
}

# signature
HMAC-SHA256(
 base64urlEncoding(header) + '.' +
 base64urlEncoding(payload),
 secret
)
```

The entire token is structured as follows:
```
base64url(header) + '.' + base64url(payload) + '.' + base64url(signature)
```

### Fields

| Code | Name | Description |
| ---- | ---- | ----------- |
| `iss` | Issuer | The principal that issued the JWT |
| `sub` | Subject | The subject of the JWT |
| `aud` | Audience | The recipients that the JWT is intended for |
| `exp` | Expiration Time | The expiration time after which the JWT must not be accepted (must be seconds since epoch) |
| `nbf` | Not Before | The time on which the JWT will start to be accepted (must be seconds since epoch) |
| `iat` | Issued at | The time at which the JWT was issued (must be seconds since epoch) |
| `jti` | JWT ID | Case sensitive unique identifier of the token even among different issuers |
