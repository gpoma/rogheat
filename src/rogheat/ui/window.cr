require "../../../lib/libui/src/libui/libui.cr"

class Window
  property title = "Rogheat"

  def initialize
    options = UI::InitOptions.new
    err = UI.init pointerof(options)
    if !ui_nil?(err)
      puts "Error initializing ui: #{err}"
      exit 1
    end

    on_closing = ->(w : UI::Window*, data : Void*) {
      UI.control_destroy ui_control(@@mainwin.not_nil!)
      UI.quit
      0
    }

    should_quit = ->(data : Void*) {
      UI.control_destroy ui_control(@@mainwin.not_nil!)
      1
    }

    open_clicked = ->(item : UI::MenuItem*, w : UI::Window*, data : Void*) {
      mainwin = @@mainwin
      filename = UI.open_file mainwin
      if ui_nil?(filename)
        UI.msg_box_error mainwin, "No file selected", "Don't be alarmed!"
      else
        UI.msg_box mainwin, "File selected", filename
        UI.free_text filename
      end
    }

    save_clicked = ->(item : UI::MenuItem*, w : UI::Window*, data : Void*) {
      mainwin = @@mainwin
      filename = UI.save_file mainwin
      if ui_nil?(filename)
        UI.msg_box_error mainwin, "No file selected", "Don't be alarmed!"
      else
        UI.msg_box mainwin, "File selected (don't worry, it's still there)", filename
        UI.free_text filename
      end
    }

    menu = UI.new_menu "File"
    item = UI.menu_append_item menu, "Open"
    UI.menu_item_on_clicked item, open_clicked, nil
    item = UI.menu_append_item menu, "Save"
    UI.menu_item_on_clicked item, save_clicked, nil
    item = UI.menu_append_quit_item menu
    UI.on_should_quit should_quit, nil

    @@mainwin = UI.new_window "#{@title}", 640, 480, 1
    mainwin = @@mainwin.not_nil!
    UI.window_set_margined mainwin, 1
    UI.window_on_closing mainwin, on_closing, nil

    UI.control_show ui_control(mainwin)

    UI.main
    UI.uninit
  end
end
