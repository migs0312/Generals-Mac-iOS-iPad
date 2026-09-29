#include "SagePatch/Hooks.h"
#include "SagePatch/Features.h"
#include "SagePatch/Logger.h"

namespace sagepatch {

bool handleKeyDown(const SDL_KeyboardEvent& ev) {
    if (ev.repeat) return false;

    SDL_Window* window = SDL_GetWindowFromID(ev.windowID);
    if (!window) return false;

    const bool ctrl = (ev.mod & SDL_KMOD_CTRL) != 0;
    // @fix Window-snap must not share a chord with the game: the SDL_PollEvent
    // interposer drops every key handled here, so the game never sees it. The
    // shipped CommandMap.ini binds every plain modifier on the number keys
    // (none = select team, Ctrl = create, Shift = add, Alt = view), but the
    // engine's input layer never reads SDL_KMOD_GUI, so Cmd+1..5 is free on
    // macOS. Windows and most Linux desktops claim Super+number for themselves.
    const bool cmd = (ev.mod & SDL_KMOD_GUI) != 0;

    switch (ev.key) {
        case SDLK_F11:
            takeScreenshot(window);
            return true;

        case SDLK_SCROLLLOCK:
            toggleCursorLock(window);
            return true;

        case SDLK_PAGEUP:
            if (ctrl) { adjustBrightness(+8); return true; }
            break;
        case SDLK_PAGEDOWN:
            if (ctrl) { adjustBrightness(-8); return true; }
            break;

        case SDLK_1:
            if (cmd) { moveWindow(window, WindowPosition::Center); return true; }
            break;
        case SDLK_2:
            if (cmd) { moveWindow(window, WindowPosition::TopLeft); return true; }
            break;
        case SDLK_3:
            if (cmd) { moveWindow(window, WindowPosition::TopRight); return true; }
            break;
        case SDLK_4:
            if (cmd) { moveWindow(window, WindowPosition::BottomLeft); return true; }
            break;
        case SDLK_5:
            if (cmd) { moveWindow(window, WindowPosition::BottomRight); return true; }
            break;

        default:
            break;
    }
    return false;
}

}
