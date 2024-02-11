
--[[
-- Simple wrapper over gh_imgui lib for frame/window + begin/end functions.
--]]


_imgui_initialized = 0


IMGUI_WINDOW_BG_COLOR = 1
IMGUI_TITLE_BG_COLOR = 2
IMGUI_PLOTLINES_COLOR = 3
IMGUI_FRAME_BG_COLOR = 4
IMGUI_TITLE_BG_ACTIVE_COLOR = 5
IMGUI_TITLE_BG_COLLAPSED_COLOR = 6
IMGUI_PLOTHISTOGRAM_COLOR = 7
IMGUI_COMBO_BG_COLOR = 8
IMGUI_BUTTON_COLOR = 9
IMGUI_SEPARATOR_COLOR = 10
IMGUI_RESIZE_GRIP_COLOR = 11
IMGUI_PLOTLINE_HOVERED_COLOR = 12
IMGUI_PLOTHISTOGRAM_HOVERED_COLOR = 13
IMGUI_BUTTON_HOVERED_COLOR = 14
IMGUI_SEPARATOR_HOVERED_COLOR = 15
IMGUI_RESIZE_GRIP_HOVERED_COLOR = 16
IMGUI_HEADER_COLOR = 17
IMGUI_HEADER_HOVERED_COLOR = 18
IMGUI_SLIDER_GRAB_COLOR = 19
IMGUI_CHECK_MARK_COLOR = 20
IMGUI_SCROLLBAR_BG_COLOR = 21
IMGUI_SCROLLBAR_GRAB_COLOR = 22
IMGUI_SCROLLBAR_GRAB_HOVERED_COLOR = 23
IMGUI_TEXT_COLOR = 24
IMGUI_POPUP_BG_COLOR = 25
IMGUI_TEXT_DISABLED_COLOR = 26
IMGUI_CHILD_BG_COLOR = 27
IMGUI_BORDER_COLOR = 28
IMGUI_BORDER_SHADOW_COLOR = 29
IMGUI_FRAME_BG_HOVERED_COLOR = 30
IMGUI_FRAME_BG_ACTIVE_COLOR = 31
IMGUI_MENU_BAR_BG_COLOR = 32
IMGUI_SCROLLBAR_GRAB_ACTIVE_COLOR = 33
IMGUI_SLIDER_GRAB_ACTIVE_COLOR = 34
IMGUI_BUTTON_ACTIVE_COLOR = 35
IMGUI_HEADER_ACTIVE_COLOR = 36
IMGUI_SEPARATOR_ACTIVE_COLOR = 37
IMGUI_RESIZE_GRIP_ACTIVE_COLOR = 38
IMGUI_CLOSE_BUTTON_COLOR = 39
IMGUI_CLOSE_BUTTON_HOVERED_COLOR = 40 
IMGUI_CLOSE_BUTTON_ACTIVE_COLOR = 41
IMGUI_PLOTLINES_HOVERED_COLOR = 42
IMGUI_TEXT_SELECTED_BG_COLOR = 43
IMGUI_MODAL_WINDOW_DARKENING_COLOR = 44
IMGUI_DRAG_DROP_TARGET_COLOR = 45



IMGUI_WIDGET_SEPARATOR = 1
IMGUI_WIDGET_SAME_LINE = 2
IMGUI_WIDGET_BULLET = 3
IMGUI_WIDGET_VERTICAL_SPACING = 4


-- Window flags
ImGuiWindowFlags_NoTitleBar = 1 -- Disable title-bar
ImGuiWindowFlags_NoResize = 2 -- Disable user resizing with the lower-right grip
ImGuiWindowFlags_NoMove = 4 -- Disable user moving the window
ImGuiWindowFlags_NoScrollbar = 8 -- Disable scrollbars (window can still scroll with mouse or programatically)
ImGuiWindowFlags_NoScrollWithMouse = 16 -- Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.
ImGuiWindowFlags_NoCollapse = 32 -- Disable user collapsing window by double-clicking on it
ImGuiWindowFlags_AlwaysAutoResize = 64 -- Resize every window to its content every frame
ImGuiWindowFlags_NoSavedSettings = 256 -- Never load/save settings in .ini file
ImGuiWindowFlags_NoInputs = 512 -- Disable catching mouse or keyboard inputs, hovering test with pass through.
ImGuiWindowFlags_MenuBar = 1024 -- Has a menu-bar
ImGuiWindowFlags_HorizontalScrollbar = 2048 -- Allow horizontal scrollbar to appear (off by default). You may use SetNextWindowContentSize(ImVec2(width,0.0f)); prior to calling Begin() to specify width. Read code in imgui_demo in the "Horizontal Scrolling" section.
ImGuiWindowFlags_NoFocusOnAppearing = 4096  -- Disable taking focus when transitioning from hidden to visible state
ImGuiWindowFlags_NoBringToFrontOnFocus = 8192 -- Disable bringing window to front when taking focus (e.g. clicking on it or programatically giving it focus)
ImGuiWindowFlags_AlwaysVerticalScrollbar = 16384 -- Always show vertical scrollbar (even if ContentSize.y < Size.y)
ImGuiWindowFlags_AlwaysHorizontalScrollbar = 32768 -- Always show horizontal scrollbar (even if ContentSize.x < Size.x)
ImGuiWindowFlags_AlwaysUseWindowPadding = 65536 -- Ensure child windows without border uses style.WindowPadding (ignored by default for non-bordered child windows, because more convenient)
ImGuiWindowFlags_ResizeFromAnySide = 131072 -- // (WIP) Enable resize from any corners and borders. Your back-end needs to honor the different values of io.MouseCursor set by imgui.


