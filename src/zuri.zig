// Copyright (c) 2022 XXIV
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
const std = @import("std");
const zuri = @import("zuri");
const allocator = std.heap.c_allocator;

const zuri_host_t = extern union {
    ip: [*c]u8,
    name: [*c]u8
};

const zuri_uri_t = extern struct {
    scheme: [*c]u8,
    username: [*c]u8,
    password: [*c]u8,
    host: zuri_host_t,
    port: u16,
    path: [*c]u8,
    query: [*c]u8,
    fragment: [*c]u8,
    len: usize,
};

/// Decode a URI
/// 
/// Example:
/// * *
/// int main()
/// {
///     char* res = zuri_decode("Hello%20World");
///     printf("%s\n", res);
///     free(res);
///     return 0;
/// }
/// * *
/// 
/// @param path
/// @return dynamic string
export fn zuri_decode(path: [*c]const u8) [*c]u8 {
     const res = zuri.Uri.decode(allocator, std.mem.span(path)) catch return null;

    if (res) |s| {
        return s.ptr;
    }
    return null;
}

/// Encode a URI
/// 
/// Example:
/// * *
/// int main()
/// {
///     char* res = zuri_encode("Hello%20World");
///     printf("%s\n", res);
///     free(res);
///     return 0;
/// }
/// * *
/// 
/// @param path
/// @return dynamic string
export fn zuri_encode(path: [*c]const u8) [*c]u8 {
     const res = zuri.Uri.encode(allocator, std.mem.span(path)) catch return null;

    if (res) |s| {
        return s.ptr;
    }
    return null;
}

/// Resolve a path
/// 
/// Example:
/// * *
/// int main()
/// {
///     char* res = zuri_resolve_path("/Hello-World");
///     printf("%s\n", res);
///     free(res);
///     return 0;
/// }
/// * *
/// 
/// @param path
/// @return dynamic string
export fn zuri_resolve_path(path: [*c]const u8) [*c]u8 {
    const res = zuri.Uri.resolvePath(allocator, std.mem.span(path)) catch return null;
    return res.ptr;
}

/// Parse a URI
/// 
/// Example:
/// * *
/// int main()
/// {
///     zuri_uri_t uri;
/// 
///     zuri_parse(&uri,"https://ziglang.org/documentation/master/#toc-Introduction", 0);
/// 
///     printf("%s\n",  uri.scheme);
///     printf("%s\n",  uri.host.name);
///     printf("%s\n",  uri.path);
///     printf("%s\n",  uri.fragment);
///     printf("%d\n",  uri.port);
///     printf("%lu\n", uri.len);
/// 
///     zuri_uri_clean(&uri);
///     return 0;
/// }
/// * *
/// 
/// @param zuri_uri pointer to zuri_uri_t
/// @param input the uri
/// @param assume_auth 0 = false, 1 = true
/// @return 0 on success and non zero value on failure
export fn zuri_parse(zuri_uri: ?*zuri_uri_t,input: [*c]const u8, assume_auth: c_int) c_int {
    if (zuri_uri) |uri| {
    var cbool = true;
    if (assume_auth == 0) { cbool = false; }
    const res = zuri.Uri.parse(std.mem.span(input), cbool) catch return -1;
    uri.* = .{
        .scheme = if (res.scheme.len == 0) null else (allocator.alloc(u8, res.scheme.len) catch return -1).ptr,
        .username = if (res.username.len == 0) null else (allocator.alloc(u8, res.username.len) catch return -1).ptr,
        .password = if (res.password.len == 0) null else (allocator.alloc(u8, res.password.len) catch return -1).ptr,
        .host = .{ .name = undefined },
        .port =  if (res.port) |val| val else 0,
        .path = if (res.path.len == 0) null else (allocator.alloc(u8, res.path.len) catch return -1).ptr,
        .query = if (res.query.len == 0) null else (allocator.alloc(u8, res.query.len) catch return -1).ptr,
        .fragment = if (res.fragment.len == 0) null else (allocator.alloc(u8, res.fragment.len) catch return -1).ptr,
        .len = res.len,
    };
 
    if (uri.scheme != null) {
    _ = std.fmt.bufPrint(std.mem.span(uri.scheme), "{s}", .{res.scheme}) catch return -1;
    }
    if (uri.username != null) {
        _ = std.fmt.bufPrint(std.mem.span(uri.username), "{s}", .{res.username}) catch return -1;
    }
    if (uri.password != null) {
    _ = std.fmt.bufPrint(std.mem.span(uri.password), "{s}", .{res.password}) catch return -1;
    }
    if (uri.path != null) {
    _ = std.fmt.bufPrint(std.mem.span(uri.path), "{s}", .{res.path}) catch return -1;
    }
    if (uri.query != null) {
    _ = std.fmt.bufPrint(std.mem.span(uri.query), "{s}", .{res.query}) catch return -1;
    }
    if (uri.fragment != null) {
    _ = std.fmt.bufPrint(std.mem.span(uri.fragment), "{s}", .{res.fragment}) catch return -1;
    }

    switch (res.host) {
        .ip => |value| {
            const str = std.fmt.allocPrint(allocator, "{s}", .{value}) catch return -1;
            uri.host = .{ .ip = if (str.len == 0) null else str.ptr };
            },
        .name => |value| {
            uri.host = .{ .name = if (value.len == 0) null else (allocator.alloc(u8, value.len) catch return -1).ptr };
            if (uri.host.name != null) {
            _ = std.fmt.bufPrint(std.mem.span(uri.host.name), "{s}", .{value}) catch return -1;
            }
        }
    }
    return 0;
    }
    return -1;
}

/// Is pchar ?
/// 
/// Example:
/// * *
/// int main()
/// {
///     int res = zuri_is_pchar("Hello World");
///     printf("is pchar: %d\n", res);
///     return 0;
/// }
/// * *
/// 
/// @param str
/// @return 1 if is pchar and 0 if not
export fn zuri_is_pchar(str: [*c]const u8) c_int {
    const res = zuri.Uri.isPchar(std.mem.span(str));
    if (res) {
        return 1;
    } else {
        return 0;
    }
}

/// Is hex ?
/// 
/// Example:
/// * *
/// int main()
/// {
///     int res = zuri_is_hex('H');
///     printf("is hex: %d\n", res);
///     return 0;
/// }
/// * *
/// 
/// @param c
/// @return 1 if is hex and 0 if not
export fn zuri_is_hex(c: u8) c_int {
    const res = zuri.Uri.isHex(c);
    if (res) {
        return 1;
    } else {
        return 0;
    }
}

/// function to free the memory after using zuri_parse
///
/// @param zuri_uri pointer to zuri_uri_t
export fn zuri_uri_clean(zuri_uri: ?*zuri_uri_t) void {
    if (zuri_uri) |uri| {
        if (uri.*.scheme) |scheme| {
            allocator.free(std.mem.span(scheme));
        }
        if (uri.*.username) |username| {
            allocator.free(std.mem.span(username));
        }
        if (uri.*.password) |password| {
            allocator.free(std.mem.span(password));
        }
        if (uri.*.path) |path| {
            allocator.free(std.mem.span(path));
        }
        if (uri.*.query) |query| {
            allocator.free(std.mem.span(query));
        }
        if (uri.*.fragment) |fragment| {
            allocator.free(std.mem.span(fragment));
        }
        if (uri.*.host.name) |value| {
            allocator.free(std.mem.span(value));
        }
    }
}