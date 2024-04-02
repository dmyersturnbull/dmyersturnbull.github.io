# Linky REST

!!! warning

    This is a draft.

[HAL/HAL-JSON](https://stateless.group/hal_specification.html),
[JSON-LD](https://json-ld.org/), and
[JSON API](https://jsonapi.org/)
are unacceptably cumbersome for many REST-like APIs,
and existing APIs can’t be made conformant without breaking changes.

<b>Example problems:</b>

- JSON API requires putting all of the resource data under a `data` key,
  which is awkward and always a breaking change.
- HAL uses `_embedded` and requires clients to understand CURIEs.
- HTTP methods can’t be included using any of the three standards.

In the spirit of [XKCD #927](https://xkcd.com/927/), here is a new proposal.

!!! note

    The key words _MUST_, _MUST NOT_, _REQUIRED_, _SHALL_, _SHALL NOT_, _SHOULD_, _SHOULD NOT_, _RECOMMENDED_, _MAY_,
    and _OPTIONAL_ in this document are to be interpreted as described in
    [RFC2119](https://www.rfc-editor.org/info/rfc2119).

This standard only defines a `_links` key and a LINK object type.
All objects must be instances of this [JSON Schema](https://json-schema.org/):

```yaml
type: object
properties:
  _links:
    type: object
    required:
      - rel
      - uri
    properties:
      rel:
        type: string
        minLength: 1
      uri:
        type: string
        pattern: '^/'
      method:
        type: string
        default: GET
        enum:
          - HEAD
          - GET
          - PUT
          - PATCH
          - DELETE
          - POST
```

```json
{
  "id": "f0JL+2as-Kf",
  "_links": [
    {"rel":  "friend", "iri":  "/person/0JCl+2KH", "method": "GET"}
  ]
}
```
