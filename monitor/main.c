/* vim: set et ts=4 sw=4 */
#include <ctype.h>
#include <stdint.h>
#include <stdio.h>

extern void __fastcall__ go(const uint16_t addr);
extern void __fastcall__ disable_interrupts(void);
extern void __fastcall__ acia_puts(const char * string);
extern void __fastcall__ acia_putc(const char c);
extern void __fastcall__ acia_prbyte(const char c);
extern char acia_getc();
extern void xmodem();

char input[32];
uint16_t i, j;
char ascii[17];
char byte_buf[3];
char addr_buf[6];

void DumpHex(const uint16_t * data, uint16_t size) {
    ascii[16] = '\0';
    for (i = 0; i < size; ++i) {
        if (i % 16 == 0) {
            acia_prbyte( ((uint16_t)data+i) >> 8);
            acia_prbyte( ((uint16_t)data+i) & 0xFF);
            acia_puts(": ");
        }
        if (i+1 % 8 == 0) acia_puts("- ");
        acia_prbyte( ((uint8_t*)data)[i] );
        acia_putc(' ');

        if (((unsigned char*)data)[i] >= ' ' && ((unsigned char*)data)[i] <= '~') {
            ascii[i % 16] = ((unsigned char*)data)[i];
        } else {
            ascii[i % 16] = '.';
        }
        if ((i+1) % 8 == 0 || i+1 == size) {
            if ((i+1) % 16 == 0) {
                acia_putc('|');
                acia_putc(' ');
                acia_puts(ascii);
                acia_puts("\r\n");
            } else if (i+1 == size) {
                ascii[(i+1) % 16] = '\0';
                if ((i+1) % 16 <= 8) {
                    acia_putc(' ');
                }
                for (j = (i+1) % 16; j < 16; ++j) {
                    acia_puts("   ");
                }
                acia_putc('|');
                acia_putc(' ');
                acia_puts(ascii);
                acia_puts("\r\n");
            }
        }
    }
}
uint16_t hex2int(char *hex) {
    uint16_t val = 0;
    while (*hex) {
        uint8_t byte = *hex++; 
        if (byte >= '0' && byte <= '9') byte = byte - '0';
        else if (byte >= 'a' && byte <='f') byte = byte - 'a' + 10;
        else if (byte >= 'A' && byte <='F') byte = byte - 'A' + 10;
        val = (val << 4) | (byte & 0xF);
    }
    return val;
}

void slice(const char* str, char* result, uint8_t start, uint8_t end) {
    str += start;
    do {
        *result++ = *str++;
        start++;
    } while (start <= end);
}

void help(void) {
    acia_putc(12);
    acia_puts("\r\nBANK Monitor\r\n");
    acia_puts("\r\n"
              "B x     - Switch to ram bank x\r\n"
              "G xxxx  - Jump to address given by xxxx\r\n"
              "H       - Print help\r\n"
              "M xxxx  - Dump a page of memory given by xxxx\r\n"
              "[SPACE] - Dump next page of memory\r\n"
              "R x     - Switch to rom bank x\r\n"
              "X       - Load a file with XModem\r\n"
              );
}

void readstr(uint8_t len, char * buf) {
    char b;
    i = 1;
    do {
        b = acia_getc();
        acia_putc(b);
        switch (b) {
            case '\r':
            case '\n':
                {
                    buf[i] = '\0';
                    return;
                }
            case 0x08:
                {
                    if (i > 1) {
                        i --;
                        acia_putc(' ');
                        acia_putc(0x08);
                    }
                    break;
                }
            default:
                {
                    buf[i] = b;
                    i++;
                    break;
                }
        }
    } while ( i < len);

    buf[i] = '\0';
}

void main(void) {
    char hexaddr[5] = "";
    uint16_t addr;
    char b;
    help();

    while (1) {
        readstr(16, input);
        acia_puts("\r\n");
        b = toupper(input[1]);
        switch (b) {
            case 'B':
                {
                    slice(input, hexaddr, 3, 3+2);
                    addr = hex2int(hexaddr);
                    if ( 0 <= addr <= 63 ) {
                        (*(uint8_t*)0xBF00) = addr & 0xF;
                        sprintf(input, "RAM BANK %d\r\n", addr);
                        acia_puts(input);
                    }
                    break;
                }
            case 'G':
                {
                    slice(input, hexaddr, 3, 3+4);
                    addr = hex2int(hexaddr);
                    go(addr);
                    break;
                }
            case 'M':
                {
                    slice(input, hexaddr, 3, 3+4);
                    addr = hex2int(hexaddr);
                    DumpHex((void*)addr, 0x100);
                    break;
                }
            case ' ':
                {
                    addr = addr + 0x100;
                    DumpHex((void*)addr, 0x100);
                    break;
                }
            case 'H':
                {
                    help();
                    break;
                }
            case 'R':
                {
                    slice(input, hexaddr, 3, 4);
                    addr = hex2int(hexaddr);
                    if ( 0 <= addr <= 3 ) {
                        // Doing it like this because I need this routine in RAM
                        (*(uint8_t*)0xC000) = 0xA9;
                        (*(uint8_t*)0xC001) = addr & 0xF;
                        (*(uint8_t*)0xC002) = 0x8D;
                        (*(uint8_t*)0xC003) = 0x01;
                        (*(uint8_t*)0xC004) = 0xBF;
                        (*(uint8_t*)0xC005) = 0x6C;
                        (*(uint8_t*)0xC006) = 0xFC;
                        (*(uint8_t*)0xC007) = 0xFF;
                        sprintf(input, "Switching to ROM bank %d\r\n",addr & 0xF);
                        acia_puts(input);
                        __asm__("jmp $C000");
                    }
                    break;
                }
            case 'X':
                {
                    xmodem();
                    break;
                }
            default:
                break;
        }
    }
}

