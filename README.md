automirror(1) -- Automatic Display Mirror
=============================================

## SYNOPSIS

`automirror`

## DESCRIPTION

automirror automatically configures the attached monitors in a mirror configuration.

automirror has no options as it determines the required operation from the connected and active monitors.

automirror uses RandR scaling to mirror the primary display to the other displays while driving the other displays at their native resolution.

I wrote automirror because my Laptop has a native resolution of 1600x900 which is not supported by any computer screen or projector.
When I connect a Full HD projector via HDMI and mirror the screen with the Gnome/Unity/XFCE Display Properties then the highes *compatible* configuration
happens to be 1024x768 which is really not helpful.

In this case automirror will simply configure the HDMI device with 1920x1080 and scale the 1600x900 laptop display. As a result I stay with the full resolution
on my laptop display and it also looks nice on the projector.

Another case is where I work with a 1920x1200 computer monitor and add the 1920x1080 projector as a second display. Again the *common* resolution offered by both
devices is 1024x768. automirror will recognize my 1920x1200 display as primary display and scale it to 1920x1080 on the secondary display, which is not really noticeable.

It is recommended to configure a hot key to run automirror so that one can run it even if the display configuration is heavily mwessed up.
In rare cases it might be neccessary to run automirror more than once so that xrandr will configure the displays correctly.

## SCENARIOS

  * **Single Monitor**:
    A single monitor will be configured to its optimum resolution without scaling

  * **Several Monitors**:
    If several monitors are active, then automirror will first determine the **primary display**
    which is either the builtin laptop monitor (`LVDS1`) or the monitor with the most lines.
    
    Then automirror configures all displays at their native resolution. The other displays are
    configured to mirror the primary display with **scaling**  so that the primary display fills
    the entire screen. The scaling does not care about aspect ratios!
    
## DEVELOPMENT

Please add test cases under `testdata` for everything you want to have covered.

To build automirror simply run `make deb`, otherwise you can simply run `automirror.sh` from the source distribution.
Build Requirements are debuild(1) and [ronn](http://rtomayko.github.io/ronn/).
 
