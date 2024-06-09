# HATEOAS `See` header

!!! tip "Status: ready to use"

    This specification is legitimately useful and ready to go.
    No changes are anticipated to be needed.

[HAL/HAL-JSON](https://stateless.group/hal_specification.html),
[JSON-LD](https://json-ld.org/), and
[JSON API](https://jsonapi.org/)
are unacceptably cumbersome for many REST-like APIs,
and existing APIs can’t be made conformant without breaking changes.

<b>Example problems:</b>

- JSON API requires putting all the resource data under a `data` key,
  which is awkward and always a breaking change.
- HAL uses `_embedded` and requires clients to understand CURIEs.
- HTTP methods can’t be included using any of the three standards.

In the spirit of [XKCD #927](https://xkcd.com/927/), here is a new proposal.

## HTTP `See` header specification

To avoid polluting your JSON response payloads, the links should be encoded in an HTTP header.
This nonstandard header is called `Link`.
<small>
Note: the `X-` prefix convention [is deprecated](https://datatracker.ietf.org/doc/html/rfc6648).
</small>

Example:

```text
See: <https://api.tld>; rel="delete"; method="DELETE", <https://api.tld?page=2>; rel="next"; method="GET"
```

??? "ABNF"

    Refer to the [ABNF (RFC5234)](https://datatracker.ietf.org/doc/html/rfc5234) docs.

    ```text
    see = "See:" *1(*SP link *("," *SP link))
    link     = "<" URI ">" *(";" *SP param)
    param    = ("method=" method) / ("rel=" rel) / ("doc=" "<" URI ">")
    method   = "HEAD" / "GET" / "PUT" / "DELETE" / "PATCH" / "POST"
    rel      = 1*TCHAR

    ; tchar as defined in RFC 7230 for valid characters in a token
    TCHAR    = "!" / "#" / "$" / "%" / "&" / "'" / "*" / "+" / "-" / "."
               / "^" / "_" / "`" / "|" / "~" / DIGIT / ALPHA
    ```

??? "XML meta-grammar"

    Refer to [XML’s custom meta-grammar](https://www.w3.org/TR/xml/#sec-notation).

    ```text
    see      ::= "See:" ( link ("," ' '* link)* )?
    link     ::= "<" URI ">" (";" ' '* param)*
    param    ::= ("method=" method) | ("rel=" rel) | ("doc=" "<" URI ">")
    method   ::= "HEAD" | "GET" | "PUT" | "DELETE" | "PATCH" | "POST"
    rel      ::= TCHAR+

    URI      ::= <per RFC 3986>
    ; tchar as defined in RFC 7230 for valid characters in a token
    TCHAR    ::= [!#$%&'*+.^_`|~0-9A-Za-z-]
    ```

## Suggested rels

- Pagination: `prev`, `next`, `first`, `last`, `up`
- Actions: `validate`, `submit`, `clone`
- This resource: `metadata`, `data`
- Context: `about`, `history`
- Other resources: `related`


## Python encoder and decoder

```python
import re
from dataclasses import asdict, dataclass
from typing import Iterable, Self
from urllib.parse import unquote, urlencode


_LINK_PATTERN = re.compile(r"(?:^|, *)<(?P<uri>[^>]+)>(?P<params>[^,]+)")
_PARAMS_PATTERN = re.compile(r"(?:^|; *)(?P<key>method|rel|doc)=<?(?P<value>[^ ;>]+)>?")


@dataclass(slots=True, frozen=True, order=True)
class See:
    uri: str
    method: str | None
    rel: str | None
    doc: str | None


class SeeEncoding:

    def encode(self: Self, see_links: Iterable[See]) -> str:
        return ", ".join(self._encode_single(see) for see in see_links)

    def decode(self: Self, header: str) -> list[See]:
        return [
            self._decode_single(m.group("uri"), m.group("params"))
            for m in _LINK_PATTERN.finditer(header)
        ]

    def _encode_single(self: Self, see: See) -> str:
        data = {
            k: urlencode(f"<{v}>") if k == "doc" else urlencode(v)
            for k, v in asdict(see).items()
            if k != "uri"
        }
        return "; ".join([f"<{urlencode(see.uri)}>", *data])

    def _decode_single(self: Self, uri: str, params: str) -> See:
        data = {
            m.group("key"): unquote(m.group("value"))
            for m in _PARAMS_PATTERN.finditer(params)
        }
        return See(uri, **data)
```
