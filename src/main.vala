namespace Fabric.Desktop.Launcher {
	class LauncherApp : Gtk.Button {
		private ApplicationData app;
		private Gtk.Box layout;
		private Gtk.Image image;
		private Gtk.Image star;
		private Gtk.Label label;

		public LauncherApp(ApplicationData app) {
			this.app = app;

			add_css_class("launcher-app");

			layout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			layout.hexpand = true;
			child = layout;

			image = new Gtk.Image.from_icon_name(app.info.get_icon().to_string());
			image.add_css_class("icon");
			image.icon_size = 128;
			layout.append(image);

			label = new Gtk.Label(app.name);
			layout.append(label);
			label.hexpand = true;
			label.halign = Gtk.Align.START;

			star = new Gtk.Image.from_icon_name("emblem-favorite");
			star.add_css_class("favorite");
			star.icon_size = 128;
			layout.append(star);

			if (!app.favorite) {
				star.hide();
			}

			bool long_pressed = false;

			clicked.connect(() => {
				if (!long_pressed) {
					app.launch();
				}
				long_pressed = false;
			});

			var long_press = new Gtk.GestureLongPress();
			long_press.pressed.connect(() => {
				long_pressed = true;
				app.toggle_favorite();
				LauncherState.instance.refresh_applications();
			});
			add_controller(long_press);
		}
	}

	class LauncherList : Gtk.Box {
		construct {
			orientation = Gtk.Orientation.VERTICAL;
			hexpand = true;
			vexpand = true;
			this.halign = Gtk.Align.FILL;
			this.valign = Gtk.Align.FILL;

			add_css_class("launcher-list");
		}

		public void refresh() {
			clear();
			LauncherState.instance.applications.foreach((app) => {
				append(new LauncherApp(app));
				return true;
			});
		}

		private void clear() {
			Gtk.Widget child;
			while ((child = get_first_child()) != null) {
				remove(child);
			}
		}

	}

	class LauncherLayout : Fabric.UI.ScrollingPage {
		private LauncherList list;

		construct {
			header.label = "Launcher";
			header.visible = false;
			list = new LauncherList();
			append(list);

			LauncherState.instance.refreshed.connect(() => {
				list.refresh();
			});
			LauncherState.instance.refresh_applications();
		}
	}

	class LauncherWindow : Fabric.UI.Window {
		construct {
			title = "Launcher";
			child = new LauncherLayout();
			hide_on_close = true;

			notify["is-active"].connect(() => {
				if (!is_active) {
					close();
				}
			});
		}

		public new void show() {
			base.show();
			maximize();
		}

		public void toggle_visibility() {
			if (visible) {
				close();
			}
			else {
				show();
			}
		}
	}

	class Application : Fabric.UI.Application {
		private static GLib.Once<Application> _instance;
		public static unowned Application instance {
			get { return _instance.once(() => { return new Application(); }); }
		}

		private LauncherWindow window;

		construct {
			application_id = "fabric.desktop.launcher";
		}

		protected override void activate() {
			add_styles_from_resource("/Fabric/Desktop/Launcher/launcher.css");
			window = new LauncherWindow() {
				application = this,
			};
#if DONT_SPAWN_PROCESSES
			window.show();
#endif
		}

		public void show() {
			window.show();
		}

		public void toggle_visibility() {
			window.toggle_visibility();
		}

		public override bool dbus_register(DBusConnection connection, string object_path) throws Error {
			base.dbus_register(connection, object_path);

			try {
				connection.register_object(
					"/%s".printf(application_id.replace(".", "/").replace("-", "_")),
					ApplicationService.instance
				);
			} catch (Error e) {
				error(e.message);
			}

			return true;
		}
	}

	public static int main(string[] args) {
		return Application.instance.run(args);
	}
}
