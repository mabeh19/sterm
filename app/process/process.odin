package process

import ev "../../../event"
import pe "../process_events"

import "core:thread"
import "core:os"
import "core:time"
import "core:log"

read_port_async :: proc(h: os.Handle) -> ^thread.Thread
{
    return thread.create_and_start_with_poly_data(h, proc(h: os.Handle) {
        context.logger = log.create_console_logger()
        for {
            b := [1]u8{}
            if n, err := os.read(h, b[:]); err == .NONE {
                ev.signal(&pe.dataReceivedEvent, b[:])
            } else {
                time.sleep(1 * time.Millisecond)
            }
        }
    })
}