-- Color edit flags
ImGuiColorEditFlags_NoAlpha = 2 -- ColorEdit, ColorPicker, ColorButton: ignore Alpha component (read 3 components from the input pointer).
ImGuiColorEditFlags_NoPicker = 4 -- ColorEdit: disable picker when clicking on colored square.
ImGuiColorEditFlags_NoOptions = 8 -- ColorEdit: disable toggling options menu when right-clicking on inputs/small preview.
ImGuiColorEditFlags_NoSmallPreview = 16-- ColorEdit, ColorPicker: disable colored square preview next to the inputs. (e.g. to show only the inputs)
ImGuiColorEditFlags_NoInputs = 32 -- ColorEdit, ColorPicker: disable inputs sliders/text widgets (e.g. to show only the small preview colored square).
ImGuiColorEditFlags_NoTooltip = 64 -- ColorEdit, ColorPicker, ColorButton: disable tooltip when hovering the preview.
ImGuiColorEditFlags_NoLabel = 128 -- ColorEdit, ColorPicker: disable display of inline text label (the label is still forwarded to the tooltip and picker).
ImGuiColorEditFlags_NoSidePreview = 256 -- ColorPicker: disable bigger color preview on right side of the picker, use small colored square preview instead.
-- User Options (right-click on widget to change some of them). You can set application defaults using SetColorEditOptions(). The idea is that you probably don't want to override them in most of your calls, let the user choose and/or call SetColorEditOptions() during startup.
ImGuiColorEditFlags_AlphaBar = 512 -- ColorEdit, ColorPicker: show vertical alpha bar/gradient in picker.
ImGuiColorEditFlags_AlphaPreview = 1024 -- ColorEdit, ColorPicker, ColorButton: display preview as a transparent color over a checkerboard, instead of opaque.
ImGuiColorEditFlags_AlphaPreviewHalf = 2048 -- ColorEdit, ColorPicker, ColorButton: display half opaque / half checkerboard, instead of opaque.
ImGuiColorEditFlags_HDR = 4096 --  (WIP) ColorEdit: Currently only disable 0.0f..1.0f limits in RGBA edition (note: you probably want to use ImGuiColorEditFlags_Float flag as well).
ImGuiColorEditFlags_RGB = 8192 -- [Inputs] ColorEdit: choose one among RGB/HSV/HEX. ColorPicker: choose any combination using RGB/HSV/HEX.
ImGuiColorEditFlags_HSV = 16384 -- [Inputs]     
ImGuiColorEditFlags_HEX = 32768 -- [Inputs] 
ImGuiColorEditFlags_Uint8 = 65536 -- [DataType]   // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0..255. 
ImGuiColorEditFlags_Float = 131072 --  [DataType]   // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0.0f..1.0f floats instead of 0..255 integers. No round-trip of value via integers.
ImGuiColorEditFlags_PickerHueBar = 262144 -- [PickerMode] // ColorPicker: bar for Hue, rectangle for Sat/Value.
ImGuiColorEditFlags_PickerHueWheel = 524288 -- [PickerMode] // ColorPicker: wheel for Hue, triangle for Sat/Value.



-- Tree node flags
ImGuiTreeNodeFlags_Selected = 1 -- Draw as selected
ImGuiTreeNodeFlags_Framed = 2 -- Full colored frame (e.g. for CollapsingHeader)
ImGuiTreeNodeFlags_AllowItemOverlap = 4  -- Hit testing to allow subsequent widgets to overlap this one
ImGuiTreeNodeFlags_NoTreePushOnOpen = 8 -- Don't do a TreePush() when open (e.g. for CollapsingHeader) = no extra indent nor pushing on ID stack
ImGuiTreeNodeFlags_NoAutoOpenOnLog = 16 -- Don't automatically and temporarily open node when Logging is active (by default logging will automatically open tree nodes)
ImGuiTreeNodeFlags_DefaultOpen = 32 -- Default node to be open
ImGuiTreeNodeFlags_OpenOnDoubleClick = 64 -- Need double-click to open node
ImGuiTreeNodeFlags_OpenOnArrow = 128 -- Only open when clicking on the arrow part. If ImGuiTreeNodeFlags_OpenOnDoubleClick is also set, single-click arrow or double-click all box to open.
ImGuiTreeNodeFlags_Leaf = 256 -- No collapsing, no arrow (use as a convenience for leaf nodes).
ImGuiTreeNodeFlags_Bullet = 512 -- Display a bullet instead of arrow
ImGuiTreeNodeFlags_FramePadding = 1024 -- Use FramePadding (even for an unframed text node) to vertically align text baseline to regular widget height. Equivalent to calling AlignTextToFramePadding().



