package view

import ue "../user_events"
import pe "../process_events"

import rb "../../ringbuffer"
import ev "../../event"
import rl "vendor:raylib"


DATA_BUFFER_SIZE :: 512


run :: proc() 
{
    SCREEN_WIDTH :: 800
    SCREEN_HEIGHT :: 450
    PORT_TOGGLE_OFFSET :: [2]f32{100, 50}
    DATA_VIEW_OFFSET :: [2]f32{0,0}
    INPUT_FIELD_OFFSET :: [2]f32{0,0}

    register_event_handlers()

    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic window")

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {

        rl.BeginDrawing()

        // Drawing logic
        {
            rl.ClearBackground(rl.RAYWHITE)

            draw_port_toggle(PORT_TOGGLE_OFFSET)
            draw_data_view(DATA_VIEW_OFFSET)
            draw_input_field(INPUT_FIELD_OFFSET)
        }

        rl.EndDrawing()
    }

    rl.CloseWindow()
}


@(private)
draw_port_toggle :: proc(offset: [2]f32)
{
    State :: enum {
        OPEN = 0,
        CLOSED = 1
    }
    BUTTON_TEXTS := [State]cstring { .CLOSED = "Open Port", .OPEN = "Close Port"}
    @static state := State.CLOSED
    if rl.GuiButton(rl.Rectangle { x = offset.x, y = offset.y, height = 50, width = 100 }, 
                    BUTTON_TEXTS[state]) {
        state ~= .CLOSED

        ev.signal(&ue.openEvent, state == .OPEN)
    }
}

@(private)
dataBuffer := rb.RingBuffer(DATA_BUFFER_SIZE, u8) {}


@(private)
draw_data_view :: proc(offset: [2]f32)
{

}


@(private)
draw_input_field :: proc(offset: [2]f32)
{

}

@(private)
register_event_handlers :: proc()
{
    ev.listen(&pe.dataReceivedEvent, proc(data: []u8) {
        rb.push(&dataBuffer, data)
    })
}
