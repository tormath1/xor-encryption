## build

make

## run

```shell
$ ./a.out | od -A x -t x1z -v
000000 92 fd 6d 99 4d 0a fa 98 01 f5 22                 >..m.M....."<
00000b
```

## exploit

* the first 5 bytes represent the mask generated randomly from `/dev/urandom`
* the 5 bytes after `0A` represent the ciphered text

## todo

- [ ] add decryption
- [ ] use stdin to get the plain text
- [ ] remove `/dev/urandom` dependency to work on uc