-- Input text flags:
ImGuiInputTextFlags_CharsDecimal = 1 -- Allow 0123456789.+-
ImGuiInputTextFlags_CharsHexadecimal = 2 -- Allow 0123456789ABCDEFabcdef
ImGuiInputTextFlags_CharsUppercase = 4 -- Turn a..z into A..Z
ImGuiInputTextFlags_CharsNoBlank = 8 -- Filter out spaces, tabs
ImGuiInputTextFlags_AutoSelectAll = 16 -- Select entire text when first taking mouse focus
ImGuiInputTextFlags_EnterReturnsTrue = 32 -- Return 'true' when Enter is pressed (as opposed to when the value was modified)
ImGuiInputTextFlags_CallbackCompletion = 64 -- Call user function on pressing TAB (for completion handling)
ImGuiInputTextFlags_CallbackHistory = 128 --Call user function on pressing Up/Down arrows (for history handling)
ImGuiInputTextFlags_CallbackAlways = 256 --Call user function every time. User code may query cursor position, modify text buffer.
ImGuiInputTextFlags_CallbackCharFilter = 512 --Call user function to filter character. Modify data->EventChar to replace/filter input, or return 1 to discard character.
ImGuiInputTextFlags_AllowTabInput = 1024 -- Pressing TAB input a '\t' character into the text field
ImGuiInputTextFlags_CtrlEnterForNewLine = 2048 -- In multi-line mode, unfocus with Enter, add new line with Ctrl+Enter (default is opposite: unfocus with Ctrl+Enter, add line with Enter).
ImGuiInputTextFlags_NoHorizontalScroll = 4096 -- Disable following the cursor horizontally
ImGuiInputTextFlags_AlwaysInsertMode = 8192 -- Insert mode
ImGuiInputTextFlags_ReadOnly = 16384 -- Read-only mode
ImGuiInputTextFlags_Password = 32768 -- Password mode, display all characters as '*'
ImGuiInputTextFlags_NoUndoRedo = 65536 -- Disable undo/redo. Note that input text owns the text data while active, if you want to provide your own undo/redo stack you need e.g. to call ClearActiveID().




function imgui_frame_begin_v2(mouse_x, mouse_y)

  if (_imgui_initialized == 0) then
    gh_imgui.init()
    _imgui_initialized = 1
  end

  local win_w, win_h = gh_window.getsize(0)

  local LEFT_BUTTON = 1
  local mouse_left_button = gh_input.mouse_get_button_state(LEFT_BUTTON) 
  local RIGHT_BUTTON = 2
  local mouse_right_button = gh_input.mouse_get_button_state(RIGHT_BUTTON) 

  gh_imgui.frame_begin(win_w, win_h, mouse_x, mouse_y, mouse_left_button, mouse_right_button)
end  



function imgui_frame_begin()

  local mouse_x, mouse_y = gh_input.mouse_get_position()
  imgui_frame_begin_v2(mouse_x, mouse_y)

end  



function imgui_frame_end()

  gh_imgui.frame_end()

end


function imgui_window_begin_v1(label, width, height, posx, posy)

  -- Flags for window style, window position and window size.
  --
  local window_default = 0
  local window_no_resize = 2
  local window_no_move = 4
  local window_no_collapse = 32
  local window_show_border = 128
  local window_no_save_settings = 256
  local pos_size_flag_always = 1 -- Always set the pos and/or size
  local pos_size_flag_once = 2 -- Set the pos and/or size once per runtime session (only the first call with succeed)
  local pos_size_flag_first_use_ever = 4  -- Set the pos and/or size if the window has no saved data (if doesn't exist in the .ini file)
  local pos_size_flag_appearing = 8  -- Set the pos and/or size if the window is appearing after being hidden/inactive (or the first time)

  -- Beginning of the window with caption "Gear control"
  --  

  local window_flags = window_default

  local is_open = gh_imgui.window_begin(label, width, height, posx, posy, window_flags, pos_size_flag_first_use_ever, pos_size_flag_first_use_ever)
  return is_open
end



function imgui_window_end()

  gh_imgui.window_end()

end


function imgui_vertical_space()
  gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
end  

function imgui_separator()
  gh_imgui.widget(IMGUI_WIDGET_SEPARATOR)
end  

function imgui_same_line()
  gh_imgui.widget(IMGUI_WIDGET_SAME_LINE)
end  

function imgui_bullet()
  gh_imgui.widget(IMGUI_WIDGET_BULLET)
end  



