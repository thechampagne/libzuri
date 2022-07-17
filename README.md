# libzuri

[![](https://img.shields.io/github/v/tag/thechampagne/libzuri?label=version)](https://github.com/thechampagne/libzuri/releases/latest) [![](https://img.shields.io/github/license/thechampagne/libzuri)](https://github.com/thechampagne/libzuri/blob/main/LICENSE)

URI parser for **C**.

### Installation & Setup

#### 1. Clone the repository
```
git clone https://github.com/thechampagne/libzuri.git
```
#### 2. Navigate to the root
```
cd libzuri
```
#### 3. Build the project
```
zig build
```

### Example

```c
#include <assert.h>
#include <string.h>
#include <zuri.h>

int main()
{
    zuri_uri_t uri;

    zuri_parse(&uri,"https://ziglang.org/documentation/master/#toc-Introduction", 0);

    assert(strcmp(uri.scheme, "https") == 0);
    assert(strcmp(uri.host.name, "ziglang.org") == 0);
    assert(strcmp(uri.path, "/documentation/master/") == 0);
    assert(strcmp(uri.fragment, "toc-Introduction") == 0);
    assert(uri.port == 443);
    assert(uri.len == 58);

    zuri_uri_clean(&uri);
    return 0;
}
```

### References
 - [zuri](https://github.com/Vexu/zuri)

### License

This repo is released under the [MIT](https://github.com/thechampagne/libzuri/blob/main/LICENSE).
