namespace Fabric.Desktop.Launcher {
	/**
	 * State for this launcher.
	 *
	 * Logic that shouldn't exist within widgets and UI elements.
	 */
	class LauncherState : Object {
		public signal void refreshed();

		private static GLib.Once<LauncherState> _instance;
		public static unowned LauncherState instance {
			get { return _instance.once(() => { return new LauncherState(); }); }
		}

		public Gee.ArrayList<ApplicationData> applications {
			get; default = new Gee.ArrayList<ApplicationData>();
		}

		public Gee.Set<string> favorites {
			get; default = new Gee.HashSet<string>();
		}

		private LauncherState() {
			load_userdata();
			refresh_applications();
		}

		public void refresh_applications() {
			applications.clear();
			foreach (var appinfo in AppInfo.get_all()) {
				if (appinfo.should_show()) {
					var appdata = new ApplicationData.from_appinfo(appinfo);
					appdata.favorite = favorites.contains(appdata.id);
					applications.add(appdata);
					appdata.notify["favorite"].connect(() => {
						if (appdata.favorite) {
							favorites.add(appdata.id);
						}
						else {
							favorites.remove(appdata.id);
						}
						save_userdata();
						sort_applications();
						refreshed();
					});
				}
			}
			sort_applications();
			refreshed();
		}

		public void sort_applications() {
			applications.sort(ApplicationData.cmp);
		}

		public void load_userdata() {
			favorites.clear();

			FileStream stream = FileStream.open(get_favorites_path(), "r");
			if (stream != null) {
				string? line = null;
				while ((line = stream.read_line()) != null) {
					favorites.add(line.strip());
				}
			}
		}

		public void save_userdata() {
			DirUtils.create_with_parents(Path.get_dirname(get_favorites_path()), 0700);
			FileStream stream = FileStream.open(get_favorites_path(), "w");
			if (stream != null) {
				foreach (var app in favorites) {
					stream.puts(app);
					stream.putc('\n');
				}
			}
			else {
				error("Could not open favorites.list for writing");
			}
		}

		public string get_favorites_path() {
			return Path.build_filename(
				Fabric.UI.Application.get_config_dir()
				, "favorites.list"
			);
		}
	}
}
