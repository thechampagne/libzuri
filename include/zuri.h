#ifndef __ZURI_H__
#define __ZURI_H__

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef union {
    char* ip;
    char* name;
} zuri_host_t;

typedef struct {
    char* scheme;
    char* username;
    char* password;
    zuri_host_t host;
    uint16_t port;
    char* path;
    char* query;
    char* fragment;
    size_t len;
} zuri_uri_t;

/*
* Decode a URI
* 
* Example:
* * *
* int main()
* {
*     char* res = zuri_decode("Hello%20World");
*     printf("%s\n", res);
*     free(res);
*     return 0;
* }
* * *
* 
* @param path
* @return dynamic string
*/
extern char* zuri_decode(const char* path);

/*
* Encode a URI
* 
* Example:
* * *
* int main()
* {
*     char* res = zuri_encode("Hello%20World");
*     printf("%s\n", res);
*     free(res);
*     return 0;
* }
* * *
* 
* @param path
* @return dynamic string
*/
extern char* zuri_encode(const char* path);

/*
* Resolve a path
* 
* Example:
* * *
* int main()
* {
*     char* res = zuri_resolve_path("/Hello-World");
*     printf("%s\n", res);
*     free(res);
*     return 0;
* }
* * *
* 
* @param path
* @return dynamic string
*/
extern char* zuri_resolve_path(const char* path);

/*
* Parse a URI
* 
* Example:
* * *
* int main()
* {
*     zuri_uri_t uri;
* 
*     zuri_parse(&uri,"https://ziglang.org/documentation/master/#toc-Introduction", 0);
* 
*     printf("%s\n",  uri.scheme);
*     printf("%s\n",  uri.host.name);
*     printf("%s\n",  uri.path);
*     printf("%s\n",  uri.fragment);
*     printf("%d\n",  uri.port);
*     printf("%lu\n", uri.len);
* 
*     zuri_uri_clean(&uri);
*     return 0;
* }
* * *
* 
* @param zuri_uri pointer to zuri_uri_t
* @param input the uri
* @param assume_auth 0 = false, 1 = true
* @return 0 on success and non zero value on failure
*/
extern int zuri_parse(zuri_uri_t* zuri_uri, const char* input, int assume_auth);

/*
* Is pchar ?
* 
* Example:
* * *
* int main()
* {
*     int res = zuri_is_pchar("Hello World");
*     printf("is pchar: %d\n", res);
*     return 0;
* }
* * *
* 
* @param str
* @return 1 if is pchar and 0 if not
*/
extern int zuri_is_pchar(const char* str);

/*
* Is hex ?
* 
* Example:
* * *
* int main()
* {
*     int res = zuri_is_hex('H');
*     printf("is hex: %d\n", res);
*     return 0;
* }
* * *
* 
* @param c
* @return 1 if is hex and 0 if not
*/
extern int zuri_is_hex(uint8_t c);

/*
* function to free the memory after using zuri_parse
*
* @param zuri_uri pointer to zuri_uri_t
*/
extern void zuri_uri_clean(zuri_uri_t* zuri_uri);

#ifdef __cplusplus
}
#endif

#endif // __ZURI_H__