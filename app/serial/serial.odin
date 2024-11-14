package serial

import "core:c"
import "core:strings"
import "core:os"

foreign import sl "serial_linux_backend.a"

foreign sl {
    OpenPort :: proc(cstring, ^PortSettingsInternal) -> c.int ---
    ClosePort :: proc(fd: c.int) ---
}

Baudrates :: enum {
    B57600    = 0010001,
    B115200   = 0010002,
    B230400   = 0010003,
    B460800   = 0010004,
    B500000   = 0010005,
    B576000   = 0010006,
    B921600   = 0010007,
    B1000000  = 0010010,
    B1152000  = 0010011,
    B1500000  = 0010012,
    B2000000  = 0010013,
    B2500000  = 0010014,
    B3000000  = 0010015,
    B3500000  = 0010016,
    B4000000  = 0010017,
}


Port :: struct {
    file: os.Handle
}


@private
PortSettingsInternal :: struct {
    baudrate: c.uint32_t,
    parity: c.char,
    stopBits: c.uint8_t,
    blocking: c.bool,
    controlflow: c.bool,
};


PortSettings :: struct {
    port: string,
    baudrate: int,
    parity: u8,
    stopBits: u8,
    blocking: bool,
};


open_port :: proc(settings: PortSettings) -> Port 
{
    port := Port {}

    settings_internal := PortSettingsInternal {
        baudrate = u32(settings.baudrate),
        parity = settings.parity,
        stopBits = settings.stopBits,
        blocking = settings.blocking,
        controlflow = false,
    }

    cport := strings.clone_to_cstring(settings.port)
    defer delete(cport)

    port.file = os.Handle(OpenPort(cport, &settings_internal))

    return port
}

close_port :: proc(port: ^Port) 
{
    ClosePort(c.int(port.file))
}
