---
layout: kb
title:  "JWK"
category: Technologies
---

**JSON Web Key** is a JSON data structure that represents a cryptographic key.

```
{
    "kty":"EC",
    "crv":"P-256",
    "x":"f83OJ3D2xF1Bg8vub9tLe1gHMzV76e8Tus9uPHvRVEU",
    "y":"x_FEzRu9m36HLN_tue659LNpXW6pCyStikYjKIWI5a0",
    "kid":"goat"
}
```

| Key | Description |
| --- | --- |
| `kty` | Key type - cryptographic algorithm family |
| `use` | Intended use of the public key (`sig` or `enc`) |
| `alg` | Algorithm intended for use with the key |
| `kid` | Key ID  - used to match a specific key in a set |

Reference: [RFC 7517 - JSON Web Key](https://tools.ietf.org/html/rfc7517)

**JSON Web Key Set** is a set of JWKs.

```
{
    "keys": [
        key1,
        key2,
        key3,
    ]
}
```

**Note:** `key1`, `key2`, and `key3` are JWK objects.
