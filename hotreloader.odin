package hotreloader

import "core:fmt"
import i "base:intrinsics"
import "core:io"
import "core:os"
import "core:time"
import "core:sync"
import dll "core:dynlib"

import fw "../filewatcher"


Procs :: struct {
    __handle: dll.Library,
    draw: proc(),
    init: proc(),
    close: proc(),
    should_close : proc() -> bool
}


lib : dll.Library = nil
lib_lock := sync.Mutex{}

procs := Procs {}

main :: proc()
{
    APP_PATH :: "./app.so"
    APP_DRAW :: "view_draw"
    APP_INIT :: "view_init"
    APP_CLOSE :: "view_close"
    APP_SHOULD_CLOSE :: "view_should_close" 

    watcher := fw.new_watcher()
    defer fw.stop(watcher)

    x := 0
    fw.watch(watcher, APP_PATH, &x, proc(x: ^int) {
        if sync.mutex_guard(&lib_lock) {
            fmt.println("Loading lib")
            
            if procs.close != nil {
                //procs.close()
            }

            if count, ok := dll.initialize_symbols(&procs, APP_PATH, "view_"); ok {
                //procs.init()
                fmt.println("loaded")
            }
        }
    })

    for procs.init == nil {
        time.sleep(100 * time.Millisecond)
    }

    procs.init()

    should_close := false
    for !should_close {
        if sync.mutex_guard(&lib_lock) {
            procs.draw()

            should_close = procs.should_close()
        }

        time.sleep(1 * time.Millisecond)
    }

    if sync.mutex_guard(&lib_lock) {
        procs.close()
    }
}

